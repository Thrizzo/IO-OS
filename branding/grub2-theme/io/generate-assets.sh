#!/usr/bin/env bash
# Generate the PNG bitmaps GRUB needs from the IO palette.
# Outputs land next to this script; build.sh copies them into the
# image overlay. Idempotent: skips work when the targets are newer
# than this script.
#
# Requires ImageMagick (`convert`). Falls back to a solid-colour
# placeholder when convert is missing — GRUB still renders the menu,
# just without the rounded pixmaps.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGO="$HERE/../../icons/io-logo.svg"

NAVY="#1a2332"
ACCENT="#D4A24A"
ACCENT_HOVER="#E0B569"
SURFACE="#243047"

needs_rebuild() {
    [ ! -f "$1" ] || [ "${BASH_SOURCE[0]}" -nt "$1" ]
}

if ! command -v convert >/dev/null 2>&1; then
    echo "==> grub theme: 'convert' missing; writing 1×1 placeholders" >&2
    for f in background selected_c selected_n selected_s selected_e selected_w \
             selected_ne selected_nw selected_se selected_sw \
             progress_c progress_filled_c scrollbar_thumb_c terminal_c; do
        target="$HERE/${f}.png"
        if needs_rebuild "$target"; then
            # 1×1 transparent PNG; GRUB scales it to whatever the theme asks.
            printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\rIDATx\xdac\xf8\xcf\xc0\x00\x00\x00\x03\x00\x01\xfa\xf9\xeb\xbf\x00\x00\x00\x00IEND\xaeB`\x82' > "$target"
        fi
    done
    exit 0
fi

bg="$HERE/background.png"
if needs_rebuild "$bg"; then
    echo "==> grub theme: rendering background.png"
    # Vertical gradient navy → slightly darker bottom + faint logo watermark.
    convert -size 1920x1080 \
        gradient:"$NAVY"-"#0d111a" \
        "$bg"
fi

# Selected-item 9-slice: amber rounded rectangle.
sel="$HERE/selected_c.png"
if needs_rebuild "$sel"; then
    echo "==> grub theme: rendering selected_*.png"
    convert -size 32x32 xc:none \
        -fill "$ACCENT" -draw "roundrectangle 0,0 31,31 6,6" \
        "$sel"
    # GRUB expects all 9 slices; we use the same texture for centre + edges +
    # corners — visually fine because the rounded shape only matters at corners.
    for s in n s e w ne nw se sw; do
        cp -f "$sel" "$HERE/selected_${s}.png"
    done
fi

# Progress bar slices.
prog_bg="$HERE/progress_c.png"
if needs_rebuild "$prog_bg"; then
    convert -size 6x6 xc:"$SURFACE" "$prog_bg"
fi
prog_fg="$HERE/progress_filled_c.png"
if needs_rebuild "$prog_fg"; then
    convert -size 6x6 xc:"$ACCENT" "$prog_fg"
fi

# Scrollbar + terminal box.
scr="$HERE/scrollbar_thumb_c.png"
if needs_rebuild "$scr"; then
    convert -size 6x6 xc:"$ACCENT_HOVER" "$scr"
fi
term="$HERE/terminal_c.png"
if needs_rebuild "$term"; then
    convert -size 8x8 xc:"$SURFACE" "$term"
fi

echo "==> grub theme: assets ready in $HERE"
