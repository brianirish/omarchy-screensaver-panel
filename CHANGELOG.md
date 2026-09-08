# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- README links the plugin's listing on the
  [Omarchy Plugin Marketplace](https://omarchyplugins.com/plugin.html?id=brianirish.screensaver)
  and explains how the verified marketplace snapshot relates to what
  `omarchy plugin add` installs.

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

[1.0.1]: https://github.com/brianirish/omarchy-screensaver-panel/releases/tag/v1.0.1
[1.0.0]: https://github.com/brianirish/omarchy-screensaver-panel/releases/tag/v1.0.0
