# io-welcome

Tiny Qt/QML application that launches on first login, shows IO branding,
briefly explains the project in German and English, links to documentation,
and offers a "don't show this again" checkbox.

## Stub status

Implementation lands after the base ISO boots successfully. Planned layout:

```
io-welcome/
├── CMakeLists.txt
├── io-welcome.desktop          # XDG autostart entry, dropped into /etc/xdg/autostart/
├── src/
│   └── main.cpp                # QApplication + QQmlApplicationEngine boilerplate
├── qml/
│   ├── Main.qml                # window shell, language toggle
│   ├── WelcomePage.qml         # IO logo, intro text, links
│   └── i18n/
│       ├── de.ts
│       └── en.ts
└── packaging/
    └── io-welcome.spec         # RPM spec, consumed by OBS
```

The "don't show this again" toggle writes a flag to
`~/.config/io-welcome/state.conf`; the autostart `.desktop` file uses
`OnlyShowIn=KDE` plus a check of that flag via `TryExec` or a wrapper.
