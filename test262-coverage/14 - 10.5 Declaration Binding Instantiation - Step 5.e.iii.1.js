// 10.5 Declaration Binding Instantiation, Step 5.e.iii.1

// 5. For each FunctionDeclaration f in code, in source text order do
//     ...
//     e. Else if env is the environment record component of the global environment then
//         ...
//         iii. If existingProp .[[Configurable]] is true, then
//             1. Call the [[DefineOwnProperty]] internal method of go, passing fn,
//                Property Descriptor {[[Value]]: undefined, [[Writable]]: true, [[Enumerable]]: true , [[Configurable]]: configurableBindings },
//                and true as arguments.

// A duplicated function declaration in a global scope overwrites the existing one, if the existing's [[Configurable]] is true.

// In the beginning, the following's [[Configurable]] is true, so we can declare a function whose name is one of the following:
// - "eval"                
// - "parseInt"            
// - "parseFloat"          
// - "isNaN"               
// - "isFinite"            
// - "decodeURI"           
// - "decodeURIComponent"  
// - "encodeURI"           
// - "encodeURIComponent"  
// - "Object"              
// - "Function"            
// - "Array"               
// - "String"              
// - "Boolean"             
// - "Number"              
// - "Date"                
// - "RegExp"              
// - "Error"               
// - "EvalError"           
// - "RangeError"          
// - "ReferenceError"      
// - "SyntaxError"         
// - "TypeError"           
// - "URIError"            
// - "Math"                
// - "JSON"                

function isNaN() {
  return false;
}
if (!(isNaN(NaN) === false)) {
  $ERROR('function isNaN() { return false; } isNaN(NaN) is false. Actual: ' + isNaN(NaN));
}

function Array() {
  return true;
}
if (!(Array() === true)) {
  $ERROR('function Array() { return true; } Array() is true. Actual: ' + Array());
}
