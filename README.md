# Omarchy Screensaver Panel

[![CI](https://github.com/brianirish/omarchy-screensaver-panel/actions/workflows/ci.yml/badge.svg)](https://github.com/brianirish/omarchy-screensaver-panel/actions/workflows/ci.yml)
[![Sync upstream](https://github.com/brianirish/omarchy-screensaver-panel/actions/workflows/sync-upstream.yml/badge.svg)](https://github.com/brianirish/omarchy-screensaver-panel/actions/workflows/sync-upstream.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Omarchy Plugin Marketplace](https://img.shields.io/badge/Omarchy_Plugin_Marketplace-listed-6f42c1)](https://omarchyplugins.com/plugin.html?id=brianirish.screensaver)

**Made in Canada 🇨🇦**

A settings GUI for the [Omarchy](https://omarchy.org) screensaver — the knobs
that were previously config-file-and-CLI only, as a native shell panel.

![The panel](preview.png)

Omarchy's screensaver (`ttfx` text effects over your ASCII branding) is
lovely, but tuning it means editing `shell.json` by hand and there's no way to
choose *which* effects play. This plugin adds a bar icon that opens a panel
with:

- **Enable/disable** toggle (right-click the bar icon for a quick toggle)
- **Idle timing** sliders for screensaver and lock delay, with snap-to presets
  (30s–30m / 1m–60m), applied instantly
- **Effect picker** — pin any subset of the 37 `ttfx` effects for the random
  rotation (searchable multi-select, Select all / Clear); empty selection
  means all effects, exactly like stock
- **Artwork** controls — edit the ASCII art as text, generate it from a
  PNG/SVG, or reset to the Omarchy logo
- **Preview** button

Everything is built from Omarchy's own UI kit, so it follows your theme.

## Install

The plugin is listed on the
[Omarchy Plugin Marketplace](https://omarchyplugins.com/plugin.html?id=brianirish.screensaver)
as `brianirish.screensaver`. Copy the install command from the listing, or run
it directly:

```bash
omarchy plugin add https://github.com/brianirish/omarchy-screensaver-panel.git --enable --yes
```

The widget lands in the bar's right section (move it with
`omarchy bar move brianirish.screensaver --section <section>`).

Everything except effect pinning works out of the box.

### Requirements

- Omarchy 4.5 or later. On Omarchy 4.0, stay on 1.x:

  ```bash
  git -C ~/.config/omarchy/plugins/brianirish.screensaver checkout v1.0.3
  ```

## Enabling effect pinning

Stock Omarchy plays a random pick from every effect. Honoring the effects you
pin in the panel takes two small scripts from `extras/`, installed to
`/usr/local/bin`, and a PATH change so they're found first. Install both:
Omarchy is part-way through replacing its screensaver, and each script covers
one of the two.

| Script | For | What it does |
|---|---|---|
| `omarchy-screensaver` | Omarchy 4.5.0, whose screensaver runs `ttfx` in a terminal | A copy of Omarchy's own screensaver script that adds the pinned effects as `--include-effects`. |
| `omarchy-launch-screensaver` | The native screensaver overlay on Omarchy's development branch, coming in a later release | Hands the pinned effects to Omarchy's own launcher as `--include-effects`. Where the native screensaver isn't installed (4.5.0), it hands straight off and changes nothing. |

```bash
plugin=~/.config/omarchy/plugins/brianirish.screensaver
sudo install -m 755 "$plugin/extras/omarchy-screensaver" /usr/local/bin/omarchy-screensaver
sudo install -m 755 "$plugin/extras/omarchy-launch-screensaver" /usr/local/bin/omarchy-launch-screensaver
```

Omarchy's `envs.lua` puts `$OMARCHY_PATH/bin` at the front of the session
PATH, ahead of `/usr/local/bin`, so Omarchy's own copies would still win. Add
this at the end of `~/.config/hypr/hyprland.lua` (your config loads after
Omarchy's defaults) to put `/usr/local/bin` first:

```lua
-- /usr/local/bin overrides ahead of Omarchy's bin dir.
local omarchy_bin = (os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/bin"
local path_entries = {}
for entry in (os.getenv("PATH") or "/usr/local/bin:/usr/bin"):gmatch("[^:]+") do
  if entry ~= omarchy_bin and entry ~= "/usr/local/bin" then
    table.insert(path_entries, entry)
  end
end
table.insert(path_entries, 1, omarchy_bin)
table.insert(path_entries, 1, "/usr/local/bin")
hl.env("PATH", table.concat(path_entries, ":"))
```

Then log out and back in, so the shell and everything Hyprland starts get the
new PATH. Every launch then goes through the scripts: idle, _System >
Screensaver_, the panel's Preview and the artwork buttons.

Pinned effects are stored inline on the widget's `shell.json` entry and read
at each launch, so a change applies to the next screensaver without logging
out again. With nothing pinned, both scripts behave exactly like stock. A
pinned effect the installed `ttfx` doesn't have is skipped instead of keeping
the screensaver from starting (the terminal one logs the skip:
`journalctl -t omarchy-screensaver`).

A later Omarchy may make some of this unnecessary: if it stops putting its bin
directory ahead of `/usr/local/bin`, the PATH block can go, and
[omacom/omarchy-screensaver#8](https://github.com/omacom/omarchy-screensaver/pull/8),
not merged yet, would let the native screensaver read pinned effects from
`shell.json` itself. The release notes will say when either happens.

### Upgrading from 1.x

1.x installed the terminal override and asked for the same PATH block. Keep
the PATH block, reinstall the override (2.0's copy matches Omarchy 4.5.0's
script and skips pins `ttfx` doesn't have), and add the wrapper, which
1.x didn't have: run both `sudo install` lines above.

### When your Omarchy moves to the native screensaver

Once you're on an Omarchy release whose screensaver is the native overlay
(`$OMARCHY_PATH/bin/omarchy-screensaver` is gone, and
`omarchy-launch-screensaver` hands off to
`/usr/lib/omarchy-screensaver/omarchy-screensaver`), Omarchy no longer runs the
terminal script, so the override sits unused and the wrapper does the
pinning. Keep the wrapper and the PATH block. The override is harmless;
remove it if you like:

```bash
sudo rm -f /usr/local/bin/omarchy-screensaver
```

### Keeping up with Omarchy

A daily workflow follows the newest Omarchy release. When the release's
screensaver script changes, it merges the change into the override and cuts a
release whose notes say to reinstall it (rerun the `sudo install` line). When
`ttfx` gains or drops an effect, it updates the effect picker; the picker
offers the effects that both the `ttfx` package (which the terminal
screensaver uses) and the native screensaver's built-in `ttfx` have, so every
effect it lists plays on either. Pick those up with
`omarchy plugin update brianirish.screensaver`. A change it shouldn't settle
alone, such as a new `omarchy-launch-screensaver`, opens an issue for a human
instead.

> The marketplace verifies one exact commit per listing, while `omarchy plugin
> add` and `omarchy plugin update` install the current `main`. After a release
> the listing may show *Update unverified* until the new commit is re-verified;
> the [listing page](https://omarchyplugins.com/plugin.html?id=brianirish.screensaver)
> names the verified commit if you want to check what you installed.

## Translations

The panel follows the language picked under _Setup > Language_. Its text,
effect names and descriptions included, lives in `i18n/`, one catalog per
language; `en.json` is the source, and the other languages are machine
translated, falling back to English for anything not translated yet. Fixes
are welcome: open a pull request that edits `i18n/<code>.json`.

## Uninstall

```bash
omarchy plugin remove brianirish.screensaver
sudo rm -f /usr/local/bin/omarchy-screensaver /usr/local/bin/omarchy-launch-screensaver
```

Then delete the PATH block from `~/.config/hypr/hyprland.lua`, unless
something else of yours lives in `/usr/local/bin` and needs it, and log out
and back in.

## License

[MIT](LICENSE)
