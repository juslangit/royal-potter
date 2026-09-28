#!/usr/bin/env bash
# One command from project to itch.io upload:
#   tools/build_web.sh
# Exports the Web build to build/web/ and zips it to build/royal-potter-web.zip,
# with index.html at the top of the zip — the way itch.io requires.
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
rm -rf build/web build/royal-potter-web.zip
mkdir -p build/web
"$GODOT" --headless --path . --import >/dev/null 2>&1 || true
"$GODOT" --headless --path . --export-release "Web" build/web/index.html >/dev/null 2>&1
(cd build/web && zip -qr ../royal-potter-web.zip .)
echo "Zip: build/royal-potter-web.zip ($(du -h build/royal-potter-web.zip | cut -f1))  <- upload this to itch.io"
