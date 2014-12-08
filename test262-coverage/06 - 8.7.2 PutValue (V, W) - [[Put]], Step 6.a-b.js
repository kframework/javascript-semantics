// 8.7.2 PutValue (V, W), [[Put]], Step 6.a & 6.b

// 6. If IsAccessorDescriptor(desc) is true, then
//     a. Let setter be desc.[[Set]] (see 8.10) which cannot be undefined.
//     b. Call the [[Call]] internal method of setter providing base as the this value and an argument list containing only W.

// For [[Put]] for a reference with a primitive base,
// if its value is an accessor descriptor, and its setter is defined, then the setter is called.

var n = 0;
Object.defineProperty(Number.prototype, "x", { "set" : function (v) { n = v; }, "enumerable" : true, "configurable" : true });
1["x"] = 10;
if (!(n === 10)) {
  $ERROR('var n = 0; Object.defineProperty(Number.prototype, "x", { "set" : function (v) { n = v; }, "enumerable" : true, "configurable" : true }); 1["x"] = 10; n is 10. Actual: ' + n);
}
