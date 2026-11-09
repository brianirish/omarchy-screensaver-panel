# Vendored upstream tools

Verbatim copies of files from [basecamp/omarchy](https://github.com/basecamp/omarchy),
used by `scripts/check` and the tests. They are unmodified so refreshing one
is a plain download; the commit column is the upstream revision the copy was
taken from.

| File | Upstream path | Commit |
|------|---------------|--------|
| `omarchy-plugin-validate` | `bin/omarchy-plugin-validate` | `ac2690c` (v4.5.0) |
| `Plural.js` | `shell/Commons/Plural.js` | `ac2690c` (v4.5.0) |
| `locales.json` | `default/i18n/locales.json` | `ac2690c` (v4.5.0) |
| `qml-text-format-scan.py` | `test/shell.d/qml-text-format-scan.py` | `4be440b` (unchanged at v4.5.0) |

`Plural.js` and `locales.json` are what Omarchy's `Commons.Translations`
uses to pick plural forms and the list of languages; `tests/tr.js` and
`tests/i18n_test.js` read them so the catalogs are checked by the shell's own
rules.

Refresh from the release the plugin supports (replace the tag when it moves):

```bash
tag=v4.5.0
base=https://raw.githubusercontent.com/basecamp/omarchy/$tag
curl -fsSL -o scripts/vendor/omarchy-plugin-validate "$base/bin/omarchy-plugin-validate"
curl -fsSL -o scripts/vendor/Plural.js "$base/shell/Commons/Plural.js"
curl -fsSL -o scripts/vendor/locales.json "$base/default/i18n/locales.json"
curl -fsSL -o scripts/vendor/qml-text-format-scan.py "$base/test/shell.d/qml-text-format-scan.py"
```

Then update the commit column and run `scripts/check`.
