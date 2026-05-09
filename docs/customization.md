# Customizing & forking IO Linux

This document is a recipe for forking IO Linux and rebranding it as a
different distribution — for a regional government, ministry, university,
or organization that wants its own variant without losing the upstream
update flow.

The whole project is layered so a fork only has to touch a few files.
Each section below maps directly to the layers in
[architecture.md](architecture.md).

## 1. Replace the branding bundle

Every visible asset lives under `branding/`. Drop in your replacements at
the same paths and rebuild:

| Asset                                 | Path                                                    |
|---------------------------------------|---------------------------------------------------------|
| Wallpaper (desktop, SDDM, Plymouth)   | `branding/wallpapers/io-default.svg`                    |
| Logo (raster sources auto-derived)    | `branding/icons/io-logo.svg`                            |
| Color scheme                          | `branding/colors/IO.colors`                             |
| Plymouth boot splash                  | `branding/plymouth/io/`                                 |
| SDDM login theme                      | `branding/sddm/io/`                                     |
| Plasma look-and-feel package          | `branding/plasma-look-and-feel/org.iolinux.desktop/`    |

The hex palette is duplicated in three places (Plasma color scheme, SDDM
`theme.conf`, Plymouth `io.script`). When you change a colour, update all
three — `branding/colors/IO.colors` is annotated with the canonical hexes.

## 2. Rename organization IDs

Search-and-replace these strings across the tree:

| From                          | To                                |
|-------------------------------|-----------------------------------|
| `org.iolinux.desktop`         | `org.<yourorg>.desktop`           |
| `IO Linux` / `IO`             | Your distribution name            |
| `io-welcome`                  | `<yourorg>-welcome` (optional)    |
| `io-logo.svg`                 | `<yourorg>-logo.svg`              |

The look-and-feel package directory under
`branding/plasma-look-and-feel/` must match its `metadata.json` `KPlugin.Id`.

## 3. Swap the Plasma layout

Panel, taskbar, and pinned-app defaults live in
`plasma-config/plasma-org.kde.plasma.desktop-appletsrc`. The current layout
is Windows-style (single bottom panel, app icons, system tray, clock).
Common alternatives:

- **Classic GNOME-like:** top bar with menu + clock, dock-style panel at
  bottom — replace the appletsrc with one exported from a Plasma session
  configured that way (`kwriteconfig6` or copy `~/.config/...`).
- **macOS-like:** top bar with global menu applet, Latte-style dock at
  bottom.

Window-management defaults (snap, electric borders, Alt+Tab style) live in
`plasma-config/kwinrc`; global hotkeys in `plasma-config/kglobalshortcutsrc`.

## 4. Default locale and keyboard

Locale is set in `kiwi/config.xml` (`<locale>` and `<keytable>` elements).
The default is `de_DE.UTF-8` with a German keyboard layout. Change both
together to keep installer and live session consistent.

User-visible strings in `packages/io-welcome/qml/Main.qml` are bilingual
(de/en). For additional languages see CONTRIBUTING's translation section.

## 5. Preinstalled Flatpaks

The default Flatpak picks (Brave, Thunderbird) are installed by the
`io-firstboot-flatpak.service` oneshot at first boot, not baked into
the ISO — keeps the image small. To change them:

- Edit the `ExecStart=` line in
  `branding/firstboot/io-firstboot-flatpak.service`.
- Update the corresponding pin in
  `plasma-config/plasma-org.kde.plasma.desktop-appletsrc`.
- Update the MIME defaults in `plasma-config/mimeapps.list`.
- Update `packages/io-welcome/qml/strings.js` `defaultApps`.

For an offline-first deployment, drop a
`/etc/flatpak/installations.d/local.conf` that points at a local mirror
and remove the network-online dependency from the firstboot service.

## 6. Windows-binary policy

Recipes for `.exe` / `.msi` apps live in
`packages/io-run/recipes/*.yaml`. Each recipe carries:

- `sha256` of the installer (lookup key)
- `arch` (`32` or `64`)
- `dll_overrides` (Wine-style override string)
- `network` (`true`/`false`, controls bwrap `--unshare-net`)
- `sandbox` (`strict` or `off`)

Forks add their own recipes under the same path; `io-run` discovers
them at runtime.

## 7. Re-publishing on your own OBS project

1. Create an OBS project (e.g. `home:<you>:<distro>`).
2. Set repository `repository.opensuse.org/Kalpa` as a path source.
3. Push your fork's tree using `osc co <project> <package>`,
   `osc add ./*`, `osc commit`.
4. In `.github/workflows/build.yml`, set the GitHub Actions repo variables
   `OBS_PROJECT` and `OBS_PACKAGE` to your project/package names, and the
   secrets `OBS_API_USER` / `OBS_API_PASS` to your OBS credentials.

## 8. License obligations

- Code: GPL-3.0-or-later — derivative works inherit.
- Branding (wallpapers, logos, colors): CC-BY-SA-4.0 unless otherwise
  marked. Forks must attribute the IO Linux contributors and re-license
  their derivatives under the same terms.
- Trademarks: "IO Linux" and the Io moon mark are not trademarked yet,
  but please don't ship a fork under the same name.

## Smoke-test your fork

Before publishing:

```sh
./build.sh
qemu-system-x86_64 -enable-kvm -m 4G -snapshot \
  -drive file=./out/*.iso,media=cdrom -boot d
```

Verify that login screen, desktop wallpaper, panel logo, and Plymouth
splash all show *your* branding and none of "IO".
