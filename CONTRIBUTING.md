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
- Keep logic in `Model.js` and keep it free of QML imports so
  `node tests/model_test.js` keeps running. Cover behaviour changes there.
- Run `scripts/check` before opening a PR — it is exactly what CI runs
  (shell lint, Omarchy's plugin validator and QML `textFormat` scanner, the
  QML API lint against the installed Omarchy shell, the `Model.js` and
  translation tests, the override, wrapper and upstream sync tests, the
  effect-list check, YAML).
- `extras/omarchy-screensaver` is a copy of Omarchy's stock script that the
  daily sync merges upstream changes into. Keep its differences from
  `extras/omarchy-screensaver.stock` to the effect-pinning block so those
  merges stay clean, and cover behaviour changes in `scripts/test-override`.
- `extras/omarchy-launch-screensaver` wraps Omarchy's own launcher rather
  than copying it: keep it a thin hand-off that only adds `--include-effects`,
  and cover behaviour changes in `scripts/test-launcher`.
- Don't hand-edit the effect list in `Model.js`; the daily workflow rebuilds
  it from `ttfx`. Fixing an effect's English label or description in
  `i18n/en.json` is fine, adding or removing entries is not.
- `scripts/test-sync` answers every fetch from fixtures
  (`scripts/sync-upstream --fixtures DIR`), so the tests never touch the
  network; keep it that way when the sync learns to read something new.

## Adding or changing text

Every string the panel shows comes from `i18n/en.json`:

1. Add the key to `i18n/en.json`, keeping the file sorted by key (the
   effect-list check fails otherwise). Write the English so it stands on its
   own: translators see only the key and the text. A string that counts
   something is a plural entry (`{"one": "…", "other": "…"}`).
2. Use it in QML as `strings.t("your.key")` (`tr.t` in `Model.js`), or `tn` with a count,
   inside a binding so a language switch updates it. Write the key out in
   full; a key built at run time (`strings.t("state." + name)`) can't be
   checked, and `tests/i18n_test.js` fails on keys it can't find in use.
3. Run `scripts/check`.

The other catalogs are machine translated afterwards and may lag; until then
the new string shows in English. Before a release, `I18N_STRICT=1
scripts/check` also requires every language to translate every string.

## Pull requests

- One logical change per PR.
- Update `CHANGELOG.md` under an `Unreleased` heading.
- Include a screenshot for visual changes (`omarchy capture screenshot`).
- Note the Omarchy version you tested on.

## Bugs and ideas

Open an issue using the templates. For security problems, see
[SECURITY.md](SECURITY.md) — please don't open public issues for those.
