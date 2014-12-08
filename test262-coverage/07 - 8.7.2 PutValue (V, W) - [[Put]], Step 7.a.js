// 8.7.2 PutValue (V, W), [[Put]], Step 7.a

// 7. Else, this is a request to create an own property on the transient object O
//     a. If Throw is true, then throw a TypeError exception.

// For [[Put]] for a reference with a primitive base,
// if it does not have its own value, but a inherited data descriptor,
// then this assignment will create its own data descriptor which cannot be used later at all, because this object will immediately disappear after this assignment
// (at least there is no reference pointing to this object, so it's not accessible).
// Thus, if throw is true, then it throws TypeError.

"use strict";
try {
  1["x"] = 10; // TypeError
  throw "Not here!";
} catch (e) {
  if (!(e instanceof TypeError)) {
    $ERROR('"use strict"; Object.defineProperty(Number.prototype, "x", { "value" : 0, "writable" : false, "enumerable" : true, "configurable" : true }); 1["x"] = 10; throws TypeError. Actual: ' + e);
  }
}
