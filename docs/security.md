# IO Linux — Security model

The pitch is sovereignty + privacy + resilience for the public sector.
This document is what we currently ship; **what we do not ship yet** is
called out per section so the gap to "production-ready" is honest.

## Threat model

We assume:

- The user is non-technical and cannot be expected to harden their own
  system. Defaults must be safe.
- Network attackers are routine; nation-state attackers are rare but
  not negligible (KRITIS).
- Physical loss of the laptop is plausible (theft, lost-on-a-train).
- Application code is hostile-by-default — every Flatpak, every Wine
  app, every browser tab gets sandboxed even when we trust it today.

We do **not** try to defend against:

- A user who explicitly disables every protection ("I deactivated
  AppArmor and pasted curl|sh into the terminal as root").
- Attacks on hardware that physically modifies the firmware before
  first boot (Secure Boot with our keys would help, see Roadmap).

## What we ship in v0.1

| Layer              | Default                                           | Where                                                  |
|--------------------|---------------------------------------------------|--------------------------------------------------------|
| Network DNS        | DoT to Quad9, fallback Cloudflare, DNSSEC on      | `/etc/systemd/resolved.conf.d/io-doh.conf`             |
| Firewall (inbound) | firewalld `public` zone, target=DROP, no inbound  | `/etc/firewalld/zones/public.xml`                      |
| Firewall (outbound)| OpenSnitch deny-by-default + interactive prompt   | `/etc/opensnitchd/`                                    |
| App sandboxing     | Flatpak (Chromium sandbox + bubblewrap)           | every preinstalled GUI app is a Flatpak                |
| Windows binaries   | per-app Wine prefix in bwrap, `--unshare-net` opt | `packages/io-run/`                                     |
| MAC                | AppArmor profiles (complain mode by default)      | `branding/security/apparmor/`                          |
| Disk encryption    | LUKS2 forced by Calamares; TPM2-bound on PCR 0+7+14 | `branding/calamares/modules/`                        |
| Updates            | openSUSE Kalpa transactional, btrfs snapshots     | `kiwi/config.xml` base                                 |
| Telemetry          | none — IO collects nothing                        | architectural; verifiable                              |
| Browser            | Brave with managed policy: P3A off, no Sync nag   | `branding/brave-policies/io-defaults.json`             |
| Productivity suite | Proton (Mail, Pass, VPN, Calendar, Drive)         | `branding/firstboot/io-firstboot-flatpak.service`      |
| Display server     | Wayland-only Plasma session                       | `kiwi/config.xml` (no `xorg-x11-server-session`)       |

## Productivity suite — Proton

IO ships the Proton suite as the default productivity stack. Rationale:

- **Swiss jurisdiction.** Proton is headquartered in Switzerland and
  governed by Swiss data-protection law, which is structurally outside
  the US CLOUD Act and the UK Investigatory Powers Act.
- **End-to-end encryption** for mail, calendar, drive, password vault.
  We do not have to trust the provider — the math does the work.
- **Open-source clients.** Every Proton Linux client is GPL/MIT, so
  we can audit and ship them via Flathub without supply-chain hand-waving.
- **No US-style ad business model.** Proton's revenue is subscriptions;
  the business does not benefit from logging or selling user behaviour.

| Component         | App                  | Delivery                                |
|-------------------|----------------------|-----------------------------------------|
| Mail              | Proton Mail desktop  | Flathub `me.proton.Mail`                |
| Password manager  | Proton Pass desktop  | Flathub `me.proton.Pass`                |
| VPN               | Proton VPN GUI       | Flathub `com.protonvpn.www`             |
| Calendar          | Proton Calendar      | Brave PWA `io-proton-calendar.desktop`  |
| Cloud storage     | Proton Drive         | Brave PWA `io-proton-drive.desktop`     |

Calendar and Drive don't have native Linux apps yet; we ship Brave
`--app=` web shortcuts and replace them with native binaries the day
Proton ships them. The PWAs honour the Brave AppArmor profile so the
sandbox story stays consistent.

**Free tier is enough.** IO never gates anything behind a Proton
subscription. Users without an account see the sign-in screen on first
launch and can ignore it; the OS works without Proton.

**Swapping out Proton.** A fork that prefers Tutanota / Posteo /
Nextcloud edits the firstboot service, mimeapps.list, the taskbar pin
list, and `packages/io-welcome/qml/strings.js`. See
`docs/customization.md` section 5.

## DNS — DoT + DNSSEC

`systemd-resolved` is configured to use DNS-over-TLS for queries.
DoT is what resolved actually speaks; the privacy guarantee — encrypted
recursion to a no-log resolver — is the same as DoH. We pick Quad9
primary (audited no-log + malware blocklist) and Cloudflare fallback.
DNSSEC is set to `allow-downgrade` so a misconfigured upstream doesn't
brick name resolution; production deployments should flip this to
`yes`.

## Firewall

The `public` zone defaults to `DROP` (no useful info to scanners). No
inbound services are opened by default — not even SSH. Outbound
traffic is unrestricted; this is a desktop, not a server.

NetworkManager assigns a zone per profile. Trusted home/office
networks should use the `home` zone (LAN discovery: mDNS, SSDP).

## Windows binary sandbox

Every `.exe` runs in its own Wine prefix at
`~/.local/share/io-run/prefixes/<app>/`, mounted as the only
read-write path inside `bwrap`. The user's real `$HOME`, SSH keys,
GPG keys, and password manager state are invisible to the binary.

Network is opt-in per recipe. A binary that doesn't ask for network
in its recipe is dispatched with `bwrap --unshare-net` — even if it
calls `connect()`, the kernel returns `ENETUNREACH`.

## AppArmor

Profiles ship in `complain` mode by default for v0.1: they log
violations to journal but don't block the action. Builds run with
`IO_APPARMOR_ENFORCE=1 ./build.sh` flip every profile to enforce mode
at install time (the build sed-edits `flags=(complain)` to `flags=()`
in each profile during the overlay step). KRITIS deployments should
flip the switch; everyone else gets a fortnight of audit data first.

In-tree profiles:

- `usr.bin.io-run` — covers io-run + the Wine subprofile.
- `com.brave.Browser` — second perimeter on Brave.

## Outbound firewall — OpenSnitch

OpenSnitch is a deny-by-default, interactive outbound firewall. The
daemon (`opensnitchd`) runs as root; the GUI runs per-user. Default
config:

- `DefaultAction: deny` — anything not on the allow-list hits a popup.
- `ProcMonitorMethod: ebpf` — kernel-side process tracking, harder to
  bypass than ptrace.
- `Firewall: nftables` — matches the rest of the IO firewall stack.

Baseline rules ship in `/etc/opensnitchd/rules/`:

- `000-allow-system.json` — systemd-resolved, NetworkManager, Flatpak,
  zypper, transactional-update. Otherwise first boot is unusable.
- `010-allow-default-apps.json` — Brave, Proton Mail/Pass/VPN,
  Thunderbird. Removing this file restores deny-by-default for those
  Flatpaks too.

Anything else gets a "this app wants to connect to X, allow?" prompt
with options: once, for a session, always, deny, deny always.

## Disk encryption — LUKS2 + TPM2

The Calamares installer (`branding/calamares/`) forces LUKS2 partition
encryption — no opt-out in the guided flow. The user types a
passphrase during install; that passphrase doubles as the recovery
unlock key.

After bootloader install, the `shellprocess@io-tpm2-enroll` step
calls `systemd-cryptenroll --tpm2-pcrs=0+7+14` on the LUKS volume.
PCRs cover:

- **0** — firmware code measurement (catches firmware tampering)
- **7** — Secure Boot signature DB (only IO-signed kernels unlock)
- **14** — boot-loader configuration (catches `grub.cfg` edits)

If any of those measurements change between boots, the TPM auto-unlock
fails and the system prompts for the passphrase. The passphrase remains
valid; only the convenience auto-unlock breaks.

Users who opt out (a hidden flag in Calamares users page) get a normal
LUKS2 system with passphrase-only unlock.

## Brave policy

Brave is a Chromium fork that already does a lot of the work
(Shields = ad/tracker block by default, no telemetry of the
Chrome variety). Our managed policy locks the bits we don't want
users to flip accidentally:

- `BraveStatsPingEnabled=false` — no ping-home stats.
- `BraveP3AEnabled=false` — no anonymised usage telemetry.
- `MetricsReportingEnabled=false` — Chrome metrics off.
- `BraveSyncDisabled=true` — no cloud sync nag.
- `BraveWalletDisabled=true` — wallet UI off (we're not a crypto distro).
- `DefaultSearchProvider*` — Brave Search.
- `BackgroundModeEnabled=false` — Brave doesn't keep running after
  the last window closes.

Users can override anything in `chrome://policy/` if they need to.
Managed != mandatory (we use top-level keys, not `Recommended`).

## What's not yet in v0.1 — see Roadmap

| Gap                                              | Plan                                            |
|--------------------------------------------------|-------------------------------------------------|
| Secure Boot with IO-controlled keys              | v0.2 — sign kernel + initrd + shim, MOK-enrol   |
| systemd-homed encrypted home                     | v0.3 — needs Calamares + portable-home story    |
| FIDO2 / smartcard SDDM login                     | v0.3 — pam-u2f + pam-pkcs11                     |
| Reproducible-build attestation                   | v0.3 — wire flags through kiwi + OBS            |
| BSI Grundschutz preset toggle                    | v0.4 — IO Settings switch flips audit + policy  |

(TPM2-bound LUKS and AppArmor enforce mode moved up to v0.1; the
preset + `IO_APPARMOR_ENFORCE=1` build flag ship in this release.)

## How to verify (any user)

The intent is that everything in this document is **observable** on a
running system, not just promised in this README. Quick checks:

```sh
# DNS encryption + DNSSEC
resolvectl status | grep -E '(DNS Servers|DNS over TLS|DNSSEC)'

# Firewall posture
firewall-cmd --get-default-zone
firewall-cmd --zone=public --list-all

# AppArmor profiles
sudo aa-status

# Telemetry: there is no telemetry daemon to check, but you can tcpdump
# for outbound traffic from a freshly booted system; nothing IO-owned
# should appear before you open an application.
```

If any of those checks return something different from what this doc
claims — open an issue. That's a bug, not a feature.
