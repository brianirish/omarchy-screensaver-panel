# Vendored upstream tools

Verbatim copies of tools from [basecamp/omarchy](https://github.com/basecamp/omarchy),
run by `scripts/check`. They are unmodified so refreshing one is a plain
download; the commit column is the upstream revision the copy was taken from.

| File | Upstream path | Commit |
|------|---------------|--------|
| `omarchy-plugin-validate` | `bin/omarchy-plugin-validate` | `f8835df` |
| `qml-text-format-scan.py` | `test/shell.d/qml-text-format-scan.py` | `4be440b` |

Refresh:

```bash
curl -fsSL -o scripts/vendor/omarchy-plugin-validate \
  https://raw.githubusercontent.com/basecamp/omarchy/HEAD/bin/omarchy-plugin-validate
curl -fsSL -o scripts/vendor/qml-text-format-scan.py \
  https://raw.githubusercontent.com/basecamp/omarchy/HEAD/test/shell.d/qml-text-format-scan.py
```

Then update the commit column and run `scripts/check`.
