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

| Layer            | Default                                           | Where                                                  |
|------------------|---------------------------------------------------|--------------------------------------------------------|
| Network DNS      | DoT to Quad9, fallback Cloudflare, DNSSEC on      | `/etc/systemd/resolved.conf.d/io-doh.conf`             |
| Firewall         | firewalld `public` zone, target=DROP, no inbound  | `/etc/firewalld/zones/public.xml`                      |
| App sandboxing   | Flatpak (Chromium sandbox + bubblewrap)           | every preinstalled GUI app is a Flatpak                |
| Windows binaries | per-app Wine prefix in bwrap, `--unshare-net` opt | `packages/io-run/`                                     |
| MAC              | AppArmor profiles (complain mode)                 | `branding/security/apparmor/`                          |
| Updates          | openSUSE Kalpa transactional, btrfs snapshots     | `kiwi/config.xml` base                                 |
| Telemetry        | none — IO collects nothing                        | architectural; verifiable                              |
| Browser          | Brave with managed policy: P3A off, no Sync nag   | `branding/brave-policies/io-defaults.json`             |
| Display server   | Wayland-only Plasma session                       | `kiwi/config.xml` (no `xorg-x11-server-session`)       |

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

Profiles ship in `complain` mode for v0.1. That means they log a
violation to journal but do not block the action. We use the first
release as audit data and switch to `enforce` in v0.2 once we have a
real signal of false-positive rate.

In-tree profiles:

- `usr.bin.io-run` — covers io-run + the Wine subprofile.
- `com.brave.Browser` — second perimeter on Brave.

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
| TPM2-bound LUKS auto-unlock                      | v0.2 — Calamares preset + printed recovery key  |
| AppArmor `enforce` mode                          | v0.2 — switch after first round of audit data   |
| systemd-homed encrypted home                     | v0.3 — needs Calamares + portable-home story    |
| FIDO2 / smartcard SDDM login                     | v0.3 — pam-u2f + pam-pkcs11                     |
| Reproducible-build attestation                   | v0.3 — wire flags through kiwi + OBS            |
| BSI Grundschutz preset toggle                    | v0.4 — IO Settings switch flips audit + policy  |

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
