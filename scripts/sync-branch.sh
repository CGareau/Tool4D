#!/bin/bash
# Creates or updates one version branch of this repository from the private Tools repository.
# usage: sync-branch.sh <branch> <auto|full>
#   auto : branch absent  -> created with tool4d + 4DBuilder + Build_Application
#          branch present -> only tool4d_* and VERSION are replaced
#   full : tool4d + 4DBuilder + Build_Application are (re)built from Tools, even if the branch exists
# env: TOOLS_URL  clone URL of Tools (with credentials), PUBLIC_URL  push URL of this repo,
#      DRY_RUN=1  build and check but do not push
set -euo pipefail
branch="${1:?branch}"; mode="${2:-auto}"
here="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT

echo "== $branch ($mode)"
git clone -q --depth 1 --branch "$branch" "$TOOLS_URL" "$work/tools"
subject="$(git -C "$work/tools" log -1 --format=%s)"
msg_build="$(grep -oE 'build [0-9]+' <<< "$subject" | grep -oE '[0-9]+' | tail -1 || true)"
# the build number of the tool4d that is really shipped (e.g. "21.1 build 21.100575", "21 R4 build 21R4.100203")
plist="$work/tools/tool4d_mac/tool4d.app/Contents/Info.plist"
shown="$(python3 -I -c 'import plistlib,sys;print(plistlib.load(open(sys.argv[1],"rb")).get("CFBundleShortVersionString",""))' "$plist" 2>/dev/null || true)"
build="$(grep -oE '[0-9]+$' <<< "$shown" || true)"
version_label="${shown%% build*}"
[ -n "$build" ] || { echo "::error::cannot read the build number of tool4d_mac in $branch"; exit 1; }
if [ -n "$msg_build" ] && [ "$msg_build" != "$build" ]; then
  echo "::warning::$branch: the Tools commit says build $msg_build but tool4d is '$shown'; publishing what the binary says"
fi

exists=0
if git ls-remote --exit-code --heads "$PUBLIC_URL" "$branch" >/dev/null 2>&1; then exists=1; fi

mkdir -p "$work/out"
if [ "$exists" = 1 ] && [ "$mode" = auto ]; then
  git clone -q --depth 1 --branch "$branch" "$PUBLIC_URL" "$work/pub"
  (cd "$work/pub" && tar --exclude=.git -cf - .) | tar -xf - -C "$work/out"
  "$here/scripts/stage.sh" "$work/tools" "$work/out" tool4d
else
  "$here/scripts/stage.sh" "$work/tools" "$work/out" tool4d
  "$here/scripts/stage.sh" "$work/tools" "$work/out" builder
fi

printf 'branch=%s\nversion=%s\nbuild=%s\nsource=%s\n' "$branch" "$version_label" "$build" "$subject" > "$work/out/VERSION"
"$here/scripts/secret-guard.sh" "$work/out"

if [ "$exists" = 1 ] && diff -rq --exclude=.git "$work/pub" "$work/out" >/dev/null 2>&1; then
  echo "$branch: already up to date (build $build)"; exit 0
fi

if [ "${DRY_RUN:-0}" = 1 ]; then
  echo "$branch: DRY RUN, would publish build $build ($(du -sh "$work/out" | cut -f1))"; exit 0
fi

cd "$work/out"
git init -q -b "$branch"
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git add -A
git commit -q -m "tool4d $branch build $build"
git push -q --force "$PUBLIC_URL" "HEAD:refs/heads/$branch"
echo "$branch: published build $build"
