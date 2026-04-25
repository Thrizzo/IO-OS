# plasma-config/

Plasma configuration files shipped as `/etc/skel/.config/` so that every
new user account on IO Linux gets the IO layout on first login.

| File                                          | What it controls                                                                                  |
|-----------------------------------------------|---------------------------------------------------------------------------------------------------|
| `plasma-org.kde.plasma.desktop-appletsrc`     | Panel layout: bottom panel, "io" launcher, pinned apps, system tray contents and order.           |
| `kdeglobals`                                  | Global UX defaults: color scheme, double-click vs single-click, 24h clock, `dd.MM.yyyy` dates.    |
| `kwinrc`                                      | Window manager: button placement, focus model, compositor settings.                               |

## Why ship these as files instead of a script?

Plasma reads these on first login and writes back the same format. By
shipping the canonical file we get atomic, reviewable diffs and avoid a
fragile chain of `kwriteconfig` calls. The cost is that updating the layout
means booting a clean image, changing it via the GUI, and copying the
resulting file back here — see `docs/customization.md` for the workflow.

## Override hierarchy

User changes always win: anything a user sets through System Settings
lands in `~/.config/` and shadows the `/etc/skel/` defaults. We never
touch `~/.config/` after first login.
