#!/bin/bash
# Run outside the Codex sandbox. Each model gets a clean Blender process.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
BLENDER_BIN="${BLENDER_BIN:-/Applications/Blender.app/Contents/MacOS/Blender}"
if [[ ! -x "$BLENDER_BIN" ]]; then
    printf 'Blender executable not found: %s\n' "$BLENDER_BIN" >&2
    exit 1
fi
cd -- "$PROJECT_ROOT"
for name in wheel courtyard castle_base visitor dragon kiln_door; do
    printf 'Building %s.glb\n' "$name"
    "$BLENDER_BIN" --background --factory-startup --python-exit-code 1 \
        --python "$SCRIPT_DIR/$name.py"
done
printf 'Built all six models. Verified counts and object names: art/models/README.md\n'
