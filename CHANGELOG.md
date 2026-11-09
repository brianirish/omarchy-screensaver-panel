# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-11-08

For Omarchy 4.5 and later; on Omarchy 4.0, stay on 1.0.3. Effect pinning now
covers both screensavers Omarchy has: the terminal one that Omarchy 4.5.0
runs, and the native overlay that Omarchy's development branch switched to
for a later release. Install both scripts in `extras/` and keep the
`hyprland.lua` PATH block, as the README shows.

### Added

- `extras/omarchy-launch-screensaver`, a wrapper for Omarchy's
  `omarchy-launch-screensaver`, installed to `/usr/local/bin` beside the
  override. Where the native screensaver is installed, it hands the pinned
  effects to Omarchy's own launcher as `--include-effects`, read afresh at
  each launch; where it isn't (Omarchy 4.5.0), it hands straight off and
  changes nothing.
- Translations. Every string the panel shows, the effect names and
  descriptions included, comes from catalogs in `i18n/` through Omarchy's
  `Commons.Translations` and follows _Setup > Language_ without a restart,
  numbers in the language's digits. English ships first; the other languages
  follow as machine translations.
- `scripts/qml-api-lint` type-checks the panel against Omarchy's own shell
  components, in `scripts/check` and in a CI job against Omarchy v4.5.0, plus
  a weekly run against the newest release. `scripts/check` also runs
  `scripts/test-override`, `scripts/test-launcher`, `scripts/test-sync`, and
  the new Node tests for `Model.js` and the catalogs.

### Changed

- `extras/omarchy-screensaver` matches Omarchy 4.5.0's stock script, which
  stops the key that ends the screensaver from echoing into the corner
  (`stty -echo`). It also skips a pinned effect the installed `ttfx` doesn't
  list (it asks `ttfx --help`), which used to keep the screensaver from
  starting at all; skips are logged to the journal. Reinstall it.
- The daily `sync-upstream` workflow follows the newest Omarchy release
  instead of the development branch, where `bin/omarchy-screensaver` was
  deleted and which failed every run since 2026-10-28. It merges the
  release's stock script into the override, watches the launcher the wrapper
  hands off to, and keeps the effect picker to the effects both the `ttfx`
  package and the native screensaver's built-in `ttfx` have. A merge
  conflict, a launcher change or a release without the terminal screensaver
  opens an issue; nothing crashes the job, and one part failing doesn't stop
  the others.
- The effect list moves from `Panel.qml` to `Model.js`, with its text in
  `i18n/en.json`.
- The `effects` setting reads a single effect name as one pin, as
  `omarchy bar set` stores it without `--json`, and the effect picker follows
  the setting when it changes outside the panel.

### Removed

- Support for Omarchy 4.0; stay on 1.0.3 there.

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
