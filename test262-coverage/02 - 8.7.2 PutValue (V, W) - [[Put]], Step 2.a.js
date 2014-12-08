// 8.7.2 PutValue (V, W), [[Put]], Step 2.a

// 2. If the result of calling the [[CanPut]] internal method of O with argument P is false, then
//     a. If Throw is true, then throw a TypeError exception.
//     b. ...

// For [[Put]] for a reference with a primitive base,
// if [[CanPut]] returns false, and Throw is true, then it throws TypeError.

// NOTE: In this example, [[CanPut]] returns false, because 'writable' is false.

"use strict";
Object.defineProperty(Number.prototype, "x", { "value" : 0, "writable" : false, "enumerable" : true, "configurable" : true });
try {
  1["x"] = 10; // TypeError
  throw "Not here!";
} catch (e) {
  if (!(e instanceof TypeError)) {
    $ERROR('"use strict"; Object.defineProperty(Number.prototype, "x", { "value" : 0, "writable" : false, "enumerable" : true, "configurable" : true }); 1["x"] = 10; throws TypeError. Actual: ' + e);
  }
}
