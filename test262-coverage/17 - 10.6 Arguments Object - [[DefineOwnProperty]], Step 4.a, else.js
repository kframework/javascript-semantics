// 10.6 Arguments Object, [[DefineOwnProperty]], Step 4.a, else-branch

// The [[DefineOwnProperty]] internal method of an arguments object for a non-strict mode function with formal parameters
// when called with a property name P, Property Descriptor Desc, and Boolean flag Throw performs the following steps:
//
// 3. Let allowed be the result of calling the default [[DefineOwnProperty]] internal method (8.12.9) on the arguments object passing P, Desc, and false as the arguments.
// 4. If allowed is false, then
//     a. If Throw is true then ..., otherwise return false.

// When the original [[DefineOwnProperty]] is false and 'Throw' is false, then return false (i.e., do nothing).

// Infeasible.
//
// [[DefineOwnProperty]], given an object O, a property P, and a descriptor Desc, returns false when:
// - P is not O's own property and O is not extensible. (Step 3)
// - Or, P is O's own property (let say Current) and:
//   - Current is not configurable and:
//     - Desc is configurable. (Step 7.a)
//     - Or, (Current's [[Enumerable]] =/= Desc's [[Enumerable]]. (Step 7.b)
//     - Or, Current's descriptor type is different from Desc's. (Step 9.a)
//     - Or, both Current and Desc are of data descriptor and:
//       - Current is not writable, but Desc is writable. (Step 10.a.i)
//       - Or, Current is not writable and Current's [[Value]] =/= Desc's [[Value]]. (Step 10.a.ii.1)
//     - Or, both Current and Desc are of accessor descriptor and:
//       - Current's [[Set]] =/= Desc's [[Set]]. (Step 11.a.i)
//       - Or, Current's [[Get]] =/= Desc's [[Get]]. (Step 11.a.ii)
// 
// Claim: All [[DefineOwnProperty]] calls, with 'Throw' being false, do not return false.
// Proof:
// - In 8.10.4 FromPropertyDescriptor,
//      10.6 Arguments Object,
//      11.1.5 Object Initialiser,
//      13.2.3 The [[ThrowTypeError]] Function Object,
//      15.2.3.4 Object.getOwnPropertyNames,
//      15.2.3.14 Object.keys,
//      15.3.4.5 Function.prototype.bind,
//      15.4.4.4 Array.prototype.concat,
//      15.4.4.10 Array.prototype.slice,
//      15.4.4.12 Array.prototype.splice,
//      15.4.4.19 Array.prototype.map,
//      15.4.4.20 Array.prototype.filter,
//      15.5.4.10 String.prototype.match,
//      15.5.4.14 String.prototype.split,
//      15.10.6.2 RegExp.prototype.exec,
//      15.12.2 parse,
//      15.12.3 stringify,
//   All [[DefineOwnProperty]] return true, since the target object is a new object that is extensible, and every existing property is configurable, if any.
// 
// - In 8.12.5 [[Put]],
//   - In Step 3.b, it returns true, since 'ownDesc' is an own data descriptor and writable (because [[CanPut]] returns true), and 'valueDesc' has only '[[Value]]'.
//   - In Step 6.b, it returns true, since 'desc' is an inherited data descriptor and 'O' is extensible (because [[CanPut]] returns true).
// 
// - In 10.2.1.2.2 CreateMutableBinding,
//      10.5 Declaration Binding Instantiation,
//      15.2.3.6 Object.defineProperty,
//      15.2.3.7 Object.defineProperties,
//      15.2.3.8 Object.seal,
//      15.2.3.9 Object.freeze,
//   'Throw' is true.
// 
// - In 15.4.5.1 [[DefineOwnProperty]],
//   This is only for Array objects not for Arguments objects.
