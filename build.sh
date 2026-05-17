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
             kglobalshortcutsrc mimeapps.list; do
        install -Dm644 "$ROOT/plasma-config/$f" "$OVERLAY/etc/skel/.config/$f"
    done
    install -Dm644 "$ROOT/plasma-config/skel/Desktop/dieser-pc.desktop" \
        "$OVERLAY/etc/skel/Desktop/dieser-pc.desktop"
    install -Dm644 "$ROOT/plasma-config/skel/Desktop/papierkorb.desktop" \
        "$OVERLAY/etc/skel/Desktop/papierkorb.desktop"

    # ---- KWin scripts (Aero Shake et al.) ----
    if [ -d "$ROOT/plasma-config/kwin-scripts" ]; then
        for script in "$ROOT/plasma-config/kwin-scripts"/*/; do
            [ -d "$script" ] || continue
            local id
            id=$(basename "$script")
            install -Dm644 "$script/metadata.json" \
                "$OVERLAY/usr/share/kwin/scripts/$id/metadata.json"
            if [ -f "$script/contents/code/main.js" ]; then
                install -Dm644 "$script/contents/code/main.js" \
                    "$OVERLAY/usr/share/kwin/scripts/$id/contents/code/main.js"
            fi
        done
    fi

    # ---- Brave managed policy + autostart for io-firstboot Flatpak ----
    install -Dm644 "$ROOT/branding/brave-policies/io-defaults.json" \
        "$OVERLAY/etc/brave/policies/managed/io-defaults.json"
    install -Dm644 "$ROOT/branding/firstboot/io-firstboot-flatpak.service" \
        "$OVERLAY/etc/systemd/system/io-firstboot-flatpak.service"
    install -dm755 "$OVERLAY/etc/systemd/system/multi-user.target.wants"
    ln -sf ../io-firstboot-flatpak.service \
        "$OVERLAY/etc/systemd/system/multi-user.target.wants/io-firstboot-flatpak.service"

    # ---- Proton suite: PWA launchers for Calendar + Drive (web-only) ----
    # Real native Proton apps (Mail, Pass, VPN) come from Flathub via the
    # firstboot unit; Calendar + Drive have no native Linux client yet,
    # so we ship Brave-launched PWA .desktop entries pinned to the
    # taskbar. Replace once Proton ships native binaries.
    for d in "$ROOT/branding/proton"/*.desktop; do
        [ -f "$d" ] || continue
        install -Dm644 "$d" \
            "$OVERLAY/usr/share/applications/$(basename "$d")"
    done

    # ---- Security drop-ins (DoT, firewalld, AppArmor, Wine FD limits) ----
    install -Dm644 "$ROOT/branding/security/resolved/io-doh.conf" \
        "$OVERLAY/etc/systemd/resolved.conf.d/io-doh.conf"
    install -Dm644 "$ROOT/branding/security/firewalld/io-public.xml" \
        "$OVERLAY/etc/firewalld/zones/public.xml"
    install -Dm644 "$ROOT/branding/security/limits.d/99-io-wine.conf" \
        "$OVERLAY/etc/security/limits.d/99-io-wine.conf"
    install -Dm644 "$ROOT/branding/security/modules-load.d/io-ntsync.conf" \
        "$OVERLAY/etc/modules-load.d/io-ntsync.conf"
    for prof in "$ROOT/branding/security/apparmor"/*; do
        [ -f "$prof" ] || continue
        local dest="$OVERLAY/etc/apparmor.d/$(basename "$prof")"
        install -Dm644 "$prof" "$dest"
        # IO_APPARMOR_ENFORCE=1 flips `flags=(complain)` to `flags=()` so
        # the profile loads in enforce mode at boot. Default is complain
        # for v0.1 — flip per release after audit data confirms no false
        # positives that would break the boot.
        if [ "${IO_APPARMOR_ENFORCE:-0}" = "1" ]; then
            sed -i -E 's/flags=\(complain([,)])/flags=(\1/; s/flags=\(complain\)/flags=()/' "$dest"
        fi
    done

    # ---- Security: OpenSnitch (interactive outbound firewall) ----
    install -Dm644 "$ROOT/branding/security/opensnitch/default-config.json" \
        "$OVERLAY/etc/opensnitchd/default-config.json"
    for r in "$ROOT/branding/security/opensnitch/rules"/*.json; do
        [ -f "$r" ] || continue
        install -Dm644 "$r" \
            "$OVERLAY/etc/opensnitchd/rules/$(basename "$r")"
    done

    # ---- Calamares branding + preset (LUKS2 + TPM2 enrol on install) ----
    install -Dm644 "$ROOT/branding/calamares/settings.conf" \
        "$OVERLAY/etc/calamares/settings.conf"
    install -Dm644 "$ROOT/branding/calamares/modules/partition.conf" \
        "$OVERLAY/etc/calamares/modules/partition.conf"
    install -Dm644 "$ROOT/branding/calamares/modules/shellprocess-tpm2.conf" \
        "$OVERLAY/etc/calamares/modules/shellprocess-tpm2.conf"
    install -Dm644 "$ROOT/branding/calamares/branding/io/branding.desc" \
        "$OVERLAY/etc/calamares/branding/io/branding.desc"

    # ---- GRUB theme ----
    if [ -f "$ROOT/branding/grub2-theme/io/theme.txt" ]; then
        install -dm755 "$OVERLAY/boot/grub2/themes/io"
        "$ROOT/branding/grub2-theme/io/generate-assets.sh" >/dev/null || true
        for f in "$ROOT/branding/grub2-theme/io"/*; do
            [ -f "$f" ] || continue
            case "$f" in
                *.sh|*.md) continue ;;
            esac
            install -Dm644 "$f" \
                "$OVERLAY/boot/grub2/themes/io/$(basename "$f")"
        done
    fi

    # ---- Sound theme (alias of freedesktop until we record .oga files) ----
    install -Dm644 "$ROOT/branding/sounds/io/index.theme" \
        "$OVERLAY/usr/share/sounds/io/index.theme"
    install -dm755 "$OVERLAY/usr/share/sounds/io/stereo"

    # ---- Cursor theme alias ----
    install -Dm644 "$ROOT/branding/cursors/io/index.theme" \
        "$OVERLAY/usr/share/icons/io/index.theme"

    # ---- io-settings (Win11-Settings-shaped front-end over KCM) ----
    install -Dm755 "$ROOT/packages/io-settings/io-settings" \
        "$OVERLAY/usr/bin/io-settings"
    install -Dm644 "$ROOT/packages/io-settings/qml/Main.qml" \
        "$OVERLAY/usr/share/io-settings/Main.qml"
    install -Dm644 "$ROOT/packages/io-settings/qml/categories.js" \
        "$OVERLAY/usr/share/io-settings/categories.js"
    install -Dm644 "$ROOT/packages/io-settings/io-settings.desktop" \
        "$OVERLAY/usr/share/applications/io-settings.desktop"

    # ---- io-run dispatcher (Windows binary launcher) ----
    install -Dm755 "$ROOT/packages/io-run/io-run" \
        "$OVERLAY/usr/bin/io-run"
    install -Dm755 "$ROOT/packages/io-run/io-run-prepare-templates" \
        "$OVERLAY/usr/bin/io-run-prepare-templates"
    install -Dm644 "$ROOT/packages/io-run/io-run.desktop" \
        "$OVERLAY/usr/share/applications/io-run.desktop"
    install -Dm644 "$ROOT/packages/io-run/io-run-prepare-templates.service" \
        "$OVERLAY/usr/lib/systemd/user/io-run-prepare-templates.service"
    install -dm755 "$OVERLAY/etc/skel/.config/systemd/user/default.target.wants"
    ln -sf ../../../../../usr/lib/systemd/user/io-run-prepare-templates.service \
        "$OVERLAY/etc/skel/.config/systemd/user/default.target.wants/io-run-prepare-templates.service"
    if [ -d "$ROOT/packages/io-run/recipes" ]; then
        for r in "$ROOT/packages/io-run/recipes"/*.yaml; do
            [ -f "$r" ] || continue
            install -Dm644 "$r" \
                "$OVERLAY/usr/share/io-run/recipes/$(basename "$r")"
        done
    fi

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
