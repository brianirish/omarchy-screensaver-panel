// Pure helpers for the screensaver panel. No QML imports, so the same file
// runs under Node for tests/model_test.js.
//
// Text comes from the i18n/ catalogs through `tr`, anything with t(key) and
// tn(key, count): the panel's Commons.Translations in the shell, the
// tests/tr.js stand-in under Node. Numbers come through `formatNumber`
// (Commons.I18n.formatNumber in the shell), so they take the language's
// digits; it defaults to plain String() here.

// Fills %1, %2, ... from values, the way QML's String.arg() does; Node has no
// arg(). Only %<digit> is a placeholder.
function fill(template, values) {
  return String(template).replace(/%(\d)/g, function(match, n) {
    var value = values[Number(n) - 1]
    return value === undefined ? match : String(value)
  })
}

function number(value, formatNumber) {
  return formatNumber ? formatNumber(value) : String(value)
}

// The effects pinned on the widget's shell.json entry, as a list of names.
// `omarchy bar set brianirish.screensaver effects matrix` without --json
// stores one string; it counts as a single pin, as it does for the launcher
// wrapper and the override, which read the same setting.
function pinnedEffects(value) {
  var list = Array.isArray(value) ? value : [value]
  return list.filter(function(name) { return typeof name === "string" && name !== "" })
}

// The status line under the panel title.
function status(enabled, pinned, total, tr, formatNumber) {
  if (!enabled) return tr.t("status.disabled")
  if (pinned === 1) return tr.t("status.onePinned")
  if (pinned > 0) {
    return fill(tr.tn("status.pinnedOfTotal", total), [number(pinned, formatNumber), number(total, formatNumber)])
  }
  return tr.t("status.random")
}

// An idle delay in seconds, as "30s", "2m" or "2m 30s".
function duration(seconds, tr, formatNumber) {
  var s = Math.max(0, Math.round(Number(seconds) || 0))
  if (s < 60) return fill(tr.t("duration.seconds"), [number(s, formatNumber)])
  var minutes = Math.floor(s / 60)
  var rest = s % 60
  if (rest === 0) return fill(tr.t("duration.minutes"), [number(minutes, formatNumber)])
  return fill(tr.t("duration.minutesSeconds"), [number(minutes, formatNumber), number(rest, formatNumber)])
}

// Every ttfx effect the screensaver can play. `value` is the name ttfx knows
// the effect by and is what gets pinned; the label and description come from
// i18n/. scripts/sync-upstream keeps this list in step with ttfx, one entry
// per line, sorted by value, with the label and description under
// effect.<value>.name and effect.<value>.description in i18n/en.json.
function effectOptions(tr) {
  return [
    { value: "beams", label: tr.t("effect.beams.name"), description: tr.t("effect.beams.description") },
    { value: "binarypath", label: tr.t("effect.binarypath.name"), description: tr.t("effect.binarypath.description") },
    { value: "blackhole", label: tr.t("effect.blackhole.name"), description: tr.t("effect.blackhole.description") },
    { value: "bouncyballs", label: tr.t("effect.bouncyballs.name"), description: tr.t("effect.bouncyballs.description") },
    { value: "bubbles", label: tr.t("effect.bubbles.name"), description: tr.t("effect.bubbles.description") },
    { value: "burn", label: tr.t("effect.burn.name"), description: tr.t("effect.burn.description") },
    { value: "colorshift", label: tr.t("effect.colorshift.name"), description: tr.t("effect.colorshift.description") },
    { value: "crumble", label: tr.t("effect.crumble.name"), description: tr.t("effect.crumble.description") },
    { value: "decrypt", label: tr.t("effect.decrypt.name"), description: tr.t("effect.decrypt.description") },
    { value: "errorcorrect", label: tr.t("effect.errorcorrect.name"), description: tr.t("effect.errorcorrect.description") },
    { value: "expand", label: tr.t("effect.expand.name"), description: tr.t("effect.expand.description") },
    { value: "fireworks", label: tr.t("effect.fireworks.name"), description: tr.t("effect.fireworks.description") },
    { value: "highlight", label: tr.t("effect.highlight.name"), description: tr.t("effect.highlight.description") },
    { value: "laseretch", label: tr.t("effect.laseretch.name"), description: tr.t("effect.laseretch.description") },
    { value: "matrix", label: tr.t("effect.matrix.name"), description: tr.t("effect.matrix.description") },
    { value: "middleout", label: tr.t("effect.middleout.name"), description: tr.t("effect.middleout.description") },
    { value: "orbittingvolley", label: tr.t("effect.orbittingvolley.name"), description: tr.t("effect.orbittingvolley.description") },
    { value: "overflow", label: tr.t("effect.overflow.name"), description: tr.t("effect.overflow.description") },
    { value: "pour", label: tr.t("effect.pour.name"), description: tr.t("effect.pour.description") },
    { value: "print", label: tr.t("effect.print.name"), description: tr.t("effect.print.description") },
    { value: "rain", label: tr.t("effect.rain.name"), description: tr.t("effect.rain.description") },
    { value: "randomsequence", label: tr.t("effect.randomsequence.name"), description: tr.t("effect.randomsequence.description") },
    { value: "rings", label: tr.t("effect.rings.name"), description: tr.t("effect.rings.description") },
    { value: "scattered", label: tr.t("effect.scattered.name"), description: tr.t("effect.scattered.description") },
    { value: "slice", label: tr.t("effect.slice.name"), description: tr.t("effect.slice.description") },
    { value: "slide", label: tr.t("effect.slide.name"), description: tr.t("effect.slide.description") },
    { value: "smoke", label: tr.t("effect.smoke.name"), description: tr.t("effect.smoke.description") },
    { value: "spotlights", label: tr.t("effect.spotlights.name"), description: tr.t("effect.spotlights.description") },
    { value: "spray", label: tr.t("effect.spray.name"), description: tr.t("effect.spray.description") },
    { value: "swarm", label: tr.t("effect.swarm.name"), description: tr.t("effect.swarm.description") },
    { value: "sweep", label: tr.t("effect.sweep.name"), description: tr.t("effect.sweep.description") },
    { value: "synthgrid", label: tr.t("effect.synthgrid.name"), description: tr.t("effect.synthgrid.description") },
    { value: "thunderstorm", label: tr.t("effect.thunderstorm.name"), description: tr.t("effect.thunderstorm.description") },
    { value: "unstable", label: tr.t("effect.unstable.name"), description: tr.t("effect.unstable.description") },
    { value: "vhstape", label: tr.t("effect.vhstape.name"), description: tr.t("effect.vhstape.description") },
    { value: "waves", label: tr.t("effect.waves.name"), description: tr.t("effect.waves.description") },
    { value: "wipe", label: tr.t("effect.wipe.name"), description: tr.t("effect.wipe.description") }
  ]
}

if (typeof module !== "undefined") {
  module.exports = {
    fill: fill,
    pinnedEffects: pinnedEffects,
    status: status,
    duration: duration,
    effectOptions: effectOptions
  }
}
