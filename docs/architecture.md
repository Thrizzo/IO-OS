# IO Linux — Architecture

## Base distribution

**Decision:** openSUSE **Kalpa** (formerly MicroOS Desktop Plasma).

### Rationale

- Direct technical fit: immutable + transactional + KDE Plasma 6 + Wayland, out of the box.
- Shares Aeon's (the GNOME sibling) mature MicroOS base — kernel, btrfs root,
  `transactional-update`, snapper, Flatpak as the default user-app channel.
- Officially blessed by openSUSE. Building on Kalpa keeps us aligned with
  upstream rather than fragmenting; it gives the German public sector a clean
  answer to "what is this based on?" (an established European Linux project).
- Plasma 6.x ships current and matches our taskbar/welcome-app target.

### Known caveats

- Kalpa is still labelled "Experimental" by openSUSE in 2026. We are alpha
  ourselves, so this is acceptable for v0.1 — but we must track upstream
  issues actively and pin a known-good snapshot for our nightly build.
- If Kalpa stalls or regresses badly during v0.1 development, the documented
  fallback is: build our own MicroOS Plasma stack via Kiwi-NG using
  `patterns-kde-plasma` on top of a MicroOS Base + Aeon's `transactional-update`
  tooling. Same end result, more maintenance.

## Build system

**Kiwi-NG via Open Build Service (OBS).**

- Local builds run through `kiwi-ng system build` (wrapped by `./build.sh`).
- Nightly builds run on OBS, triggered via the GitHub Actions workflow in
  `.github/workflows/build.yml` — we publish OBS-built ISOs as release
  artifacts rather than re-building from scratch in CI minutes.
- Image definition lives in `kiwi/config.xml`; post-install customization in
  `kiwi/config.sh`; overlay files in `kiwi/root/`.

## App delivery

**Flatpak.** Preinstalled apps (LibreOffice, Firefox, Thunderbird, Bottles,
Discover) ship as Flatpaks from Flathub. Rationale: keeps the read-only base
small, lets users update apps without `transactional-update` reboots, sandboxes
by default. The IO Store (v0.4) will be a Plasma front-end over the same
Flatpak substrate.

## Branding & customization layers

| Layer             | Mechanism                                                  | Location                                              |
|-------------------|------------------------------------------------------------|-------------------------------------------------------|
| Boot splash       | Plymouth theme                                             | `branding/plymouth/`                                  |
| Login             | SDDM theme                                                 | `branding/sddm/`                                      |
| Desktop look      | Plasma Look-and-Feel package + color scheme                | `branding/plasma-look-and-feel/`, `branding/colors/`  |
| Panel layout      | `plasma-org.kde.plasma.desktop-appletsrc` (shipped as skel/system default) | `plasma-config/`                      |
| Window behaviour  | `kwinrc`                                                   | `plasma-config/`                                      |
| First-run UX      | `io-welcome` autostart                                     | `packages/io-welcome/`                                |

Every customization file carries a one-line comment explaining *why* it
diverges from upstream defaults. Removing any single override should fall
back gracefully to upstream Kalpa behaviour.

## Locale

`de_DE.UTF-8` default; `en_US.UTF-8` available at install/login. Both are
first-class — no DE-only strings ship without an EN translation, and vice
versa.

## What this architecture does not include (by design)

- Custom kernel.
- Forks of Plasma, Wine, or any upstream component.
- A custom installer (we use openSUSE's existing Calamares-based flow).
- The Windows compatibility layer, IO Store, IO VPN Manager, or Apple-format
  bundle — see `docs/roadmap.md` for v0.2–v0.5.
