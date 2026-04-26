#!/usr/bin/env bash
# IO Linux post-install configuration, executed by Kiwi inside the new
# image root. Keep this minimal: every line that diverges from upstream
# defaults gets a one-line comment explaining why.

set -euo pipefail

# Standard Kiwi/openSUSE includes — provide suseSetupProduct,
# suseInsertService, baseSetRunlevel, and friends.
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

echo "Configuring image: [${kiwi_iname:-IO-Linux}]..."

# --- openSUSE setup helpers ----------------------------------------------
suseSetupProduct

# Enable services we want active on first boot.
suseInsertService NetworkManager
suseInsertService sshd
suseInsertService sddm

# Boot into the graphical target — Plasma is the point of this image.
baseSetRunlevel 5

# --- Live user (deleted by Calamares at install time) --------------------
echo "io ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/io-live
chmod 440 /etc/sudoers.d/io-live

mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/10-io-live-autologin.conf <<'SDDM_EOF'
# IO Linux live ISO: log the live user straight into Plasma. The installer
# (Calamares) creates a real user with no autologin.
[Autologin]
User=io
Session=plasma
SDDM_EOF

# --- Locale + hostname ----------------------------------------------------
echo 'LANG=de_DE.UTF-8'         >  /etc/locale.conf
echo 'LANGUAGE=de_DE:en_US'     >> /etc/locale.conf
echo 'io-linux-live'            >  /etc/hostname

# --- Activate IO branding -------------------------------------------------
# Plymouth: switch the default theme and rebuild the initramfs so the
# splash actually shows on boot. -R = regenerate initrd.
if [ -f /usr/share/plymouth/themes/io/io.plymouth ]; then
    plymouth-set-default-theme -R io || true
fi

# Refresh icon cache so the IO launcher icon shows up in menus.
if [ -d /usr/share/icons/hicolor ]; then
    gtk-update-icon-cache -t /usr/share/icons/hicolor || true
fi

# Refresh KDE service / desktop / mime caches if the tools are present.
command -v kbuildsycoca6 >/dev/null 2>&1 && kbuildsycoca6 --noincremental || true
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database -q /usr/share/applications || true
command -v update-mime-database    >/dev/null 2>&1 && update-mime-database    /usr/share/mime || true

echo "Configuration complete."
