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

# --- openSUSE setup helpers ---
suseSetupProduct

# Enable services we want active on first boot.
suseInsertService NetworkManager
suseInsertService sshd
suseInsertService sddm

# Boot into the graphical target — Plasma is the point of this image.
baseSetRunlevel 5

# Live user: passwordless sudo so testers can poke at the live environment
# without surprises. Calamares replaces this user at install time.
echo "io ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/io-live
chmod 440 /etc/sudoers.d/io-live

# Autologin the live user into Plasma. SDDM's drop-in directory is read
# in lexicographic order, so the `10-` prefix keeps us first.
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/10-io-live-autologin.conf <<'SDDM_EOF'
# IO Linux live ISO: log the live user straight into Plasma. The installer
# (Calamares) creates a real user with no autologin, so this only affects
# the live session.
[Autologin]
User=io
Session=plasma
SDDM_EOF

# Default locale: de_DE.UTF-8 with en_US as fallback (see docs/architecture.md).
echo 'LANG=de_DE.UTF-8'         >  /etc/locale.conf
echo 'LANGUAGE=de_DE:en_US'     >> /etc/locale.conf

# Hostname — temporary, the installer lets the user pick a real one.
echo 'io-linux-live' > /etc/hostname

echo "Configuration complete."
