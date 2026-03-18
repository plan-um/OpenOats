#!/usr/bin/env python3
"""
Qwen3-ASR-1.7B Server for OpenOats
Serves speech-to-text transcription via HTTP API.

Usage:
    pip install -r requirements.txt
    python server.py [--host 0.0.0.0] [--port 9876]

API:
    POST /v1/transcribe
        Body: raw float32 PCM audio at 16kHz mono
        Headers: X-Language (optional, e.g. "ko")
        Response: {"text": "transcribed text"}

    GET /health
        Response: {"status": "ok", "model": "Qwen/Qwen3-ASR-1.7B"}
"""

import argparse
import io
import struct
import sys
import numpy as np
from fastapi import FastAPI, Request, Response
from fastapi.responses import JSONResponse
import uvicorn

app = FastAPI(title="Qwen3-ASR Server")

# Global model references
processor = None
model = None
device = None
MODEL_ID = "Qwen/Qwen3-ASR-1.7B"


def load_model():
    """Load Qwen3-ASR-1.7B model and processor."""
    global processor, model, device
    import torch
    from transformers import AutoProcessor, Qwen3AudioForConditionalGeneration

    print(f"Loading {MODEL_ID}...")

    # Use MPS on Apple Silicon, CPU otherwise
    if torch.backends.mps.is_available():
        device = "mps"
    elif torch.cuda.is_available():
        device = "cuda"
    else:
        device = "cpu"

    processor = AutoProcessor.from_pretrained(MODEL_ID, trust_remote_code=True)
    model = Qwen3AudioForConditionalGeneration.from_pretrained(
        MODEL_ID,
        torch_dtype=torch.float16 if device != "cpu" else torch.float32,
        device_map=device,
        trust_remote_code=True,
    )
    model.eval()
    print(f"Model loaded on {device}")


@app.get("/health")
async def health():
    return {"status": "ok", "model": MODEL_ID, "device": str(device)}


@app.post("/v1/transcribe")
async def transcribe(request: Request):
    import torch
    import soundfile as sf

    language = request.headers.get("X-Language", None)
    body = await request.body()

    if not body:
        return JSONResponse({"text": "", "error": "Empty audio"}, status_code=400)

    # Decode raw float32 PCM
    num_samples = len(body) // 4
    samples = np.frombuffer(body, dtype=np.float32, count=num_samples)

    if len(samples) == 0:
        return JSONResponse({"text": ""})

    # Write to WAV buffer for processor
    wav_buffer = io.BytesIO()
    sf.write(wav_buffer, samples, 16000, format="WAV", subtype="FLOAT")
    wav_buffer.seek(0)

    # Build conversation for Qwen3-Audio
    lang_tag = f"<|{language}|>" if language else ""
    conversation = [
        {
            "role": "user",
            "content": [
                {"type": "audio", "audio": wav_buffer},
                {"type": "text", "text": f"{lang_tag}Transcribe the audio."},
            ],
        }
    ]

    text_prompt = processor.apply_chat_template(
        conversation, add_generation_prompt=True, tokenize=False
    )

    audios, _ = processor.extract_audio(conversation)

    inputs = processor(
        text=text_prompt,
        audios=audios,
        return_tensors="pt",
        padding=True,
    )
    inputs = {k: v.to(model.device) for k, v in inputs.items()}

    with torch.no_grad():
        generated_ids = model.generate(**inputs, max_new_tokens=512)

    # Strip prompt tokens
    generated_ids_trimmed = [
        out_ids[len(in_ids):]
        for in_ids, out_ids in zip(inputs["input_ids"], generated_ids)
    ]

    text = processor.batch_decode(
        generated_ids_trimmed,
        skip_special_tokens=True,
        clean_up_tokenization_spaces=False,
    )[0]

    return {"text": text.strip()}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Qwen3-ASR-1.7B Server")
    parser.add_argument("--host", default="0.0.0.0", help="Bind host")
    parser.add_argument("--port", type=int, default=9876, help="Bind port")
    args = parser.parse_args()

    load_model()
    uvicorn.run(app, host=args.host, port=args.port)
