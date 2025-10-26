#!/usr/bin/env bash
set -euo pipefail

# Build standalone binaries with PyInstaller for:
# - NEXUS.py
# - display.py
# - moonraker-ws.py
#
# Prerequisite: Python virtual environment at ~/moonraker-env
# This script activates that environment and uses its Python/PyInstaller.

ENV_DIR="$HOME/moonraker-env"
PYTHON="$ENV_DIR/bin/python"
PIP="$ENV_DIR/bin/pip"
PYI="$ENV_DIR/bin/pyinstaller"

if [[ ! -x "$PYTHON" ]]; then
  echo "[error] Python not found at $PYTHON. Ensure the env exists (python -m venv ~/moonraker-env)." >&2
  exit 1
fi

if [[ ! -x "$PIP" ]]; then
  echo "[error] pip not found in $ENV_DIR. The env may be broken." >&2
  exit 1
fi

# Activate environment so PATH picks tools from it
source "$ENV_DIR/bin/activate"

# Ensure PyInstaller is available
if ! command -v pyinstaller >/dev/null 2>&1; then
  echo "[info] Installing PyInstaller in $ENV_DIR..."
  "$PIP" install --upgrade pip
  "$PIP" install pyinstaller
fi

# Optionally ensure runtime deps are available for analysis hooks
if [[ -f requirements.txt ]]; then
  echo "[info] Installing requirements (for build analysis)..."
  "$PIP" install -r requirements.txt || true
fi

# Move to repo root (script location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Clean previous artifacts
rm -rf build dist
mkdir -p dist

echo "[build] Building NEXUS.py → dist/nexus"
pyinstaller --onefile --name nexus NEXUS.py

echo "[build] Building display.py → dist/display"
pyinstaller --onefile --name display display.py

echo "[build] Building moonraker-ws.py → dist/moonraker-ws"
pyinstaller --onefile --name moonraker-ws moonraker-ws.py

echo "[done] Artifacts available in $(pwd)/dist"


