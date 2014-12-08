// 10.5 Declaration Binding Instantiation, Step 5.e.iv, Second condition is true

// 5. For each FunctionDeclaration f in code, in source text order do
//     ...
//     e. Else if env is the environment record component of the global environment then
//         ...
//         iii. If existingProp .[[Configurable]] is true, then
//             ... 
//         iv. Else if ... or existingProp does not have attribute values {[[Writable]]: true, [[Enumerable]]: true}, then
//             1. Throw a TypeError exception.

// A duplicated function declaration in a global scope throws TypeError,
// if the existing is not-configurable and (either non-writable or non-enumerable).

// In the below example, we put the duplicated function declaration in 'eval', in order to the declaration is evaluated after the 'Object.defineProperty' statement,
// otherwise the function declaration will be evaluated first before the first statement.

// both writable and enumerable are false
Object.defineProperty(this, "f1", { "value" : 0, "writable" : false, "enumerable" : false, "configurable" : false });
try {
  eval(" function f1() { return 0; } "); // TypeError
  throw "Not here!";
} catch (e) {
  if (!(e instanceof TypeError)) {
    $ERROR('Object.defineProperty(this, "f1", { "value" : 0, "writable" : false, "enumerable" : false, "configurable" : false }); eval(" function f1() { return 0; } "); throws TypeError. Actual: ' + e);
  }
}

// writable is true, and enumerable is false
Object.defineProperty(this, "f2", { "value" : 0, "writable" : true,  "enumerable" : false, "configurable" : false });
try {
  eval(" function f2() { return 0; } "); // TypeError
  throw "Not here!";
} catch (e) {
  if (!(e instanceof TypeError)) {
    $ERROR('Object.defineProperty(this, "f2", { "value" : 0, "writable" : true,  "enumerable" : false, "configurable" : false }); eval(" function f1() { return 0; } "); throws TypeError. Actual: ' + e);
  }
}

// writable is false, and enumerable is true
Object.defineProperty(this, "f3", { "value" : 0, "writable" : false, "enumerable" : true,  "configurable" : false });
try {
  eval(" function f3() { return 0; } "); // TypeError
  throw "Not here!";
} catch (e) {
  if (!(e instanceof TypeError)) {
    $ERROR('Object.defineProperty(this, "f3", { "value" : 0, "writable" : false, "enumerable" : true,  "configurable" : false }); eval(" function f1() { return 0; } "); throws TypeError. Actual: ' + e);
  }
}
