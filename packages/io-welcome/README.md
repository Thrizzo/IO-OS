# io-welcome

Tiny first-run greeting for IO Linux. Pure QML so we don't drag in
CMake / C++ / an RPM spec for a 100-line UI in v0.1.

## Files

| File                    | Installs to                                              |
|-------------------------|----------------------------------------------------------|
| `qml/Main.qml`          | `/usr/share/io-welcome/Main.qml`                         |
| `io-welcome-launcher`   | `/usr/bin/io-welcome-launcher` (mode 755)                |
| `io-welcome.desktop`    | `/etc/xdg/autostart/io-welcome.desktop`                  |

## How it runs

1. `io-welcome.desktop` triggers on Plasma session start
   (`OnlyShowIn=KDE`, `X-KDE-autostart-after=panel`).
2. `io-welcome-launcher` checks `~/.config/io-welcome/disabled`. If the
   file exists, it exits silently — the user opted out previously.
3. Otherwise it locates a Qt6 `qml` runtime on `PATH` (openSUSE ships
   it as `qml6` or `qml` from `qt6-declarative-tools`) and runs
   `Main.qml`.
4. `Main.qml` shows IO branding, bilingual intro, links to docs, a
   "don't show again" checkbox, and a language toggle.
5. On Close: the QML app exits with code `42` if the checkbox is set,
   `0` otherwise. The launcher persists the opt-out by touching the
   `disabled` file when it sees `42`.

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
