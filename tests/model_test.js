// Unit tests for Model.js (the panel's pure helpers). Run with: node tests/model_test.js
// Model.js is a QML JavaScript library; it exports through `module.exports`
// only when loaded by Node, so it can be required directly here.
"use strict";
const assert = require("node:assert/strict");
const path = require("node:path");

const Model = require(path.join(__dirname, "..", "Model.js"));
const { tr } = require(path.join(__dirname, "tr.js"));
const en = tr("en");

let passed = 0;
function test(name, fn) {
  try { fn(); passed++; console.log("ok   " + name); }
  catch (e) { console.log("FAIL " + name + "\n     " + (e && e.message)); process.exitCode = 1; }
}

// A translator that answers with the key, to see which string was asked for.
const keys = { t: (key) => key, tn: (key, count) => key + "#" + count };
// Commons.I18n.formatNumber with Arabic-Indic digits, to see numbers go through it.
const arabicDigits = (v) => String(v).replace(/\d/g, (d) => "٠١٢٣٤٥٦٧٨٩"[d]);

// pinnedEffects
test("pinnedEffects keeps a list of names", () => {
  assert.deepEqual(Model.pinnedEffects(["matrix", "rain"]), ["matrix", "rain"]);
});
test("pinnedEffects reads one string as one pin, as `omarchy bar set` without --json stores it", () => {
  assert.deepEqual(Model.pinnedEffects("matrix"), ["matrix"]);
});
test("pinnedEffects drops what isn't a name, and a missing setting is no pins", () => {
  assert.deepEqual(Model.pinnedEffects(["matrix", 3, null, "", { x: 1 }]), ["matrix"]);
  assert.deepEqual(Model.pinnedEffects(undefined), []);
  assert.deepEqual(Model.pinnedEffects(null), []);
  assert.deepEqual(Model.pinnedEffects(""), []);
  assert.deepEqual(Model.pinnedEffects([]), []);
});

// status
test("status: disabled wins over pins", () => {
  assert.equal(Model.status(false, 3, 37, en), "Disabled");
});
test("status: nothing pinned plays every effect", () => {
  assert.equal(Model.status(true, 0, 37, en), "All effects · random");
});
test("status: one pin", () => {
  assert.equal(Model.status(true, 1, 37, en), "1 effect pinned");
});
test("status: several pins out of the total", () => {
  assert.equal(Model.status(true, 5, 37, en), "5 of 37 effects");
});
test("status: the plural form follows the total the noun counts", () => {
  assert.equal(Model.status(true, 5, 37, keys), "status.pinnedOfTotal#37");
});
test("status numbers go through formatNumber", () => {
  assert.equal(Model.status(true, 5, 37, en, arabicDigits), "٥ of ٣٧ effects");
});

// duration
test("duration: seconds under a minute", () => {
  assert.equal(Model.duration(30, en), "30s");
  assert.equal(Model.duration(0, en), "0s");
});
test("duration: whole minutes", () => {
  assert.equal(Model.duration(120, en), "2m");
  assert.equal(Model.duration(3600, en), "60m");
});
test("duration: minutes and seconds", () => {
  assert.equal(Model.duration(150, en), "2m 30s");
});
test("duration rounds and clamps what it is handed", () => {
  assert.equal(Model.duration(89.6, en), "1m 30s");
  assert.equal(Model.duration(-5, en), "0s");
  assert.equal(Model.duration("nonsense", en), "0s");
});
test("duration numbers go through formatNumber", () => {
  assert.equal(Model.duration(150, en, arabicDigits), "٢m ٣٠s");
});

// effectOptions
const options = Model.effectOptions(en);
test("effectOptions are sorted by value, with no duplicates", () => {
  const values = options.map((o) => o.value);
  assert.deepEqual(values, [...new Set(values)].sort());
});
test("effect values are plain names, which the wrapper and the override pass to ttfx", () => {
  for (const o of options) assert.match(o.value, /^[a-z][a-z0-9-]*$/);
});
test("every effect has an English label and description", () => {
  for (const o of options) {
    assert.notEqual(o.label, "effect." + o.value + ".name", o.value + " has no label");
    assert.notEqual(o.description, "effect." + o.value + ".description", o.value + " has no description");
  }
});
test("effect labels and descriptions are looked up by the effect's own keys", () => {
  const matrix = Model.effectOptions(keys).find((o) => o.value === "matrix");
  assert.deepEqual(matrix, { value: "matrix", label: "effect.matrix.name", description: "effect.matrix.description" });
});
test("an effect renders in English", () => {
  const matrix = options.find((o) => o.value === "matrix");
  assert.deepEqual(matrix, { value: "matrix", label: "Matrix", description: "Matrix digital rain" });
});

// fill
test("fill replaces numbered placeholders and leaves unknown ones", () => {
  assert.equal(Model.fill("%2 then %1, %3", ["a", "b"]), "b then a, %3");
});

console.log(process.exitCode ? "some tests failed" : passed + " tests passed");
