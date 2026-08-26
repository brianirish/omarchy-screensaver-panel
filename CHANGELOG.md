# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.0.0]: https://github.com/brianirish/omarchy-screensaver-panel/releases/tag/v1.0.0
