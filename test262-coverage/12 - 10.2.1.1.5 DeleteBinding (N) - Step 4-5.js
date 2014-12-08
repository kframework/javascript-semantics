// 10.2.1.1.5 DeleteBinding (N), Step 4 & 5

// 4. Remove the binding for N from envRec.
// 5. Return true.

// If a binding of a declarative environment record (i.e., not in a global scope nor an 'with' construct) is deletable, then remove it and return true.

// The only way to create a deletable binding is to call CreateMutableBinding with the second argument 'D' of true,
// while the only time to call CreateMutableBinding with 'D' of true is when 'configurableBindings' is true in "10.5 Declaration Binding Instantiation",
// while 'configurableBindings' is true only when 'code' is eval code.
// Thus, a binding of a declarative environment record is deletable only when
// - a function or a variable name is declared in a eval code
// - a formal parameter of a function or an argument object of a function in a eval code (although, in this case, it is not specified whether 'configurableBindings' is used or not)

// a variable declaration in an eval code
function f11() {
  eval(" var x11 = 1; delete x11; ");
  return x11; // ReferenceError
}
try {
  f11();
  throw "Not here!";
} catch (e) {
  if (!(e instanceof ReferenceError)) {
    $ERROR('function f11() { eval(" var x11 = 1; delete x11; "); return x11; } f11(); throws ReferenceError. Actual: ' + e);
  }
}

// a function declaration in an eval code
function f12() {
  eval(" function g12() { return 1; } delete g12; ");
  return g12(); // ReferenceError
}
try {
  f12();
  throw "Not here!";
} catch (e) {
  if (!(e instanceof ReferenceError)) {
    $ERROR('function f12() { eval(" function g12() { return 1; } delete g12; "); return g12(); } f12(); throws ReferenceError. Actual: ' + e);
  }
}

// a formal parameter in a function in an eval code
function f21() {
  eval(" function g21(x21) { delete x21; return x21; } ");
  return g21(1); // ReferenceError
}
if (!(f21() === 1)) {
  $ERROR('function f21() { eval(" function g21(x21) { delete x21; return x21; } "); return g21(1); } f21() is 1. Actual: ' + f21());
}
/*
try {
  f21();
  throw "Not here!";
} catch (e) {
  if (!(e instanceof ReferenceError)) {
    $ERROR('function f21() { eval(" function g21(x21) { delete x21; return x21; } "); return g21(1); } f21(); throws ReferenceError. Actual: ' + e);
  }
}
*/

// an arguments object in a function in an eval code
function f22() {
  eval(" function g22() { delete arguments; return arguments[0]; } ");
  return g22(1); // ReferenceError
}
if (!(f22() === 1)) {
  $ERROR('function f22() { eval(" function g22() { delete arguments; return arguments[0]; } "); return g22(1); } f22() is 1. Actual: ' + f22());
}
/*
try {
  f22();
  throw "Not here!";
} catch (e) {
  if (!(e instanceof ReferenceError)) {
    $ERROR('function f22() { eval(" function g22() { delete arguments; return arguments[0]; } "); return g22(1); } f22(); throws ReferenceError. Actual: ' + e);
  }
}
*/
