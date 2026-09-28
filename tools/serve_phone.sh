#!/usr/bin/env bash
# Serve the web build on the Wi-Fi so the iPhone can play it before itch.io:
#   tools/serve_phone.sh      (phone on the same Wi-Fi; Ctrl+C stops it)
set -euo pipefail
cd "$(dirname "$0")/../build/web"
PORT=8060
IP=$(ipconfig getifaddr en0 || ipconfig getifaddr en1 || echo "localhost")
echo "On the iPhone, open:  http://$IP:$PORT"
python3 -m http.server "$PORT" --bind 0.0.0.0
