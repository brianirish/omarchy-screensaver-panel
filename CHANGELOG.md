# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-11-08

Omarchy 4.5 replaced the terminal screensaver with the native
`omarchy-screensaver` overlay and removed the `bin/omarchy-screensaver` script
that 1.x overrode, so effect pinning stopped working and the daily sync failed
on every run since 2026-10-28.

### Changed

- Effect pinning now works through `extras/omarchy-launch-screensaver`, a thin
  wrapper installed to `/usr/local/bin` that hands pinned effects to Omarchy's
  own launcher as `--include-effects`. No PATH changes are needed: Omarchy 4.5
  no longer puts its bin directory ahead of `/usr/local/bin`. Pins apply to the
  next screensaver without a relog, and a pin the installed screensaver doesn't
  know is skipped instead of keeping it from starting.
- The daily `sync-upstream` workflow follows the effect list of the `ttfx`
  that the `omarchy-screensaver` package bundles (its PKGBUILD's version, then
  the ttfx tag in its `Cargo.toml`), and watches Omarchy's
  `omarchy-launch-screensaver`. Any change to the launcher, its removal
  included, opens an issue, as does upstream moving something the sync reads;
  one half failing no longer stops the other, and nothing crashes the job.
  `scripts/sync-upstream --accept-launcher` records a reviewed launcher commit.
- `scripts/check` runs new tests for the wrapper (`scripts/test-launcher`) and
  the sync (`scripts/test-sync`).

### Removed

- Support for Omarchy 3.x; stay on 1.0.3 there.
- `extras/omarchy-screensaver`, its `.stock` merge base, and the
  `hyprland.lua` PATH block 1.x asked for. Upgrading:
  `sudo rm -f /usr/local/bin/omarchy-screensaver`, drop the PATH block, and
  install the wrapper as the README shows.

## [1.0.3] - 2026-10-25

### Changed

- `extras/omarchy-screensaver`: re-synced with the stock Omarchy script (https://github.com/basecamp/omarchy/commit/7aae3f54eed03fe422cb838b4aa45a9a7d8bf2c5)

## [1.0.2] - 2026-09-10

### Changed

- README links the plugin's listing on the
  [Omarchy Plugin Marketplace](https://omarchyplugins.com/plugin.html?id=brianirish.screensaver)
  and explains how the verified marketplace snapshot relates to what
  `omarchy plugin add` installs.
- README notes that the project is made in Canada.

## [1.0.1] - 2026-09-06

### Added

- `scripts/check` runs every CI check locally: shell syntax and ShellCheck,
  Omarchy's own `omarchy-plugin-validate`, its QML `textFormat` scanner (both
  vendored verbatim under `scripts/vendor/`), the effect-list consistency
  check, and YAML validation.
- A daily `sync-upstream` workflow re-syncs `extras/omarchy-screensaver` with
  Omarchy's stock script (three-way merge against
  `extras/omarchy-screensaver.stock`) and the effect picker with the `ttfx`
  version Omarchy ships, then commits and publishes a release. A merge
  conflict in the override opens an issue instead. `upstream.json` records
  what was last synced.

### Changed

- The override's effect-name allowlist accepts digits and dashes
  (`^[a-z][a-z0-9-]*$`) so a future hyphenated `ttfx` effect can be pinned. A
  leading dash is still rejected, so config values still cannot become flags.

### Security

- Every `Text` element in `Panel.qml` declares `textFormat: Text.PlainText`,
  matching the hardening Omarchy applied across its shell: Qt's default
  `AutoText` promotes a string containing markup to rich text, and rich text
  fetches `<img src="http://...">`. Nothing the panel renders comes from
  outside the shell today; this keeps it that way and CI now enforces it.

## [1.0.0] - 2026-08-26

### Added

- Screensaver settings panel as an Omarchy shell bar-widget plugin:
  - Enable/disable toggle (panel row, plus right-click on the bar icon)
  - Idle timing sliders for screensaver and lock delay with snap-to presets
    and tick marks, written to `shell.json` and applied instantly
  - Searchable effect picker over all 37 `ttfx` effects with Select all /
    Clear, pinning a subset for the random rotation
  - Artwork controls (edit text, convert from image, reset) wrapping
    `omarchy branding screensaver`
  - Preview button
- `extras/omarchy-screensaver`: optional `/usr/local/bin` override of the
  stock launcher script that honors pinned effects via `--include-effects`,
  with allowlist filtering of effect names read from config

[2.0.0]: https://github.com/brianirish/omarchy-screensaver-panel/releases/tag/v2.0.0
[1.0.3]: https://github.com/brianirish/omarchy-screensaver-panel/releases/tag/v1.0.3
[1.0.2]: https://github.com/brianirish/omarchy-screensaver-panel/releases/tag/v1.0.2
[1.0.1]: https://github.com/brianirish/omarchy-screensaver-panel/releases/tag/v1.0.1
[1.0.0]: https://github.com/brianirish/omarchy-screensaver-panel/releases/tag/v1.0.0
