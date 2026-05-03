# io-welcome

First-run OOBE wizard for IO Linux. Pure QML so we don't drag in
CMake / C++ / an RPM spec for a 6-page UI in v0.1.

## Files

| File                    | Installs to                                              |
|-------------------------|----------------------------------------------------------|
| `qml/Main.qml`          | `/usr/share/io-welcome/Main.qml`                         |
| `qml/strings.js`        | `/usr/share/io-welcome/strings.js`                       |
| `i18n/*.qm` (optional)  | `/usr/share/io-welcome/i18n/`                            |
| `io-welcome-launcher`   | `/usr/bin/io-welcome-launcher` (mode 755)                |
| `io-welcome.desktop`    | `/etc/xdg/autostart/io-welcome.desktop`                  |

## How it runs

1. `io-welcome.desktop` triggers on Plasma session start
   (`OnlyShowIn=KDE`, `X-KDE-autostart-after=panel`).
2. `io-welcome-launcher` checks `~/.config/io-welcome/disabled`. If the
   file exists, it exits silently — the user opted out previously.
3. Otherwise it locates a Qt6 `qml` runtime on `PATH` (openSUSE ships
   it as `qml6` or `qml` from `qt6-declarative-tools`) and runs
   `Main.qml`. If the runtime is missing, the launcher posts a
   passive `kdialog` notification so the user notices.
4. `Main.qml` is a six-step wizard: welcome, network, theme,
   privacy, default apps, done. Strings live in `strings.js` so the
   QML stays focused on layout.
5. On Finish: the QML app exits with code `42` if the
   "don't show again" checkbox is ticked on the final page, `0`
   otherwise. The launcher persists the opt-out by touching the
   `disabled` file when it sees `42`.

## Translations

Two paths exist in parallel:

- **`strings.js`** — single source of truth used by the QML at runtime.
  Adding a locale is "drop a key into the `strings` object." No build
  toolchain required.
- **`i18n/*.ts`** — Qt Linguist files for translators who prefer that
  workflow. `build.sh` runs `lrelease-qt6` on these when the toolchain
  is available, producing `*.qm` next to the source. The wizard does
  not currently load `.qm` files (the JS path is authoritative); the
  `.ts` files are kept as a migration target so we can switch when we
  outgrow the inline approach.

## Dependencies (added to `kiwi/config.xml`)

- `qt6-declarative` (the QML engine)
- `qt6-declarative-tools` (the `qml` runtime binary)
- `qt6-quickcontrols` (the `QtQuick.Controls` import)

## Future evolution

Once io-welcome needs anything beyond QML — system info from
DBus, disk-usage progress, network status, etc. — promote it to a
proper Qt6 C++ application with CMakeLists.txt and an RPM spec, and
build it through OBS like any other package. Keep the launcher
contract (`disabled` file, exit-code-42 opt-out) so the new binary is
a drop-in replacement.
