# IO Linux

> **Alpha — do not run on production systems.**
> **Alpha — nicht auf Produktivsystemen einsetzen.**

A sovereign European Linux distribution based on **openSUSE Kalpa**
(immutable KDE Plasma 6) with a Windows-familiar layout. Named after Io,
sister moon to Europa.

Eine souveräne europäische Linux-Distribution auf Basis von **openSUSE Kalpa**
(unveränderlich, KDE Plasma 6) mit einem für Windows-Anwender:innen
vertrauten Layout. Benannt nach Io, Schwestermond von Europa.

---

## English

### What is IO Linux?

IO Linux targets the German public sector, KRITIS operators, and
privacy-conscious European users currently running Windows. The pitch:
sovereignty without sacrificing usability.

- **Base:** openSUSE Kalpa (immutable, transactional updates)
- **Desktop:** KDE Plasma 6, configured to feel familiar to Windows users
- **Apps:** Flatpaks from Flathub (Brave, Thunderbird, LibreOffice, …)
- **Windows binaries:** sandboxed via `io-run` (Wine + bwrap, per-app prefix)
- **Security:** AppArmor + firewalld (deny-incoming) + DoT/DNSSEC by default
- **Languages:** German (default) and English, both first-class

### Project status

v0.1 alpha. The ISO boots and the desktop is themed; nothing else is
production-ready. The Windows compatibility layer, IO Store, VPN unifier,
and Apple-format bundle are planned for v0.2–v0.5 — see
[docs/roadmap.md](docs/roadmap.md).

### System requirements (build host)

| Resource     | Minimum             | Recommended           |
|--------------|---------------------|-----------------------|
| OS           | openSUSE Tumbleweed | openSUSE Tumbleweed   |
| Disk (free)  | 15 GB               | 30 GB                 |
| RAM          | 4 GB                | 8 GB                  |
| Build time   | 20–40 min           | 10–20 min on NVMe     |
| Network      | required            | required              |

`kiwi-ng` requires root for chroot/loopback mounts; `./build.sh` calls
`sudo` automatically when not run as root.

### Building the ISO

```sh
sudo zypper install kiwi-ng librsvg-tools
./build.sh
# Output: ./out/IO-Linux-<version>.x86_64.iso
#         ./out/SHA256SUMS
#         ./out/kiwi-build.log
```

### Troubleshooting

- **`no .iso produced`** — open `out/kiwi-build.log`; the last 50 lines
  almost always pinpoint a failed package install or repo fetch.
- **`No space left on device`** during build — kiwi stages into
  `/var/tmp` by default. Either free space there or set `TMPDIR` to a
  larger volume before running `./build.sh`.
- **`rsvg-convert: command not found`** — install `librsvg-tools`
  (the build will skip rasterization otherwise and Plymouth/legacy
  menus will fall back to placeholder icons).
- **First-boot "no qml runtime"** notification — the live image is
  missing `qt6-declarative-tools`; add it to `kiwi/config.xml`.

### Testing the ISO in QEMU

```sh
qemu-img create -f qcow2 io-test.qcow2 20G
qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -smp 2 \
  -snapshot \
  -drive file=./out/IO-Linux-*.iso,media=cdrom \
  -drive file=io-test.qcow2,if=virtio \
  -boot d
```

`-snapshot` discards writes to the qcow2 on shutdown, so each run starts
clean. Drop it once you're ready to install for real.

### Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

### License

GPL-3.0-or-later (proposed — see [LICENSE](LICENSE)). Branding assets
(wallpapers, logos) are released under CC-BY-SA-4.0 unless noted otherwise
inside `branding/`.

---

## Deutsch

### Was ist IO Linux?

IO Linux richtet sich an den deutschen öffentlichen Sektor,
KRITIS-Betreiber und datenschutzbewusste europäische Anwender:innen, die
heute Windows einsetzen. Das Versprechen: Souveränität ohne Verzicht auf
Bedienbarkeit.

- **Basis:** openSUSE Kalpa (unveränderlich, transaktionale Updates)
- **Desktop:** KDE Plasma 6, für Windows-Anwender:innen angepasst
- **Anwendungen:** Flatpaks aus Flathub (Brave, Thunderbird, LibreOffice, …)
- **Windows-Programme:** über `io-run` sandboxed (Wine + bwrap)
- **Sicherheit:** AppArmor + firewalld + DoT/DNSSEC standardmäßig
- **Sprachen:** Deutsch (Standard) und Englisch, gleichrangig

### Projektstatus

v0.1 Alpha. Das ISO startet und das Desktop ist gebrandet; alles weitere
ist nicht produktionsreif. Windows-Kompatibilitätsschicht, IO Store,
VPN-Vereinheitlichung und Apple-Formate sind für v0.2–v0.5 geplant —
siehe [docs/roadmap.md](docs/roadmap.md).

### Systemvoraussetzungen (Build-Host)

| Ressource         | Minimum             | Empfohlen             |
|-------------------|---------------------|-----------------------|
| Betriebssystem    | openSUSE Tumbleweed | openSUSE Tumbleweed   |
| Freier Speicher   | 15 GB               | 30 GB                 |
| Arbeitsspeicher   | 4 GB                | 8 GB                  |
| Bauzeit           | 20–40 min           | 10–20 min auf NVMe    |
| Netzwerk          | erforderlich        | erforderlich          |

### ISO bauen

```sh
sudo zypper install kiwi-ng librsvg-tools
./build.sh
# Ergebnis: ./out/IO-Linux-<version>.x86_64.iso
#           ./out/SHA256SUMS
#           ./out/kiwi-build.log
```

### Fehlersuche

- **`no .iso produced`** → `out/kiwi-build.log` öffnen.
- **`No space left on device`** → `TMPDIR` auf ein größeres Volume setzen.
- **`rsvg-convert: command not found`** → `librsvg-tools` installieren.

### ISO in QEMU testen

```sh
qemu-img create -f qcow2 io-test.qcow2 20G
qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -smp 2 \
  -snapshot \
  -drive file=./out/IO-Linux-*.iso,media=cdrom \
  -drive file=io-test.qcow2,if=virtio \
  -boot d
```

`-snapshot` verwirft Schreibzugriffe nach dem Beenden — nützlich beim Testen.

### Mitwirken

Siehe [CONTRIBUTING.md](CONTRIBUTING.md).

### Lizenz

GPL-3.0-or-later (vorgeschlagen — siehe [LICENSE](LICENSE)).
Branding-Assets (Hintergründe, Logos) stehen unter CC-BY-SA-4.0, sofern
in `branding/` nicht anders ausgewiesen.
