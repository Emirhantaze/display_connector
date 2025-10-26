#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEMD_DIR="/etc/systemd/system"

install_unit() {
  local unit_name="$1"
  local src_unit="$REPO_DIR/systemd/$unit_name"
  local dst_unit="$SYSTEMD_DIR/$unit_name"
  if [[ ! -f "$src_unit" ]]; then
    echo "[error] Missing unit file: $src_unit" >&2
    exit 1
  fi
  echo "[install] Installing unit: $src_unit -> $dst_unit"
  sudo install -m 0644 "$src_unit" "$dst_unit"
}

main() {
  install_unit "moonraker-ws.service"
  install_unit "display.service"

  echo "[systemd] Reloading daemon"
  sudo systemctl daemon-reload

  echo "[systemd] Disabling makerbase-client.service (not removing)"
  sudo systemctl disable makerbase-client.service || true

  echo "[systemd] Enabling services"
  sudo systemctl enable moonraker-ws.service
  sudo systemctl enable display.service

  echo "[systemd] Starting moonraker-ws first"
  sudo systemctl restart moonraker-ws.service || sudo systemctl start moonraker-ws.service

  echo "[systemd] Starting display after moonraker-ws"
  sudo systemctl restart display.service || sudo systemctl start display.service

  echo "[done] Services installed and started"
  echo "- Status:"
  sudo systemctl --no-pager status moonraker-ws.service | sed -n '1,6p' || true
  sudo systemctl --no-pager status display.service | sed -n '1,6p' || true
}

main "$@"
