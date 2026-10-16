#!/bin/bash
# Fails if the directory about to be published contains anything that looks like a secret.
# Never prints a matched value: only file names and line numbers.
# usage: secret-guard.sh <dir>
dir="${1:?dir}"
fail=0

# 1. forbidden file / folder names
while IFS= read -r f; do
  echo "::error::forbidden file: ${f#"$dir"/}"; fail=1
done < <(find "$dir" \( -name .git -prune \) -o \( \
    -name key -o -name 'key.*' -o -name '*.pem' -o -name '*.p12' -o -name '*.pfx' -o -name '*.p8' \
    -o -name '.env' -o -name '.env.*' -o -name '*.env' -o -name 'id_rsa*' -o -name '*.keystore' \
    -o -name '.github' -o -name 'tools_maj.sh' \) -print)

# 2. suspicious content (text files only; -I skips binaries)
check() { # <label> <extended regex> [subfolders of <dir> to scan; default: everything]
  local hits label="$1" re="$2" scan=() d
  shift 2
  for d in "$@"; do [ -e "$dir/$d" ] && scan+=("$dir/$d"); done
  [ "$#" -eq 0 ] && scan=("$dir")
  [ "${#scan[@]}" -eq 0 ] && return 0
  hits=$(grep -rIn -E --exclude-dir=.git -e "$re" "${scan[@]}" 2>/dev/null | cut -d: -f1,2 | sed "s|^$dir/||")
  if [ -n "$hits" ]; then
    while IFS= read -r h; do echo "::error::$label at $h"; done <<< "$hits"
    fail=1
  fi
}
check "download token in URL"            'token=[A-Za-z0-9_-]{16,}'
check "encrypted key / pass phrase"      'Decrypt data BLOB|/RESOURCES/key|BASE64 DECODE:C896\("[A-Za-z0-9+/=]{16,}"' 4DBuilder Build_Application
check "private key block"                'BEGIN ([A-Z]+ )?PRIVATE KEY'
check "GitHub token"                     'gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}'
check "AWS key"                          'AKIA[0-9A-Z]{16}'
check "Apple signing identity"           'Developer ?ID ?Application: ?[A-Za-z .]+ ?\([A-Z0-9]{10}\)'
check "personal home path"               '/Users/[A-Za-z0-9._-]+/' 4DBuilder Build_Application/Project Build_Application/ProjectDemo

if [ "$fail" -ne 0 ]; then
  echo "secret-guard: FAILED, nothing will be published" >&2
  exit 1
fi
echo "secret-guard: OK"
