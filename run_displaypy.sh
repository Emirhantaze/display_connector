#!/usr/bin/env bash
set -euo pipefail

ENV_DIR="$HOME/moonraker-env"
PYTHON="$ENV_DIR/bin/python"

if [[ ! -x "$PYTHON" ]]; then
    echo "[error] Python not found at $PYTHON. Ensure the env exists (python -m venv ~/moonraker-env)." >&2
    exit 1
fi

# Temporarily disable unbound variable check when sourcing activate
set +u
if [[ -f "$ENV_DIR/bin/activate" ]]; then
    source "$ENV_DIR/bin/activate"
else
    echo "[error] Activate script not found at $ENV_DIR/bin/activate" >&2
    exit 1
fi
set -u

# Move to script directory (repo root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [[ ! -f display.py ]]; then
    echo "[error] display.py not found in $SCRIPT_DIR" >&2
    exit 1
fi

echo "[run] Launching display.py with $PYTHON"
exec "$PYTHON" display.py "$@"