# Contributing

Thanks for helping improve the Omarchy screensaver panel!

## Development setup

The plugin is developed in place — clone it where Omarchy loads plugins from:

```bash
git clone https://github.com/brianirish/omarchy-screensaver-panel.git \
  ~/.config/omarchy/plugins/brianirish.screensaver
omarchy-shell shell rescanPlugins
omarchy plugin enable brianirish.screensaver
```

(If you installed via `omarchy plugin add`, that directory is already a git
checkout — fork, add your remote, and work there.)

## Iterating

- Saving files under `~/.config/omarchy/plugins/` triggers the shell's
  hot-reload, **but** the QML engine can keep serving a cached component even
  after `rescanPlugins`. When a change doesn't show up, run
  `omarchy restart shell` — that always picks it up.
- Watch for QML errors with
  `journalctl --user -f | grep -i qml`.
- Style: follow the stock panels in `/usr/share/omarchy/shell/plugins/panels/`
  (the power panel was this plugin's template). Use the `qs.Ui` kit and
  `Style`/`Color` tokens instead of hardcoded values so themes keep working.
- Run `scripts/check` before opening a PR — it is exactly what CI runs
  (shell lint, Omarchy's plugin validator and QML `textFormat` scanner, the
  effect-list check, YAML).
- If you change `extras/omarchy-screensaver`, keep its diff against
  `extras/omarchy-screensaver.stock` as small as possible. A daily workflow
  three-way merges upstream changes onto the override using that file as the
  base; the bigger the fork, the likelier a conflict lands on a human.
- Don't hand-edit the effect list in `Panel.qml`; the same workflow rebuilds
  it from the `ttfx` version Omarchy ships. Fixing a label or description is
  fine, adding or removing entries is not.

## Pull requests

- One logical change per PR.
- Update `CHANGELOG.md` under an `Unreleased` heading.
- Include a screenshot for visual changes (`omarchy capture screenshot`).
- Note the Omarchy version you tested on.

## Bugs and ideas

Open an issue using the templates. For security problems, see
[SECURITY.md](SECURITY.md) — please don't open public issues for those.
