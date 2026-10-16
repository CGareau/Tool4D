#!/bin/bash
# Prints (and exports as step output "branches") the JSON list of 4D versions to publish:
# the highest public LTS N and every public R of N (and of the next cycles, if already public),
# limited to the versions whose branch exists in the Tools repository.
# "public" = resources-download.4d.com answers 302 for that version without any credential.
# usage: resolve-versions.sh   (env: TOOLS_URL)
set -euo pipefail
B=https://resources-download.4d.com/release

public() { [ "$(curl -s -o /dev/null -w '%{http_code}' -I -m 30 --retry 2 "$B/$1/win/tool4d_win.tar.xz")" = 302 ]; }

lts=""
for n in $(seq 40 -1 20); do
  if public "$n.x/latest/latest"; then lts="$n"; break; fi
done
[ -n "$lts" ] || { echo "::error::no public LTS found (resources-download unreachable?)" >&2; exit 1; }

gitlog="$(mktemp)"
tools_branches="$(git ls-remote --heads "$TOOLS_URL" 2>"$gitlog" | sed 's|.*refs/heads/||')" || true
if [ -z "$tools_branches" ]; then
  sed -E 's|(https://[^:]*:)[^@]*@|\1***@|g' "$gitlog" | sed 's/^/git: /' >&2
  echo "::error::cannot read 4eDimension/Tools: secret TOOLS_READ_TOKEN is missing, expired, has the wrong resource owner (must be 4eDimension) or its SSO access is not authorized" >&2
  tok="$(sed -E 's|^https://[^:]*:([^@]*)@.*|\1|' <<< "$TOOLS_URL")"
  echo "diagnostic: token length ${#tok} (0 = secret empty / not a repository secret)" >&2
  if [ -n "$tok" ]; then
    hdr="$(mktemp)"
    code="$(curl -s -D "$hdr" -o /dev/stdout -w '\n%{http_code}' -H "Authorization: Bearer $tok" https://api.github.com/repos/4eDimension/Tools | tail -1)"
    echo "diagnostic: GET /repos/4eDimension/Tools -> HTTP $code" >&2
    grep -iE '^(x-github-sso|x-accepted-github-permissions|github-authentication-token-expiration):' "$hdr" | sed -E 's/(url=)[^ ,;]+/\1.../' >&2 || true
    code3="$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $tok" "https://api.github.com/repos/4eDimension/Tools/branches?per_page=1")"
    echo "diagnostic: GET /repos/4eDimension/Tools/branches -> HTTP $code3 (200 needs the Contents: Read permission)" >&2
    code2="$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $tok" https://api.github.com/user)"
    echo "diagnostic: GET /user -> HTTP $code2 (401 = token invalid or expired)" >&2
  fi
  exit 1
fi
has() { grep -qx "$1" <<< "$tools_branches"; }

found=()
has "$lts" && found+=("$lts") || echo "::warning::Tools has no branch $lts" >&2
for n in $(seq "$lts" $((lts + 3))); do
  for k in $(seq 1 15); do
    if public "$n%20Rx/$n%20R$k/latest" && has "${n}R$k"; then found+=("${n}R$k"); fi
  done
done

[ "${#found[@]}" -gt 0 ] || { echo "::error::nothing to publish" >&2; exit 1; }
json="$(printf '%s\n' "${found[@]}" | jq -R . | jq -sc .)"
echo "$json"
[ -n "${GITHUB_OUTPUT:-}" ] && echo "branches=$json" >> "$GITHUB_OUTPUT"
exit 0
