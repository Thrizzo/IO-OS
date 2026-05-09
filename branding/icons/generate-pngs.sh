#!/usr/bin/env bash
# Rasterize branding/icons/io-logo.svg into PNGs at the standard hicolor sizes.
# Plymouth, SDDM, and several legacy menus need raster icons; SVG sources
# live in the repo so we can re-export at any time without redrawing.
#
# Requires: rsvg-convert  (package: librsvg-tools on openSUSE).
# Falls back to inkscape if rsvg-convert isn't installed.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$ROOT/io-logo.svg"
OUT="$ROOT/png"
SIZES=(16 24 32 48 64 128 256 512)

mkdir -p "$OUT"

if command -v rsvg-convert >/dev/null 2>&1; then
    convert() { rsvg-convert -w "$1" -h "$1" "$SRC" -o "$2"; }
elif command -v inkscape >/dev/null 2>&1; then
    convert() { inkscape "$SRC" --export-type=png --export-width="$1" --export-height="$1" --export-filename="$2" >/dev/null 2>&1; }
else
    echo "error: need rsvg-convert (librsvg-tools) or inkscape on PATH" >&2
    exit 1
fi

# Skip rasterization when an up-to-date PNG already exists. The SVG is the
# source of truth — touching it (or any newer mtime) invalidates the cache.
needs_rebuild() {
    local out="$1"
    [ ! -f "$out" ] && return 0
    [ "$SRC" -nt "$out" ] && return 0
    return 1
}

for s in "${SIZES[@]}"; do
    out="$OUT/io-logo-${s}.png"
    if needs_rebuild "$out"; then
        echo "  ${s}x${s}  ->  ${out}"
        convert "$s" "$out"
    else
        echo "  ${s}x${s}  ->  ${out} (cached)"
    fi
done

echo "Done. PNGs in $OUT/"
