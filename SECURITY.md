# Security Policy

## Supported versions

Only the latest release on `main` is supported. Omarchy plugins are installed
as git checkouts and updated with `omarchy plugin update`, so staying current
is one command.

## Reporting a vulnerability

Please **do not** open a public issue for security problems. Instead, use
GitHub's private vulnerability reporting:

**[Report a vulnerability](https://github.com/brianirish/omarchy-screensaver-panel/security/advisories/new)**

You should get a response within a week. Please include reproduction steps and
the Omarchy version (`omarchy version`).

## Threat model notes

Useful context for assessing findings:

- Omarchy shell plugins run **unsandboxed** inside `omarchy-shell` as the
  logged-in user — this is true of every plugin and is warned about by
  `omarchy plugin add`. This plugin executes only fixed `omarchy-*` commands
  plus a `jq` rewrite of `~/.config/omarchy/shell.json` whose interpolated
  inputs are pinned to known keys and integers (`saveIdle` in `Panel.qml`).
- The optional `extras/omarchy-screensaver` override runs as the user (never
  root). Effect names read from `shell.json` are allowlist-filtered
  (`^[a-z][a-z0-9-]*$`, so never a leading dash) before being passed to `ttfx`, so config values cannot inject
  flags.
- The plugin handles no secrets, opens no sockets, and makes no network
  requests.

Reports about escalation from user-writable config into anything beyond the
user's own session are especially welcome.
