#!/usr/bin/env bash

set -euo pipefail

root_dir="$(cd "$(dirname "$0")/.." && pwd)"
"$root_dir/gradlew" -p "$root_dir/smoke-tests/maven-consumer" compileKotlin --no-daemon
