#!/bin/bash
# Pre-normalize 4D Helper*.app CEF layout inside a product (.app / Volume Desktop / Server).
# Replaces CEF symlinks with APFS clonefile copies (distinct inodes — Apple notary OK).
# Never hardlink (cp -al) — shared inodes → notary Invalid (AutoTestExec v20).
# Usage: normalize_cef_helpers.sh /path/to/Product.app
set -euo pipefail

product_path="${1%/}"
if [ -z "${product_path}" ] || [ ! -d "$product_path" ]; then
  echo "❌ Usage: $0 /path/to/Product.app" >&2
  exit 1
fi

shopt -s nullglob
py_resolve='import os,sys; base=sys.argv[1]; tgt=sys.argv[2]; print(os.path.abspath(os.path.join(base, tgt)))'

FOUND=0
MUTATED=0

while IFS= read -r -d '' BUNDLE_ROOT; do
  FOUND=1
  echo "📦 Bundle: $BUNDLE_ROOT"

  SRC_CEF="${BUNDLE_ROOT}/Chromium Embedded Framework.framework"
  if [ ! -d "$SRC_CEF" ]; then
    echo "❌ CEF introuvable dans $BUNDLE_ROOT" >&2
    exit 1
  fi

  while IFS= read -r -d '' APP; do
    NAME="$(basename "$APP" .app)"
    EXE="$APP/Contents/MacOS/$NAME"
    DEST_CEF="$APP/Contents/Frameworks/Chromium Embedded Framework.framework"

    need_exe=0
    need_cef=0
    [ -L "$EXE" ] && need_exe=1
    if [ -L "$DEST_CEF" ] || [ ! -d "$DEST_CEF" ]; then
      need_cef=1
    fi
    if [ "$need_exe" -eq 0 ] && [ "$need_cef" -eq 0 ]; then
      echo "⏭️ Helper OK (déjà local): $APP"
      continue
    fi

    if [ "$need_exe" -eq 1 ]; then
      TGT="$(readlink "$EXE")"
      RESOLVED=$(python3 -c "$py_resolve" "$(dirname "$EXE")" "$TGT")
      if [ ! -f "$RESOLVED" ]; then
        echo "❌ Cible du symlink introuvable: $EXE -> $TGT" >&2
        exit 1
      fi
      echo "🪄 Remplace symlink exécutable: $EXE  (-> $TGT)"
      rm -f "$EXE"
      /usr/bin/ditto "$RESOLVED" "$EXE"
      chmod 755 "$EXE"
      MUTATED=$((MUTATED + 1))
    fi

    if [ "$need_cef" -eq 1 ]; then
      if [ -L "$DEST_CEF" ]; then
        echo "🪄 Supprime symlink CEF dans $APP"
        rm -f "$DEST_CEF"
      fi
      if [ ! -d "$DEST_CEF" ]; then
        mkdir -p "$(dirname "$DEST_CEF")"
        if cp -cR "$SRC_CEF" "$DEST_CEF" 2>/dev/null; then
          echo "📚 CEF clonefile → $DEST_CEF"
        else
          echo "📚 CEF ditto fallback → $DEST_CEF"
          /usr/bin/ditto "$SRC_CEF" "$DEST_CEF"
        fi
        SRC_BIN=$(find "$SRC_CEF" -type f -name "Chromium Embedded Framework" -print -quit 2>/dev/null || true)
        DST_BIN=$(find "$DEST_CEF" -type f -name "Chromium Embedded Framework" -print -quit 2>/dev/null || true)
        if [ -n "$SRC_BIN" ] && [ -n "$DST_BIN" ]; then
          SRC_INO=$(stat -f '%i' "$SRC_BIN" 2>/dev/null || true)
          DST_INO=$(stat -f '%i' "$DST_BIN" 2>/dev/null || true)
          if [ -n "$SRC_INO" ] && [ "$SRC_INO" = "$DST_INO" ]; then
            echo "❌ CEF hardlink détecté (inode=$SRC_INO) — notary Invalid; abort" >&2
            exit 1
          fi
        fi
        MUTATED=$((MUTATED + 1))
      fi
    fi
  done < <(find "$BUNDLE_ROOT" -type d -name "4D Helper*.app" -print0)

done < <(find "$product_path" -type d -path "*/WebViewerCEF.bundle/Contents/Frameworks" -print0)

if [ $FOUND -eq 0 ]; then
  echo "ℹ️ Aucun WebViewerCEF.bundle trouvé sous $product_path (OK si produit sans CEF)"
else
  echo "ℹ️ CEF prenorm: mutations=$MUTATED path=$product_path"
fi
