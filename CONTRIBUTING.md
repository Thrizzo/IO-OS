# Contributing to IO Linux

> Stub — to be expanded as the project opens up to outside contributors.

## Ground rules

- One logical change per commit. Use Conventional Commits prefixes
  (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `ci:`).
- Every customization that diverges from upstream openSUSE Kalpa must carry
  a one-line comment explaining *why*. "What" is documentation;
  "why" is what future maintainers actually need.
- Prefer upstream defaults. Every override is technical debt.
- German and English are both first-class. User-visible strings ship in
  both.

## Local development

See [README.md](README.md) for the build and QEMU-test loop.

## Pull-request checklist

Before opening a PR:

- [ ] `./build.sh` succeeds locally (or you've explained why it's not
      runnable in your environment).
- [ ] The resulting ISO boots in QEMU at least to the SDDM login screen.
- [ ] `git status` is clean — no staged copies under `kiwi/root/` other
      than its `.gitignore` and `README.md`.
- [ ] User-visible strings ship in *both* German and English.
- [ ] Every override of an upstream default carries a one-line comment
      explaining *why*.

## Translation workflow

User-facing UI is bilingual today (de/en) and v0.2+ will scale to more
languages via Qt Linguist `.ts` files.

- Welcome screen strings live inline in
  `packages/io-welcome/qml/Main.qml` via `window.t("de", "en")`.
  When adding a string, supply both forms.
- Login screen (SDDM) strings live in `branding/sddm/io/Main.qml`.
  Same `t()` pattern.
- Desktop file `Name=` and `Comment=` keys (e.g.
  `packages/io-welcome/io-welcome.desktop`) use freedesktop's
  locale-suffix convention: `Name[de]=…`, `Name[en]=…`.

When a third language lands we'll switch to `.ts` files and a
`lupdate`/`lrelease` step in `build.sh`. Translators don't need to wait
for that — adding a third locale via the inline pattern is fine for now;
we'll migrate once the file outgrows it.

## Reporting issues

Until we're in a public beta, open issues against this repository directly.

## Code of conduct

We follow the openSUSE Guiding Principles in spirit:
respectful, transparent, focused on the work.
