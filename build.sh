#!/usr/bin/env bash
# IO Linux — local ISO build entry point.
#
# Pipeline:
#   1. (optional) Generate raster icons from SVG sources.
#   2. Stage branding + plasma-config into kiwi/root/ as the image overlay.
#   3. Hand off to `kiwi-ng system build` against ./kiwi/.
#   4. Print where the ISO landed.
#
# Expected host: openSUSE Tumbleweed with kiwi-ng installed
# (`sudo zypper install kiwi-ng`). Kiwi needs root for chroot/mount,
# so this script will use `sudo` if not already running as root.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESC="$ROOT/kiwi"
OVERLAY="$DESC/root"
OUT="$ROOT/out"

# --- pre-flight ----------------------------------------------------------
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

# --- step 1: rasterize the IO logo (skip silently if no rasterizer) ------
generate_pngs() {
    local gen="$ROOT/branding/icons/generate-pngs.sh"
    if command -v rsvg-convert >/dev/null 2>&1 || command -v inkscape >/dev/null 2>&1; then
        echo "==> Rasterizing IO logo"
        "$gen"
    else
        echo "==> Skipping logo rasterization (no rsvg-convert or inkscape on PATH)"
        echo "    legacy menus may show a fallback icon for io-logo."
    fi
}

# --- step 2: stage the image overlay -------------------------------------
stage_overlay() {
    echo "==> Staging image overlay -> $OVERLAY"

    # Wipe previous staging, but keep .gitignore + README.md so git stays clean.
    find "$OVERLAY" -mindepth 1 -maxdepth 1 \
        ! -name '.gitignore' ! -name 'README.md' \
        -exec rm -rf {} +

    # ---- Branding: color schemes (dark + light) ----
    install -Dm644 "$ROOT/branding/colors/IO.colors" \
        "$OVERLAY/usr/share/color-schemes/IO.colors"
    install -Dm644 "$ROOT/branding/colors/IO-light.colors" \
        "$OVERLAY/usr/share/color-schemes/IO-light.colors"

    # ---- Branding: wallpaper (Plasma-recognised package layout) ----
    install -Dm644 "$ROOT/branding/wallpapers/io-default.svg" \
        "$OVERLAY/usr/share/wallpapers/IO/contents/images/io-default.svg"
    cat > "$OVERLAY/usr/share/wallpapers/IO/metadata.json" <<'JSON'
{
    "KPlugin": {
        "Authors": [{"Email": "", "Name": "The IO Linux contributors"}],
        "Id": "IO",
        "Name": "IO",
        "License": "CC-BY-SA-4.0",
        "Version": "0.1.0"
    }
}
JSON

    # ---- Branding: icons ----
    install -Dm644 "$ROOT/branding/icons/io-logo.svg" \
        "$OVERLAY/usr/share/icons/hicolor/scalable/apps/io-logo.svg"
    if [ -d "$ROOT/branding/icons/png" ]; then
        for size in 16 24 32 48 64 128 256 512; do
            local f="$ROOT/branding/icons/png/io-logo-${size}.png"
            [ -f "$f" ] && install -Dm644 "$f" \
                "$OVERLAY/usr/share/icons/hicolor/${size}x${size}/apps/io-logo.png"
        done
    fi

    # ---- Branding: Plymouth ----
    install -Dm644 "$ROOT/branding/plymouth/io/io.plymouth" \
        "$OVERLAY/usr/share/plymouth/themes/io/io.plymouth"
    install -Dm644 "$ROOT/branding/plymouth/io/io.script" \
        "$OVERLAY/usr/share/plymouth/themes/io/io.script"
    # Plymouth needs a raster logo; use the 256px PNG if generation ran.
    if [ -f "$ROOT/branding/icons/png/io-logo-256.png" ]; then
        install -Dm644 "$ROOT/branding/icons/png/io-logo-256.png" \
            "$OVERLAY/usr/share/plymouth/themes/io/logo.png"
    else
        echo "    note: no logo.png for Plymouth — boot splash will be text-only."
    fi

    # ---- Branding: SDDM ----
    install -Dm644 "$ROOT/branding/sddm/io/metadata.desktop" \
        "$OVERLAY/usr/share/sddm/themes/io/metadata.desktop"
    install -Dm644 "$ROOT/branding/sddm/io/theme.conf" \
        "$OVERLAY/usr/share/sddm/themes/io/theme.conf"
    install -Dm644 "$ROOT/branding/sddm/io/Main.qml" \
        "$OVERLAY/usr/share/sddm/themes/io/Main.qml"
    install -Dm644 "$ROOT/branding/wallpapers/io-default.svg" \
        "$OVERLAY/usr/share/sddm/themes/io/background.svg"
    # Tell SDDM to use the IO theme.
    install -dm755 "$OVERLAY/etc/sddm.conf.d"
    cat > "$OVERLAY/etc/sddm.conf.d/20-io-theme.conf" <<'EOF'
[Theme]
Current=io
EOF

    # ---- Branding: Plasma look-and-feel ----
    install -Dm644 "$ROOT/branding/plasma-look-and-feel/org.iolinux.desktop/metadata.json" \
        "$OVERLAY/usr/share/plasma/look-and-feel/org.iolinux.desktop/metadata.json"
    install -Dm644 "$ROOT/branding/plasma-look-and-feel/org.iolinux.desktop/contents/defaults" \
        "$OVERLAY/usr/share/plasma/look-and-feel/org.iolinux.desktop/contents/defaults"

    # ---- Plasma config in /etc/skel/.config/ ----
    for f in plasma-org.kde.plasma.desktop-appletsrc kdeglobals kwinrc dolphinrc \
             kglobalshortcutsrc; do
        install -Dm644 "$ROOT/plasma-config/$f" "$OVERLAY/etc/skel/.config/$f"
    done
    install -Dm644 "$ROOT/plasma-config/skel/Desktop/dieser-pc.desktop" \
        "$OVERLAY/etc/skel/Desktop/dieser-pc.desktop"
    install -Dm644 "$ROOT/plasma-config/skel/Desktop/papierkorb.desktop" \
        "$OVERLAY/etc/skel/Desktop/papierkorb.desktop"

    # ---- io-welcome (QML + strings + optional .qm + launcher + autostart) ----
    install -Dm644 "$ROOT/packages/io-welcome/qml/Main.qml" \
        "$OVERLAY/usr/share/io-welcome/Main.qml"
    install -Dm644 "$ROOT/packages/io-welcome/qml/strings.js" \
        "$OVERLAY/usr/share/io-welcome/strings.js"
    # Optional: compiled translations. lrelease is invoked above only when
    # the toolchain is present; if no .qm exists we still have strings.js
    # as the fallback path so the welcome wizard always renders.
    if [ -d "$ROOT/packages/io-welcome/i18n" ]; then
        for qm in "$ROOT/packages/io-welcome/i18n"/*.qm; do
            [ -f "$qm" ] || continue
            install -Dm644 "$qm" \
                "$OVERLAY/usr/share/io-welcome/i18n/$(basename "$qm")"
        done
    fi
    install -Dm755 "$ROOT/packages/io-welcome/io-welcome-launcher" \
        "$OVERLAY/usr/bin/io-welcome-launcher"
    install -Dm644 "$ROOT/packages/io-welcome/io-welcome.desktop" \
        "$OVERLAY/etc/xdg/autostart/io-welcome.desktop"
}

# --- step 1.5: optional Qt Linguist compile ------------------------------
# If lrelease is on PATH, compile any io-welcome .ts files into .qm so the
# wizard can use the QTranslator path; otherwise the JS strings module
# (strings.js) is the fallback and nothing is missing.
compile_translations() {
    local ts_dir="$ROOT/packages/io-welcome/i18n"
    [ -d "$ts_dir" ] || return 0
    if command -v lrelease-qt6 >/dev/null 2>&1; then
        local LRELEASE=lrelease-qt6
    elif command -v lrelease >/dev/null 2>&1; then
        local LRELEASE=lrelease
    else
        echo "==> Skipping translation compile (no lrelease on PATH)"
        return 0
    fi
    echo "==> Compiling io-welcome translations"
    for ts in "$ts_dir"/*.ts; do
        [ -f "$ts" ] || continue
        "$LRELEASE" "$ts" -qm "${ts%.ts}.qm" >/dev/null
    done
}

# --- step 3: build --------------------------------------------------------
SUDO=""
[ "$EUID" -ne 0 ] && SUDO="sudo"

generate_pngs
compile_translations
stage_overlay

echo "==> Building IO Linux ISO"
echo "    description: $DESC"
echo "    output:      $OUT"
echo

# kiwi-ng spawns zypper, which already parallelises; --logfile keeps the
# verbose build trace next to the ISO so post-mortems don't need scrollback.
$SUDO kiwi-ng --type iso --logfile "$OUT/kiwi-build.log" system build \
    --description "$DESC" \
    --target-dir "$OUT"

echo
echo "==> Build complete. Artefacts:"
if ls "$OUT"/*.iso >/dev/null 2>&1; then
    ls -lh "$OUT"/*.iso

    # Emit deterministic checksums for downstream verification (mirrors,
    # release pages). Overwrites on re-build so SHA256SUMS is always current.
    ( cd "$OUT" && sha256sum -- *.iso > SHA256SUMS )
    echo
    echo "==> SHA256SUMS:"
    cat "$OUT/SHA256SUMS"
else
    echo "    no .iso produced — see $OUT/kiwi-build.log"
    exit 1
fi
