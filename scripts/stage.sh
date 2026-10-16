#!/bin/bash
# Builds the content to publish for one branch.
# usage: stage.sh <tools checkout> <out dir> <mode>
#   mode "tool4d"  : only tool4d_win / tool4d_mac / tool4d_linux
#   mode "builder" : 4DBuilder + Build_Application (secrets removed, downloads patched)
set -euo pipefail
src="${1:?tools checkout}"; out="${2:?out dir}"; mode="${3:?mode}"
here="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p "$out"

if [ "$mode" = "tool4d" ]; then
  rm -rf "$out"/tool4d_win "$out"/tool4d_mac "$out"/tool4d_linux
  for d in tool4d_win tool4d_mac tool4d_linux; do
    [ -d "$src/$d" ] || { echo "::error::$d missing in Tools branch"; exit 1; }
    cp -a "$src/$d" "$out/$d"
  done
fi

if [ "$mode" = "builder" ]; then
  rm -rf "$out/4DBuilder" "$out/Build_Application"
  cp -a "$src/4DBuilder" "$out/4DBuilder"
  cp -a "$src/Build_Application" "$out/Build_Application"
  # not published: private CI of the demo project, encrypted download key
  rm -rf "$out/Build_Application/ProjectDemo/.github" "$out/Build_Application/Resources/key"
  find "$out" -name '.DS_Store' -delete
  # personal home paths left in comments
  grep -rIlE '^[[:space:]]*//.*/Users/[A-Za-z0-9._-]+/' "$out/4DBuilder" "$out/Build_Application/Project" 2>/dev/null | while IFS= read -r f; do
    sed -i.bak -E '/^[[:space:]]*\/\/.*\/Users\/[A-Za-z0-9._-]+\//d' "$f" && rm -f "$f.bak"
  done
  # Apple signing identity ("Developer ID Application: NAME (TEAMID)") in default settings / demo json
  grep -rIlE 'Developer ?ID ?Application: ?[A-Za-z .]+ ?\([A-Z0-9]{10}\)' "$out" 2>/dev/null | while IFS= read -r f; do
    sed -i.bak -E 's/Developer ?ID ?Application: ?[A-Za-z .]+ ?\([A-Z0-9]{10}\)/Developer ID Application: YOUR NAME (TEAMID)/g' "$f" && rm -f "$f.bak"
  done
  python3 -I "$here/scripts/patch_methods.py" "$out/Build_Application" "$here/templates"
fi
