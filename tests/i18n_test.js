// Checks the i18n/ catalogs the way Omarchy's own i18n-test.sh checks the
// shell's: run with `node tests/i18n_test.js`. A missing language or string
// falls back to English, so day to day that is only counted; releases run
// I18N_STRICT=1, which requires every language to translate every string.
//
// - en.json holds every key the plugin's code asks for, and nothing else.
// - Each catalog is a flat object of strings and plural entries.
// - A translation keeps exactly the English %1-style placeholders.
// - A plural entry uses the CLDR categories of its own language.
// - Every Omarchy language (scripts/vendor/locales.json) has a catalog.
"use strict";
const fs = require("node:fs");
const path = require("node:path");

const root = path.join(__dirname, "..");
const i18nDir = path.join(root, "i18n");
const Plural = require(path.join(root, "scripts", "vendor", "Plural.js"));
const locales = JSON.parse(fs.readFileSync(path.join(root, "scripts", "vendor", "locales.json"), "utf8"));
const strict = process.env.I18N_STRICT === "1";

let passed = 0;
let failed = 0;
function check(name, problems) {
  if (problems.length === 0) { passed++; console.log("ok   " + name); return; }
  failed++;
  console.log("FAIL " + name);
  for (const p of problems.slice(0, 20)) console.log("     " + p);
  if (problems.length > 20) console.log("     … and " + (problems.length - 20) + " more");
}

const read = (code) => JSON.parse(fs.readFileSync(path.join(i18nDir, code + ".json"), "utf8"));
const english = read("en");
const placeholders = (value) => (String(value).match(/%\d/g) || []).sort().join(" ");
const isPlural = (value) => value !== null && typeof value === "object" && !Array.isArray(value);

// Keys the code asks for: t("key") / tn("key", …) with a literal key, in the
// plugin's QML and JavaScript (tests and scripts excluded).
function sources(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) return ["tests", "scripts", "node_modules", "docs", "i18n"].includes(entry.name) || entry.name.startsWith(".") ? [] : sources(full);
    return /\.(qml|js)$/.test(entry.name) ? [full] : [];
  });
}
const used = new Set();
for (const file of sources(root)) {
  const text = fs.readFileSync(file, "utf8");
  for (const m of text.matchAll(/\btn?\(\s*"([A-Za-z0-9_.-]+)"/g)) used.add(m[1]);
}

check("the code asks only for keys en.json has", [...used].filter((k) => !Object.hasOwn(english, k)).map((k) => k + ": missing from en.json"));
check("en.json has no keys the code never asks for", Object.keys(english).filter((k) => !used.has(k)).map((k) => k + ": unused"));
check("en.json values are non-empty strings or plural entries with one and other", Object.entries(english).flatMap(([k, v]) => {
  if (typeof v === "string") return v.length > 0 ? [] : [k + ": empty"];
  if (!isPlural(v)) return [k + ": neither a string nor a plural entry"];
  return Object.keys(v).sort().join(",") === "one,other" ? [] : [k + ": English plural forms must be exactly one and other"];
}));

const codes = Object.keys(locales);
const absent = codes.filter((c) => !fs.existsSync(path.join(i18nDir, c + ".json")));
if (strict) check("every Omarchy language has a catalog", absent.map((c) => c + ".json missing"));
check("no catalog for a language Omarchy doesn't have", fs.readdirSync(i18nDir).filter((f) => f.endsWith(".json") && !Object.hasOwn(locales, f.slice(0, -5))).map((f) => f + ": not in locales.json"));

let untranslated = 0;
for (const code of codes.filter((c) => c !== "en" && fs.existsSync(path.join(i18nDir, c + ".json")))) {
  let catalog;
  try { catalog = read(code); } catch (e) { check(code + ".json", ["does not parse: " + e.message]); continue; }
  const problems = [];
  for (const [key, value] of Object.entries(catalog)) {
    if (!Object.hasOwn(english, key)) { problems.push(key + ": not in en.json"); continue; }
    const en = english[key];
    if (isPlural(en)) {
      if (!isPlural(value)) { problems.push(key + ": should be plural forms"); continue; }
      const want = Plural.categories(code).slice().sort().join(",");
      const have = Object.keys(value).sort().join(",");
      if (have !== want) problems.push(key + ": plural categories " + have + ", " + code + " uses " + want);
      if (Object.values(value).some((form) => typeof form !== "string" || form.length === 0)) problems.push(key + ": empty plural form");
      const expected = placeholders(en.other);
      if (placeholders(value.other || "") !== expected) problems.push(key + ": other form placeholders differ from English");
      for (const form of Object.values(value)) {
        if (placeholders(form).split(" ").some((p) => p && !expected.split(" ").includes(p))) problems.push(key + ": a form invents a placeholder");
      }
    } else if (typeof value !== "string" || value.length === 0) {
      problems.push(key + ": not a non-empty string");
    } else if (placeholders(value) !== placeholders(en)) {
      problems.push(key + ": placeholders " + (placeholders(value) || "none") + ", English has " + (placeholders(en) || "none"));
    }
  }
  const missing = Object.keys(english).filter((k) => !Object.hasOwn(catalog, k));
  untranslated += missing.length;
  if (strict) for (const k of missing) problems.push(k + ": untranslated");
  check(code + ".json", problems);
}

console.log("");
if (absent.length > 0 && !strict) console.log(absent.length + " languages have no catalog yet and use English (I18N_STRICT=1 fails on them)");
if (untranslated > 0) console.log(untranslated + " untranslated strings fall back to English" + (strict ? "" : " (I18N_STRICT=1 fails on them)"));
console.log(passed + " passed" + (failed ? ", " + failed + " failed" : ""));
if (failed) process.exitCode = 1;
