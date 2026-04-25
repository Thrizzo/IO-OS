#!/usr/bin/env bash
# IO Linux — local ISO build entry point.
# Wraps `kiwi-ng system build` against ./kiwi/, output lands in ./out/.
#
# Expected host: openSUSE Tumbleweed with kiwi-ng installed
# (`sudo zypper install kiwi-ng`). Kiwi needs root for chroot/mount,
# so this script will use `sudo` if not already running as root.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESC="$ROOT/kiwi"
OUT="$ROOT/out"

if ! command -v kiwi-ng >/dev/null 2>&1; then
    echo "error: kiwi-ng not found." >&2
    echo "On openSUSE Tumbleweed: sudo zypper install kiwi-ng" >&2
    exit 1
fi

if [ ! -f "$DESC/config.xml" ]; then
    echo "error: $DESC/config.xml not found." >&2
    exit 1
fi

mkdir -p "$OUT"

SUDO=""
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
fi

echo "==> Building IO Linux ISO"
echo "    description: $DESC"
echo "    output:      $OUT"
echo

$SUDO kiwi-ng --type iso system build \
    --description "$DESC" \
    --target-dir "$OUT"

echo
echo "==> Build complete. Artefacts:"
ls -lh "$OUT"/*.iso 2>/dev/null || {
    echo "    no .iso produced — check kiwi log above"
    exit 1
}
