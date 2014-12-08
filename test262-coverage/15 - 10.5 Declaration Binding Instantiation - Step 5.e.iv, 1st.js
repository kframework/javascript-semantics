// 10.5 Declaration Binding Instantiation, Step 5.e.iv, First condition is true

// 5. For each FunctionDeclaration f in code, in source text order do
//     ...
//     e. Else if env is the environment record component of the global environment then
//         ...
//         iii. If existingProp .[[Configurable]] is true, then
//             ... 
//         iv. Else if IsAccessorDescriptor(existingProp) or ..., then
//             1. Throw a TypeError exception.

// A duplicated function declaration in a global scope throws TypeError,
// if the existing is not configurable and an accessor descriptor.

// In the below example, we put the duplicated function declaration in 'eval', in order to the declaration is evaluated after the 'Object.defineProperty' statement,
// otherwise the function declaration will be evaluated first before the first statement.

Object.defineProperty(this, "f", { "get" : undefined, "set" : undefined, "enumerable" : false, "configurable" : false });
try {
  eval(" function f() { return 0; } "); // TypeError
  throw "Not here!";
} catch (e) {
  if (!(e instanceof TypeError)) {
    $ERROR('Object.defineProperty(this, "f", { "get" : undefined, "set" : undefined, "enumerable" : false, "configurable" : false }); eval(" function f() { return 0; } "); throws TypeError. Actual: ' + e);
  }
}
