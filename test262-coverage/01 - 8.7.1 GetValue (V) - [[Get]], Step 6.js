// 8.7.1 GetValue (V), [[Get]], Step 6

// 6. If getter is undefined, return undefined.

// For [[Get]] for a reference with a primitive base,
// if its value is an accessor descriptor, and its getter is undefined, then it returns undefined.

var r;
var n;
Object.defineProperty(Number.prototype, "x", { "set" : function (v) { n = v; }, "enumerable" : true, "configurable" : true });
r = 1["x"]; // undefined
if (!(r === undefined)) {
  $ERROR('Object.defineProperty(Number.prototype, "x", { "enumerable" : true, "configurable" : true, "set" : function (v) { n = v; } }); 1["x"] is undefined. Actual: ' + r);
}
