//////////////////////////////////////////////////////////////////////////////
// Initializing Configuration
//////////////////////////////////////////////////////////////////////////////

// 10.2.3 The Global Environment
syntax Eid  ::= "@GlobalEid"

// 15 Standard Built-in ECMAScript Objects
syntax Oid  ::= "@GlobalOid"
              | "@ObjectOid"   | "@ObjectProtoOid"
              | "@FunctionOid" | "@FunctionProtoOid"
              | "@ArrayOid"    | "@ArrayProtoOid"
              | "@StringOid"   | "@StringProtoOid"
              | "@BooleanOid"  | "@BooleanProtoOid"
              | "@NumberOid"   | "@NumberProtoOid"
              | "@MathOid"
              | "@DateOid"     | "@DateProtoOid"
              | "@RegExpOid"   | "@RegExpProtoOid"
              | "@ErrorOid"    | "@ErrorProtoOid"
              //
              | "@EvalErrorOid"      | "@EvalErrorProtoOid"
              | "@RangeErrorOid"     | "@RangeErrorProtoOid"
              | "@ReferenceErrorOid" | "@ReferenceErrorProtoOid"
              | "@SyntaxErrorOid"    | "@SyntaxErrorProtoOid"
              | "@TypeErrorOid"      | "@TypeErrorProtoOid"
              | "@URIErrorOid"       | "@URIErrorProtoOid"
              //
              | "@JSONOid"

// NOTE: All of '@(...)'s are place-holders. They will be eventually replaced with actual standard built-in methods written in self-hosting javascript programs.

syntax KItem /* .K */ ::= "@InitConfig"
// TODO: More initializations
rule <k> @InitConfig => . ... </k>
     // 15 Standard Built-in ECMAScript Objects
     <objs>
       // 15.1 The Global Object
       (. => <obj>
               <oid> @GlobalOid </oid>
               <properties>
               //"window"              |-> @desc("Value" |-> @GlobalOid               "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1 The Global Object
                 // 15.1.1 Value Properties of the Global Object
                 "NaN"                 |-> @desc("Value" |-> @NaN                     "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.1.1.1 NaN
                 "Infinity"            |-> @desc("Value" |-> @+Infinity               "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.1.1.2 Infinity
                 "undefined"           |-> @desc("Value" |-> Undefined               "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.1.1.3 undefined
                 // 15.1.2 Function Properties of the Global Object
                 "eval"                |-> @desc("Value" |-> @("eval_i")              "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.2.1 eval (x)
                 "parseInt"            |-> @desc("Value" |-> @("parseInt"  )          "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.2.2 parseInt (string , radix)
                 "parseFloat"          |-> @desc("Value" |-> @("parseFloat")          "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.2.3 parseFloat (string)
                 "isNaN"               |-> @desc("Value" |-> @("isNaN"     )          "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.2.4 isNaN (number)
                 "isFinite"            |-> @desc("Value" |-> @("isFinite"  )          "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.2.5 isFinite (number)
                 // 15.1.3 URI Handling Function Properties
                 "decodeURI"           |-> @desc("Value" |-> @("decodeURI"         )  "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.3.1 decodeURI (encodedURI)
                 "decodeURIComponent"  |-> @desc("Value" |-> @("decodeURIComponent")  "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.3.2 decodeURIComponent (encodedURIComponent)
                 "encodeURI"           |-> @desc("Value" |-> @("encodeURI"         )  "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.3.3 encodeURI (uri)
                 "encodeURIComponent"  |-> @desc("Value" |-> @("encodeURIComponent")  "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.3.4 encodeURIComponent (uriComponent)
                 // 15.1.4 Constructor Properties of the Global Object
                 "Object"              |-> @desc("Value" |-> @ObjectOid               "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.1 Object ( . . . )
                 "Function"            |-> @desc("Value" |-> @FunctionOid             "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.2 Function ( . . . )
                 "Array"               |-> @desc("Value" |-> @ArrayOid                "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.3 Array ( . . . )
                 "String"              |-> @desc("Value" |-> @StringOid               "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.4 String ( . . . )
                 "Boolean"             |-> @desc("Value" |-> @BooleanOid              "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.5 Boolean ( . . . )
                 "Number"              |-> @desc("Value" |-> @NumberOid               "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.6 Number ( . . . )
                 "Date"                |-> @desc("Value" |-> @DateOid                 "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.7 Date ( . . . )
                 "RegExp"              |-> @desc("Value" |-> @RegExpOid               "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.8 RegExp ( . . . )
                 "Error"               |-> @desc("Value" |-> @ErrorOid                "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.9 Error ( . . . ) 
                 "EvalError"           |-> @desc("Value" |-> @EvalErrorOid            "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.10 EvalError ( . . . )
                 "RangeError"          |-> @desc("Value" |-> @RangeErrorOid           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.11 RangeError ( . . . )
                 "ReferenceError"      |-> @desc("Value" |-> @ReferenceErrorOid       "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.12 ReferenceError ( . . . )
                 "SyntaxError"         |-> @desc("Value" |-> @SyntaxErrorOid          "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.13 SyntaxError ( . . . )
                 "TypeError"           |-> @desc("Value" |-> @TypeErrorOid            "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.14 TypeError ( . . . )
                 "URIError"            |-> @desc("Value" |-> @URIErrorOid             "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.15 URIError ( . . . )
                 // 15.1.5 Other Properties of the Global Object
                 "Math"                |-> @desc("Value" |-> @MathOid                 "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.5.1 Math
                 "JSON"                |-> @desc("Value" |-> @JSONOid                 "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.5.2 JSON
               </properties>
               <internalProperties>
                 // 15.1 The Global Object
                 // The values of the [[Prototype]] and [[Class]] internal properties of the global object are implementation-dependent.
                 "Prototype"  |-> @ObjectProtoOid
                 "Class"      |-> "Object"
                 "Extensible" |-> true // TODO: check if it is correct?
               </internalProperties>
             </obj>)

       // 15.2 Object Objects
       (. => <obj>
               <oid> @ObjectOid </oid>
               // 15.2.3 Properties of the Object Constructor
               <properties>
                 "length"                   |-> @desc("Value" |-> 1                                    "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.2.3 Properties of the Object Constructor
                 "prototype"                |-> @desc("Value" |-> @ObjectProtoOid                      "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.2.3.1 Object.prototype
                 "getPrototypeOf"           |-> @desc("Value" |-> @("Object.getPrototypeOf")           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.2.3.2 Object.getPrototypeOf ( O )
                 "getOwnPropertyDescriptor" |-> @desc("Value" |-> @("Object.getOwnPropertyDescriptor") "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.2.3.3 Object.getOwnPropertyDescriptor ( O, P )
                 "getOwnPropertyNames"      |-> @desc("Value" |-> @("Object.getOwnPropertyNames")      "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.2.3.4 Object.getOwnPropertyNames ( O )
                 "create"                   |-> @desc("Value" |-> @("Object.create")                   "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.2.3.5 Object.create ( O [, Properties] )
                 "defineProperty"           |-> @desc("Value" |-> @("Object.defineProperty")           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.2.3.6 Object.defineProperty ( O, P, Attributes )
                 "defineProperties"         |-> @desc("Value" |-> @("Object.defineProperties")         "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.2.3.7 Object.defineProperties ( O, Properties )
                 "seal"                     |-> @desc("Value" |-> @("Object.seal")                     "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.2.3.8 Object.seal ( O )
                 "freeze"                   |-> @desc("Value" |-> @("Object.freeze")                   "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.2.3.9 Object.freeze ( O )
                 "preventExtensions"        |-> @desc("Value" |-> @("Object.preventExtensions")        "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.2.3.10 Object.preventExtensions ( O )
                 "isSealed"                 |-> @desc("Value" |-> @("Object.isSealed")                 "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.2.3.11 Object.isSealed ( O )
                 "isFrozen"                 |-> @desc("Value" |-> @("Object.isFrozen")                 "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.2.3.12 Object.isFrozen ( O )
                 "isExtensible"             |-> @desc("Value" |-> @("Object.isExtensible")             "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.2.3.13 Object.isExtensible ( O )
                 "keys"                     |-> @desc("Value" |-> @("Object.keys")                     "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.2.3.14 Object.keys ( O )
               </properties>
               <internalProperties>
                 "Prototype"        |-> @FunctionProtoOid
                 "Class"            |-> "Function"
                 "Extensible"       |-> true
               </internalProperties>
             </obj>)
       // 15.2.4 Properties of the Object Prototype Object
       (. => <obj>
               <oid> @ObjectProtoOid </oid>
               <properties>
                 "constructor"          |-> @desc("Value" |-> @ObjectOid                                 "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.2.4.1 Object.prototype.constructor
                 "toString"             |-> @desc("Value" |-> @("Object.prototype.toString")             "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.2.4.2 Object.prototype.toString ( ) 
                 "toLocaleString"       |-> @desc("Value" |-> @("Object.prototype.toLocaleString")       "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.2.4.3 Object.prototype.toLocaleString ( )
                 "valueOf"              |-> @desc("Value" |-> @("Object.prototype.valueOf")              "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.2.4.4 Object.prototype.valueOf ( )
                 "hasOwnProperty"       |-> @desc("Value" |-> @("Object.prototype.hasOwnProperty")       "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.2.4.5 Object.prototype.hasOwnProperty (V)
                 "isPrototypeOf"        |-> @desc("Value" |-> @("Object.prototype.isPrototypeOf")        "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.2.4.6 Object.prototype.isPrototypeOf (V)
                 "propertyIsEnumerable" |-> @desc("Value" |-> @("Object.prototype.propertyIsEnumerable") "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.2.4.7 Object.prototype.propertyIsEnumerable (V
               </properties>
               <internalProperties>
                 "Prototype"  |-> @NullOid
                 "Class"      |-> "Object"
                 "Extensible" |-> true
               </internalProperties>
             </obj>)

       // 15.3 Function Objects
       (. => <obj>
               <oid> @FunctionOid </oid>
               // 15.3.3 Properties of the Function Constructor
               <properties>
                 "length"           |-> @desc("Value" |-> 1                 "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.3.3.2 Function.length
                 "prototype"        |-> @desc("Value" |-> @FunctionProtoOid "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.3.3.1 Function.prototype
               </properties>
               <internalProperties>
                 "Prototype"        |-> @FunctionProtoOid
                 "Class"            |-> "Function"
                 "Extensible"       |-> true
               </internalProperties>
             </obj>)
       // 15.3.4 Properties of the Function Prototype Object
       (. => <obj>
               <oid> @FunctionProtoOid </oid>
               <properties>
                 "length"      |-> @desc("Value" |-> 0                                "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.3.4 Properties of the Function Prototype Object
                 "constructor" |-> @desc("Value" |-> @FunctionOid                     "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.3.4.1 Function.prototype.constructor
                 "toString"    |-> @desc("Value" |-> @("Function.prototype.toString") "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.3.4.2 Function.prototype.toString // TODO:
                 "apply"       |-> @desc("Value" |-> @("Function.prototype.apply")    "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.3.4.3 Function.prototype.apply // TODO:
                 "call"        |-> @desc("Value" |-> @("Function.prototype.call")     "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.3.4.4 Function.prototype.call // TODO:
                 "bind"        |-> @desc("Value" |-> @("Function.prototype.bind")     "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.3.4.5 Function.prototype.bind // TODO:
               </properties>
               <internalProperties>
                 "Prototype"  |-> @ObjectProtoOid
                 "Class"      |-> "Function"
                 "Extensible" |->  true
               </internalProperties>
             </obj>)

       // 15.4 Array Objects
       // 15.4.5 Properties of Array Instances // TODO:
       (. => <obj>
               <oid> @ArrayOid </oid>
               // 15.4.3 Properties of the Array Constructor
               <properties>
                 "length"           |-> @desc("Value" |-> 1                  "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.4.3 Properties of the Array Constructor
                 "prototype"        |-> @desc("Value" |-> @ArrayProtoOid     "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.4.3.1 Array.prototype
                 "isArray"          |-> @desc("Value" |-> @("Array.isArray") "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.3.2 Array.isArray ( arg )
               </properties>
               <internalProperties>
                 "Prototype"        |-> @FunctionProtoOid
                 "Class"            |-> "Function"
                 "Extensible"       |-> true
               </internalProperties>
             </obj>)
       // 15.4.4 Properties of the Array Prototype Object
       (. => <obj>
               <oid> @ArrayProtoOid </oid>
               <properties>
                 "length"           |-> @desc("Value" |-> 0                                   "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> false) // 15.4.5.2 length
                 "constructor"      |-> @desc("Value" |-> @ArrayOid                           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.1 Array.prototype.constructor
                 "toString"         |-> @desc("Value" |-> @("Array.prototype.toString"      ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.2 Array.prototype.toString ( )
                 "toLocaleString"   |-> @desc("Value" |-> @("Array.prototype.toLocaleString") "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.3 Array.prototype.toLocaleString ( )
                 "concat"           |-> @desc("Value" |-> @("Array.prototype.concat"        ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.4 Array.prototype.concat ( [ item1 [ , item2 [ , ... ] ] ] )
                 "join"             |-> @desc("Value" |-> @("Array.prototype.join"          ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.5 Array.prototype.join (separator)
                 "pop"              |-> @desc("Value" |-> @("Array.prototype.pop"           ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.6 Array.prototype.pop ( )
                 "push"             |-> @desc("Value" |-> @("Array.prototype.push"          ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.7 Array.prototype.push ( [ item1 [ , item2 [ , ... ] ] ] )
                 "reverse"          |-> @desc("Value" |-> @("Array.prototype.reverse"       ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.8 Array.prototype.reverse ( )
                 "shift"            |-> @desc("Value" |-> @("Array.prototype.shift"         ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.9 Array.prototype.shift ( )
                 "slice"            |-> @desc("Value" |-> @("Array.prototype.slice"         ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.10 Array.prototype.slice (start, end)
                 "sort"             |-> @desc("Value" |-> @("Array.prototype.sort"          ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.11 Array.prototype.sort (comparefn)
                 "splice"           |-> @desc("Value" |-> @("Array.prototype.splice"        ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.12 Array.prototype.splice (start, deleteCount [ , item1 [ , item2 [ , ... ] ] ] )
                 "unshift"          |-> @desc("Value" |-> @("Array.prototype.unshift"       ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.13 Array.prototype.unshift ( [ item1 [ , item2 [ , ... ] ] ] )
                 "indexOf"          |-> @desc("Value" |-> @("Array.prototype.indexOf"       ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.14 Array.prototype.indexOf ( searchElement [ , fromIndex ] )
                 "lastIndexOf"      |-> @desc("Value" |-> @("Array.prototype.lastIndexOf"   ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.15 Array.prototype.lastIndexOf ( searchElement [ , fromIndex ] )
                 "every"            |-> @desc("Value" |-> @("Array.prototype.every"         ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.16 Array.prototype.every ( callbackfn [ , thisArg ] )
                 "some"             |-> @desc("Value" |-> @("Array.prototype.some"          ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.17 Array.prototype.some ( callbackfn [ , thisArg ] )
                 "forEach"          |-> @desc("Value" |-> @("Array.prototype.forEach"       ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.18 Array.prototype.forEach ( callbackfn [ , thisArg ] )
                 "map"              |-> @desc("Value" |-> @("Array.prototype.map"           ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.19 Array.prototype.map ( callbackfn [ , thisArg ] )
                 "filter"           |-> @desc("Value" |-> @("Array.prototype.filter"        ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.20 Array.prototype.filter ( callbackfn [ , thisArg ] )
                 "reduce"           |-> @desc("Value" |-> @("Array.prototype.reduce"        ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.21 Array.prototype.reduce ( callbackfn [ , initialValue ] )
                 "reduceRight"      |-> @desc("Value" |-> @("Array.prototype.reduceRight"   ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.4.4.22 Array.prototype.reduceRight ( callbackfn [ , initialValue ] )
               </properties>
               <internalProperties>
                 "Prototype"      |-> @ObjectProtoOid
                 "Class"          |-> "Array"
                 "Extensible"     |->  true
               </internalProperties>
             </obj>)

       // 15.5 String Objects
       (. => <obj>
               <oid> @StringOid </oid>
               // 15.5.3 Properties of the String Constructor
               <properties>
                 "length"           |-> @desc("Value" |-> 1                        "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.5.3 Properties of the String Constructor
                 "prototype"        |-> @desc("Value" |-> @StringProtoOid          "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.5.3.1 String.prototype
                 "fromCharCode"     |-> @desc("Value" |-> @("String.fromCharCode") "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.3.2 String.fromCharCode ( [ char0 [ , char1 [ , ... ] ] ] )
               </properties>
               <internalProperties>
                 "Prototype"        |-> @FunctionProtoOid
                 "Class"            |-> "Function"
                 "Extensible"       |-> true
               </internalProperties>
             </obj>)
       // 15.5.4 Properties of the String Prototype Object
       (. => <obj>
               <oid> @StringProtoOid </oid>
               <properties>
                 "length"            |-> @desc("Value" |-> 0                                       "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                 "constructor"       |-> @desc("Value" |-> @StringOid                              "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.1 String.prototype.constructor
                 "toString"          |-> @desc("Value" |-> @("String.prototype.toString"         ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.2 String.prototype.toString ( )
                 "valueOf"           |-> @desc("Value" |-> @("String.prototype.valueOf"          ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.3 String.prototype.valueOf ( )
                 "charAt"            |-> @desc("Value" |-> @("String.prototype.charAt"           ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.4 String.prototype.charAt (pos)
                 "charCodeAt"        |-> @desc("Value" |-> @("String.prototype.charCodeAt"       ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.5 String.prototype.charCodeAt (pos)
                 "concat"            |-> @desc("Value" |-> @("String.prototype.concat"           ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.6 String.prototype.concat ( [ string1 [ , string2 [ , ... ] ] ] )
                 "indexOf"           |-> @desc("Value" |-> @("String.prototype.indexOf"          ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.7 String.prototype.indexOf (searchString, position)
                 "lastIndexOf"       |-> @desc("Value" |-> @("String.prototype.lastIndexOf"      ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.8 String.prototype.lastIndexOf (searchString, position)
                 "localeCompare"     |-> @desc("Value" |-> @("String.prototype.localeCompare"    ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.9 String.prototype.localeCompare (that)
                 "match"             |-> @desc("Value" |-> @("String.prototype.match"            ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.10 String.prototype.match (regexp)
                 "replace"           |-> @desc("Value" |-> @("String.prototype.replace"          ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.11 String.prototype.replace (searchValue, replaceValue)
                 "search"            |-> @desc("Value" |-> @("String.prototype.search"           ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.12 String.prototype.search (regexp)
                 "slice"             |-> @desc("Value" |-> @("String.prototype.slice"            ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.13 String.prototype.slice (start, end)
                 "split"             |-> @desc("Value" |-> @("String.prototype.split"            ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.14 String.prototype.split (separator, limit)
                 "substring"         |-> @desc("Value" |-> @("String.prototype.substring"        ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.15 String.prototype.substring (start, end)
                 "toLowerCase"       |-> @desc("Value" |-> @("String.prototype.toLowerCase"      ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.16 String.prototype.toLowerCase ( )
                 "toLocaleLowerCase" |-> @desc("Value" |-> @("String.prototype.toLocaleLowerCase") "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.17 String.prototype.toLocaleLowerCase ( )
                 "toUpperCase"       |-> @desc("Value" |-> @("String.prototype.toUpperCase"      ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.18 String.prototype.toUpperCase ( )
                 "toLocaleUpperCase" |-> @desc("Value" |-> @("String.prototype.toLocaleUpperCase") "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.19 String.prototype.toLocaleUpperCase ( )
                 "trim"              |-> @desc("Value" |-> @("String.prototype.trim"             ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.4.20 String.prototype.trim ( )
               </properties>
               <internalProperties>
                 "Prototype"      |-> @ObjectProtoOid
                 "Class"          |-> "String"
                 "Extensible"     |->  true
                 "PrimitiveValue" |-> ""
               </internalProperties>
             </obj>)

       // 15.6 Boolean Objects
       (. => <obj>
               <oid> @BooleanOid </oid>
               // 15.6.3 Properties of the Boolean Constructor
               <properties>
                 "length"           |-> @desc("Value" |-> 1                "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                 "prototype"        |-> @desc("Value" |-> @BooleanProtoOid "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.6.3.1 Boolean.prototype
               </properties>
               <internalProperties>
                 "Prototype"        |-> @FunctionProtoOid
                 "Class"            |-> "Function"
                 "Extensible"       |-> true
               </internalProperties>
             </obj>)
       // 15.6.4 Properties of the Boolean Prototype Object
       (. => <obj>
               <oid> @BooleanProtoOid </oid>
               <properties>
                 "constructor"      |-> @desc("Value" |-> @BooleanOid                     "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.6.4.1 Boolean.prototype.constructor
                 "toString"         |-> @desc("Value" |-> @("Boolean.prototype.toString") "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.6.4.2 Boolean.prototype.toString ( )
                 "valueOf"          |-> @desc("Value" |-> @("Boolean.prototype.valueOf")  "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.6.4.3 Boolean.prototype.valueOf ( )
               </properties>
               <internalProperties>
                 "Prototype"      |-> @ObjectProtoOid
                 "Class"          |-> "Boolean"
                 "Extensible"     |->  true
                 "PrimitiveValue" |-> false
               </internalProperties>
             </obj>)

       // 15.7 Number Objects
       (. => <obj>
               <oid> @NumberOid </oid>
               // 15.7.3 Properties of the Number Constructor
               <properties>
                 "length"            |-> @desc("Value" |-> 1                      "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                 "prototype"         |-> @desc("Value" |-> @NumberProtoOid        "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.7.3.1 Number.prototype
                 "MAX_VALUE"         |-> @desc("Value" |-> 1.7976931348623157e308 "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.7.3.2 Number.MAX_VALUE
                 "MIN_VALUE"         |-> @desc("Value" |-> 4.9e-324               "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.7.3.3 Number.MIN_VALUE
                 "NaN"               |-> @desc("Value" |-> @NaN                   "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.7.3.4 Number.NaN
                 "NEGATIVE_INFINITY" |-> @desc("Value" |-> @-Infinity             "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.7.3.5 Number.NEGATIVE_INFINITY
                 "POSITIVE_INFINITY" |-> @desc("Value" |-> @+Infinity             "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.7.3.6 Number.POSITIVE_INFINITY
               </properties>
               <internalProperties>
                 "Prototype"        |-> @FunctionProtoOid
                 "Class"            |-> "Function"
                 "Extensible"       |-> true
               </internalProperties>
             </obj>)
       // 15.7.4 Properties of the Number Prototype Object
       (. => <obj>
               <oid> @NumberProtoOid </oid>
               <properties>
                 "constructor"      |-> @desc("Value" |-> @NumberOid                           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.7.4.1 Number.prototype.constructor
                 "toString"         |-> @desc("Value" |-> @("Number.prototype.toString")       "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.7.4.2 Number.prototype.toString ( [ radix ] )
                 "toLocaleString"   |-> @desc("Value" |-> @("Number.prototype.toLocaleString") "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.7.4.3 Number.prototype.toLocaleString()
                 "valueOf"          |-> @desc("Value" |-> @("Number.prototype.valueOf")        "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.7.4.4 Number.prototype.valueOf ( )
                 "toFixed"          |-> @desc("Value" |-> @("Number.prototype.toFixed")        "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.7.4.5 Number.prototype.toFixed (fractionDigits)
                 "toExponential"    |-> @desc("Value" |-> @("Number.prototype.toExponential")  "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.7.4.6 Number.prototype.toExponential (fractionDigits)
                 "toPrecision"      |-> @desc("Value" |-> @("Number.prototype.toPrecision")    "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.7.4.7 Number.prototype.toPrecision (precision)
               </properties>
               <internalProperties>
                 "Prototype"      |-> @ObjectProtoOid
                 "Class"          |-> "Number"
                 "Extensible"     |->  true
                 "PrimitiveValue" |-> 0
               </internalProperties>
             </obj>)

       // 15.8 The Math Object
       (. => <obj>
               <oid> @MathOid </oid>
               <properties>
                 // 15.8.1 Value Properties of the Math Object
                 "E"       |-> @desc("Value" |-> 2.7182818284590452354 "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.8.1.1 E
                 "LN10"    |-> @desc("Value" |-> 2.302585092994046     "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.8.1.2 LN10
                 "LN2"     |-> @desc("Value" |-> 0.6931471805599453    "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.8.1.3 LN2
                 "LOG2E"   |-> @desc("Value" |-> 1.4426950408889634    "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.8.1.4 LOG2E
                 "LOG10E"  |-> @desc("Value" |-> 0.4342944819032518    "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.8.1.5 LOG10E
                 "PI"      |-> @desc("Value" |-> 3.1415926535897932    "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.8.1.6 PI
                 "SQRT1_2" |-> @desc("Value" |-> 0.7071067811865476    "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.8.1.7 SQRT1_2
                 "SQRT2"   |-> @desc("Value" |-> 1.4142135623730951    "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.8.1.8 SQRT2
                 // 15.8.2 Function Properties of the Math Object
                 "abs"     |-> @desc("Value" |-> @("abs"   )           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.8.2.1 abs (x)
                 "acos"    |-> @desc("Value" |-> @("acos"  )           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.8.2.2 acos (x)
                 "asin"    |-> @desc("Value" |-> @("asin"  )           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.8.2.3 asin (x)
                 "atan"    |-> @desc("Value" |-> @("atan"  )           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.8.2.4 atan (x)
                 "atan2"   |-> @desc("Value" |-> @("atan2" )           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.8.2.5 atan2 (y, x)
                 "ceil"    |-> @desc("Value" |-> @("ceil"  )           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.8.2.6 ceil (x)
                 "cos"     |-> @desc("Value" |-> @("cos"   )           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.8.2.7 cos (x)
                 "exp"     |-> @desc("Value" |-> @("exp"   )           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.8.2.8 exp (x)
                 "floor"   |-> @desc("Value" |-> @("floor" )           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.8.2.9 floor (x)
                 "log"     |-> @desc("Value" |-> @("log"   )           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.8.2.10 log (x)
                 "max"     |-> @desc("Value" |-> @("max"   )           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.8.2.11 max ( [ value1 [ , value2 [ , ... ] ] ] )
                 "min"     |-> @desc("Value" |-> @("min"   )           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.8.2.12 min ( [ value1 [ , value2 [ , ... ] ] ] )
                 "pow"     |-> @desc("Value" |-> @("pow"   )           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.8.2.13 pow (x, y)
                 "random"  |-> @desc("Value" |-> @("random")           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.8.2.14 random ( )
                 "round"   |-> @desc("Value" |-> @("round" )           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.8.2.15 round (x)
                 "sin"     |-> @desc("Value" |-> @("sin"   )           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.8.2.16 sin (x)
                 "sqrt"    |-> @desc("Value" |-> @("sqrt"  )           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.8.2.17 sqrt (x)
                 "tan"     |-> @desc("Value" |-> @("tan"   )           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.8.2.18 tan (x)
               </properties>
               <internalProperties>
                 "Prototype"        |-> @ObjectProtoOid
                 "Class"            |-> "Math"
                 "Extensible"       |-> true
               </internalProperties>
             </obj>)

       // 15.9 Date Objects
       (. => <obj>
               <oid> @DateOid </oid>
               // 15.9.4 Properties of the Date Constructor
               <properties>
                 "length"            |-> @desc("Value" |-> 7                      "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                 "prototype"         |-> @desc("Value" |-> @DateProtoOid          "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.9.4.1 Date.prototype
                 "parse"             |-> @desc("Value" |-> @("Date.parse")        "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.9.4.2 Date.parse (string)
                 "UTC"               |-> @desc("Value" |-> @("Date.UTC"  )        "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.9.4.3 Date.UTC (year, month [, date [, hours [, minutes [, seconds [, ms ] ] ] ] ] )
                 "now"               |-> @desc("Value" |-> @("Date.now"  )        "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.9.4.4 Date.now ( )
               </properties>
               <internalProperties>
                 "Prototype"        |-> @FunctionProtoOid
                 "Class"            |-> "Function"
                 "Extensible"       |-> true
               </internalProperties>
             </obj>)
       // 15.9.5 Properties of the Date Prototype Object
       (. => <obj>
               <oid> @DateProtoOid </oid>
               <properties>
                 "constructor"         |-> @desc("Value" |-> @DateOid                                 "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.1 Date.prototype.constructor
                 "toString"            |-> @desc("Value" |-> @("Date.prototype.toString")             "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.2 Date.prototype.toString ( )
                 "toDateString"        |-> @desc("Value" |-> @("Date.prototype.toDateString")         "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.3 Date.prototype.toDateString ( )
                 "toTimeString"        |-> @desc("Value" |-> @("Date.prototype.toTimeString")         "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.4 Date.prototype.toTimeString ( )
                 "toLocaleString"      |-> @desc("Value" |-> @("Date.prototype.toLocaleString")       "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.5 Date.prototype.toLocaleString ( )
                 "toLocaleDateString"  |-> @desc("Value" |-> @("Date.prototype.toLocaleDateString")   "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.6 Date.prototype.toLocaleDateString ( )
                 "toLocaleTimeString"  |-> @desc("Value" |-> @("Date.prototype.toLocaleTimeString")   "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.7 Date.prototype.toLocaleTimeString ( )
                 "valueOf"             |-> @desc("Value" |-> @("Date.prototype.valueOf")              "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.8 Date.prototype.valueOf ( )
                 "getTime"             |-> @desc("Value" |-> @("Date.prototype.getTime")              "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.9 Date.prototype.getTime ( )
                 "getFullYear"         |-> @desc("Value" |-> @("Date.prototype.getFullYear")          "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.10 Date.prototype.getFullYear ( )
                 "getUTCFullYear"      |-> @desc("Value" |-> @("Date.prototype.getUTCFullYear")       "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.11 Date.prototype.getUTCFullYear ( )
                 "getMonth"            |-> @desc("Value" |-> @("Date.prototype.getMonth")             "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.12 Date.prototype.getMonth ( )
                 "getUTCMonth"         |-> @desc("Value" |-> @("Date.prototype.getUTCMonth")          "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.13 Date.prototype.getUTCMonth ( )
                 "getDate"             |-> @desc("Value" |-> @("Date.prototype.getDate")              "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.14 Date.prototype.getDate ( )
                 "getUTCDate"          |-> @desc("Value" |-> @("Date.prototype.getUTCDate")           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.15 Date.prototype.getUTCDate ( )
                 "getDay"              |-> @desc("Value" |-> @("Date.prototype.getDay")               "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.16 Date.prototype.getDay ( )
                 "getUTCDay"           |-> @desc("Value" |-> @("Date.prototype.getUTCDay")            "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.17 Date.prototype.getUTCDay ( )
                 "getHours"            |-> @desc("Value" |-> @("Date.prototype.getHours")             "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.18 Date.prototype.getHours ( )
                 "getUTCHours"         |-> @desc("Value" |-> @("Date.prototype.getUTCHours")          "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.19 Date.prototype.getUTCHours ( )
                 "getMinutes"          |-> @desc("Value" |-> @("Date.prototype.getMinutes")           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.20 Date.prototype.getMinutes ( )
                 "getUTCMinutes"       |-> @desc("Value" |-> @("Date.prototype.getUTCMinutes")        "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.21 Date.prototype.getUTCMinutes ( )
                 "getSeconds"          |-> @desc("Value" |-> @("Date.prototype.getSeconds")           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.22 Date.prototype.getSeconds ( )
                 "getUTCSeconds"       |-> @desc("Value" |-> @("Date.prototype.getUTCSeconds")        "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.23 Date.prototype.getUTCSeconds ( )
                 "getMilliseconds"     |-> @desc("Value" |-> @("Date.prototype.getMilliseconds")      "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.24 Date.prototype.getMilliseconds ( )
                 "getUTCMilliseconds"  |-> @desc("Value" |-> @("Date.prototype.getUTCMilliseconds")   "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.25 Date.prototype.getUTCMilliseconds ( )
                 "getTimezoneOffset"   |-> @desc("Value" |-> @("Date.prototype.getTimezoneOffset")    "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.26 Date.prototype.getTimezoneOffset ( )
                 "setTime"             |-> @desc("Value" |-> @("Date.prototype.setTime")              "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.27 Date.prototype.setTime (time)
                 "setMilliseconds"     |-> @desc("Value" |-> @("Date.prototype.setMilliseconds")      "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.28 Date.prototype.setMilliseconds (ms)
                 "setUTCMilliseconds"  |-> @desc("Value" |-> @("Date.prototype.setUTCMilliseconds")   "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.29 Date.prototype.setUTCMilliseconds (ms)
                 "setSeconds"          |-> @desc("Value" |-> @("Date.prototype.setSeconds")           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.30 Date.prototype.setSeconds (sec [, ms ] )
                 "setUTCSeconds"       |-> @desc("Value" |-> @("Date.prototype.setUTCSeconds")        "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.31 Date.prototype.setUTCSeconds (sec [, ms ] )
                 "setMinutes"          |-> @desc("Value" |-> @("Date.prototype.setMinutes")           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.32 Date.prototype.setMinutes (min [, sec [, ms ] ] )
                 "setUTCMinutes"       |-> @desc("Value" |-> @("Date.prototype.setUTCMinutes")        "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.33 Date.prototype.setUTCMinutes (min [, sec [, ms ] ] )
                 "setHours"            |-> @desc("Value" |-> @("Date.prototype.setHours")             "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.34 Date.prototype.setHours (hour [, min [, sec [, ms ] ] ] )
                 "setUTCHours"         |-> @desc("Value" |-> @("Date.prototype.setUTCHours")          "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.35 Date.prototype.setUTCHours (hour [, min [, sec [, ms ] ] ] )
                 "setDate"             |-> @desc("Value" |-> @("Date.prototype.setDate")              "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.36 Date.prototype.setDate (date)
                 "setUTCDate"          |-> @desc("Value" |-> @("Date.prototype.setUTCDate")           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.37 Date.prototype.setUTCDate (date)
                 "setMonth"            |-> @desc("Value" |-> @("Date.prototype.setMonth")             "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.38 Date.prototype.setMonth (month [, date ] )
                 "setUTCMonth"         |-> @desc("Value" |-> @("Date.prototype.setUTCMonth")          "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.39 Date.prototype.setUTCMonth (month [, date ] )
                 "setFullYear"         |-> @desc("Value" |-> @("Date.prototype.setFullYear")          "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.40 Date.prototype.setFullYear (year [, month [, date ] ] )
                 "setUTCFullYear"      |-> @desc("Value" |-> @("Date.prototype.setUTCFullYear")       "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.41 Date.prototype.setUTCFullYear (year [, month [, date ] ] )
                 "toUTCString"         |-> @desc("Value" |-> @("Date.prototype.toUTCString")          "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.42 Date.prototype.toUTCString ( )
                 "toISOString"         |-> @desc("Value" |-> @("Date.prototype.toISOString")          "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.43 Date.prototype.toISOString ( )
                 "toJSON"              |-> @desc("Value" |-> @("Date.prototype.toJSON")               "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.9.5.44 Date.prototype.toJSON ( key )
               </properties>
               <internalProperties>
                 "Prototype"      |-> @ObjectProtoOid
                 "Class"          |-> "Date"
                 "Extensible"     |->  true
                 "PrimitiveValue" |-> @NaN
               </internalProperties>
             </obj>)

       // 15.10 RegExp (Regular Expression) Objects
       (. => <obj>
               <oid> @RegExpOid </oid>
               // 15.10.5 Properties of the RegExp Constructor
               <properties>
                 "length"            |-> @desc("Value" |-> 2                      "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                 "prototype"         |-> @desc("Value" |-> @RegExpProtoOid        "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.10.5.1 RegExp.prototype
               </properties>
               <internalProperties>
                 "Prototype"        |-> @FunctionProtoOid
                 "Class"            |-> "Function"
                 "Extensible"       |-> true
               </internalProperties>
             </obj>)
       // 15.10.6 Properties of the RegExp Prototype Object
       (. => <obj>
               <oid> @RegExpProtoOid </oid>
               <properties>
                 "constructor"      |-> @desc("Value" |-> @RegExpOid                             "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.10.6.1 RegExp.prototype.constructor
                 "exec"             |-> @desc("Value" |-> @("RegExp.prototype.exec"    )         "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.10.6.2 RegExp.prototype.exec(string)
                 "test"             |-> @desc("Value" |-> @("RegExp.prototype.test"    )         "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.10.6.3 RegExp.prototype.test(string)
                 "toString"         |-> @desc("Value" |-> @("RegExp.prototype.toString")         "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.10.6.4 RegExp.prototype.toString()
                 // 15.10.7 Properties of RegExp Instances
                 "source"      |-> @desc("Value" |-> ""    "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.10.7.1 source
                 "global"      |-> @desc("Value" |-> false "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.10.7.2 global
                 "ignoreCase"  |-> @desc("Value" |-> false "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.10.7.3 ignoreCase
                 "multiline"   |-> @desc("Value" |-> false "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.10.7.4 multiline
                 "lastIndex"   |-> @desc("Value" |-> 0     "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> false) // 15.10.7.5 lastIndex
               </properties>
               <internalProperties>
                 "Prototype"      |-> @ObjectProtoOid
                 "Class"          |-> "RegExp"
                 "Extensible"     |->  true
               </internalProperties>
             </obj>)

       // 15.11 ErrorObjects
       (. => <obj>
               <oid> @ErrorOid </oid>
               // 15.11.3 Properties of the Error Constructor
               <properties>
                 "length"            |-> @desc("Value" |-> 1              "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                 "prototype"         |-> @desc("Value" |-> @ErrorProtoOid "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.11.3.1 Error.prototype
               </properties>
               <internalProperties>
                 "Prototype"        |-> @FunctionProtoOid
                 "Class"            |-> "Function"
                 "Extensible"       |-> true
               </internalProperties>
             </obj>)
       // 15.11.4 Properties of the Error Prototype Object
       (. => <obj>
               <oid> @ErrorProtoOid </oid>
               <properties>
                 "constructor"      |-> @desc("Value" |-> @ErrorOid                     "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.4.1 Error.prototype.constructor
                 "name"             |-> @desc("Value" |-> "Error"                       "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.4.2 Error.prototype.name
                 "message"          |-> @desc("Value" |-> ""                            "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.4.3 Error.prototype.message
                 "toString"         |-> @desc("Value" |-> @("Error.prototype.toString") "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.4.4 Error.prototype.toString ( )
               </properties>
               <internalProperties>
                 "Prototype"      |-> @ObjectProtoOid
                 "Class"          |-> "Error"
                 "Extensible"     |-> true
               </internalProperties>
             </obj>)

       // 15.11.7 NativeError Object Structure
       // 15.11.7.11 Properties of NativeError Instances
       (. => <obj>
               <oid> @EvalErrorOid </oid>
               // 15.11.7.5 Properties of the NativeError Constructors
               <properties>
                 "length"            |-> @desc("Value" |-> 1                  "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                 "prototype"         |-> @desc("Value" |-> @EvalErrorProtoOid "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.11.7.6 NativeError.prototype
               </properties>
               <internalProperties>
                 "Prototype"        |-> @FunctionProtoOid
                 "Class"            |-> "Function"
                 "Extensible"       |-> true
               </internalProperties>
             </obj>)
       (. => <obj>
               <oid> @RangeErrorOid </oid>
               // 15.11.7.5 Properties of the NativeError Constructors
               <properties>
                 "length"            |-> @desc("Value" |-> 1                   "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                 "prototype"         |-> @desc("Value" |-> @RangeErrorProtoOid "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.11.7.6 NativeError.prototype
               </properties>
               <internalProperties>
                 "Prototype"        |-> @FunctionProtoOid
                 "Class"            |-> "Function"
                 "Extensible"       |-> true
               </internalProperties>
             </obj>)
       (. => <obj>
               <oid> @ReferenceErrorOid </oid>
               // 15.11.7.5 Properties of the NativeError Constructors
               <properties>
                 "length"            |-> @desc("Value" |-> 1                       "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                 "prototype"         |-> @desc("Value" |-> @ReferenceErrorProtoOid "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.11.7.6 NativeError.prototype
               </properties>
               <internalProperties>
                 "Prototype"        |-> @FunctionProtoOid
                 "Class"            |-> "Function"
                 "Extensible"       |-> true
               </internalProperties>
             </obj>)
       (. => <obj>
               <oid> @SyntaxErrorOid </oid>
               // 15.11.7.5 Properties of the NativeError Constructors
               <properties>
                 "length"            |-> @desc("Value" |-> 1                    "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                 "prototype"         |-> @desc("Value" |-> @SyntaxErrorProtoOid "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.11.7.6 NativeError.prototype
               </properties>
               <internalProperties>
                 "Prototype"        |-> @FunctionProtoOid
                 "Class"            |-> "Function"
                 "Extensible"       |-> true
               </internalProperties>
             </obj>)
       (. => <obj>
               <oid> @TypeErrorOid </oid>
               // 15.11.7.5 Properties of the NativeError Constructors
               <properties>
                 "length"            |-> @desc("Value" |-> 1                  "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                 "prototype"         |-> @desc("Value" |-> @TypeErrorProtoOid "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.11.7.6 NativeError.prototype
               </properties>
               <internalProperties>
                 "Prototype"        |-> @FunctionProtoOid
                 "Class"            |-> "Function"
                 "Extensible"       |-> true
               </internalProperties>
             </obj>)
       (. => <obj>
               <oid> @URIErrorOid </oid>
               // 15.11.7.5 Properties of the NativeError Constructors
               <properties>
                 "length"            |-> @desc("Value" |-> 1                 "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                 "prototype"         |-> @desc("Value" |-> @URIErrorProtoOid "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.11.7.6 NativeError.prototype
               </properties>
               <internalProperties>
                 "Prototype"        |-> @FunctionProtoOid
                 "Class"            |-> "Function"
                 "Extensible"       |-> true
               </internalProperties>
             </obj>)
       // 15.11.7.7 Properties of the NativeError Prototype Objects
       (. => <obj>
               <oid> @EvalErrorProtoOid </oid>
               <properties>
                 "constructor"      |-> @desc("Value" |-> @EvalErrorOid            "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.7.8 NativeError.prototype.constructor
                 "name"             |-> @desc("Value" |-> "EvalError"              "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.7.9 NativeError.prototype.name
                 "message"          |-> @desc("Value" |-> ""                       "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.7.10 NativeError.prototype.message
               </properties>
               <internalProperties>
                 "Prototype"      |-> @ErrorProtoOid
                 "Class"          |-> "Error"
                 "Extensible"     |-> true
               </internalProperties>
             </obj>)
       (. => <obj>
               <oid> @RangeErrorProtoOid </oid>
               <properties>
                 "constructor"      |-> @desc("Value" |-> @RangeErrorOid            "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.7.8 NativeError.prototype.constructor
                 "name"             |-> @desc("Value" |-> "RangeError"              "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.7.9 NativeError.prototype.name
                 "message"          |-> @desc("Value" |-> ""                        "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.7.10 NativeError.prototype.message
               </properties>
               <internalProperties>
                 "Prototype"      |-> @ErrorProtoOid
                 "Class"          |-> "Error"
                 "Extensible"     |-> true
               </internalProperties>
             </obj>)
       (. => <obj>
               <oid> @ReferenceErrorProtoOid </oid>
               <properties>
                 "constructor"      |-> @desc("Value" |-> @ReferenceErrorOid            "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.7.8 NativeError.prototype.constructor
                 "name"             |-> @desc("Value" |-> "ReferenceError"              "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.7.9 NativeError.prototype.name
                 "message"          |-> @desc("Value" |-> ""                            "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.7.10 NativeError.prototype.message
               </properties>
               <internalProperties>
                 "Prototype"      |-> @ErrorProtoOid
                 "Class"          |-> "Error"
                 "Extensible"     |-> true
               </internalProperties>
             </obj>)
       (. => <obj>
               <oid> @SyntaxErrorProtoOid </oid>
               <properties>
                 "constructor"      |-> @desc("Value" |-> @SyntaxErrorOid            "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.7.8 NativeError.prototype.constructor
                 "name"             |-> @desc("Value" |-> "SyntaxError"              "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.7.9 NativeError.prototype.name
                 "message"          |-> @desc("Value" |-> ""                         "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.7.10 NativeError.prototype.message
               </properties>
               <internalProperties>
                 "Prototype"      |-> @ErrorProtoOid
                 "Class"          |-> "Error"
                 "Extensible"     |-> true
               </internalProperties>
             </obj>)
       (. => <obj>
               <oid> @TypeErrorProtoOid </oid>
               <properties>
                 "constructor"      |-> @desc("Value" |-> @TypeErrorOid            "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.7.8 NativeError.prototype.constructor
                 "name"             |-> @desc("Value" |-> "TypeError"              "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.7.9 NativeError.prototype.name
                 "message"          |-> @desc("Value" |-> ""                       "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.7.10 NativeError.prototype.message
               </properties>
               <internalProperties>
                 "Prototype"      |-> @ErrorProtoOid
                 "Class"          |-> "Error"
                 "Extensible"     |-> true
               </internalProperties>
             </obj>)
       (. => <obj>
               <oid> @URIErrorProtoOid </oid>
               <properties>
                 "constructor"      |-> @desc("Value" |-> @URIErrorOid            "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.7.8 NativeError.prototype.constructor
                 "name"             |-> @desc("Value" |-> "URIError"              "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.7.9 NativeError.prototype.name
                 "message"          |-> @desc("Value" |-> ""                      "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.11.7.10 NativeError.prototype.message
               </properties>
               <internalProperties>
                 "Prototype"      |-> @ErrorProtoOid
                 "Class"          |-> "Error"
                 "Extensible"     |-> true
               </internalProperties>
             </obj>)

       // 15.12 The JSON Object
       (. => <obj>
               <oid> @JSONOid </oid>
               <properties>
                 "parse"     |-> @desc("Value" |-> @("parse"    ) "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.12.2 parse ( text [ , reviver ] )
                 "stringify" |-> @desc("Value" |-> @("stringify") "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.12.3 stringify ( value [ , replacer [ , space ] ] )
               </properties>
               <internalProperties>
                 "Prototype"        |-> @ObjectProtoOid
                 "Class"            |-> "JSON"
                 "Extensible"       |-> true
               </internalProperties>
             </obj>)

     </objs>
