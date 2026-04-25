# IO Linux — Roadmap

> Intent only. Each milestone gets its own design doc before work starts.

## v0.1 — Alpha (current)

A bootable, branded, Windows-familiar Plasma desktop on top of openSUSE Kalpa.
No custom services. See `docs/architecture.md` for what's in scope.

## v0.2 — IO Compatibility Layer

A Plasma-integrated dispatcher that handles `.exe` and `.msi` files via
Bottles with curated recipes, sandboxed per-app via bubblewrap. Goal: a
Windows user can double-click a familiar installer and have it Just Work for
the apps we explicitly support.

## v0.3 — IO VPN Manager

NetworkManager front-end that auto-detects VPN config format
(OpenVPN, WireGuard, IPsec, AnyConnect, GlobalProtect) and routes the user
to the correct Linux-native client without making them choose. Targets the
KRITIS / public-sector reality where every customer hands you a different
VPN profile.

## v0.4 — IO Store

A Plasma front-end over Flatpak/Flathub plus a curated European software
catalog with a "verified for KRITIS" tier (provenance, sandbox profile,
update SLA). Built on the same Flatpak substrate v0.1 already uses.

## v0.5 — Apple file format support

Bundle libheif, hfsplus, dmg2img, and LibreOffice import filters for iWork
by default. So a user moving from macOS doesn't lose access to their
existing files on day one.

## Beyond v0.5

Out of scope for now. Decisions about LTS cadence, signed-image
attestation, hardware-vendor partnerships, and a managed-fleet story will
be made once v0.2–v0.5 have shipped and we have real user feedback.
