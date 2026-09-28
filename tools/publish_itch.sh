#!/usr/bin/env bash
# Build and upload to https://juslangit.itch.io/kiln-keep (channel html5):
#   tools/publish_itch.sh "0.3-models"
# Needs BUTLER_API_KEY in ~/.claude/.env and butler in ~/Documents/dev/tools/butler.
set -euo pipefail
cd "$(dirname "$0")/.."
VERSION="${1:-$(date +%Y%m%d-%H%M)}"
tools/build_web.sh
set -a; source "$HOME/.claude/.env"; set +a
"$HOME/Documents/dev/tools/butler/butler" push build/web juslangit/kiln-keep:html5 --userversion "$VERSION"
