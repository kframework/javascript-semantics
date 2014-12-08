// 10.2.1.1.4 GetBindingValue(N,S), Step 3.a

// 3. If the binding for N in envRec is an uninitialised immutable binding, then
//     a. If S is false, return the value undefined, otherwise throw a ReferenceError exception.

// Infeasible.
// There are only two ways to create an immutable binding:
//   1. 'arguments' is an immutable binding in a strict mode function.
//   2. name of a recursive function expression (it should be a function 'expression', not a function 'declaration') is an immutable binding of the function body's environment.
// In both cases, they are initialized immeditely after created, thus there cannot exist an uninitialized immutable binding at all.
