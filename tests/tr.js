// A Node stand-in for Omarchy's Commons.Translations, so tests can render
// the widget's text in any language. Same lookup order as the shell: the
// language, then its base language (pt-BR to pt), then English, then the
// key itself; plural entries pick their form by Omarchy's own CLDR rules.
"use strict";
const fs = require("node:fs");
const path = require("node:path");

const root = path.join(__dirname, "..");
const Plural = require(path.join(root, "scripts", "vendor", "Plural.js"));

function catalog(code) {
  const file = path.join(root, "i18n", code + ".json");
  return fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, "utf8")) : {};
}

function tr(code) {
  const language = code || "en";
  const base = language.split("-")[0];
  const layers = [[catalog(language), language]];
  if (base !== language) layers.push([catalog(base), base]);
  if (language !== "en") layers.push([catalog("en"), "en"]);
  return {
    t(key, fallback) {
      for (const [strings] of layers) {
        let value = strings[key];
        if (value && typeof value === "object") value = value.other;
        if (typeof value === "string" && value.length > 0) return value;
      }
      return fallback !== undefined ? fallback : key;
    },
    tn(key, count, fallback) {
      for (const [strings, rules] of layers) {
        const value = Plural.pick(strings[key], rules, count);
        if (typeof value === "string" && value.length > 0) return value;
      }
      return fallback !== undefined ? fallback : key;
    }
  };
}

module.exports = { tr, catalog };
