#!/bin/bash
# Downloads 4D Server, 4D Volume Desktop and 4D (mono) for one version from the
# PS FTP runtimes/ contract (factory output) and publishes them as GitHub Release
# assets — the factory tar.xz files themselves (NOT re-zipped).
#
# Re-zipping a Mac .app on Linux blows past GitHub's 2 GiB release-asset limit
# (xz ≈ 230 MB → zip often > 2 GB). Consumers extract with tar -xJf
# (see templates/Methods/extractRuntimeArchive.4dm).
#
# Release tag: <branch>-<build>  assets: <os>_4D_Server.tar.xz etc.
# Idempotent: skips when the release already exists (checked BEFORE download).
# Publishes only when win AND mac share the same build (VERSION build preferred).
#
# usage: fetch-binaries.sh <branch>
# env:
#   FTP_PRIVATE_PATH / FTP_PRIVATE_LOGIN / FTP_PRIVATE_PASSWORD
#   FTP_PRIVATE_SSL=1 (default) → --ftp-ssl-reqd
#   GH_TOKEN  token allowed to create releases in this repository
#   GITHUB_REPOSITORY  owner/repo
set -euo pipefail
branch="${1:?branch}"
: "${FTP_PRIVATE_PATH:?}" "${FTP_PRIVATE_LOGIN:?}" "${FTP_PRIVATE_PASSWORD:?}"
: "${GH_TOKEN:?}" "${GITHUB_REPOSITORY:?}"

# version of the tool4d published in this repository's branch (written by sync-branch.sh)
vfile="$(gh api "repos/$GITHUB_REPOSITORY/contents/VERSION?ref=$branch" --jq .content | base64 -d)"
want_build="$(sed -n 's/^build=//p' <<< "$vfile" | head -1)"
[ -n "$want_build" ] || { echo "::error::no VERSION file on branch $branch (run Sync tool4d first)"; exit 1; }

dir="$(mktemp -d)"; trap 'rm -rf "$dir"' EXIT

CURL_FTP=(curl -fsSL --ftp-pasv --retry 3 --retry-delay 5 --connect-timeout 30 --max-time 3600
  --user "${FTP_PRIVATE_LOGIN}:${FTP_PRIVATE_PASSWORD}")
if [[ "${FTP_PRIVATE_SSL:-1}" != "0" ]]; then
  CURL_FTP+=(--ftp-ssl-reqd)
fi

ftp_base="${FTP_PRIVATE_PATH%/}/runtimes/${branch}"
# GitHub Releases reject assets ≥ 2 GiB.
MAX_ASSET=$((2147483648 - 1))

ftp_try() {
  # usage: ftp_try URL OUT
  local url="$1" out="$2"
  if "${CURL_FTP[@]}" -o "$out" "$url"; then
    return 0
  fi
  rm -f "$out"
  return 1
}

# Echo build id for one OS, or empty. Prefers VERSION build, else latest-build.txt.
# Quiet on miss (caller decides whether that is skip vs error).
peek_build_for_os() {
  local os="$1"
  local exact="${ftp_base}/${os}/${want_build}/manifest.json"
  local latest_txt="${ftp_base}/${os}/latest-build.txt"
  local latest_manifest="${ftp_base}/${os}/latest/manifest.json"
  if ftp_try "$exact" "$dir/manifest-${os}.json"; then
    printf '%s' "$want_build"
    return 0
  fi
  if ftp_try "$latest_txt" "$dir/latest-build-${os}.txt"; then
    tr -d '[:space:]' < "$dir/latest-build-${os}.txt"
    return 0
  fi
  if ftp_try "$latest_manifest" "$dir/manifest-${os}.json"; then
    python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["build"])' "$dir/manifest-${os}.json"
    return 0
  fi
  return 1
}

build_win="$(peek_build_for_os win || true)"
build_mac="$(peek_build_for_os mac || true)"

if [ -z "$build_win" ] && [ -z "$build_mac" ]; then
  echo "$branch: nothing on FTP for win/mac — skipped"
  exit 0
fi

# Only publish a tag when both OSes share the same build (prefer VERSION).
release_build=""
if [ -n "$build_win" ] && [ -n "$build_mac" ] && [ "$build_win" = "$build_mac" ]; then
  release_build="$build_win"
elif [ "$build_win" = "$want_build" ] && [ "$build_mac" = "$want_build" ]; then
  release_build="$want_build"
else
  echo "$branch: FTP not aligned yet (VERSION=$want_build win=${build_win:-none} mac=${build_mac:-none}) — skipped (re-run factories, then Fetch)"
  exit 0
fi

echo "$branch: using build $release_build (win+mac)"

tag="$branch-$release_build"
if gh release view "$tag" --repo "$GITHUB_REPOSITORY" >/dev/null 2>&1; then
  # Complete = at least one win_*.tar.xz and one mac_*.tar.xz (old zip-only or
  # mac-only tags from a mismatched factory are rebuilt).
  assets_json="$(gh release view "$tag" --repo "$GITHUB_REPOSITORY" --json assets)"
  has_win=$(printf '%s' "$assets_json" | jq '[.assets[].name | select(startswith("win_") and endswith(".tar.xz"))] | length')
  has_mac=$(printf '%s' "$assets_json" | jq '[.assets[].name | select(startswith("mac_") and endswith(".tar.xz"))] | length')
  if [ "$has_win" -gt 0 ] && [ "$has_mac" -gt 0 ]; then
    echo "$tag: release already exists — skip download"
    exit 0
  fi
  echo "$tag: incomplete (win_tarxz=$has_win mac_tarxz=$has_mac) — deleting to republish from FTP"
  gh release delete "$tag" --repo "$GITHUB_REPOSITORY" --yes --cleanup-tag
fi

files=()
for os in win mac; do
  build_dir="${ftp_base}/${os}/${release_build}"
  declare -A map=(
    [4D_Server.tar.xz]="${os}_4D_Server.tar.xz"
    [4D_Volume_Desktop.tar.xz]="${os}_4D_Volume_Desktop.tar.xz"
    [4D_Mono.tar.xz]="${os}_4D.tar.xz"
  )
  for artifact in 4D_Server.tar.xz 4D_Volume_Desktop.tar.xz 4D_Mono.tar.xz; do
    asset="${map[$artifact]}"
    echo "downloading FTP runtimes/${branch}/${os}/${release_build}/$artifact → $asset"
    if ! ftp_try "${build_dir}/${artifact}" "$dir/$asset"; then
      if [ "$artifact" = "4D_Mono.tar.xz" ]; then
        echo "$artifact missing on FTP (factory often skips mono without packageManager) — no $asset"
        continue
      fi
      echo "::error::required $artifact missing under $build_dir"
      exit 1
    fi
    size=$(wc -c < "$dir/$asset" | tr -d ' ')
    if [ "$size" -gt "$MAX_ASSET" ]; then
      echo "::error::$asset is $size bytes — GitHub Release limit is 2 GiB"
      exit 1
    fi
    files+=("$dir/$asset")
  done
done

[ "${#files[@]}" -gt 0 ] || { echo "$branch: no assets produced — skipped"; exit 0; }

gh release create "$tag" "${files[@]}" --repo "$GITHUB_REPOSITORY" --latest=false \
  --title "4D $branch build $release_build" \
  --notes "4D Server, 4D Volume Desktop and 4D (when published) for $branch build $release_build.
Source: PS FTP runtimes/${branch}/{win,mac}/${release_build}/*.tar.xz (installer factory).
Assets are the factory tar.xz files (not re-zipped — stays under GitHub's 2 GiB limit).
Extract with tar -xJf. Used by Build_Application through TOOL4D_DOWNLOAD_REPO."

gh release list --repo "$GITHUB_REPOSITORY" --limit 200 --json tagName --jq '.[].tagName' \
  | grep -E "^${branch}-[0-9]+$" | grep -vx "$tag" \
  | xargs -r -n1 gh release delete --repo "$GITHUB_REPOSITORY" --cleanup-tag -y || true
echo "$tag: published (${#files[@]} assets)"
