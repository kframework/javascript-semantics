// 10.2.1.1.3 SetMutableBinding (N,V,S), Step 4, if-condition is true

// 4. Else this must be an attempt to change the value of an immutable binding so if S if true throw a TypeError exception.

// In a strict mode, assigning an immutable binding throws TypeError.

// There are only two ways to create an immutable binding:
//   1. 'arguments' is an immutable binding in a strict mode function.
//   2. name of a recursive function expression (it should be a function 'expression', not a function 'declaration') is an immutable binding of the function body's environment.
// In the first case, assigning such binding raises a syntax error, in advance, in a strict mode code, thus it cannot reach here.
// Thus, assigning the second kind of binding is the only case that can reach here, and the below example represents this case.

// In the example below, 'g' is a name of recursive function expression, thus inside the function body, 'g' is a immutable binding.
// Note that 'g' is not visible outside of the function body, that is, it is not visible in a global scope.

"use strict";
var f = function g() {
  g = 0;
};
try {
  f(); // TypeError
  throw "Not here!";
} catch (e) {
  if (!(e instanceof TypeError)) {
    $ERROR('"use strict"; var f = function g() { g = 0; }; f(); throws TypeError. Actual: ' + e);
  }
}
