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
- **Apps:** Flatpaks from Flathub (LibreOffice, Firefox, Thunderbird, …)
- **Languages:** German (default) and English, both first-class

### Project status

v0.1 alpha. The ISO boots and the desktop is themed; nothing else is
production-ready. The Windows compatibility layer, IO Store, VPN unifier,
and Apple-format bundle are planned for v0.2–v0.5 — see
[docs/roadmap.md](docs/roadmap.md).

### Building the ISO

Requires an openSUSE Tumbleweed workstation with `kiwi-ng` installed.

```sh
./build.sh
# Output: ./out/IO-Linux-<version>.x86_64.iso
```

### Testing the ISO in QEMU

```sh
qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -smp 2 \
  -drive file=./out/IO-Linux-*.iso,media=cdrom \
  -drive file=io-test.qcow2,if=virtio \
  -boot d
```

(Create `io-test.qcow2` once with `qemu-img create -f qcow2 io-test.qcow2 20G`.)

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
- **Anwendungen:** Flatpaks aus Flathub (LibreOffice, Firefox, Thunderbird, …)
- **Sprachen:** Deutsch (Standard) und Englisch, gleichrangig

### Projektstatus

v0.1 Alpha. Das ISO startet und das Desktop ist gebrandet; alles weitere
ist nicht produktionsreif. Windows-Kompatibilitätsschicht, IO Store,
VPN-Vereinheitlichung und Apple-Formate sind für v0.2–v0.5 geplant —
siehe [docs/roadmap.md](docs/roadmap.md).

### ISO bauen

Voraussetzung: openSUSE Tumbleweed mit installiertem `kiwi-ng`.

```sh
./build.sh
# Ergebnis: ./out/IO-Linux-<version>.x86_64.iso
```

### ISO in QEMU testen

```sh
qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -smp 2 \
  -drive file=./out/IO-Linux-*.iso,media=cdrom \
  -drive file=io-test.qcow2,if=virtio \
  -boot d
```

(`io-test.qcow2` einmalig erzeugen mit
`qemu-img create -f qcow2 io-test.qcow2 20G`.)

### Mitwirken

Siehe [CONTRIBUTING.md](CONTRIBUTING.md).

### Lizenz

GPL-3.0-or-later (vorgeschlagen — siehe [LICENSE](LICENSE)).
Branding-Assets (Hintergründe, Logos) stehen unter CC-BY-SA-4.0, sofern
in `branding/` nicht anders ausgewiesen.
