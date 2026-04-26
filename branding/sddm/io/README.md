# SDDM: IO login theme

Files:

| File              | Purpose                                                       |
|-------------------|---------------------------------------------------------------|
| `metadata.desktop`| Theme manifest read by SDDM.                                  |
| `theme.conf`      | Theme-tunable config exposed to `Main.qml` as `config.*`.     |
| `Main.qml`        | Greeter UI: backdrop, user dropdown, password, session, language toggle, login button. |
| `background.svg`  | Wallpaper. **Symlink or copy of `branding/wallpapers/io-default.svg` at install time.** |

## Install path inside the image

```
/usr/share/sddm/themes/io/
├── metadata.desktop
├── theme.conf
├── Main.qml
└── background.svg
```

Activate via `/etc/sddm.conf.d/20-io-theme.conf`:

```ini
[Theme]
Current=io
```

## Status

Alpha. The QML is structurally correct against the Plasma 6 / SDDM 0.21
API but **not yet tested on a real greeter session**. First boot will
likely surface layout/sizing issues; iterate from there.

## Known TODOs

- Wire the language toggle to actually swap the greeter's locale
  (currently cosmetic).
- Replace `Layout.alignment: Qt.AlignHCenter` shortcuts with a proper
  centred grid once the layout stabilizes.
- Add a `preview.png` referenced by `metadata.desktop`.
