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
        Headers: X-Language (optional, e.g. "Korean")
        Response: {"text": "transcribed text"}

    GET /health
        Response: {"status": "ok", "model": "Qwen/Qwen3-ASR-1.7B"}
"""

import argparse
import io
import tempfile
import os
import numpy as np
import soundfile as sf
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import uvicorn

app = FastAPI(title="Qwen3-ASR Server")

# Global model reference
asr_model = None
MODEL_ID = "Qwen/Qwen3-ASR-1.7B"

# Language code to full name mapping for Qwen3-ASR
LANG_MAP = {
    "ko": "Korean", "en": "English", "ja": "Japanese", "zh": "Chinese",
    "es": "Spanish", "fr": "French", "de": "German", "pt": "Portuguese",
    "ru": "Russian", "ar": "Arabic", "hi": "Hindi", "vi": "Vietnamese",
    "th": "Thai", "id": "Indonesian", "tr": "Turkish", "it": "Italian",
}


def load_model():
    """Load Qwen3-ASR-1.7B model."""
    global asr_model
    import torch
    from qwen_asr import Qwen3ASRModel

    print(f"Loading {MODEL_ID}...")

    # Use MPS on Apple Silicon, CUDA if available, else CPU
    if torch.backends.mps.is_available():
        device = "mps"
    elif torch.cuda.is_available():
        device = "cuda:0"
    else:
        device = "cpu"

    dtype = torch.float16 if device != "cpu" else torch.float32

    asr_model = Qwen3ASRModel.from_pretrained(
        MODEL_ID,
        dtype=dtype,
        device_map=device,
        max_new_tokens=512,
    )
    print(f"Model loaded on {device}")


@app.get("/health")
async def health():
    return {"status": "ok", "model": MODEL_ID}


@app.post("/v1/transcribe")
async def transcribe(request: Request):
    language = request.headers.get("X-Language", None)
    body = await request.body()

    if not body:
        return JSONResponse({"text": "", "error": "Empty audio"}, status_code=400)

    # Decode raw float32 PCM
    num_samples = len(body) // 4
    samples = np.frombuffer(body, dtype=np.float32, count=num_samples)

    if len(samples) == 0:
        return JSONResponse({"text": ""})

    # Write to temp WAV file for qwen-asr
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
        sf.write(tmp.name, samples, 16000, format="WAV", subtype="FLOAT")
        tmp_path = tmp.name

    try:
        # Map short language codes to full names
        lang_name = LANG_MAP.get(language, language) if language else None

        results = asr_model.transcribe(
            audio=tmp_path,
            language=lang_name,
        )
        text = results[0].text if results else ""
    finally:
        os.unlink(tmp_path)

    return {"text": text.strip()}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Qwen3-ASR-1.7B Server")
    parser.add_argument("--host", default="0.0.0.0", help="Bind host")
    parser.add_argument("--port", type=int, default=9876, help="Bind port")
    args = parser.parse_args()

    load_model()
    uvicorn.run(app, host=args.host, port=args.port)
