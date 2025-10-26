#!/usr/bin/env bash
set -euo pipefail

echo "[systemd] Disabling our services"
sudo systemctl disable display.service || true
sudo systemctl disable moonraker-ws.service || true

echo "[systemd] Stopping our services if running"
sudo systemctl stop display.service || true
sudo systemctl stop moonraker-ws.service || true

echo "[systemd] Reloading daemon"
sudo systemctl daemon-reload

echo "[systemd] Re-enabling makerbase-client.service"
sudo systemctl enable makerbase-client.service || true

echo "[systemd] Starting makerbase-client.service"
sudo systemctl restart makerbase-client.service || sudo systemctl start makerbase-client.service || true

echo "[done] Reverted to makerbase-client.service"
echo "- Status:"
sudo systemctl --no-pager status makerbase-client.service | sed -n '1,6p' || true
