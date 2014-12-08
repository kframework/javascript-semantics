// 8.7.2 PutValue (V, W), [[Put]], Step 4.b

// 4. If IsDataDescriptor(ownDesc) is true, then
//     a. ...
//     b. Else return.

// Infeasible.
// Like Step 4.a,
// Since 'base' is a primitive value, 'O' is a newly created object who has no its own properties, thus 'IsDataDescriptor(ownDesc)' cannot be true.
// Although, if 'base' is a string value, then 'O' has its own property of 'length', but in this case, [[CanPut]](O,'length') is false since 'length' is not writable, and stopped at Step 2.
