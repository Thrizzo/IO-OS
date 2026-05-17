# IO Linux GRUB theme

Theme files for GRUB 2's pixmap-based menu. Installed to
`/boot/grub2/themes/io/` by the build overlay; activated by
`kiwi/config.sh` which appends `GRUB_THEME=...` to `/etc/default/grub`.

## Files

| File              | Role                                                     |
|-------------------|----------------------------------------------------------|
| `theme.txt`       | The theme manifest (colours, fonts, component layout)    |
| `background.png`  | Full-screen backdrop (1920×1080 PNG, derived from logo)  |
| `selected_*.png`  | 9-slice tiles for the selected menu item                 |
| `progress_*.png`  | 9-slice tiles for the timeout progress bar               |
| `scrollbar_*.png` | 9-slice tiles for the menu scrollbar                     |
| `terminal_*.png`  | 9-slice tiles for the GRUB terminal box                  |

## Why no PNGs in the repo

GRUB themes need PNG bitmaps, not SVG. We rasterise from the IO logo
and a procedurally-generated background at build time via
`branding/grub2-theme/io/generate-assets.sh` (see that script). The
generator falls back gracefully when neither `convert` nor
`rsvg-convert` are installed — GRUB ships a plain text menu in that
case.

## Palette source of truth

`theme.txt` mirrors hex values from `branding/colors/IO.colors`.
Update both when the palette changes.
