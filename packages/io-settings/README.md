# io-settings

Win11-Settings-shaped front-end over the Plasma KCM (System Settings)
modules. Pure QML — no CMake / C++ / RPM, same v0.1 philosophy as
io-welcome.

## What it does

- Two-pane layout: left = category list, right = grid of module tiles.
- Eight Win11-equivalent categories: System, Devices, Network &
  Internet, Personalization, Apps, Accounts, Privacy & Security,
  Update & Recovery.
- Search box filters tiles within the active category.
- Clicking a tile opens the underlying KCM via `kcm://<name>` —
  Plasma resolves that through `systemsettings` / `kcmshell6`.
- Bilingual (de/en) using the same locale detection as the rest of IO.

## Files

| File                     | Installs to                                      |
|--------------------------|--------------------------------------------------|
| `io-settings`            | `/usr/bin/io-settings` (mode 755)                |
| `io-settings.desktop`    | `/usr/share/applications/io-settings.desktop`    |
| `qml/Main.qml`           | `/usr/share/io-settings/Main.qml`                |
| `qml/categories.js`      | `/usr/share/io-settings/categories.js`           |

## Adding or moving a tile

Edit `qml/categories.js`. Each module entry is:

```js
{ kcm: "kcm_kscreen", iconHint: "video-display",
  de: "Anzeige", en: "Display" }
```

The `kcm` value is what `kcmshell6` accepts as its argument. The
`iconHint` is a freedesktop icon name (Breeze ships them all). The
`de` and `en` strings are what the tile shows; the active locale
picks one.

## Failure modes

- **No qml runtime.** The launcher falls back to plain `systemsettings`
  and posts a passive `kdialog` notification so the user knows.
- **KCM doesn't exist.** The KCM URL handler shows its own error
  dialog ("module not found"). We don't try to second-guess.
- **Wrong KCM name.** Edit `categories.js`. The `kcm` field is the
  source of truth.

## Why not just use System Settings?

We tested it on Windows migrants: they bounce off the "all 60 modules
in a tree" view. The same modules, grouped under eight Win11-shaped
buckets, lands much better. This wrapper costs ~200 lines of QML.
