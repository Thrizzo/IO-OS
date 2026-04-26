# kiwi/root/

Kiwi-NG overlays the contents of this directory onto the new image's
filesystem at build time — paths here become absolute paths in the ISO.

**Do not commit files into this directory.** It is a derived staging
area populated by `./build.sh` from `branding/` and `plasma-config/`.
Source-of-truth files live there; this directory mirrors them into the
exact paths the image expects.

The `.gitignore` ignores everything except itself and this README.

## Why staged, not committed?

Two reasons:

1. The same SVG (e.g. the wallpaper) is installed at multiple paths
   (`/usr/share/wallpapers/IO/...`, `/usr/share/sddm/themes/io/background.svg`).
   Symlinks across the project root would be fragile under git.
2. Generated PNGs from `branding/icons/io-logo.svg` should not live in git.

`build.sh stage_overlay` performs the copy and then `kiwi-ng` consumes
the result.
