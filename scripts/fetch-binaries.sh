#!/bin/bash
# Downloads 4D Server, 4D Volume Desktop and 4D (components, PackageManager) for one version
# from product-download.4d.com (needs the API key) and publishes them as a GitHub Release
# named <branch>-<build>, assets <os>_<zip> (e.g. win_4D_Server.zip), os = win, mac.
# Older releases of the same branch are deleted. Idempotent: nothing happens if the release exists.
# usage: fetch-binaries.sh <branch>
# env: PRODUCT_DOWNLOAD_TOKEN  4D API key (secret, never printed or written outside a 0600 curl config)
#      GH_TOKEN                token allowed to create releases in this repository
set -euo pipefail
branch="${1:?branch}"
: "${PRODUCT_DOWNLOAD_TOKEN:?}" "${GH_TOKEN:?}" "${GITHUB_REPOSITORY:?}"
B=https://product-download.4d.com/release
PUB=https://resources-download.4d.com/release

# version of the tool4d published in this repository's branch (written by sync-branch.sh)
vfile="$(gh api "repos/$GITHUB_REPOSITORY/contents/VERSION?ref=$branch" --jq .content | base64 -d)"
build="$(sed -n 's/^build=//p' <<< "$vfile" | head -1)"
[ -n "$build" ] || { echo "::error::no VERSION file on branch $branch (run Sync tool4d first)"; exit 1; }
tag="$branch-$build"

if gh release view "$tag" --repo "$GITHUB_REPOSITORY" >/dev/null 2>&1; then
  echo "$tag: release already exists"; exit 0
fi

# folder names used by product-download: "21.x/21.2" (LTS, minor discovered) or "21%20Rx/21%20R4"
if [[ "$branch" =~ ^([0-9]+)R([0-9]+)$ ]]; then
  version="${BASH_REMATCH[1]}%20Rx"; folder="${BASH_REMATCH[1]}%20R${BASH_REMATCH[2]}"
elif [[ "$branch" =~ ^([0-9]+)$ ]]; then
  version="${BASH_REMATCH[1]}.x"; folder=""
  for k in $(seq 0 9); do
    code="$(curl -s -o /dev/null -w '%{http_code}' -I -m 30 "$PUB/$version/${BASH_REMATCH[1]}.$k/$build/win/tool4d_win.tar.xz")"
    [ "$code" = 302 ] && folder="${BASH_REMATCH[1]}.$k" && break
  done
  [ -n "$folder" ] || { echo "::error::cannot find LTS minor for $branch build $build"; exit 1; }
else
  echo "::error::unsupported branch name $branch"; exit 1
fi

dir="$(mktemp -d)"; trap 'rm -rf "$dir"' EXIT
cfg="$dir/curl.cfg"; : > "$cfg"; chmod 600 "$cfg"
files=()
for os in win mac; do
  for zip in "4D%20Server.zip" "4D%20Volume%20Desktop.zip" "4D.zip"; do
    asset="${os}_${zip//%20/_}"
    printf 'url = "%s/%s/%s/%s/%s/%s?token=%s"\n' "$B" "$version" "$folder" "$build" "$os" "$zip" "$PRODUCT_DOWNLOAD_TOKEN" > "$cfg"
    echo "downloading $asset"
    curl -fsSL --retry 3 --retry-delay 10 -K "$cfg" -o "$dir/$asset"
    unzip -tq "$dir/$asset" >/dev/null || { echo "::error::$asset is not a valid zip"; exit 1; }
    files+=("$dir/$asset")
  done
done
: > "$cfg"

gh release create "$tag" "${files[@]}" --repo "$GITHUB_REPOSITORY" --latest=false \
  --title "4D $branch build $build" \
  --notes "4D Server, 4D Volume Desktop and 4D (components, PackageManager) for $branch build $build. Used by Build_Application through TOOL4D_DOWNLOAD_BASE."

gh release list --repo "$GITHUB_REPOSITORY" --limit 200 --json tagName --jq '.[].tagName' \
  | grep -E "^${branch}-[0-9]+$" | grep -vx "$tag" \
  | xargs -r -n1 gh release delete --repo "$GITHUB_REPOSITORY" --cleanup-tag -y || true
echo "$tag: published"
