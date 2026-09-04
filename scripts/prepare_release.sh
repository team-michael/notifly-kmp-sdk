#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <version>" >&2
  exit 2
fi

version="$1"
root_dir="$(cd "$(dirname "$0")/.." && pwd)"
framework_dir="$root_dir/kmp/build/XCFrameworks/release/NotiflyKMP.xcframework"
release_dir="$root_dir/kmp/build/release/$version"
archive_path="$release_dir/NotiflyKMP.xcframework.zip"

if [[ "${SKIP_BUILD:-false}" != "true" ]]; then
  "$root_dir/gradlew" :kmp:assembleNotiflyKMPReleaseXCFramework --no-daemon
fi

if [[ ! -d "$framework_dir" ]]; then
  echo "missing XCFramework: $framework_dir" >&2
  exit 1
fi

mkdir -p "$release_dir"
if [[ -e "$archive_path" ]]; then
  find "$archive_path" -depth -delete
fi
ditto -c -k --sequesterRsrc --keepParent "$framework_dir" "$archive_path"

checksum="$(swift package compute-checksum "$archive_path")"
printf '%s\n' "$checksum" > "$release_dir/checksum.txt"
printf '%s\n' "$archive_path"
printf '%s\n' "$checksum"
