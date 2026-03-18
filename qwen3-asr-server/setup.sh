#!/bin/bash
# Qwen3-ASR-1.7B Server Setup for Mac Mini
# Run this script on the Mac Mini to set up the ASR server.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Qwen3-ASR-1.7B Server Setup ==="
echo ""

# Check Python
if ! command -v python3 &>/dev/null; then
    echo "Error: python3 not found. Install Python 3.10+ first."
    exit 1
fi

PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
echo "Python version: $PYTHON_VERSION"

# Create venv
VENV_DIR="$SCRIPT_DIR/.venv"
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"

# Install dependencies
echo "Installing dependencies..."
pip install --upgrade pip
pip install -r "$SCRIPT_DIR/requirements.txt"

echo ""
echo "=== Setup complete ==="
echo ""
echo "To start the server:"
echo "  cd $SCRIPT_DIR"
echo "  source .venv/bin/activate"
echo "  python server.py"
echo ""
echo "First run will download Qwen3-ASR-1.7B (~3.4GB)."
echo "The server listens on http://0.0.0.0:9876"
echo ""
echo "In OpenOats settings, set Remote ASR Server URL to:"
echo "  http://$(hostname).local:9876"
