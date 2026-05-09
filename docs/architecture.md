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

## Why these choices (and not the alternatives)

### Why Plasma, not GNOME?

GNOME's design language deliberately diverges from Windows: hot corners,
no taskbar by default, no minimise/maximise buttons until you install an
extension. Plasma 6 ships with a Windows-shaped panel, a Start-menu
launcher, and standard window controls — much less work to make it feel
familiar to migrants from Windows. It also exposes far more configuration
through declarative files (`kwinrc`, `kglobalshortcutsrc`,
`plasma-org.kde.plasma.desktop-appletsrc`), which is what lets us ship
opinionated defaults without forking the desktop.

### Why Kalpa, not plain Tumbleweed or Leap?

Kalpa is openSUSE's immutable Plasma desktop — it gives us
`transactional-update`, `btrfs` snapshots, and Flatpak-by-default for free.
A KRITIS-targeted distribution needs atomic, rollbackable updates; building
that on top of Tumbleweed manually would mean re-implementing what Kalpa
already provides. Leap is too conservative for a desktop that wants
current Plasma 6.

### Why Kiwi-NG, not osbuild / mkosi / Image Builder?

Kiwi-NG is the canonical openSUSE image builder — every official openSUSE
ISO is built with it. Using anything else would force us to maintain a
package list outside of OBS's view and lose the nightly OBS rebuild story.

### Why Flatpak, not Snap or AppImage?

Snap is single-vendor (Canonical) and its server is proprietary. AppImage
has no sandboxing or update story. Flatpak is the cross-distribution
standard, ships with Kalpa, and Flathub already carries the apps our
target users need (LibreOffice, Firefox, Thunderbird).

### Why no custom kernel?

A custom kernel is a permanent maintenance tax for marginal gain. We
accept openSUSE's kernel as-is; if a hardware-vendor partnership later
demands an out-of-tree driver, we'll ship it as a DKMS module rather than
a kernel fork.
