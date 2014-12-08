// 8.7.2 PutValue (V, W), [[Put]], Step 2.b

// 2. If the result of calling the [[CanPut]] internal method of O with argument P is false, then
//     a. ...
//     b. Else return.

// For [[Put]] for a reference with a primitive base,
// if [[CanPut]] returns false, and Throw is false, then it does nothing.

// NOTE: In this example, [[CanPut]] returns false, because 'writable' is false.

Object.defineProperty(Number.prototype, "x", { "value" : 0, "writable" : false, "enumerable" : true, "configurable" : true });
try {
  1["x"] = 10; // Nop
} catch (e) {
  $ERROR('Object.defineProperty(Number.prototype, "x", { "value" : 0, "writable" : false, "enumerable" : true, "configurable" : true }); 1["x"] = 10; does nothing. Actual: ' + e);
}
