# branding/

Everything visual that makes IO look like IO instead of vanilla
openSUSE Plasma. The bundle is intentionally compact: every layer here
gets installed by `kiwi/config.sh` (in a later commit) and can be
swapped or removed without breaking the rest.

## Layout

| Directory                                     | What it is                                                                | Installs to                                                             |
|-----------------------------------------------|---------------------------------------------------------------------------|-------------------------------------------------------------------------|
| `colors/IO.colors`                            | Plasma color scheme (navy + amber).                                       | `/usr/share/color-schemes/IO.colors`                                    |
| `wallpapers/io-default.svg`                   | Default desktop / SDDM / lock-screen backdrop. Stylized Io moon.          | `/usr/share/wallpapers/IO/contents/images/io-default.svg`               |
| `icons/io-logo.svg` + `generate-pngs.sh`      | IO mark used for taskbar launcher, Plymouth, app icons.                   | SVG goes to `/usr/share/icons/hicolor/scalable/apps/io-logo.svg`; PNGs to `/usr/share/icons/hicolor/<size>x<size>/apps/io-logo.png`. |
| `plymouth/io/`                                | Plymouth boot splash theme (script + manifest).                           | `/usr/share/plymouth/themes/io/`                                        |
| `sddm/io/`                                    | SDDM greeter (QML + metadata + config).                                   | `/usr/share/sddm/themes/io/`                                            |
| `plasma-look-and-feel/org.iolinux.desktop/`   | Look-and-feel package wrapping color scheme + splash + cursor + decoration into one switchable global theme. | `/usr/share/plasma/look-and-feel/org.iolinux.desktop/` |

## Generating raster assets

SVG sources live in the repo. Plymouth and several legacy menu paths
need PNGs. Run once, then copy outputs into the right install paths:

```sh
./icons/generate-pngs.sh           # → branding/icons/png/io-logo-{16,24,32,48,64,128,256,512}.png
```

`branding/plymouth/io/logo.png` is a copy of `io-logo-256.png`.
`branding/sddm/io/background.svg` is a copy/symlink of `wallpapers/io-default.svg`.

These copies are deliberately not committed — the SVG source is the
single source of truth, and `kiwi/config.sh` will perform the copy at
image-build time.

## Palette

| Role            | Hex       | RGB             |
|-----------------|-----------|-----------------|
| Background      | `#1a2332` | 26, 35, 50      |
| Panel / alt bg  | `#243047` | 36, 48, 71      |
| Accent (amber)  | `#D4A24A` | 212, 162, 74    |
| Hover amber     | `#E0B569` | 224, 181, 105   |
| Text (primary)  | `#F0F0F0` | 240, 240, 240   |
| Text (dim)      | `#A0A8B5` | 160, 168, 181   |

Pure black is intentionally avoided — `#1a2332` reads as a sky, not a void.

## Licensing

All branding assets in this directory are CC-BY-SA-4.0 unless an
individual file declares otherwise.
