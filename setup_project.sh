#!/usr/bin/env bash
set -e

echo "📚 Setup documentation (Sphinx)..."

VENV_DIR=".venv"
URL="http://127.0.0.1:8000"

# Check python
if ! command -v python3 &> /dev/null; then
    echo "❌ python3 not found. Please install Python."
    exit 1
fi

# Create venv if not exists
if [ ! -d "$VENV_DIR" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
else
    echo "📦 Virtual environment already exists."
fi

# Activate venv
echo "🚀 Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Update pip
echo "⬆️ Updating pip..."
pip install --upgrade pip

# Install dependencies
if [ -f "requirements.txt" ]; then
    echo "📚 Installing dependencies..."
    pip install -r requirements.txt
else
    echo "❌ requirements.txt not found. Please clone the project again."
    exit 1
fi

# Open browser after short delay
echo "🌐 Opening documentation in browser..."
( sleep 2 && xdg-open "$URL" >/dev/null 2>&1 ) &

# Run autobuild
echo "🔁 Running sphinx-autobuild..."
sphinx-autobuild ./ ./build/