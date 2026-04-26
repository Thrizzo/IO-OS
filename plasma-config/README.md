# plasma-config/

Plasma configuration files shipped as `/etc/skel/.config/` so every new
user account on IO Linux gets the IO layout on first login. The files
under `skel/` get placed at the matching path under `/etc/skel/`.

## Inventory

| File                                              | Installs to                                 | What it controls                                                                                              |
|---------------------------------------------------|---------------------------------------------|---------------------------------------------------------------------------------------------------------------|
| `plasma-org.kde.plasma.desktop-appletsrc`         | `/etc/skel/.config/`                        | Bottom panel: "io" kickoff, spacer, pinned-app icontasks, spacer, system tray, 24h clock with `dd.MM.yyyy`. Folder-view desktop with the IO wallpaper. |
| `kdeglobals`                                      | `/etc/skel/.config/`                        | `ColorScheme=IO`, look-and-feel package, `SingleClick=false`, Breeze widget style, German short-date locale. |
| `kwinrc`                                          | `/etc/skel/.config/`                        | Window button placement Windows-style (close on right), click-to-focus, click-raise.                          |
| `dolphinrc`                                       | `/etc/skel/.config/`                        | Breadcrumb address bar, Places sidebar visible, double-click open (inherits from `kdeglobals`).               |
| `skel/Desktop/dieser-pc.desktop`                  | `/etc/skel/Desktop/`                        | "Dieser PC / This PC" desktop link to `file:///`.                                                              |
| `skel/Desktop/papierkorb.desktop`                 | `/etc/skel/Desktop/`                        | "Papierkorb / Trash" desktop link to `trash:/`.                                                                |

`xdg-user-dirs-update` translates `~/Desktop` to `~/Schreibtisch` on
first login when the locale is `de_DE.UTF-8`; the contents follow.

## Why ship these as files instead of a script

Plasma reads these on first login and writes back the same format. By
shipping the canonical file we get atomic, reviewable diffs and avoid
a fragile chain of `kwriteconfig6` calls. The cost: updating the layout
means booting a clean image, changing it via Plasma's GUI, and copying
the resulting file back here.

## Override hierarchy

User changes always win. Anything a user sets through System Settings
lands in `~/.config/` and shadows the `/etc/skel/` defaults. We never
touch `~/.config/` after first login.

## Status

`appletsrc` is hand-crafted and expected to need iteration on first
boot — the format is sensitive to applet ID numbering and Plasma 6
plugin name changes. If something breaks the layout, the safe
debugging move is: boot the image, configure Plasma manually via the
GUI, then `cp ~/.config/plasma-org.kde.plasma.desktop-appletsrc` back
into this directory and commit the result.
