# io-run

IO Linux's dispatcher for Windows binaries. The package's job is to
make double-clicking a `.exe` feel as close to native as we can without
shipping kernel anti-cheat workarounds (which we will never).

## Goals

- **Cold start under one second.** A pre-warmed Wine prefix template is
  cloned via `cp --reflink=auto` (CoW on btrfs) instead of running
  `wineboot` per-app. First launch goes from ~30s to <1s.
- **Sandboxed by default.** Each app gets its own prefix; `bwrap`
  hides the user's real `$HOME` and makes `/etc` read-only. Network
  access is opt-in per recipe.
- **Honest trust prompt.** On the first run of an unknown binary the
  user sees a SmartScreen-style "this is unsigned, are you sure?"
  dialog. Trusted hashes persist in `~/.config/io-run/trusted.json`.
- **One recipe per known app.** YAML files in
  `/usr/share/io-run/recipes/` carry per-app DLL overrides, sandbox
  policy, and network permission. Forks add their own without rebuilding.

## Files

| File                                     | Installs to                                              |
|------------------------------------------|----------------------------------------------------------|
| `io-run`                                 | `/usr/bin/io-run` (mode 755)                             |
| `io-run.desktop`                         | `/usr/share/applications/io-run.desktop`                 |
| `io-run-prepare-templates`               | `/usr/bin/io-run-prepare-templates` (mode 755)           |
| `io-run-prepare-templates.service`       | `/usr/lib/systemd/user/io-run-prepare-templates.service` |
| `recipes/*.yaml`                         | `/usr/share/io-run/recipes/`                             |

## How it runs

1. User double-clicks an `.exe`. Plasma's MIME table routes
   `application/x-msdownload` to `io-run.desktop`, which runs
   `io-run /path/to/foo.exe`.
2. `io-run` reads the PE header, picks 32 vs 64-bit, computes the
   sha256 and looks up a recipe. No recipe + not in trust DB ⇒
   SmartScreen prompt.
3. Per-app prefix is materialised at
   `~/.local/share/io-run/prefixes/<app_id>/` by reflinking the
   warmed template from `~/.local/share/io-run/templates/win64`.
4. `bwrap` boxes Wine into the prefix; only the .exe and the prefix
   are read/write-visible, everything else is `--ro-bind` or tmpfs.
5. Recipes can opt out of the sandbox (`sandbox: off`) or open the
   network (`network: true`) when an app genuinely needs it.

## Performance levers

- **Cold start** — pre-warmed templates are cloned, not built per-app.
- **Sync primitives** — `WINEESYNC=1`, `WINEFSYNC=1`, `WINENTSYNC=1`
  set in env. NTSYNC is detected at runtime via `/dev/ntsync`
  (Linux 6.10+).
- **DXVK + VKD3D-Proton** — pre-installed into the template by
  `io-run-prepare-templates` if `setup_dxvk` / `setup_vkd3d_proton`
  are on PATH. Games get DirectX→Vulkan translation without
  per-prefix install.
- **FD limits** — `/etc/security/limits.d/99-io-wine.conf` bumps the
  open-file ceiling to 524288 because esync needs the headroom.

## Honest limits

- **Anti-cheat games** (Vanguard, BattlEye in some kernel modes) do
  not work on any Linux distribution. We do not pretend otherwise.
- **DirectX 12 games** run via VKD3D-Proton at 85–95% of native; some
  edge cases regress more.
- **Hardware-bound .NET applications** that pin to a specific
  Windows build often misbehave. Recipes can pin a Mono/Wine version
  but the maintenance burden is real.
- **Apps that install a kernel driver** (some VPN clients, some
  hardware tools) cannot work at all; surface this clearly when we
  detect a driver-install MSI.

## Future evolution

- Move from sha256 lookup to **signed-recipe** lookup (so a community
  can publish recipes with provenance).
- Hook into a Plasma "running Windows app" indicator with FPS/RAM.
- Write the YAML parser properly (the current `parse_simple_yaml` is
  intentionally minimal — works for flat key:value, no nesting).
- ARM64 PE support via Hangover, gated on v0.3 ARM target.
