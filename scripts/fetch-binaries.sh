#!/bin/bash
# Downloads 4D Server, 4D Volume Desktop and 4D (mono) for one version from the
# PS FTP runtimes/ contract (factory output), repacks them as ZIP assets, and
# publishes a GitHub Release named <branch>-<build>, assets <os>_<name>.zip
# (e.g. win_4D_Server.zip). Older releases of the same branch are deleted.
# Idempotent: nothing happens if the release already exists.
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

ftp_try() {
  # usage: ftp_try URL OUT
  local url="$1" out="$2"
  if "${CURL_FTP[@]}" -o "$out" "$url"; then
    return 0
  fi
  rm -f "$out"
  return 1
}

resolve_build_for_os() {
  # Sets global: resolved_build. Prefers VERSION build, else latest-build.txt.
  local os="$1"
  local exact="${ftp_base}/${os}/${want_build}/manifest.json"
  local latest_txt="${ftp_base}/${os}/latest-build.txt"
  local latest_manifest="${ftp_base}/${os}/latest/manifest.json"
  if ftp_try "$exact" "$dir/manifest-${os}.json"; then
    resolved_build="$want_build"
    return 0
  fi
  echo "::warning::$branch/$os build $want_build not on FTP — trying latest/"
  if ftp_try "$latest_txt" "$dir/latest-build-${os}.txt"; then
    resolved_build="$(tr -d '[:space:]' < "$dir/latest-build-${os}.txt")"
  elif ftp_try "$latest_manifest" "$dir/manifest-${os}.json"; then
    resolved_build="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["build"])' "$dir/manifest-${os}.json")"
  else
    echo "::warning::$branch/$os: no FTP runtime (exact nor latest) — skipped for this OS"
    resolved_build=""
    return 1
  fi
  [ -n "$resolved_build" ] || return 1
  if [ "$resolved_build" != "$want_build" ]; then
    echo "::warning::$branch/$os: VERSION wants $want_build but FTP latest is $resolved_build — publishing FTP build"
  fi
  return 0
}

tar_to_zip() {
  # usage: tar_to_zip TARXZ OUT_ZIP
  local tarxz="$1" out_zip="$2"
  local stage="$dir/stage-$$"
  rm -rf "$stage"
  mkdir -p "$stage"
  tar -xJf "$tarxz" -C "$stage"
  # ZIP root = whatever the factory packed (4D Server.app / 4D Server / …)
  (cd "$stage" && zip -qr "$out_zip" .)
  rm -rf "$stage"
  unzip -tq "$out_zip" >/dev/null
}

files=()
# One release tag per branch: use max resolved build across OS (they should match).
release_build=""

for os in win mac; do
  resolved_build=""
  resolve_build_for_os "$os" || continue
  if [ -z "$release_build" ]; then
    release_build="$resolved_build"
  elif [ "$release_build" != "$resolved_build" ]; then
    echo "::warning::$branch: win/mac FTP builds differ ($release_build vs $resolved_build) — using $release_build for tag"
  fi

  build_dir="${ftp_base}/${os}/${resolved_build}"
  # Prefer concrete build folder; if we fell back via latest-build.txt, that folder must exist.
  declare -A map=(
    [4D_Server.tar.xz]="${os}_4D_Server.zip"
    [4D_Volume_Desktop.tar.xz]="${os}_4D_Volume_Desktop.zip"
    [4D_Mono.tar.xz]="${os}_4D.zip"
  )
  for artifact in 4D_Server.tar.xz 4D_Volume_Desktop.tar.xz 4D_Mono.tar.xz; do
    asset="${map[$artifact]}"
    echo "downloading FTP runtimes/${branch}/${os}/${resolved_build}/$artifact → $asset"
    if ! ftp_try "${build_dir}/${artifact}" "$dir/$artifact"; then
      if [ "$artifact" = "4D_Mono.tar.xz" ]; then
        echo "::warning::$artifact missing on FTP (factory often skips mono without packageManager) — no $asset"
        continue
      fi
      echo "::error::required $artifact missing under $build_dir"
      exit 1
    fi
    tar_to_zip "$dir/$artifact" "$dir/$asset"
    files+=("$dir/$asset")
    rm -f "$dir/$artifact"
  done
done

[ -n "$release_build" ] || { echo "::warning::$branch: nothing on FTP for win/mac — skipped"; exit 0; }
[ "${#files[@]}" -gt 0 ] || { echo "::warning::$branch: no assets produced — skipped"; exit 0; }

tag="$branch-$release_build"
if gh release view "$tag" --repo "$GITHUB_REPOSITORY" >/dev/null 2>&1; then
  echo "$tag: release already exists"; exit 0
fi

gh release create "$tag" "${files[@]}" --repo "$GITHUB_REPOSITORY" --latest=false \
  --title "4D $branch build $release_build" \
  --notes "4D Server, 4D Volume Desktop and 4D (when published) for $branch build $release_build.
Source: PS FTP runtimes/${branch}/{win,mac}/${release_build}/ (installer factory), not product-download ZIPs.
Used by Build_Application through TOOL4D_DOWNLOAD_REPO."

gh release list --repo "$GITHUB_REPOSITORY" --limit 200 --json tagName --jq '.[].tagName' \
  | grep -E "^${branch}-[0-9]+$" | grep -vx "$tag" \
  | xargs -r -n1 gh release delete --repo "$GITHUB_REPOSITORY" --cleanup-tag -y || true
echo "$tag: published (${#files[@]} assets)"
