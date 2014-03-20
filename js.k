require "builtins/mint.k"
require "modules/substitution.k"
require "js-trans.k"

module JS

imports MINT
imports SUBSTITUTION
imports JS-TRANS

//////////////////////////////////////////////////////////////////////////////
// Configuration
//////////////////////////////////////////////////////////////////////////////

syntax K ::= "@Run" "(" Stmt ")"
rule @Run(Pgm:Stmt) => @EnterGlobalCode(Pgm) ~> Pgm

configuration
<T>
  <k> @InitConfig ~> @Run(^SourceElements($PGM:SourceElements)) </k>
  <objs>
    // 8.6 The Object Type
    <obj multiplicity="*">
      <oid> .K </oid> // Oid
      <properties> .Map </properties> // Var -> PropertyDescriptor
      <internalProperties> .Map </internalProperties> // Var -> PropertyDescriptor
    </obj>
  </objs>
  <envs>
    // 10.2 Lexical Environments
    <env multiplicity="*">
      <eid> .K </eid> // Eid
      <outer> .K </outer> // Eid // Reference to an outer Lexical Environment
      <strict> .K </strict> // Bool
      // 10.2.1 Environment Records
      // Either declarative or object environment record
        // 10.2.1.1 Declarative Environment Records
        <declEnvRec multiplicity="?"> .Map </declEnvRec> // Var -> ValEnv
        // 10.2.1.2 Object Environment Records
        <objEnvRec multiplicity="?">
          <bindingObj> .K </bindingObj> // Oid
          <provideThis> .K </provideThis> // Bool
        </objEnvRec>
    </env>
  </envs>
  <ctrl>
    // 10.3 Execution Contexts
    <ctx>
      // Active Execution Contexts
      <activeStack> .List </activeStack>
      // Running Execution Context
      <running>
        // Table 19 Execution Context State Components
        <lexicalEnv> .K </lexicalEnv> // Eid
        <thisBinding> .K </thisBinding> // Oid + @Undefined
        <lastNonEmptyValue> .K </lastNonEmptyValue> // Val // last non-empty stmt value to be used by eval
      </running>
    </ctx>
    <excStack> .List </excStack>
    <pseudoStack> .List </pseudoStack>
  </ctrl>
  <in stream="stdin"> .List </in>
  <out stream="stdout"> .List </out>
  <log> .List </log>
</T>

// <properties>
// 8.6.1 Property Attribute
// 8.10 The Property Descriptor and Property Identifier Specification Types
syntax PropertyDescriptor ::= "@desc" "(" Map ")"
syntax Val ::= PropertyDescriptor

// <declEnvRec>
syntax Val ::= "@ve" "(" Val "," Bool "," Bool "," Bool ")" // ValEnv = Value * Initialized * Mutable * Deletable

// <activeStack>
syntax ListItem ::= "@active" "(" RunningCellFragment ")"

// <excStack>
syntax ListItem ::= "@excTC"  "(" Var "," Stmt ","          K "," CtrlCellFragment ")"
                  | "@excTF"  "("                  Stmt "," K "," CtrlCellFragment ")"
                  | "@excTCF" "(" Var "," Stmt "," Stmt "," K "," CtrlCellFragment ")"

// <pseudoStack>
syntax ListItem ::= "@pseudo" "(" K ")"

//////////////////////////////////////////////////////////////////////////////
// Values
//////////////////////////////////////////////////////////////////////////////

// KResult            8    Types
// @Undefined         8.1  The Undefined Type
// @NullVal           8.2  The Null Type
// Bool               8.3  The Boolean Type
// String             8.4  The String Type
// Number             8.5  The Number Type
// Oid                8.6  The Object Type
// Reference          8.7  The Reference Specification Type
// Vals               8.8  The List Specification Type
// CompletionType     8.9  The Completion Specification Type
// PropertyDescriptor 8.10 The Property Descriptor and Property Identifier Specification Types
// Eid                8.11 The Lexical Environment and Environment Record Specification Types

// 8.8 The List Specification Type
syntax Vals ::= "@Cons" "(" Val "," Vals ")"
              | "@Nil"
syntax Val  ::= "@Undefined" // 8.1 The Undefined Type
              | "@NullVal" // 8.2 The Null Type
              | Primitive
              | Oid
            //| Reference // NOTE: We made it using isVal
// 8.6 The Object Type
syntax Oid  ::= "@o" "(" Int ")"
              | "@NullOid"
// 8.11 The Lexical Environment and Environment Record Specification Types
syntax Eid  ::= "@e" "(" Int ")"
              | "@NullEid"

syntax Primitive ::= Bool // 8.3 The Boolean Type
                   | String // 8.4 The String Type
                   | Number
// 8.5 The Number Type
syntax Number    ::= Int
                   | Float
                   | "@nz" // negative zero: -0 // TODO: make it systematically using artifical number type with explicit sign
                   | "@NaN"
                   | "@+Infinity"
                   | "@-Infinity"

// Subsorts information
syntax Exps    ::= Vals
syntax Exp     ::= Val
syntax KResult ::= Vals
                 | Val

// TODO: Check if it is correct
syntax KResult ::= Var
                 | Eid

// 8.9 The Completion Specification Type

syntax CompletionType ::= CompletionTypeNormal
                        | CompletionTypeAbrupt

syntax CompletionTypeNormal ::= "@Normal"

syntax CompletionTypeAbrupt ::= CompletionTypeGoto
                              | CompletionTypeReturn
syntax CompletionTypeGoto   ::= "@Break"    "(" Var ")"
                              | "@Continue" "(" Var ")"
syntax CompletionTypeReturn ::= "@Return"   "(" Val ")"
syntax K                    ::= "@Throw"    "(" K /* Val */ ")" [seqstrict(1)] // NOTE: @Throw is no longer a completion type. Rather, we use another exception handling mechanism.

syntax KResult ::= CompletionType
syntax Stmt    ::= CompletionType

// TODO: check if we can describe without following
syntax KResult ::= "@m" "(" Map ")"
syntax KResult ::= "@s" "(" Set ")"

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

syntax K /* .K */ ::= "@InitConfig"
// TODO: More initializations
rule <k> @InitConfig => . ... </k>
     // 15 Standard Built-in ECMAScript Objects
     <objs>
       // 15.1 The Global Object
       (. => <obj>
               <oid> @GlobalOid </oid>
               <properties>
                 // 15.1.1 Value Properties of the Global Object
                 "window"         |-> @desc("Value" |-> @GlobalOid         "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1 The Global Object
                 "NaN"            |-> @desc("Value" |-> @NaN               "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.1.1.1 NaN
                 "Infinity"       |-> @desc("Value" |-> @+Infinity         "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.1.1.2 Infinity
                 "undefined"      |-> @desc("Value" |-> @Undefined         "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.1.1.3 undefined
                 // 15.1.2 Function Properties of the Global Object
                 "eval"           |-> @desc("Value" |-> @("eval_i")        "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.1.2.1 eval (x)
                 "parseInt"       |-> @desc("Value" |-> @("parseInt")      "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.1.2.2 parseInt (string , radix)
                 "parseFloat"     |-> @desc("Value" |-> @("parseFloat")    "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.1.2.3 parseFloat (string)
                 "isNaN"          |-> @desc("Value" |-> @("isNaN")         "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.1.2.4 isNaN (number)
                 "isFinite"       |-> @desc("Value" |-> @("isFinite")      "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.1.2.5 isFinite (number)
                 // 15.1.3 URI Handling Function Properties // TODO:
                 // 15.1.4 Constructor Properties of the Global Object
                 "Object"         |-> @desc("Value" |-> @ObjectOid         "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.1 Object ( . . . )
                 "Function"       |-> @desc("Value" |-> @FunctionOid       "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.2 Function ( . . . )
                 "Array"          |-> @desc("Value" |-> @ArrayOid          "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.3 Array ( . . . )
                 "String"         |-> @desc("Value" |-> @StringOid         "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.4 String ( . . . )
                 "Boolean"        |-> @desc("Value" |-> @BooleanOid        "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.5 Boolean ( . . . )
                 "Number"         |-> @desc("Value" |-> @NumberOid         "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.6 Number ( . . . )
                 "Date"           |-> @desc("Value" |-> @DateOid           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.7 Date ( . . . )
                 "RegExp"         |-> @desc("Value" |-> @RegExpOid         "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.8 RegExp ( . . . )
                 "Error"          |-> @desc("Value" |-> @ErrorOid          "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.9 Error ( . . . ) 
                 "EvalError"      |-> @desc("Value" |-> @EvalErrorOid      "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.10 EvalError ( . . . )
                 "RangeError"     |-> @desc("Value" |-> @RangeErrorOid     "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.11 RangeError ( . . . )
                 "ReferenceError" |-> @desc("Value" |-> @ReferenceErrorOid "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.12 ReferenceError ( . . . )
                 "SyntaxError"    |-> @desc("Value" |-> @SyntaxErrorOid    "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.13 SyntaxError ( . . . )
                 "TypeError"      |-> @desc("Value" |-> @TypeErrorOid      "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.14 TypeError ( . . . )
                 "URIError"       |-> @desc("Value" |-> @URIErrorOid       "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.15 URIError ( . . . )
                 // 15.1.5 Other Properties of the Global Object
                 "Math"           |-> @desc("Value" |-> @MathOid           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.5.1 Math
                 "JSON"           |-> @desc("Value" |-> @JSONOid           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.5.2 JSON
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
       // 15.2.5 Properties of Object Instances // TODO: is it needed?
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
       // 15.3.5 Properties of Function Instances // TODO:
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
               //"Code"       |-> // TODO: // 15.3.4: when invoked, accepts any arguments and returns undefined
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
                 "length"           |-> @desc("Value" |-> 0                             "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                 "constructor"      |-> @desc("Value" |-> @ArrayOid                     "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.4.4.1 Array.prototype.constructor
                 "toString"         |-> @desc("Value" |-> @("Array.prototype.toString") "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.4.4.2 Array.prototype.toString ( ) // TODO:
                 "reduce"           |-> @desc("Value" |-> @("Array.prototype.reduce")   "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.4.4.21 Array.prototype.reduce ( callbackfn [ , initialValue ] )
                 // TODO: others 15.4.4.3 - 15.4.4.22
               </properties>
               <internalProperties>
                 "Prototype"      |-> @ObjectProtoOid
                 "Class"          |-> "Array"
                 "Extensible"     |->  true
               </internalProperties>
             </obj>)

       // 15.5 String Objects
       // 15.5.5 Properties of String Instances // TODO:
       (. => <obj>
               <oid> @StringOid </oid>
               // 15.5.3 Properties of the String Constructor
               <properties>
                 "length"           |-> @desc("Value" |-> 1               "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.5.3 Properties of the String Constructor
                 "prototype"        |-> @desc("Value" |-> @StringProtoOid "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.5.3.1 String.prototype
               //"fromCharCode"     |-> @desc("Value" |-> ...             "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.5.3.2 String.fromCharCode ( [ char0 [ , char1 [ , ... ] ] ] ) // TODO:
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
                 "length"           |-> @desc("Value" |-> 0                              "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                 "constructor"      |-> @desc("Value" |-> @StringOid                     "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.5.4.1 String.prototype.constructor
                 "toString"         |-> @desc("Value" |-> @("String.prototype.toString") "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.5.4.2 String.prototype.toString ( ) // TODO:
                 "valueOf"          |-> @desc("Value" |-> @("String.prototype.valueOf")  "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.5.4.3 String.prototype.valueOf ( )
                 // TODO: others 15.5.4.3 - 15.5.4.20
               </properties>
               <internalProperties>
                 "Prototype"      |-> @ObjectProtoOid
                 "Class"          |-> "String"
                 "Extensible"     |->  true
                 "PrimitiveValue" |-> ""
               </internalProperties>
             </obj>)

       // 15.6 Boolean Objects
       // 15.6.5 Properties of Boolean Instances // TODO:
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
                 "toString"         |-> @desc("Value" |-> @("Boolean.prototype.toString") "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true) // 15.6.4.2 Boolean.prototype.toString ( ) // TODO:
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
       // 15.7.5 Properties of Number Instances // TODO:
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
                 // TODO: others 15.7.4.5 - 15.7.4.7
               </properties>
               <internalProperties>
                 "Prototype"      |-> @ObjectProtoOid
                 "Class"          |-> "Number"
                 "Extensible"     |->  true
                 "PrimitiveValue" |-> 0
               </internalProperties>
             </obj>)

       // 15.11 ErrorObjects
       // 15.11.5 Properties of Error Instances // TODO:
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

       // TODO:
       // 15.8 The Math Object
       // 15.9 Date Objects
       // 15.10 RegExp (RegularExpression) Objects
       // 15.12 The JSON Object
     </objs>

//////////////////////////////////////////////////////////////////////////////
// 7.6.1 Reserved Words
//////////////////////////////////////////////////////////////////////////////
// TODO: This should have been used by a front-end such as 'js-trans.k' so that we can distinguish between 'Name' and 'String', both are 'PropertyName'.

syntax K ::= "@CheckReserved" "(" Bool "," Var ")"
rule @CheckReserved(Strict:Bool, X:Var)
  => %If @IsReservedWord(Strict,X) = true then {
       %Do @Throw(@SyntaxError("A reserved word cannot be used as an identifier",X));
     };

syntax Bool ::= "@IsReservedWord" "(" Bool "," Var ")" [function]
rule @IsReservedWord(Strict:Bool, X:Var)
  =>      @IsKeyword(X)
   orBool @IsFutureReservedWord(X)
   orBool (Strict andBool @IsFutureReservedWordInStrictMode(X))
   orBool (X ==K "null")
   orBool (X ==K "true")
   orBool (X ==K "false")

syntax Bool ::= "@IsKeyword" "(" Var ")" [function]
rule @IsKeyword(X:Var)
  =>      (X ==K "break")
   orBool (X ==K "case")
   orBool (X ==K "catch")
   orBool (X ==K "continue")
   orBool (X ==K "debugger")
   orBool (X ==K "default")
   orBool (X ==K "delete")
   orBool (X ==K "do")
   orBool (X ==K "else")
   orBool (X ==K "finally")
   orBool (X ==K "for")
   orBool (X ==K "function")
   orBool (X ==K "if")
   orBool (X ==K "in")
   orBool (X ==K "instanceof")
   orBool (X ==K "new")
   orBool (X ==K "return")
   orBool (X ==K "switch")
   orBool (X ==K "this")
   orBool (X ==K "throw")
   orBool (X ==K "try")
   orBool (X ==K "typeof")
   orBool (X ==K "var")
   orBool (X ==K "void")
   orBool (X ==K "while")
   orBool (X ==K "with")

syntax Bool ::= "@IsFutureReservedWord" "(" Var ")" [function]
rule @IsFutureReservedWord(X:Var)
  =>      (X ==K "class")
   orBool (X ==K "const")
   orBool (X ==K "enum")
   orBool (X ==K "export")
   orBool (X ==K "extends")
   orBool (X ==K "import")
   orBool (X ==K "super")

syntax Bool ::= "@IsFutureReservedWordInStrictMode" "(" Var ")" [function]
rule @IsFutureReservedWordInStrictMode(X:Var)
  =>      (X ==K "implements")
   orBool (X ==K "interface")
   orBool (X ==K "let")
   orBool (X ==K "package")
   orBool (X ==K "private")
   orBool (X ==K "protected")
   orBool (X ==K "public")
   orBool (X ==K "static")
   orBool (X ==K "yield")

//////////////////////////////////////////////////////////////////////////////
// 7.8 Literals
//////////////////////////////////////////////////////////////////////////////

// 7.8.1 Null Literals
rule %null => @NullVal

// 7.8.2 Boolean Literals
// Bool

// 7.8.3 Numeric Literals
// Int
// Float

// 7.8.4 String Literals
// String

// 7.8.5 Regular Expression Literals
// TODO:

//////////////////////////////////////////////////////////////////////////////
// 8.7 The Reference Specification Type
//////////////////////////////////////////////////////////////////////////////

syntax Reference ::= "@Ref" "(" K /* Base */ "," K /* Var */ "," K /* Bool */ ")" [seqstrict(1,2,3)]
rule isVal(@Ref(B,N,S)) => isBase(B) ==K true andBool isVar(N) ==K true andBool isBool(S) ==K true

syntax Base
rule isBase(@Undefined) => true
rule isBase(_:Primitive) => true
rule isBase(_:Oid) => true
rule isBase(_:Eid) => true

syntax K /* Base */ ::= "@GetBase" "(" K /* Reference */ ")" [function]
rule @GetBase(@Ref(Base:Base,_,_)) => Base

syntax Var ::= "@GetReferencedName" "(" K /* Reference */ ")" [function]
rule @GetReferencedName(@Ref(_,Name:Var,_)) => Name

syntax Bool ::= "@IsStrictReference" "(" K /* Reference */ ")" [function]
rule @IsStrictReference(@Ref(_,_,Strict:Bool)) => Strict

syntax Bool ::= "@HasPrimitiveBase" "(" K /* Reference */ ")" [function]
rule @HasPrimitiveBase(@Ref(@Undefined, _,_)) => false
rule @HasPrimitiveBase(@Ref(_:Primitive,_,_)) => true
rule @HasPrimitiveBase(@Ref(_:Oid,      _,_)) => false
rule @HasPrimitiveBase(@Ref(_:Eid,      _,_)) => false

syntax Bool ::= "@IsPropertyReference" "(" K /* Reference */ ")" [function]
rule @IsPropertyReference(@Ref(@Undefined, _,_)) => false
rule @IsPropertyReference(@Ref(_:Primitive,_,_)) => true
rule @IsPropertyReference(@Ref(_:Oid,      _,_)) => true
rule @IsPropertyReference(@Ref(_:Eid,      _,_)) => false

syntax Bool ::= "@IsUnresolvableReference" "(" K /* Reference */ ")" [function]
rule @IsUnresolvableReference(@Ref(Base:Base,_,_)) => Base ==K @Undefined

// 8.7.1 GetValue (V)
// TODO: Do we need to consider step 1?

syntax K /* Val */ ::= "@GetValue" "(" K /* Reference */ ")" [seqstrict(1)]

rule @GetValue(@Ref(E:Eid,      N:Var, Strict:Bool)) => @GetBindingValue(E,N,Strict)
rule @GetValue(@Ref(O:Oid,      P:Var, _          )) => @Get(O,P)

rule @GetValue(@Ref(@Undefined, P:Var, _          )) => @Throw(@ReferenceError("GetValue",P))

/* NOTE: This does not work!!! [[Get]] with 'ToObject' differs from [[Get]] for Primitive base.
rule @GetValue(@Ref(B:Bool,     P:Var, Strict:Bool)) => @GetValue(@Ref(@ToObject(B),P,Strict))
rule @GetValue(@Ref(S:String,   P:Var, Strict:Bool)) => @GetValue(@Ref(@ToObject(S),P,Strict))
rule @GetValue(@Ref(N:Number,   P:Var, Strict:Bool)) => @GetValue(@Ref(@ToObject(N),P,Strict))
*/

rule @GetValue(@Ref(B:Primitive,P:Var, _          )) => @GetPrimitive(B,P)

syntax K /* Val */ ::= "@GetPrimitive" "(" Primitive "," Var ")"
rule @GetPrimitive(Base:Primitive,P:Var)
  => %Let $o = @ToObject(Base);
     %Let $desc = @GetProperty($o::K::Oid,P);
     %If $desc = @Undefined then {
       %Return @Undefined;
     } else {
       %If @IsDataDescriptor($desc::K::Val) = true then {
         %Return $desc."Value";
       } else {
         %Let $getter = $desc."Get";
         %If $getter = @Undefined then {
           %Return @Undefined;
         } else {
           %Return @Call($getter,Base,@Nil); // NOTE: Only difference from @Get@Default: 'Base' is used, instead of '$o'.
         }
       }
     }

// 8.7.2 PutValue (V, W)

// NOTE: Step 1 is covered by @GetReference that raise ReferenceError for non-reference expressions
syntax K /* .K */ ::= "@PutValue" "(" K /* Reference */ "," K /* Val */ ")" [seqstrict(1,2)]

rule @PutValue(@Ref(E:Eid,      N:Var, Strict:Bool), V:Val) => @SetMutableBinding(E,N,V,Strict) when (N =/=K "eval" andBool N =/=K "arguments") orBool Strict =/=K true
rule @PutValue(@Ref(O:Oid,      P:Var, Strict:Bool), V:Val) => @Put(O,         P,V,Strict)
rule @PutValue(@Ref(@Undefined, P:Var, false      ), V:Val) => @Put(@GlobalOid,P,V,false)
rule @PutValue(@Ref(@Undefined, P:Var, true       ), _    ) => @Throw(@ReferenceError("PutValue",P))

// NOTE: Handled by this: 11.13.1 step 4, 11.13.2 step 6, 11.3.1, 11.3.2, 11.4.4, 11.4.5
rule @PutValue(@Ref(_:Eid,      N:Var, true       ), _    ) => @Throw(@SyntaxError("PutValue",N)) when N ==K "eval" orBool N ==K "arguments"

/*
/* NOTE: This does not work!!! [[Put]] with 'ToObject' differs from [[Put]] for Primitive base.
rule @PutValue(@Ref(B:Bool,     P:Var, Strict:Bool), V:Val) => @PutValue(@Ref(@ToObject(B),P,Strict),V)
rule @PutValue(@Ref(S:String,   P:Var, Strict:Bool), V:Val) => @PutValue(@Ref(@ToObject(S),P,Strict),V)
rule @PutValue(@Ref(N:Number,   P:Var, Strict:Bool), V:Val) => @PutValue(@Ref(@ToObject(N),P,Strict),V)
*/

rule @PutValue(@Ref(B:Primitive,P:Var, Strict:Bool), V:Val) => @PutPrimitive(B,P,V,Strict)

syntax K /* Val */ ::= "@PutPrimitive" "(" Primitive "," Var "," Val "," Bool ")"
rule @PutPrimitive(Base:Primitive,P:Var,V:Val,Throw:Bool)
  => %Let $o = @ToObject(Base);
     %If @CanPut($o::K::Oid,P) = false then {
       %If Throw = true then {
         %Do @Throw(@TypeError("PutPrimitive, cannot put",@PutPrimitive(Base,P,V,Throw)));
       } else {
         %Return;
       }
     } else {
       %Let $ownDesc = @GetOwnProperty($o::K::Oid,P);
       %If @IsDataDescriptor($ownDesc::K::Val) = true then {
         // NOTE: different from [[Put]]: do not put value
         %If Throw = true then {
           %Do @Throw(@TypeError("PutPrimitive, own Desc is a data descriptor",@PutPrimitive(Base,P,V,Throw)));
         } else {
           %Return;
         }
       } else {
         %Let $desc = @GetProperty($o::K::Oid,P);
         %If @IsAccessorDescriptor($desc::K::Val) = true then {
           %Let $setter = $desc."Set";
           %DoI @Call($setter::K::Oid,Base,@Cons(V,@Nil)); // NOTE: different from [[Put]]: use 'Base' instead of '$o'
         } else {
           // NOTE: different from [[Put]]: do not put value
           %If Throw = true then {
             %Do @Throw(@TypeError("PutPrimitive, inherited Desc is a data descriptor",@PutPrimitive(Base,P,V,Throw)));
           } else {
             %Return;
           }
         }
       }
     }

//////////////////////////////////////////////////////////////////////////////
// 8.10 The Property Descriptor and Property Identifier Specification Types
//////////////////////////////////////////////////////////////////////////////

// 8.10.1 IsAccessorDescriptor ( Desc )

syntax Bool ::= "@IsAccessorDescriptor" "(" Val ")" [function]

rule @IsAccessorDescriptor(@Undefined) => false
rule @IsAccessorDescriptor(@desc(Desc)) => ("Get" in keys(Desc)) orBool
                                           ("Set" in keys(Desc))

// 8.10.2 IsDataDescriptor ( Desc )

syntax Bool ::= "@IsDataDescriptor" "(" Val ")" [function]

rule @IsDataDescriptor(@Undefined) => false
rule @IsDataDescriptor(@desc(Desc)) => ("Value"    in keys(Desc)) orBool
                                       ("Writable" in keys(Desc))

// 8.10.3 IsGenericDescriptor ( Desc )

syntax Bool ::= "@IsGenericDescriptor" "(" Val ")" [function]

rule @IsGenericDescriptor(@Undefined) => false
rule @IsGenericDescriptor(@desc(Desc)) => notBool("Get"      in keys(Desc)) andBool
                                          notBool("Set"      in keys(Desc)) andBool
                                          notBool("Value"    in keys(Desc)) andBool
                                          notBool("Writable" in keys(Desc))

// 8.10.? IsValidDescriptor ( Desc )

syntax Bool ::= "@IsValidDescriptor" "(" PropertyDescriptor ")" [function]

rule @IsValidDescriptor(Desc:PropertyDescriptor) => notBool(@IsAccessorDescriptor(Desc) andBool @IsDataDescriptor(Desc))

// 8.10.? IsFullyPopulatedDescriptor ( Desc )

syntax Bool ::= "@IsFullyPopulatedDescriptor" "(" PropertyDescriptor ")" [function]

rule @IsFullyPopulatedDescriptor(@desc("Value" |-> _ "Writable" |-> _ "Enumerable" |-> _ "Configurable" |-> _)) => true
rule @IsFullyPopulatedDescriptor(@desc("Get"   |-> _ "Set"      |-> _ "Enumerable" |-> _ "Configurable" |-> _)) => true

// 8.10.? MakeFullyPopulatedDescriptor ( Desc )

syntax Bool ::= "@MakeFullyPopulatedDataDescriptor1" "(" PropertyDescriptor ")" [function]
rule @MakeFullyPopulatedDataDescriptor1(Desc:PropertyDescriptor) => @MakeFullyPopulatedDataDescriptor2(Desc,@desc("Value" |-> @Undefined "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false))

syntax Bool ::= "@MakeFullyPopulatedAccessorDescriptor1" "(" PropertyDescriptor ")" [function]
rule @MakeFullyPopulatedAccessorDescriptor1(Desc:PropertyDescriptor) => @MakeFullyPopulatedAccessorDescriptor2(Desc,@desc("Get" |-> @Undefined "Set" |-> @Undefined "Enumerable" |-> false "Configurable" |-> false))

syntax Bool ::= "@MakeFullyPopulatedDataDescriptor2" "(" PropertyDescriptor "," PropertyDescriptor ")" [function]
rule @MakeFullyPopulatedDataDescriptor2(@desc(Desc),Default:PropertyDescriptor) => @MakeFullyPopulatedDataDescriptor2(@desc(@AddMap("Value",       Default."Value",       Desc)),Default) when notBool("Value"        in keys(Desc))
rule @MakeFullyPopulatedDataDescriptor2(@desc(Desc),Default:PropertyDescriptor) => @MakeFullyPopulatedDataDescriptor2(@desc(@AddMap("Writable",    Default."Writable",    Desc)),Default) when notBool("Writable"     in keys(Desc))
rule @MakeFullyPopulatedDataDescriptor2(@desc(Desc),Default:PropertyDescriptor) => @MakeFullyPopulatedDataDescriptor2(@desc(@AddMap("Enumerable",  Default."Enumerable",  Desc)),Default) when notBool("Enumerable"   in keys(Desc))
rule @MakeFullyPopulatedDataDescriptor2(@desc(Desc),Default:PropertyDescriptor) => @MakeFullyPopulatedDataDescriptor2(@desc(@AddMap("Configurable",Default."Configurable",Desc)),Default) when notBool("Configurable" in keys(Desc))
rule @MakeFullyPopulatedDataDescriptor2(@desc(Desc),Default:PropertyDescriptor) => @desc(Desc) when @IsFullyPopulatedDescriptor(@desc(Desc))

syntax Bool ::= "@MakeFullyPopulatedAccessorDescriptor2" "(" PropertyDescriptor "," PropertyDescriptor ")" [function]
rule @MakeFullyPopulatedAccessorDescriptor2(@desc(Desc),Default:PropertyDescriptor) => @MakeFullyPopulatedAccessorDescriptor2(@desc(@AddMap("Get",         Default."Get",         Desc)),Default) when notBool("Get"          in keys(Desc))
rule @MakeFullyPopulatedAccessorDescriptor2(@desc(Desc),Default:PropertyDescriptor) => @MakeFullyPopulatedAccessorDescriptor2(@desc(@AddMap("Set",         Default."Set",         Desc)),Default) when notBool("Set"          in keys(Desc))
rule @MakeFullyPopulatedAccessorDescriptor2(@desc(Desc),Default:PropertyDescriptor) => @MakeFullyPopulatedAccessorDescriptor2(@desc(@AddMap("Enumerable",  Default."Enumerable",  Desc)),Default) when notBool("Enumerable"   in keys(Desc))
rule @MakeFullyPopulatedAccessorDescriptor2(@desc(Desc),Default:PropertyDescriptor) => @MakeFullyPopulatedAccessorDescriptor2(@desc(@AddMap("Configurable",Default."Configurable",Desc)),Default) when notBool("Configurable" in keys(Desc))
rule @MakeFullyPopulatedAccessorDescriptor2(@desc(Desc),Default:PropertyDescriptor) => @desc(Desc) when @IsFullyPopulatedDescriptor(@desc(Desc))

// 8.10.4 FromPropertyDescriptor ( Desc )

syntax K /* Val */ ::= "@FromPropertyDescriptor" "(" K /* PropertyDescriptor */ ")" [seqstrict(1)]

rule @FromPropertyDescriptor(@Undefined) => @Undefined

syntax Id ::= "$obj"

rule @FromPropertyDescriptor(Desc:PropertyDescriptor)
  => %Let $obj = @CreateObject;
     %DoI @DefineOwnProperty($obj, "value",        @desc("Value" |-> Desc."Value"        "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     %DoI @DefineOwnProperty($obj, "writable",     @desc("Value" |-> Desc."Writable"     "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     %DoI @DefineOwnProperty($obj, "enumerable",   @desc("Value" |-> Desc."Enumerable"   "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     %DoI @DefineOwnProperty($obj, "configurable", @desc("Value" |-> Desc."Configurable" "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     %Return $obj;
     when @IsDataDescriptor(Desc) ==K true
  andBool @IsFullyPopulatedDescriptor(Desc) ==K true

rule @FromPropertyDescriptor(Desc:PropertyDescriptor)
  => %Let $obj = @CreateObject;
     %DoI @DefineOwnProperty($obj, "get",          @desc("Value" |-> Desc."Get"          "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     %DoI @DefineOwnProperty($obj, "set",          @desc("Value" |-> Desc."Set"          "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     %DoI @DefineOwnProperty($obj, "enumerable",   @desc("Value" |-> Desc."Enumerable"   "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     %DoI @DefineOwnProperty($obj, "configurable", @desc("Value" |-> Desc."Configurable" "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     %Return $obj;
     when @IsAccessorDescriptor(Desc) ==K true
  andBool @IsFullyPopulatedDescriptor(Desc) ==K true

// 8.10.5 ToPropertyDescriptor ( Obj )
// TODO: make it more elegant

syntax K /* PropertyDescriptor */ ::= "@ToPropertyDescriptor" "(" Val ")"

rule @ToPropertyDescriptor(V:Val) => @Throw(@TypeError("ToPropertyDescriptor",V)) when @IsOid(V) ==K false

syntax Id ::= "$desc0" | "$desc1" | "$desc2" | "$desc3" | "$desc4" | "$desc5" | "$desc6"

rule @ToPropertyDescriptor(O:Oid)
  => %Let $desc0 = @desc(.Map);
     %Let $desc1 = @ToPropertyDescriptorAux(O,"enumerable",  $desc0::K::PropertyDescriptor,"Enumerable");
     %Let $desc2 = @ToPropertyDescriptorAux(O,"configurable",$desc1::K::PropertyDescriptor,"Configurable");
     %Let $desc3 = @ToPropertyDescriptorAux(O,"value",       $desc2::K::PropertyDescriptor,"Value");
     %Let $desc4 = @ToPropertyDescriptorAux(O,"writable",    $desc3::K::PropertyDescriptor,"Writable");
     %Let $desc5 = @ToPropertyDescriptorAux(O,"get",         $desc4::K::PropertyDescriptor,"Get");
     %Let $desc6 = @ToPropertyDescriptorAux(O,"set",         $desc5::K::PropertyDescriptor,"Set");
     %If @IsValidDescriptor($desc6::K::PropertyDescriptor) = true then {
       %Return $desc6;
     } else {
       %Do @Throw(@TypeError("ToPropertyDescriptor InvalidDescriptor",$desc6));
     }

syntax K /* PropertyDescriptor */ ::= "@ToPropertyDescriptorAux" "(" Oid "," Var "," PropertyDescriptor "," String ")"

syntax Id ::= "$value"

rule @ToPropertyDescriptorAux(O:Oid,P:Var,Desc:PropertyDescriptor,Attr:String) =>
     %If @HasProperty(O,P) = true then {
       %Let $value = @ToBoolean(@Get(O,P));
       %Return @AddDesc(Attr, $value, Desc);
     } else {
       %Return Desc;
     }
     when (P ==K "enumerable"   andBool Attr ==K "Enumerable")
   orBool (P ==K "configurable" andBool Attr ==K "Configurable")
   orBool (P ==K "writable"     andBool Attr ==K "Writable")

rule @ToPropertyDescriptorAux(O:Oid,P:Var,Desc:PropertyDescriptor,Attr:String) =>
     %If @HasProperty(O,P) = true then {
       %Let $value = @Get(O,P);
       %Return @AddDesc(Attr, $value, Desc);
     } else {
       %Return Desc;
     }
     when P ==K "value" andBool Attr ==K "Value"

rule @ToPropertyDescriptorAux(O:Oid,P:Var,Desc:PropertyDescriptor,Attr:String) =>
     %If @HasProperty(O,P) = true then {
       %Let $value = @Get(O,P);
       %If @IsCallable($value) = true then {
         %Nop;
       } else {
         %If $value = @Undefined then {
           %Nop;
         } else {
           %Do @Throw(@TypeError("ToPropertyDescriptorAux",$value));
         }
       }
       %Return @AddDesc(Attr, $value, Desc);
     } else {
       %Return Desc;
     }
     when (P ==K "get" andBool Attr ==K "Get")
   orBool (P ==K "set" andBool Attr ==K "Set")

//////////////////////////////////////////////////////////////////////////////
// 8.12 Algorithms for Object Internal Methods
//////////////////////////////////////////////////////////////////////////////

// 8.12.1 [[GetOwnProperty]] (P)

syntax K /* Val */ ::= "@GetOwnProperty" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict(1,2)]

rule @GetOwnProperty(O:Oid,P:Var)
  => %If @IsArgumentsObjectNonStrictWithFormalParams(O) = true then {
       %Do @GetOwnProperty@Arguments(O,P);
     } else {
       %Do @GetOwnProperty@Default(O,P);
     }

syntax K /* Val */ ::= "@GetOwnProperty@Default" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict(1,2)]

rule <k> @GetOwnProperty@Default(O:Oid,P:Var) => V ... </k>
     <obj>
       <oid> O </oid>
       <properties> P |-> V:Val _ </properties>
       _
     </obj>
rule <k> @GetOwnProperty@Default(O:Oid,P:Var) => @Undefined ... </k>
     <obj>
       <oid> O </oid>
       <properties> Prop </properties>
       _
     </obj>
     when notBool(P in keys(Prop))

// 8.12.? [[GetInternalProperty]] (P)

syntax K /* Val */ ::= "@GetInternalProperty" "(" Oid "," Var ")"

rule <k> @GetInternalProperty(O:Oid,P:Var) => V ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties> P |-> V:Val _ </internalProperties>
       _
     </obj>
rule <k> @GetInternalProperty(O:Oid,P:Var) => @Undefined ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties> Prop </internalProperties>
       _
     </obj>
     when notBool(P in keys(Prop))

// 8.12.? [[SetInternalProperty]] (P,V)

syntax K /* .K */ ::= "@SetInternalProperty" "(" Oid "," Var "," Val ")"

rule <k> @SetInternalProperty(O:Oid,P:Var,V:Val) => . ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties> Prop => @AddMap(P,V,Prop) </internalProperties>
       _
     </obj>

// 8.12.? [[GetInheritedProperty]] (P)

syntax K /* Val */ ::= "@GetInheritedProperty" "(" Oid "," Var ")"

rule <k> @GetInheritedProperty(O:Oid,P:Var) => @GetProperty(O',P) ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties> "Prototype" |-> O':Oid _ </internalProperties>
       _
     </obj>
     when O' =/=K @NullOid
rule <k> @GetInheritedProperty(O:Oid,_) => @Undefined ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties> "Prototype" |-> @NullOid _ </internalProperties>
       _
     </obj>

// 8.12.2 [[GetProperty]] (P)

syntax K /* Val */ ::= "@GetProperty" "(" Oid "," Var ")"

syntax Id ::= "$prop"
rule @GetProperty(O:Oid,P:Var)
  => %Let $prop = @GetOwnProperty(O,P);
     %If $prop = @Undefined then {
       %Return @GetInheritedProperty(O,P);
     } else {
       %Return $prop;
     }

// 8.12.3 [[Get]] (P)

syntax K /* Val */ ::= "@Get" "(" Oid "," Var ")" 

rule @Get(O:Oid,P:Var)
  => %If @IsArgumentsObjectNonStrictWithFormalParams(O) = true then {
       %Do @Get@Arguments(O,P);
     } else {
       %Do @Get@Default(O,P);
     }

syntax K /* Val */ ::= "@Get@Default" "(" Oid "," Var ")" 

syntax Id ::= "$desc" | "$getter"
rule @Get@Default(O:Oid,P:Var)
  => %Let $desc = @GetProperty(O,P);
     %If $desc = @Undefined then {
       %Return @Undefined;
     } else {
       %If @IsDataDescriptor($desc::K::Val) = true then {
         %Return $desc."Value";
       } else {
         %Let $getter = $desc."Get";
         %If $getter = @Undefined then {
           %Return @Undefined;
         } else {
           %Return @Call($getter,O,@Nil);
         }
       }
     }

// 8.12.4 [[CanPut]] (P)

// Intuistic Algorithm
//
// If O has P as its own property,
//   the property should be writable
//   or, its setter function should be defined.
//
// If O has P as its inherited property,
//   O should be extensible and the inherited property should be writable (the inherited property is not supposed to be updated, though)
//   or, its setter function should be defined.
//
// If O has no P along with prototype chain,
//   O should be extensible.

syntax K /* Bool */ ::= "@CanPut" "(" Oid "," Var ")"

syntax Id ::= "$proto" | "$inherited"
rule @CanPut(O:Oid,P:Var)
  => %Let $desc = @GetOwnProperty(O,P);
     %If $desc = @Undefined then {
       %Let $proto = @GetInternalProperty(O,"Prototype");
       %If $proto = @NullOid then {
         %Return @GetInternalProperty(O,"Extensible");
       } else {
         %Let $inherited = @GetProperty($proto::K::Oid,P);
         %If $inherited = @Undefined then {
           %Return @GetInternalProperty(O,"Extensible");
         } else {
           %If @IsAccessorDescriptor($inherited::K::Val) = true then {
             %If $inherited."Set" = @Undefined then {
               %Return false;
             } else {
               %Return true;
             }
           } else {
             %If @GetInternalProperty(O,"Extensible") = false then {
               %Return false;
             } else {
               %Return $inherited."Writable";
             }
           }
         }
       }
     } else {
       %If @IsAccessorDescriptor($desc::K::Val) = true then {
         %If $desc."Set" = @Undefined then {
           %Return false;
         } else {
           %Return true;
         }
       } else {
         %Return $desc."Writable";
       }
     }

// 8.12.5 [[Put]] ( P, V, Throw )

syntax K /* .K */ ::= "@Put" "(" K /* Oid */ "," K /* Var */ "," K /* Val */ "," K /* Bool */ ")" [seqstrict(1,2,3,4)]

syntax Id ::= "$ownDesc" | "$valueDesc" | "$setter" | "$newDesc"
rule @Put(O:Oid,P:Var,V:Val,Throw:Bool)
  => %If @CanPut(O,P) = false then {
       %If Throw = true then {
         %Do @Throw(@TypeError("Put",@Put(O,P,V,Throw)));
       } else {
         %Return;
       }
     } else {
       %Let $ownDesc = @GetOwnProperty(O,P);
       %If @IsDataDescriptor($ownDesc::K::Val) = true then {
         %Let $valueDesc = @desc("Value" |-> V);
         %DoI @DefineOwnProperty(O,P,$valueDesc::K::PropertyDescriptor,Throw);
       } else {
         %Let $desc = @GetProperty(O,P);
         %If @IsAccessorDescriptor($desc::K::Val) = true then {
           %Let $setter = $desc."Set";
           %DoI @Call($setter::K::Oid,O,@Cons(V,@Nil));
         } else {
           %Let $newDesc = @desc("Value" |-> V "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true);
           %DoI @DefineOwnProperty(O,P,$newDesc::K::PropertyDescriptor,Throw);
         }
       }
     }

// 8.12.? [[HasOwnProperty]] (P)

syntax K /* Bool */ ::= "@HasOwnProperty" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict(1,2)]

rule @HasOwnProperty(O:Oid,P:Var)
  => %If @GetOwnProperty(O,P) = @Undefined then {
       %Return false;
     } else {
       %Return true;
     }

// 8.12.6 [[HasProperty]] (P)

syntax K /* Bool */ ::= "@HasProperty" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict(1,2)]

rule @HasProperty(O:Oid,P:Var)
  => %If @GetProperty(O,P) = @Undefined then {
       %Return false;
     } else {
       %Return true;
     }

// 8.12.7 [[Delete]] (P, Throw)

syntax K /* Bool */ ::= "@Delete" "(" K /* Oid */ "," K /* Var */ "," K /* Bool */ ")" [seqstrict(1,2,3)]

rule @Delete(O:Oid,P:Var,Throw:Bool)
  => %If @IsArgumentsObjectNonStrictWithFormalParams(O) = true then {
       %Do @Delete@Arguments(O,P,Throw);
     } else {
       %Do @Delete@Default(O,P,Throw);
     }

syntax K /* Bool */ ::= "@Delete@Default" "(" Oid "," Var "," Bool ")" 

rule <k> @Delete@Default(O:Oid,P:Var,Throw:Bool) => true ... </k>
     <obj>
       <oid> O </oid>
       <properties> Prop:Map </properties>
       _
     </obj>
     when notBool(P in keys(Prop))
rule <k> @Delete@Default(O:Oid,P:Var,Throw:Bool) => true ... </k>
     <obj>
       <oid> O </oid>
       <properties>
         (P |-> @desc("Configurable" |-> true _) => .)
         _
       </properties>
       _
     </obj>
rule <k> @Delete@Default(O:Oid,P:Var,Throw:Bool) => @Reject(Throw,"Delete@Default",@Delete@Default(O,P,Throw)) ... </k>
     <obj>
       <oid> O </oid>
       <properties>
         P |-> @desc("Configurable" |-> false _)
         _
       </properties>
       _
     </obj>

// 8.12.8 [[DefaultValue]] (hint)

syntax K /* Val */ ::= "@DefaultValue" "(" Oid "," String ")" 
// TODO: Can we make it more elegant?

syntax Id ::= "$toString" | "$valueOf" | "$str" | "$val"

rule @DefaultValue(O:Oid,"String")
  => %BEGIN
     %Let $toString = @Get(O,"toString");
     %If @IsCallable($toString) = true then {
       %Let $str = @Call($toString,O,@Nil);
       %If @IsPrimitive($str::K::Val) = true then {
         %Return $str; %Exit;
       };
     };
     %Let $valueOf = @Get(O,"valueOf");
     %If @IsCallable($valueOf) = true then {
       %Let $val = @Call($valueOf,O,@Nil);
       %If @IsPrimitive($val::K::Val) = true then {
         %Return $val; %Exit;
       };
     };
     %Do @Throw(@TypeError("DefaultValue String",O));
     %END

rule @DefaultValue(O:Oid,"Number")
  => %BEGIN
     %Let $valueOf = @Get(O,"valueOf");
     %If @IsCallable($valueOf) = true then {
       %Let $val = @Call($valueOf,O,@Nil);
       %If @IsPrimitive($val::K::Val) = true then {
         %Return $val; %Exit;
       };
     };
     %Let $toString = @Get(O,"toString");
     %If @IsCallable($toString) = true then {
       %Let $str = @Call($toString,O,@Nil);
       %If @IsPrimitive($str::K::Val) = true then {
         %Return $str; %Exit;
       };
     };
     %Do @Throw(@TypeError("DefaultValue Number",O));
     %END

rule <k> @DefaultValue(O:Oid,"") => @DefaultValue(O,"String") ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties> "Class" |-> "Date" _ </internalProperties>
       _
     </obj>

rule <k> @DefaultValue(O:Oid,"") => @DefaultValue(O,"Number") ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties> "Class" |-> Class:String _ </internalProperties>
       _
     </obj>
     when Class =/=String "Date"

// 8.12.9 [[DefineOwnProperty]] (P, Desc, Throw)

// Intuitive algorithm
//
// If O has P as its own property,
//   If the property is configurable,
//     any change is acceptable.
//   Else,
//     only value field can be updated when the property is writable.
//     o.w., rejected.
//
// If O does not have P as its own property,
//   If O is extensible,
//     freely update it.
//   Else,
//     reject.

syntax K /* Bool */ ::= "@DefineOwnProperty" "(" K /* Oid */ "," K /* Var */ "," K /* PropertyDescriptor */ "," K /* Bool */ ")" [seqstrict(1,2,3,4)]

rule @DefineOwnProperty(O:Oid,P:Var,Desc:PropertyDescriptor,Throw:Bool)
  => %If @IsArgumentsObjectNonStrictWithFormalParams(O) = true then {
       %Do @DefineOwnProperty@Arguments(O,P,Desc,Throw);
     } else {
       %Do @DefineOwnProperty@Default(O,P,Desc,Throw);
     }

syntax K /* Bool */ ::= "@DefineOwnProperty@Default" "(" K /* Oid */ "," K /* Var */ "," K /* PropertyDescriptor */ "," K /* Bool */ ")" [seqstrict(1,2,3,4)]

syntax Id ::= "$current" | "$current2" | "$extensible"
rule @DefineOwnProperty@Default(O:Oid,P:Var,Desc:PropertyDescriptor,Throw:Bool) =>
   //@LOG(@DefineOwnProperty@Default(O,P,Desc,Throw)) ~>
     %BEGIN
     %Let $current = @GetOwnProperty(O,P);
   //%Do @LOG($current);
   //%Do @LOG(@IsDataDescriptor($current::K::PropertyDescriptor));
   //%Do @LOG(@IsDataDescriptor(Desc));
     %Let $extensible = @GetInternalProperty(O,"Extensible");
     %If $current = @Undefined then {
       %If $extensible = false then {
         %Return @Reject(Throw,"DefineOwnProperty@Default not extensible",@DefineOwnProperty@Default(O,P,Desc,Throw)); %Exit;
       } else {
         %If @OrBool(@IsGenericDescriptor(Desc), @IsDataDescriptor(Desc)) = true then {
         //%Do @LOG("Data");
         //%Do @LOG(Desc);
           %Do @SetOwnProperty(O,P,@MakeFullyPopulatedDataDescriptor1(Desc));
         } else {
         //%Do @LOG("Accessor");
         //%Do @LOG(Desc);
           %Do @SetOwnProperty(O,P,@MakeFullyPopulatedAccessorDescriptor1(Desc));
         }
         %Return true;
       }
     } else {
       %If @SubDesc(Desc,$current::K::PropertyDescriptor) = true then {
         %Return true;
       } else {
         %If $current."Configurable" = false then {
           %If Desc."Configurable" = true then {
             %Return @Reject(Throw,"DefineOwnProperty@Default conflict configurable",@DefineOwnProperty@Default(O,P,Desc,Throw)); %Exit;
           };
           %If @OrBool(@AndBool(@EqVal($current."Enumerable", true ), @EqVal(Desc."Enumerable", false)),
                       @AndBool(@EqVal($current."Enumerable", false), @EqVal(Desc."Enumerable", true ))) = true then {
             %Return @Reject(Throw,"DefineOwnProperty@Default conflict enumerable",@DefineOwnProperty@Default(O,P,Desc,Throw)); %Exit;
           };
         };
         %If @IsGenericDescriptor(Desc) = true then {
           %Nop;
         } else {
           %If @OrBool(@AndBool(@IsDataDescriptor($current::K::PropertyDescriptor), @IsAccessorDescriptor(Desc)),
                       @AndBool(@IsAccessorDescriptor($current::K::PropertyDescriptor), @IsDataDescriptor(Desc))) = true then {
             %If $current."Configurable" = false then {
               %Return @Reject(Throw,"DefineOwnProperty@Default conflict descriptor type",@DefineOwnProperty@Default(O,P,Desc,Throw)); %Exit;
             };
           //%Do @LOG("convert");
             %Do @ConvertDescriptorType(O,P);
           } else {
             %If @AndBool(@IsDataDescriptor($current::K::PropertyDescriptor), @IsDataDescriptor(Desc)) = true then {
               %If $current."Configurable" = false then {
                 %If @AndBool(@EqVal($current."Writable", false), @EqVal(Desc."Writable", true)) = true then {
                   %Return @Reject(Throw,"DefineOwnProperty@Default conflict writable",@DefineOwnProperty@Default(O,P,Desc,Throw)); %Exit;
                 };
                 %If @AndBool(@AndBool(@EqVal($current."Writable", false), @NeqVal(Desc."Value", @Undefined)), @NotBool(@SameValue(Desc."Value",$current."Value"))) = true then {
                   %Return @Reject(Throw,"DefineOwnProperty@Default not writable",@DefineOwnProperty@Default(O,P,Desc,Throw)); %Exit;
                 };
               };
             } else {
               %If $current."Configurable" = false then {
                 %If @AndBool(@NeqVal(Desc."Set", @Undefined), @NotBool(@SameValue(Desc."Set",$current."Set"))) = true then {
                   %Return @Reject(Throw,"DefineOwnProperty@Default conflict set",@DefineOwnProperty@Default(O,P,Desc,Throw)); %Exit;
                 };
                 %If @AndBool(@NeqVal(Desc."Get", @Undefined), @NotBool(@SameValue(Desc."Get",$current."Get"))) = true then {
                   %Return @Reject(Throw,"DefineOwnProperty@Default conflict get",@DefineOwnProperty@Default(O,P,Desc,Throw)); %Exit;
                 };
               };
             }
           }
         }
         %Let $current2 = @GetOwnProperty(O,P);
         %If @OrBool(@IsGenericDescriptor($current2::K::PropertyDescriptor), @IsDataDescriptor($current2::K::PropertyDescriptor)) = true then {
         //%Do @LOG("Data");
         //%Do @LOG(Desc);
         //%Do @LOG($current2);
           %Do @SetOwnProperty(O,P,@MakeFullyPopulatedDataDescriptor2(Desc,$current2::K::PropertyDescriptor));
         } else {
         //%Do @LOG("Accessor");
         //%Do @LOG(Desc);
         //%Do @LOG($current2);
           %Do @SetOwnProperty(O,P,@MakeFullyPopulatedAccessorDescriptor2(Desc,$current2::K::PropertyDescriptor));
         }
         %Return true;
       }
     }
     %END

syntax K /* .K */ ::= "@ConvertDescriptorType" "(" Oid "," Var ")"
rule <k> @ConvertDescriptorType(O:Oid,P:Var) => . ... </k>
     <obj>
       <oid> O </oid>
       <properties>
         P |-> ( @desc("Value" |-> _          "Writable" |-> _          "Enumerable" |-> Enumerable:Bool "Configurable" |-> Configurable:Bool)
              => @desc("Get"   |-> @Undefined "Set"      |-> @Undefined "Enumerable" |-> Enumerable      "Configurable" |-> Configurable     ) )
         _
       </properties>
       _
     </obj>
rule <k> @ConvertDescriptorType(O:Oid,P:Var) => . ... </k>
     <obj>
       <oid> O </oid>
       <properties>
         P |-> ( @desc("Get"   |-> _          "Set"      |-> _          "Enumerable" |-> Enumerable:Bool "Configurable" |-> Configurable:Bool)
              => @desc("Value" |-> @Undefined "Writable" |-> false      "Enumerable" |-> Enumerable      "Configurable" |-> Configurable     ) )
         _
       </properties>
       _
     </obj>

syntax K /* .K */ ::= "@SetOwnProperty" "(" K /* Oid */ "," K /* Var */ "," K /* Val */ ")" [seqstrict(1,2,3)]
rule <k> @SetOwnProperty(O:Oid,P:Var,V:Val) => . ... </k>
     <obj>
       <oid> O </oid>
       <properties> Prop => @AddMap(P,V,Prop) </properties>
       _
     </obj>

syntax K /* Bool */ ::= "@Reject" "(" Bool "," String "," K ")"
rule @Reject(true, S:String,K:K) => @Throw(@TypeError("Reject" +String S, K))
rule @Reject(false,_,       _  ) => false

//////////////////////////////////////////////////////////////////////////////
// 9 Type Conversion and Testing
//////////////////////////////////////////////////////////////////////////////

// 9.1 ToPrimitive

syntax K /* Val */ ::= "@ToPrimitive" "(" K /* Val */ "," String ")" [seqstrict(1)]

rule @ToPrimitive(@Undefined,               _) => @Undefined
rule @ToPrimitive(@NullVal,                 _) => @NullVal
rule @ToPrimitive(B:Bool,                   _) => B
rule @ToPrimitive(S:String,                 _) => S
rule @ToPrimitive(N:Number,                 _) => N
rule @ToPrimitive(O:Oid, PreferredType:String) => @DefaultValue(O,PreferredType)

// 9.2 ToBoolean

syntax K /* Bool */ ::= "@ToBoolean" "(" K /* Val */ ")" [seqstrict(1)]

rule @ToBoolean(@Undefined) => false
rule @ToBoolean(@NullVal  ) => false
rule @ToBoolean(B:Bool    ) => B
rule @ToBoolean(S:String  ) => true when S =/=String ""
rule @ToBoolean(""        ) => false
rule @ToBoolean(N:Number  ) => true when N =/=K 0 andBool N =/=K @NaN andBool N =/=K @nz
rule @ToBoolean(0         ) => false
rule @ToBoolean(@nz       ) => false
rule @ToBoolean(@NaN      ) => false
rule @ToBoolean(O:Oid     ) => true

// 9.3 ToNumber

syntax K /* Number */ ::= "@ToNumber" "(" K /* Val */ ")" [seqstrict(1)]

rule @ToNumber(@Undefined) => @NaN
rule @ToNumber(@NullVal  ) => 0
rule @ToNumber(true      ) => 1
rule @ToNumber(false     ) => 0
rule @ToNumber(S:String  ) => @StringToNumber(@Parse(S)) when S =/=String ""
rule @ToNumber(""        ) => 0
rule @ToNumber(N:Number  ) => N
rule @ToNumber(O:Oid     ) => @ToNumber(@ToPrimitive(O,"Number"))

// 9.3.1 ToNumber Applied to the String Type

// TODO: more correctly
syntax K ::= "@StringToNumber" "(" K /* Stmt or Throw */ ")"
rule @StringToNumber(%exp(E:Exp)) => @ResolveOverflow(E) when @IsNumericExp(E) ==K  true
rule @StringToNumber(%exp(E:Exp)) => @NaN                when @IsNumericExp(E) =/=K true
rule @StringToNumber(%emptyStmt)  => 0
rule @StringToNumber(@Throw(@SyntaxError("#parse",_))) => @NaN

// TODO: check if it works without defining false cases
syntax Bool ::= "@IsNumericExp" "(" Exp ")" [function]
rule @IsNumericExp(%con(_:Int)) => true
rule @IsNumericExp(%con(_:Float)) => true
rule @IsNumericExp(%var("Infinity")) => true
rule @IsNumericExp(%pre(%plus, E:Exp)) => @IsNumericExp(E)
rule @IsNumericExp(%pre(%minus,E:Exp)) => @IsNumericExp(E)

// 9.4 ToInteger

syntax K /* Val */ ::= "@ToInteger" "(" Val ")"

rule @ToInteger(V:Val) => @NumberToInteger(@ToNumber(V))

// TODO: Do more correctly
syntax K /* Int */ ::= "@NumberToInteger" "(" K /* Number */ ")" [seqstrict(1)]
rule @NumberToInteger(I:Int  ) => I
rule @NumberToInteger(F:Float) => Float2Int(F)
rule @NumberToInteger(@nz    ) => @nz
rule @NumberToInteger(@NaN   ) => 0
rule @NumberToInteger(@+Infinity) => @+Infinity
rule @NumberToInteger(@-Infinity) => @-Infinity

// 9.5 ToInt32: (Signed 32 Bit Integer)

syntax K /* Int32 */ ::= "@ToInt32" "(" K /* Val */ ")" [seqstrict(1)]

rule @ToInt32(V:Val) => @NumberToInt32(@ToNumber(V))

syntax K /* Int32 */ ::= "@NumberToInt32" "(" K /* Number */ ")" [seqstrict(1)]
rule @NumberToInt32(I:Int  )    => @IntToInt32(I)
rule @NumberToInt32(F:Float)    => @IntToInt32(Float2Int(F))
rule @NumberToInt32(@nz    )    => 0
rule @NumberToInt32(@NaN   )    => 0
rule @NumberToInt32(@+Infinity) => 0
rule @NumberToInt32(@-Infinity) => 0

syntax K /* Int32 */ ::= "@IntToInt32" "(" Int ")"
rule @IntToInt32(I:Int) => iMInt(sMInt(mi(32,I)))

// 9.6 ToUint32: (Unsigned 32 Bit Integer)

syntax K /* Val */ ::= "@ToUint32" "(" Val ")"

rule @ToUint32(V:Val) => @NumberToUint32(@ToNumber(V))

syntax K /* Int32 */ ::= "@NumberToUint32" "(" K /* Number */ ")" [seqstrict(1)]
rule @NumberToUint32(I:Int  )    => @IntToUint32(I)
rule @NumberToUint32(F:Float)    => @IntToUint32(Float2Int(F))
rule @NumberToUint32(@nz    )    => 0
rule @NumberToUint32(@NaN   )    => 0
rule @NumberToUint32(@+Infinity) => 0
rule @NumberToUint32(@-Infinity) => 0

syntax K /* Uint32 */ ::= "@IntToUint32" "(" Int ")"
rule @IntToUint32(I:Int) => iMInt(uMInt(mi(32,I)))

// 9.7 ToUint16: (Unsigned 16 Bit Integer)

syntax K /* Val */ ::= "@ToUint16" "(" Val ")"

rule @ToUint16(V:Val) => @NumberToUint16(@ToNumber(V))

syntax K /* Int32 */ ::= "@NumberToUint16" "(" K /* Number */ ")" [seqstrict(1)]
rule @NumberToUint16(I:Int  )    => @IntToUint16(I)
rule @NumberToUint16(F:Float)    => @IntToUint16(Float2Int(F))
rule @NumberToUint16(@nz    )    => 0
rule @NumberToUint16(@NaN   )    => 0
rule @NumberToUint16(@+Infinity) => 0
rule @NumberToUint16(@-Infinity) => 0

syntax K /* Uint16 */ ::= "@IntToUint16" "(" Int ")"
rule @IntToUint16(I:Int) => iMInt(uMInt(mi(16,I)))

// 9.8 ToString

syntax K /* Val */ ::= "@ToString" "(" K /* Val */ ")" [seqstrict(1)]

rule @ToString(@Undefined) => "undefined"
rule @ToString(@NullVal  ) => "null"
rule @ToString(true      ) => "true"
rule @ToString(false     ) => "false"
rule @ToString(S:String  ) => S
rule @ToString(I:Int     ) => Int2String(I)
rule @ToString(F:Float   ) => Float2String(F)
rule @ToString(@nz       ) => "0"
rule @ToString(@NaN      ) => "NaN"
rule @ToString(@+Infinity) =>  "Infinity"
rule @ToString(@-Infinity) => "-Infinity"
rule @ToString(O:Oid     ) => @ToString(@ToPrimitive(O,"String"))

// 9.9 ToObject

syntax K /* Val */ ::= "@ToObject" "(" K /* Val */ ")" [seqstrict(1)]

rule @ToObject(@Undefined) => @Throw(@TypeError("ToObject","Undefined"))
rule @ToObject(@NullVal  ) => @Throw(@TypeError("ToObject","Null"))
rule @ToObject(B:Bool    ) => @NewBoolean(@Cons(B,@Nil))
rule @ToObject(S:String  ) => @NewString(@Cons(S,@Nil))
rule @ToObject(N:Number  ) => @NewNumber(@Cons(N,@Nil))
rule @ToObject(O:Oid) => O

// 9.10 CheckObjectCoercible

syntax K /* .K */ ::= "@CheckObjectCoercible" "(" Val ")"
rule <k> @CheckObjectCoercible(V:Val) => . ... </k>
     when (V =/=K @Undefined) andBool
          (V =/=K @NullVal)
rule @CheckObjectCoercible(@Undefined) => @Throw(@TypeError("CheckObjectCoercible","Undefined"))
rule @CheckObjectCoercible(@NullVal  ) => @Throw(@TypeError("CheckObjectCoercible","Null"))

// 9.11 IsCallable

syntax K /* Bool */ ::= "@IsCallable" "(" K /* Val */ ")" [seqstrict(1)]

rule @IsCallable(@Undefined) => false
rule @IsCallable(@NullVal  ) => false
rule @IsCallable(B:Bool    ) => false
rule @IsCallable(S:String  ) => false
rule @IsCallable(N:Number  ) => false
rule <k> @IsCallable(O:Oid ) => Class ==K "Function" ... </k> // TODO: Do more correctly
     <obj>
       <oid> O </oid>
       <internalProperties> "Class" |-> Class:String _ </internalProperties>
       _
     </obj>
rule @IsCallable(@(_)) => true

// 9.12 The SameValue Algorithm

syntax Bool ::= "@SameValue" "(" K /* Val */ "," K /* Val */ ")" [function]

// TODO: Do more correctly Step 4 of Number
rule @SameValue(V1:Val,V2:Val) => V1 ==K V2 when notBool(isInt(V1)   ==K true andBool isFloat(V2) ==K true)
                                         andBool notBool(isFloat(V1) ==K true andBool isInt(V2)   ==K true)
rule @SameValue(I1:Int,  F2:Float) => Int2Float(I1) ==Float F2
rule @SameValue(F1:Float,I2:Int  ) =>            F1 ==Float Int2Float(I2)

//////////////////////////////////////////////////////////////////////////////
// 10.2.1 Environment Records
//////////////////////////////////////////////////////////////////////////////

syntax K /* Bool */ ::= "@HasBinding" "(" Eid "," Var ")"
// 10.2.1.1.1 HasBinding(N)
rule <k> @HasBinding(E:Eid,N:Var) => N in keys(Record) ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> Record:Map </declEnvRec>
       _
     </env>
// 10.2.1.2.1 HasBinding(N)
rule <k> @HasBinding(E:Eid,N:Var) => @HasProperty(O,N) ... </k>
     <env>
       <eid> E </eid>
       <objEnvRec>
         <bindingObj> O:Oid </bindingObj>
         _
       </objEnvRec>
       _
     </env>

syntax K /* .K */ ::= "@CreateMutableBinding" "(" Eid "," Var "," Bool ")" 
// 10.2.1.1.2 CreateMutableBinding (N, D)
rule <k> @CreateMutableBinding(E:Eid,N:Var,D:Bool) => . ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> (. => N |-> @ve(@Undefined,false,true,D)) Record:Map </declEnvRec>
       _
     </env>
     when notBool(N in keys(Record))
// 10.2.1.2.2 CreateMutableBinding (N, D)
rule <k> @CreateMutableBinding(E:Eid,N:Var,D:Bool)
      => @HasProperty(O,N) ~> @False?
      ~> @DefineOwnProperty(O, N, @desc("Value" |-> @Undefined "Writable" |-> true "Enumerable" |-> true "Configurable" |-> D), true) ~> @Ignore
     ... </k>
     <env>
       <eid> E </eid>
       <objEnvRec>
         <bindingObj> O:Oid </bindingObj>
         _
       </objEnvRec>
       _
     </env>

syntax K /* .K */ ::= "@SetMutableBinding" "(" K /* Eid */ "," K /* Var */ "," K /* Val */ "," K /* Bool */ ")" [seqstrict(1,2,3,4)]
// 10.2.1.1.3 SetMutableBinding (N,V,S)
rule <k> @SetMutableBinding(E:Eid,N:Var,V:Val,S:Bool) => . ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> ... N |-> @ve((_ => V),(_ => true),true,_) ... </declEnvRec>
       _
     </env>
rule <k> @SetMutableBinding(E:Eid,N:Var,_:Val,true) => @Throw(@TypeError("SetMutableBinding",N)) ... </k> // TODO: what if S is false? undefined behavior?
     <env>
       <eid> E </eid>
       <declEnvRec> ... N |-> @ve(_,_,false,_) ... </declEnvRec>
       _
     </env>
// 10.2.1.2.3 SetMutableBinding (N,V,S)
rule <k> @SetMutableBinding(E:Eid,N:Var,V:Val,S:Bool) => @Put(O,N,V,S) ... </k>
     <env>
       <eid> E </eid>
       <objEnvRec>
         <bindingObj> O:Oid </bindingObj>
         _
       </objEnvRec>
       _
     </env>

syntax K /* Val */ ::= "@GetBindingValue" "(" Eid "," Var "," Bool ")" 
// 10.2.1.1.4 GetBindingValue(N,S)
rule <k> @GetBindingValue(E:Eid,N:Var,S:Bool) => V ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> ... N |-> @ve(V:Val,Initialized:Bool,Mutable:Bool,_) ... </declEnvRec>
       _
     </env>
     when notBool(Initialized ==K false andBool Mutable ==K false)
rule <k> @GetBindingValue(E:Eid,N:Var,S:Bool)
      => %If S = true then {
           %Do @Throw(@ReferenceError("GetBindingValue, DeclEnv", N));
         } else {
           %Return @Undefined;
         }
      ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> ... N |-> @ve(_,false,false,_) ... </declEnvRec>
       _
     </env>
// 10.2.1.2.4 GetBindingValue(N,S)
rule <k> @GetBindingValue(E:Eid,N:Var,S:Bool)
      => %If @HasProperty(O,N) = true then {
           %Return @Get(O,N);
         } else {
           %If S = true then {
             %Do @Throw(@ReferenceError("GetBindingValue, ObjEnv", N));
           } else {
             %Return @Undefined;
           }
         } 
     ... </k>
     <env>
       <eid> E </eid>
       <objEnvRec>
         <bindingObj> O:Oid </bindingObj>
         _
       </objEnvRec>
       _
     </env>

syntax K /* Bool */ ::= "@DeleteBinding" "(" Eid "," Var ")" 
// 10.2.1.1.5 DeleteBinding (N)
rule <k> @DeleteBinding(E:Eid,N:Var) => true ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> ... (N |-> @ve(_,_,_,true) => .) ... </declEnvRec>
       _
     </env>
rule <k> @DeleteBinding(E:Eid,N:Var) => false ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> ... N |-> @ve(_,_,_,false) ... </declEnvRec>
       _
     </env>
rule <k> @DeleteBinding(E:Eid,N:Var) => true ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> Record:Map </declEnvRec>
       _
     </env>
     when notBool(N in keys(Record))
// 10.2.1.2.5 DeleteBinding (N)
rule <k> @DeleteBinding(E:Eid,N:Var) => @Delete(O,N,false) ... </k>
     <env>
       <eid> E </eid>
       <objEnvRec>
         <bindingObj> O:Oid </bindingObj>
         _
       </objEnvRec>
       _
     </env>

syntax K /* Val */ ::= "@ImplicitThisValue" "(" Eid ")" 
// 10.2.1.1.6 ImplicitThisValue()
rule <k> @ImplicitThisValue(E:Eid) => @Undefined ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> _ </declEnvRec>
       _
     </env>
// 10.2.1.2.6 ImplicitThisValue()
rule <k> @ImplicitThisValue(E:Eid) => O ... </k>
     <env>
       <eid> E </eid>
       <objEnvRec>
         <bindingObj> O:Oid </bindingObj>
         <provideThis> true </provideThis>
       </objEnvRec>
       _
     </env>
rule <k> @ImplicitThisValue(E:Eid) => @Undefined ... </k>
     <env>
       <eid> E </eid>
       <objEnvRec>
         <provideThis> false </provideThis>
         _
       </objEnvRec>
       _
     </env>

syntax K /* .K */ ::= "@CreateImmutableBinding" "(" Eid "," Var ")" 
// 10.2.1.1.7 CreateImmutableBinding (N)
rule <k> @CreateImmutableBinding(E:Eid,N:Var) => . ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> (. => N |-> @ve(@Undefined,false,false,false)) Record:Map </declEnvRec>
       _
     </env>
     when notBool(N in keys(Record))

syntax K /* .K */ ::= "@InitializeImmutableBinding" "(" Eid "," Var "," Val ")" 
// 10.2.1.1.8 InitializeImmutableBinding (N,V)
rule <k> @InitializeImmutableBinding(E:Eid,N:Var,V:Val) => . ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> ... N |-> @ve((_ => V),(false => true),false,_) ... </declEnvRec>
       _
     </env>

//////////////////////////////////////////////////////////////////////////////
// 10.2.2 Lexical Environment Operations
//////////////////////////////////////////////////////////////////////////////

// 10.2.2.1 GetIdentifierReference (lex, name, strict)

syntax K /* Reference */ ::= "@GetIdentifierReference" "(" Eid "," Var "," Bool ")"

rule @GetIdentifierReference(@NullEid,N:Var,Strict:Bool) => @Ref(@Undefined,N,Strict)
rule <k> @GetIdentifierReference(E:Eid,N:Var,Strict:Bool)
      => %If @HasBinding(E,N) = true then {
           %Return @Ref(E,N,Strict);
         } else {
           %Return @GetIdentifierReference(E',N,Strict);
         }
     ... </k>
     <env>
       <eid> E </eid>
       <outer> E' </outer>
       _
     </env>
     when E =/=K @NullEid

// 10.2.2.2 NewDeclarativeEnvironment (E)

syntax K /* Eid */ ::= "@NewDeclarativeEnvironment" "(" Eid "," Bool ")" 

rule <k> @NewDeclarativeEnvironment(E:Eid, Strict:Bool) => @e(N) ... </k>
     <envs>
       (. => <env>
               <eid> @e(N) </eid>
               <outer> E </outer>
               <strict> Strict </strict>
               <declEnvRec> .Map </declEnvRec>
             </env>)
       _
     </envs>
     when fresh(N:Int)

// 10.2.2.3 NewObjectEnvironment (O, E)

syntax K /* Eid */ ::= "@NewObjectEnvironment" "(" K /* Oid */ "," K /* Eid */ "," K /* Bool */ "," Bool ")" [seqstrict(1,2,3)]

rule <k> @NewObjectEnvironment(O:Oid,E:Eid,ProvideThis:Bool,Strict:Bool) => @e(N) ... </k>
     <envs>
       (. => <env>
               <eid> @e(N) </eid>
               <outer> E </outer>
               <strict> Strict </strict>
               <objEnvRec>
                 <bindingObj> O </bindingObj>
                 <provideThis> ProvideThis </provideThis>
               </objEnvRec>
             </env>)
       _
     </envs>
     when fresh(N:Int)

//////////////////////////////////////////////////////////////////////////////
// 10.4 Establishing an Execution Context
//////////////////////////////////////////////////////////////////////////////

// 10.4.1 Entering Global Code

syntax K /* .K */ ::= "@EnterGlobalCode" "(" Stmt ")"
rule <k> @EnterGlobalCode(Code:Stmt)
      => @CheckEarlyErrors(@IsStrict(Code), Code)
      ~> @BindDeclarations("function",false,Code)
      ~> @BindDeclarations("variable",false,Code)
     ... </k>
     <envs>
       // 10.2.3 The Global Environment
       (. => <env>
               <eid> @GlobalEid </eid>
               <objEnvRec>
                 <bindingObj> @GlobalOid </bindingObj>
                 <provideThis> false </provideThis>
               </objEnvRec>
               <outer> @NullEid </outer>
               <strict> @IsStrict(Code) </strict> // 10.1.1 Strict Mode Code, Case 1
             </env>)
     </envs>
     <ctx>
       <activeStack> . </activeStack>
       <running>
         <lexicalEnv>  . => @GlobalEid </lexicalEnv>
         <thisBinding> . => @GlobalOid </thisBinding>
         <lastNonEmptyValue> . => @Undefined </lastNonEmptyValue>
       </running>
     </ctx>

// 10.4.2 Entering Eval Code

syntax K /* .K */ ::= "@EnterEvalCode" "(" Stmt "," Bool /* Direct? */ ")"
syntax Id ::= "$strict"
rule <k> @EnterEvalCode(Code:Stmt, true)
      => %Let $strict = @IsStrict(Code) orBool Strict; // 10.1.1 Strict Mode Code, Case 2 (direct call to eval)
         %Do @CheckEarlyErrors($strict::K::Bool, Code);
         %Do @SetRunningCtx(@NewDeclarativeEnvironmentForEval(E,$strict::K::Bool), This);
         %Do @BindDeclarations("function",true,Code);
         %Do @BindDeclarations("variable",true,Code);
     ... </k>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         <thisBinding> This:Val </thisBinding>
         _
       </running>
       _
     </ctx>
     <env>
       <eid> E </eid>
       <strict> Strict:Bool </strict>
       _
     </env>
//
rule @EnterEvalCode(Code:Stmt, false)
  => %Let $strict = @IsStrict(Code); // 10.1.1 Strict Mode Code, Case 2 (NOT direct call to eval)
     %Do @CheckEarlyErrors($strict::K::Bool, Code);
     %Do @SetRunningCtx(@NewDeclarativeEnvironmentForEval(@GlobalEid,$strict::K::Bool), @GlobalOid);
     %Do @BindDeclarations("function",true,Code);
     %Do @BindDeclarations("variable",true,Code);

syntax K /* Eid */ ::= "@NewDeclarativeEnvironmentForEval" "(" Eid "," Bool /* Strict? */ ")"
rule @NewDeclarativeEnvironmentForEval(E,true ) => @NewDeclarativeEnvironment(E, true)
rule @NewDeclarativeEnvironmentForEval(E,false) => E

// 10.4.3 Entering Function Code

syntax K /* .K */ ::= "@EnterFunctionCode" "(" Oid "," Val "," Vals ")"
rule <k> @EnterFunctionCode(F:Oid,This:Val,Args:Vals)
      => %Do @SetRunningCtx(@NewDeclarativeEnvironment(E,Strict), @ResolveThis(Strict,This));
         %Do @BindFunctionParameters(F,Args);
         %Do @BindDeclarations("function",false,Code);
         %Do @BindArgumentsObject(F,Args);
         %Do @BindDeclarations("variable",false,Code);
     ... </k>
     <obj>
       <oid> F </oid>
       <internalProperties>
         "Scope" |-> E:Eid
         "Code" |-> Code:Stmt
         "Strict" |-> Strict:Bool
         _
       </internalProperties>
       _
     </obj>

syntax K /* Oid */ ::= "@ResolveThis" "(" Bool "," Val ")"
rule @ResolveThis(true, V:Val) => V
rule @ResolveThis(false,O:Oid) => O                   // NOTE: Method call or function call under the 'with'
rule @ResolveThis(false,@Undefined) => @GlobalOid     // NOTE: Function call without the 'with' (from p.28 of Good Parts)
rule @ResolveThis(false,@NullVal  ) => @GlobalOid     // NOTE: Apply call with 'null' as a 'this' value (from p.30 of Good Parts)
rule @ResolveThis(false,V:Val) => @ToObject(V) when isPrimitive(V) ==K true

syntax K /* .K */ ::= "@SetRunningCtx" "(" K /* Eid */ "," K /* Oid */ ")" [seqstrict(1,2)]
rule <k> @SetRunningCtx(E:Eid,This:Val) => . ... </k>
     <ctx>
       <activeStack> (. => @active(R)) _ </activeStack>
       <running>
         (R => <lexicalEnv> E </lexicalEnv>
               <thisBinding> This </thisBinding>
               <lastNonEmptyValue> @Undefined </lastNonEmptyValue>)
       </running>
     </ctx>

syntax K /* Val */ ::= "@RestoreRunningCtx"
rule <k> @RestoreRunningCtx => . ... </k>
     <ctx>
       <activeStack> (@active(R) => .) _ </activeStack>
       <running> _ => R </running>
     </ctx>

// 10.5 Declaration Binding Instantiation

// 10.5: Step 4: Function Parameter Binding Instantiation
syntax K /* .K */ ::= "@BindFunctionParameters" "(" Oid "," Vals ")" 
rule <k> @BindFunctionParameters(F:Oid,Args:Vals) => @SetParams(Ns,Args) ... </k>
     <obj>
       <oid> F </oid>
       <internalProperties> "FormalParameters" |-> Ns:Exps _ </internalProperties>
       _
     </obj>
//
syntax K /* .K */ ::= "@SetParams" "(" Exps "," Vals ")" 
rule @SetParams(%nil, _:Vals) => .
rule @SetParams(%cons(%var(N:Var), Ns:Exps), @Nil                 ) => @SetParam(N, @Undefined) ~> @SetParams(Ns, @Nil)
rule @SetParams(%cons(%var(N:Var), Ns:Exps), @Cons(V:Val, Vs:Vals)) => @SetParam(N, V         ) ~> @SetParams(Ns, Vs)
//
syntax K /* .K */ ::= "@SetParam" "(" Var "," Val ")"
rule <k> @SetParam(N,V)
      => @BindVariableDeclaration(N,false) // TODO: check if it is correct that the configurableBindings is false: Unspecified at Step 4.d.iv.
      ~> @SetMutableBinding(E,N,V,Strict) ... </k>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         _
       </running>
       _
     </ctx>
     <env>
       <eid> E </eid>
       <strict> Strict:Bool </strict>
       _
     </env>

// 10.5: Step 5 & 8: Function/Variable Declarations Binding Instantiation
// Visitor function
// NOTE: the second boolean argument indicates whether it is eval code or not
syntax K /* .K */ ::= "@BindDeclarations" "(" String "," Bool "," Stmt ")"
rule @BindDeclarations(Mode:String, CB:Bool, %fdecl(F:Var,Ps:Exps,FB:Stmt))      => %If Mode = "function" then { %Do @BindFunctionDeclaration(F,Ps,FB,CB); };
rule @BindDeclarations(Mode:String, CB:Bool, %vdecl(N:Var))                      => %If Mode = "variable" then { %Do @BindVariableDeclaration(N,CB); };
rule @BindDeclarations(Mode:String, CB:Bool, %seq(S1:Stmt,S2:Stmt))              => @BindDeclarations(Mode,CB,S1) ~> @BindDeclarations(Mode,CB,S2)
rule @BindDeclarations(Mode:String, CB:Bool, %exp(_))                            => .
rule @BindDeclarations(Mode:String, CB:Bool, %if(_,S1:Stmt,S2:Stmt))             => @BindDeclarations(Mode,CB,S1) ~> @BindDeclarations(Mode,CB,S2)
rule @BindDeclarations(Mode:String, CB:Bool, %do(S:Stmt,_))                      => @BindDeclarations(Mode,CB,S)
rule @BindDeclarations(Mode:String, CB:Bool, %while(_,S:Stmt))                   => @BindDeclarations(Mode,CB,S)
rule @BindDeclarations(Mode:String, CB:Bool, %for  (S1:Stmt,_,_,S2:Stmt))        => @BindDeclarations(Mode,CB,S1) ~> @BindDeclarations(Mode,CB,S2)
rule @BindDeclarations(Mode:String, CB:Bool, %forin(S1:Stmt,_,_,S2:Stmt))        => @BindDeclarations(Mode,CB,S1) ~> @BindDeclarations(Mode,CB,S2)
rule @BindDeclarations(Mode:String, CB:Bool, %continue(_))                       => .
rule @BindDeclarations(Mode:String, CB:Bool, %break(_))                          => .
rule @BindDeclarations(Mode:String, CB:Bool, %label(_,S:Stmt))                   => @BindDeclarations(Mode,CB,S)
rule @BindDeclarations(Mode:String, CB:Bool, %return(_))                         => .
rule @BindDeclarations(Mode:String, CB:Bool, %throw(_))                          => .
rule @BindDeclarations(Mode:String, CB:Bool, %try(S1:Stmt,_,S2:Stmt,S3:Stmt))    => @BindDeclarations(Mode,CB,S1) ~> @BindDeclarations(Mode,CB,S2) ~> @BindDeclarations(Mode,CB,S3)
rule @BindDeclarations(Mode:String, CB:Bool, %try(S1:Stmt,          S3:Stmt))    => @BindDeclarations(Mode,CB,S1) ~>                                  @BindDeclarations(Mode,CB,S3)
rule @BindDeclarations(Mode:String, CB:Bool, %with(_,S:Stmt))                    => @BindDeclarations(Mode,CB,S)
rule @BindDeclarations(Mode:String, CB:Bool, %emptyStmt)                         => .
rule @BindDeclarations(Mode:String, CB:Bool, %print(_))                          => .
rule @BindDeclarations(Mode:String, CB:Bool, %switch(_,S1:Stmt,S2:Stmt,S3:Stmt)) => @BindDeclarations(Mode,CB,S1) ~> @BindDeclarations(Mode,CB,S2) ~> @BindDeclarations(Mode,CB,S3)
rule @BindDeclarations(Mode:String, CB:Bool, %case(_,S:Stmt))                    => @BindDeclarations(Mode,CB,S)
rule @BindDeclarations(Mode:String, CB:Bool, %default(S:Stmt))                   => @BindDeclarations(Mode,CB,S)

// 10.5: Step 5: Function Declaration Binding Instantiation
syntax K /* .K */ ::= "@BindFunctionDeclaration" "(" Var "," Exps "," Stmt "," Bool ")"
syntax Id ::= "$existingProp"
rule <k> @BindFunctionDeclaration(N:Var, Params:Exps, FunBody:Stmt, ConfigurableBindings:Bool)
      => %If @HasBinding(E,N) = false then {
           %Do @CreateMutableBinding(E,N,ConfigurableBindings);
         } else {
           %If E = @GlobalEid then {
             %Let $existingProp = @GetProperty(@GlobalOid,N);
             %If $existingProp."Configurable" = true then {
               %DoI @DefineOwnProperty(@GlobalOid, N, @desc("Value" |-> @Undefined "Writable" |-> true "Enumerable" |-> true "Configurable" |-> ConfigurableBindings), true);
             } else {
               %If @IsAccessorDescriptor($existingProp::K::Val) = true then {
                 %Do @Throw(@TypeError("BindFunctionDeclaration accessor",$existingProp));
               };
               %If @AndBool($existingProp."Writable", $existingProp."Enumerable") = false then {
                 %Do @Throw(@TypeError("BindFunctionDeclaration writable/enumerable",$existingProp));
               };
             }
           };
         }
         %Do @SetMutableBinding(E, N, @FunctionDeclaration(N,Params,FunBody), Strict);
     ... </k>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         _
       </running>
       _
     </ctx>
     <env>
       <eid> E </eid>
       <strict> Strict:Bool </strict>
       _
     </env>

// 10.5: Step 8: Variable Declaration Binding Instantiation
syntax K /* .K */ ::= "@BindVariableDeclaration" "(" Var "," Bool ")"
rule <k> @BindVariableDeclaration(N:Var, ConfigurableBindings:Bool)
      => %If @HasBinding(E,N) = true then {
           %Return;
         } else {
           %Do @CreateMutableBinding(E,N,ConfigurableBindings);
           %Do @SetMutableBinding(E,N,@Undefined,Strict);
         }
     ... </k>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         _
       </running>
       _
     </ctx>
     <env>
       <eid> E </eid>
       <strict> Strict:Bool </strict>
       _
     </env>

syntax K /* .K */ ::= "@BindArgumentsObject" "(" Oid "," Vals ")"
syntax Id ::= "$argsObj"
rule <k> @BindArgumentsObject(F:Oid,Args:Vals)
      => %If @HasBinding(E,"arguments") = false then {
           %Let $argsObj = @CreateArgumentsObject(F,Names,Args,E,Strict);
           %If Strict = true then {
             %Do @CreateImmutableBinding(E,"arguments");
             %Do @InitializeImmutableBinding(E,"arguments",$argsObj::K::Val);
           } else {
             %Do @CreateMutableBinding(E,"arguments",false); // TODO: check if the third argument is false or not (not mentioned in the specification)
             %Do @SetMutableBinding(E,"arguments",$argsObj::K::Val,false);
           }
         };
     ... </k>
     <obj>
       <oid> F </oid>
       <internalProperties>
         "FormalParameters" |-> Names:Exps
         _
       </internalProperties>
       _
     </obj>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         _
       </running>
       _
     </ctx>
     <env>
       <eid> E </eid>
       <strict> Strict:Bool </strict>
       _
     </env>

// 10.6 Arguments Object

syntax K /* Oid */ ::= "@CreateArgumentsObject" "(" Oid "," Exps "," Vals "," Eid "," Bool ")"
syntax Id ::= "$len" | "$map"
rule @CreateArgumentsObject(Func:Oid, Names:Exps, Args:Vals, Env:Eid, Strict:Bool)
  => %Let $len = @LengthVals(Args);
     %Let $obj = @CreateObject;
     %Do @SetInternalProperty($obj::K::Oid, "Class", "Arguments");
     %DoI @DefineOwnProperty($obj, "length", @GenDesc("Value", $len, "Writable", true, "Enumerable", false, "Configurable", true), false);
     %Let $map = @CreateObject;
     %Do @BindActualParams($obj::K::Oid, Args, 0);
     %If Strict = false then {
       %Do @BindFormalParams($map::K::Oid, Names, Args, Env, 0);
     };
     %If @Length(Names) >Int 0 = true then {
       %Do @SetInternalProperty($obj::K::Oid, "ParameterMap", $map::K::Val);
     };
     %If Strict = true then {
       %DoI @DefineOwnProperty($obj, "caller", @desc("Get" |-> @("ThrowTypeError") "Set" |-> @("ThrowTypeError") "Enumerable" |-> false "Configurable" |-> false), false);
       %DoI @DefineOwnProperty($obj, "callee", @desc("Get" |-> @("ThrowTypeError") "Set" |-> @("ThrowTypeError") "Enumerable" |-> false "Configurable" |-> false), false);
     } else {
       %DoI @DefineOwnProperty($obj, "callee", @desc("Value" |-> Func "Writable" |-> true "Enumerable" |-> false "Configurable" |-> true), false);
     }
     %Return $obj;

syntax K /* .K */ ::= "@BindActualParams" "(" Oid "," Vals "," Int ")"
rule @BindActualParams(O:Oid, @Nil, _) => .
rule @BindActualParams(O:Oid, @Cons(V:Val,Vs:Vals), I:Int)
  => @DefineOwnProperty(O, @ToString(I), @desc("Value" |-> V "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false) ~> @Ignore ~>
     @BindActualParams(O, Vs, I +Int 1)

syntax K /* .K */ ::= "@BindFormalParams" "(" Oid "," Exps "," Vals "," Eid "," Int ")"
// TODO: consider step 11.c.ii 2nd condition: "name is not an element of mappedNames". what if duplicated names?
rule @BindFormalParams(M:Oid, %nil, _, _, _) => .
rule @BindFormalParams(M:Oid, _, @Nil, _, _) => .
rule @BindFormalParams(M:Oid, %cons(%var(Name:Var),Names:Exps), @Cons(Arg:Val,Args:Vals), Env:Eid, I:Int)
  => %Let $getter = @MakeArgGetter(Name,Env);
     %Let $setter = @MakeArgSetter(Name,Env);
     %DoI @DefineOwnProperty(M, @ToString(I), @GenDesc("Get", $getter, "Set", $setter, "Configurable", true), false);
     %Do @BindFormalParams(M, Names, Args, Env, I +Int 1);

syntax K /* Oid */ ::= "@MakeArgGetter" "(" Var "," Eid ")"
rule @MakeArgGetter(N:Var,E:Eid) => @CreateFunctionObject(%nil, %return(%var(N)), E, true) // TODO: in what case? // 10.1.1 Strict Mode Code, Case ?

syntax K /* Oid */ ::= "@MakeArgSetter" "(" Var "," Eid ")"
syntax Id ::= "$param"
rule @MakeArgSetter(N:Var,E:Eid)
  => %Let $param = N::String +String "_arg";
     %Return @CreateFunctionObject(%cons(%var($param::K::Var),%nil), %exp(%bop(%assign,%var(N),%var($param::K::Var))), E, true); // TODO: in what case? // 10.1.1 Strict Mode Code, Case ?

syntax K /* Bool */ ::= "@IsArgumentsObjectNonStrictWithFormalParams" "(" Oid ")"
rule <k> @IsArgumentsObjectNonStrictWithFormalParams(O:Oid)
      => Class ==String "Arguments" andBool notBool(Strict) andBool "ParameterMap" in keys(InternalProperties) ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "Class" |-> Class:String
         InternalProperties:Map
       </internalProperties>
       _
     </obj>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         _
       </running>
       _
     </ctx>
     <env>
       <eid> E </eid>
       <strict> Strict:Bool </strict>
       _
     </env>

syntax Id ::= "$isMapped" | "$allowed"

syntax K /* Val */ ::= "@Get@Arguments" "(" Oid "," Var ")" 

rule @Get@Arguments(O:Oid,P:Var)
  => %Let $map = @GetInternalProperty(O,"ParameterMap");
     %Let $isMapped = @GetOwnProperty($map,P);
     %If $isMapped = @Undefined then {
       %Return @Get@Default(O,P); // TODO: consider step 3.b
     } else {
       %Return @Get($map::K::Oid,P);
     }

syntax K /* Val */ ::= "@GetOwnProperty@Arguments" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict(1,2)]

rule @GetOwnProperty@Arguments(O:Oid,P:Var)
  => %Let $desc = @GetOwnProperty@Default(O,P);
     %If $desc = @Undefined then {
       %Return $desc;
     } else {
       %Let $map = @GetInternalProperty(O,"ParameterMap");
       %Let $isMapped = @GetOwnProperty($map,P);
       %If $isMapped = @Undefined then {
         %Return $desc;
       } else {
         %Return @AddDesc("Value", @Get($map::K::Oid,P), $desc);
       }
     }

syntax K /* Bool */ ::= "@DefineOwnProperty@Arguments" "(" K /* Oid */ "," K /* Var */ "," K /* PropertyDescriptor */ "," K /* Bool */ ")" [seqstrict(1,2,3,4)]

rule @DefineOwnProperty@Arguments(O:Oid,P:Var,Desc:PropertyDescriptor,Throw:Bool)
  => %Let $map = @GetInternalProperty(O,"ParameterMap");
     %Let $isMapped = @GetOwnProperty($map,P);
     %Let $allowed = @DefineOwnProperty@Default(O,P,Desc,false);
     %If $allowed = false then {
       %If Throw = true then {
         %Do @Throw(@TypeError("DefineOwnProperty for Arguments",@DefineOwnProperty(O,P,Desc,Throw)));
       } else {
         %Return false;
       }
     } else {
       %If $isMapped = @Undefined then {
         %Nop;
       } else {
         %If @IsAccessorDescriptor(Desc) = true then {
           %DoI @Delete($map::K::Oid, P, false);
         } else {
           %If @MemDesc(Desc,"Value") = true then {
             %Do @Put($map::K::Oid, P, Desc."Value", Throw);
           };
           %If Desc."Writable" = false then {
             %DoI @Delete($map::K::Oid, P, false);
           };
         }
       }
       %Return true;
     }

syntax K /* Bool */ ::= "@Delete@Arguments" "(" Oid "," Var "," Bool ")" 

rule @Delete@Arguments(O:Oid,P:Var,Throw:Bool)
  => %Let $map = @GetInternalProperty(O,"ParameterMap");
     %Let $isMapped = @GetOwnProperty($map,P);
     %Let $result = @Delete@Default(O,P,Throw);
     %If @AndBool($result, @NeqVal($isMapped, @Undefined)) = true then {
       %DoI @Delete($map::K::Oid, P, false);
     };
     %Return $result;

//////////////////////////////////////////////////////////////////////////////
// 11 Expressions
//////////////////////////////////////////////////////////////////////////////

syntax K /* Reference */ ::= "@GetReference" "(" Exp ")"

rule <k> @GetReference(%var(N:Var)) => @GetIdentifierReference(E,N,Strict) ... </k>
     <running>
       <lexicalEnv> E:Eid </lexicalEnv>
       _
     </running>
     <env>
       <eid> E </eid>
       <strict> Strict:Bool </strict>
       _
     </env>

context @GetReference(%mem(HOLE,_))
context @GetReference(%mem(_:Val,HOLE))
rule <k> @GetReference(%mem(O:Val,N:Val)) // NOTE: O does not need to be an Oid
      => @CheckObjectCoercible(O) ~> @Ref(O, @ToString(N), Strict) ... </k>
     <running>
       <lexicalEnv> E:Eid </lexicalEnv>
       _
     </running>
     <env>
       <eid> E </eid>
       <strict> Strict:Bool </strict>
       _
     </env>

rule @GetReference(E:Exp) => @Throw(@ReferenceError("GetReference",E)) when @IsReferenceExp(E) =/=K true

syntax K /* Bool */ ::= "@IsReferenceExp" "(" Exp ")" [function]

rule @IsReferenceExp(E:Exp) => getKLabel(E) ==KLabel '%var`(_`)
                        orBool getKLabel(E) ==KLabel '%mem`(_`,_`)

rule %emptyExp => @Undefined

// 11.1.1 The this Keyword

rule <k> %this => This ... </k>
     <running>
       <thisBinding> This:Val </thisBinding>
       _
     </running>

// 11.1.2 Identifier Reference
// 10.3.1 Identifier Resolution

rule %var(N:Var) => @GetValue(@GetReference(%var(N)))

// 11.1.3 Literal Reference
// TODO: Numeric, Regular Expressions

rule %con(%this)    => %this
rule %con(%null)    => %null
rule %con(B:Bool)   => B
rule %con(I:Int)    => @ResolveOverflow(I)
rule %con(F:Float)  => @ResolveOverflow(F)
rule %con(S:String) => S

// 11.1.4 Array Initialiser

rule %arr(Es:Exps) => @MakeArray(@RemoveLastEmptyExp(Es))

// NOTE: the last ending comma should be ignored: [ 1, 2, ] => [ 1, 2 ]
//       "If an element is elided at the end of an array, that element does not contribute to the length of the Array."
syntax Exps ::= "@RemoveLastEmptyExp" "(" Exps ")" [function]
rule @RemoveLastEmptyExp(                   %nil ) => %nil
rule @RemoveLastEmptyExp(%cons(%emptyExp,   %nil)) => %nil
rule @RemoveLastEmptyExp(%cons(E:Exp,       %nil)) => %cons(E,%nil) when E =/=K %emptyExp
rule @RemoveLastEmptyExp(%cons(E:Exp,    Es:Exps)) => %cons(E,@RemoveLastEmptyExp(Es)) when Es =/=K %nil

// 11.1.5 Object Initialiser
// TODO:IMP: step 4 of p.66: duplicated properties

rule %obj(PAs:Exps) => @AssignProps(@CreateObject,PAs)

syntax K /* Oid */ ::= "@AssignProps" "(" K /* Oid */ "," Exps ")" [seqstrict(1)]
rule @AssignProps(O:Oid, %nil) => O
rule @AssignProps(O:Oid, %cons(PA:Exp, PAs:Exps)) => @AssignProp(O,PA) ~> @AssignProps(O,PAs)

syntax K /* .K */ ::= "@AssignProp" "(" Oid "," Exp ")" 

context @AssignProp(_,%prop(_,HOLE))
rule @AssignProp(O:Oid, %prop(P:Var,V:Val))
  => @DefineOwnProperty(O, P, @desc("Value" |-> V "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false) ~> @Ignore

rule <k> @AssignProp(O:Oid, %get(P:Var,FunBody:Stmt))
      => %Let $closure = @CreateFunctionObject(%nil, FunBody, E, @IsStrict(FunBody) orBool Strict); // 10.1.1 Strict Mode Code, Case 3
         %DoI @DefineOwnProperty(O, P, @GenDesc("Get", $closure, "Enumerable", true, "Configurable", true), false);
     ... </k>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         _
       </running>
       _
     </ctx>
     <env>
       <eid> E </eid>
       <strict> Strict:Bool </strict>
       _
     </env>

rule <k> @AssignProp(O:Oid, %set(P:Var,X:Var,FunBody:Stmt))
      => %Let $closure = @CreateFunctionObject(%cons(%var(X),%nil), FunBody, E, @IsStrict(FunBody) orBool Strict); // 10.1.1 Strict Mode Code, Case 3
         %DoI @DefineOwnProperty(O, P, @GenDesc("Set", $closure, "Enumerable", true, "Configurable", true), false);
     ... </k>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         _
       </running>
       _
     </ctx>
     <env>
       <eid> E </eid>
       <strict> Strict:Bool </strict>
       _
     </env>

// 11.1.6 The Grouping Operator
// NOTE: Nothing to do

// 11.2.1 Property Accessors

rule %mem(E1:Exp,E2:Exp) => @GetValue(@GetReference(%mem(E1,E2)))

// 11.2.2 The new Operator

rule %new(F:Exp,Es:Exps) => @ConstructIfPossible(F,Es)
     when @IsStandardBuiltinObject(F) ==K false // TODO: could it be made in uniform way?

syntax K /* Oid */ ::= "@ConstructIfPossible" "(" K /* Val */ "," K /* Vals */ ")" [seqstrict(1,2)]
rule @ConstructIfPossible(F:Val, Args:Vals)
  => %If @IsConstructable(F) = true then {
       %Do @Construct(F, Args);
     } else {
       %Do @Throw(@TypeError("ConstructIfPossible",F));
     }

syntax K /* Bool */ ::= "@IsConstructable" "(" Val ")"
rule <k> @IsConstructable(F:Oid) => "prototype" in keys(Prop) ... </k>
     <obj>
       <oid> F </oid>
       <properties> Prop </properties>
       _
     </obj>
rule @IsConstructable(F:Val) => false when @IsOid(F) =/=K true

// 11.2.3 Function Calls

rule %call(F:Exp,Es:Exps) => @CallIfPossible(F, @DetermineThis(F), Es)
     when @IsStandardBuiltinObject(F) ==K false // TODO: could it be made in uniform way?

syntax K /* Val */ ::= "@DetermineThis" "(" Exp ")"

rule @DetermineThis(F) => @FindThis(@GetReference(F)) when @IsReferenceExp(F) ==K true
rule @DetermineThis(F) => @Undefined                  when @IsReferenceExp(F) ==K false

syntax K /* Val */ ::= "@FindThis" "(" K /* Reference */ ")" [seqstrict(1)]

rule @FindThis(@Ref(O:Oid,_,_)) => O
rule @FindThis(@Ref(E:Eid,_,_)) => @ImplicitThisValue(E)
rule @FindThis(@Ref(I:Primitive,_,_)) => I // NOTE: This will be resolved by @ResolveThis
rule @FindThis(@Ref(@Undefined,_,_)) => @Undefined

syntax K /* Val */ ::= "@CallIfPossible" "(" K /* Val */ "," K /* Val */ "," K /* Vals */ ")" [seqstrict(1,2,3)]

rule @CallIfPossible(F:Val, This:Val, Args:Vals)
  => %If @IsCallable(F) = true then {
       %Do @Call(F, This, Args);
     } else {
       %Do @Throw(@TypeError("CallIfPossible",F));
     }

// 11.2.4 Argument Lists

context %cons(HOLE,_)
context %cons(_:Val,HOLE)
rule %cons(V:Val,Vs:Vals) => @Cons(V,Vs)
rule %nil => @Nil

// 11.2.5 Function Expressions

rule %fun(       Params:Exps, FunBody:Stmt) => @FunctionExpressionAnonymous(   Params, FunBody)
rule %fun(F:Var, Params:Exps, FunBody:Stmt) => @FunctionExpressionRecursive(F, Params, FunBody)

// 11.3.1 Postfix Increment Operator

syntax Id ::= "$lhs" | "$oldValue" | "$newValue"

rule %post(E:Exp,%inc)
  => %Let $lhs = @GetReference(E);
     %Let $oldValue = @ToNumber(@GetValue($lhs));
     %Let $newValue = @Addition($oldValue,1);
     %Do @PutValue($lhs,$newValue);
     %Return $oldValue;

// 11.3.2 Postfix Decrement Operator

rule %post(E:Exp,%dec)
  => %Let $lhs = @GetReference(E);
     %Let $oldValue = @ToNumber(@GetValue($lhs));
     %Let $newValue = @Subtraction($oldValue,1);
     %Do @PutValue($lhs,$newValue);
     %Return $oldValue;

// 11.4.1 The delete Operator

// TODO: consider the first sentence of note.
rule %pre(%delete,E:Exp)
  => %If @IsReferenceExp(E) = false then {
       %DoI E;
       %Return true;
     } else {
       %Let $ref = @GetReference(E);
       %If @IsUnresolvableReference($ref) = true then {
         %If @IsStrictReference($ref) = true then {
           %Do @Throw(@SyntaxError("delete unresolvable ref",$ref));
         } else {
           %Return true;
         }
       } else {
         %If @IsPropertyReference($ref) = true then {
           %Return @Delete(@ToObject(@GetBase($ref)), @GetReferencedName($ref), @IsStrictReference($ref));
         } else {
           %If @IsStrictReference($ref) = true then {
             %Do @Throw(@SyntaxError("delete not property ref",$ref));
           } else {
             %Return @DeleteBinding(@GetBase($ref), @GetReferencedName($ref));
           }
         }
       }
     }

// 11.4.2 The void Operator

rule %pre(%void,E:Exp) => E ~> @Ignore ~> @Undefined

// 11.4.3 The typeof Operator

rule %pre(%typeof,E:Exp) => @Try(@TypeOf(E),"undefined")

syntax K ::= "@TypeOf" "(" K /* Val */ ")" [seqstrict(1)]
rule @TypeOf(@Undefined) => "undefined"
rule @TypeOf(@NullVal  ) => "object"
rule @TypeOf(_:Bool    ) => "boolean"
rule @TypeOf(_:Number  ) => "number"
rule @TypeOf(_:String  ) => "string"
rule @TypeOf(O:Oid     )
  => %If @IsCallable(O) = true then {
       %Return "function";
     } else {
       %Return "object";
     }
// for built-in objects' functions
rule @TypeOf(@(_)      ) => "function" // TODO: is there any better way?

// NOTE: We don't need to consider the 'Case 2.a' that the reference value of E is an unresolvable reference.
//       If the case happens, evaluating E throws an ReferenceError and we can catch the case.

syntax K ::= "@Try" "(" K "," K ")" | "@PopExc"
syntax ListItem ::= "@exc" "(" K "," K "," CtrlCellFragment ")"

rule <k> (@Try(E1:K,E2:K) => E1 ~> @PopExc) ~> K </k>
     <ctrl>
       <excStack> (. => @exc(E2,K,Ctrl)) _ </excStack>
       Ctrl
     </ctrl>

rule <k> V:Val ~> @PopExc => V ... </k>
     <ctrl>
       <excStack> (@exc(_,_,_) => .) _ </excStack>
       _
     </ctrl>

rule <k> @Throw(V) ~> _ => E2 ~> K </k>
     <ctrl>
       <excStack> (@exc(E2,K,Ctrl) => .) _ </excStack>
       (_ => Ctrl)
     </ctrl>

// 11.4.4 Prefix Increment Operator

rule %pre(%inc,E:Exp)
  => %Let $lhs = @GetReference(E);
     %Let $oldValue = @ToNumber(@GetValue($lhs));
     %Let $newValue = @Addition($oldValue,1);
     %Do @PutValue($lhs,$newValue);
     %Return $newValue;

// 11.4.5 Prefix Decrement Operator

rule %pre(%dec,E:Exp)
  => %Let $lhs = @GetReference(E);
     %Let $oldValue = @ToNumber(@GetValue($lhs));
     %Let $newValue = @Subtraction($oldValue,1);
     %Do @PutValue($lhs,$newValue);
     %Return $newValue;

// 11.4.6 Unary + Operator

rule %pre(%plus,E:Exp) => @ToNumber(E)

// 11.4.7 Unary - Operator

rule %pre(%minus,E:Exp) => @Minus(@ToNumber(E))

syntax K ::= "@Minus" "(" K /* Number */ ")" [seqstrict(1)]
rule @Minus(I:Int     ) => I *Int   (-1)   when I =/=Int   0
rule @Minus(F:Float   ) => F *Float (-1.0) when F =/=Float 0.0
rule @Minus(0         ) => @nz
rule @Minus(0.0       ) => @nz
rule @Minus(@nz       ) => 0.0
rule @Minus(@NaN      ) => @NaN
rule @Minus(@+Infinity) => @-Infinity
rule @Minus(@-Infinity) => @+Infinity

// 11.4.8 Bitwise NOT Operator ( ~ )

rule %pre(%tilde,E:Exp) => @NotBitwise(@ToInt32(E))

syntax K ::= "@NotBitwise" "(" K ")" [seqstrict(1)]

rule @NotBitwise(I:Int) => ~Int I

// 11.4.9 Logical NOT Operator ( ! )

rule %pre(%bang,E:Exp) => @Not(@ToBoolean(E))

syntax K ::= "@Not" "(" K /* Bool */ ")" [seqstrict(1)]
rule @Not(true) => false
rule @Not(false) => true

// 11.? Binary Operator

context %bop(OpNormal,HOLE,_)
context %bop(OpNormal,_:Val,HOLE)

// TODO: IEEE 754 binary double-precision arithmetic: *, /, %, +, -

syntax K ::= "@ResolveOverflow" "(" K /* Number */ ")" [seqstrict(1)]
rule @ResolveOverflow(F:Float) => @ResolveOverflowAux(F,F)
rule @ResolveOverflow(I:Int)   => @ResolveOverflowAux(I,Int2Float(I))
//
rule @ResolveOverflow(N:Number) => N when isFloat(N) =/=K true andBool isInt(N) =/=K true

syntax K ::= "@ResolveOverflowAux" "(" Number "," Float ")"
syntax Id ::= "$max"
rule @ResolveOverflowAux(N:Number, F:Float)
  => %Let $max = 1.7976931348623157e308; // MAX_VALUE
     %If F >=Float 0.0 = true then {
       %If F >Float $max::K::Float = true then {
         %Return @+Infinity;
       } else {
         %Return N;
       }
     } else {
       %If (F *Float -1.0) >Float $max::K::Float = true then {
         %Return @-Infinity;
       } else {
         %Return N;
       }
     }

syntax K ::= "@ResolveNumber" "(" K /* Number */ "," K /* Bool */ ")" [seqstrict(1,2)]
rule @ResolveNumber(0.0,false) => @nz
rule @ResolveNumber(N:Number,Positive:Bool) => N when N =/=K 0.0 orBool Positive =/=K false

syntax Bool ::= "@IsPositive" "(" Number ")" [function]
rule @IsPositive(I:Int)   => I >=Int   0
rule @IsPositive(F:Float) => F >=Float 0.0
rule @IsPositive(@nz) => false
rule @IsPositive(@NaN) => true // TODO:
rule @IsPositive(@+Infinity) => true
rule @IsPositive(@-Infinity) => false

// 11.5.1 Applying the * Operator

rule %bop(%times,V1:Val,V2:Val) => @ResolveOverflow(@MultiplicationSign(@ToNumber(V1),@ToNumber(V2)))

syntax K ::= "@MultiplicationSign" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
rule @MultiplicationSign(N1:Number,N2:Number) => @ResolveNumber(@Multiplication(N1,N2), @XorBool(@IsPositive(N1),@IsPositive(N2)))

syntax K ::= "@Multiplication" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
rule @Multiplication(@NaN,_) => @NaN
rule @Multiplication(_,@NaN) => @NaN
//
rule @Multiplication(I1:Int,I2:Int    ) => I1            *Int   I2
rule @Multiplication(I1:Int,F2:Float  ) => Int2Float(I1) *Float F2
rule @Multiplication( I:Int,@nz       ) => @MultiplicationNegativeZero(I)
rule @Multiplication( I:Int,@+Infinity) => @MultiplicationInfinity(I)
rule @Multiplication( I:Int,@-Infinity) => @MultiplicationInfinity(@Minus(I))
//
rule @Multiplication(F1:Float,I2:Int    ) => F1 *Float Int2Float(I2)
rule @Multiplication(F1:Float,F2:Float  ) => F1 *Float F2
rule @Multiplication( F:Float,@nz       ) => @MultiplicationNegativeZero(F)
rule @Multiplication( F:Float,@+Infinity) => @MultiplicationInfinity(F)
rule @Multiplication( F:Float,@-Infinity) => @MultiplicationInfinity(@Minus(F))
//
rule @Multiplication(@nz,I:Int     ) => @MultiplicationNegativeZero(I)
rule @Multiplication(@nz,F:Float   ) => @MultiplicationNegativeZero(F)
rule @Multiplication(@nz,@nz       ) => 0
rule @Multiplication(@nz,@+Infinity) => @NaN
rule @Multiplication(@nz,@-Infinity) => @NaN
//
rule @Multiplication(@+Infinity,I:Int     ) => @MultiplicationInfinity(I)
rule @Multiplication(@+Infinity,F:Float   ) => @MultiplicationInfinity(F)
rule @Multiplication(@+Infinity,@nz       ) => @MultiplicationInfinity(@nz)
rule @Multiplication(@+Infinity,@+Infinity) => @+Infinity
rule @Multiplication(@+Infinity,@-Infinity) => @-Infinity
//
rule @Multiplication(@-Infinity,I:Int     ) => @MultiplicationInfinity(@Minus(I))
rule @Multiplication(@-Infinity,F:Float   ) => @MultiplicationInfinity(@Minus(F))
rule @Multiplication(@-Infinity,@nz       ) => @MultiplicationInfinity(@Minus(@nz))
rule @Multiplication(@-Infinity,@+Infinity) => @-Infinity
rule @Multiplication(@-Infinity,@-Infinity) => @+Infinity

syntax K ::= "@MultiplicationInfinity" "(" K /* Number */ ")" [seqstrict(1)]
rule @MultiplicationInfinity(@nz    ) => @NaN
rule @MultiplicationInfinity(0      ) => @NaN
rule @MultiplicationInfinity(I:Int  ) => @+Infinity when I >Int 0
rule @MultiplicationInfinity(I:Int  ) => @-Infinity when I <Int 0
rule @MultiplicationInfinity(0.0    ) => @NaN
rule @MultiplicationInfinity(F:Float) => @+Infinity when F >Float 0.0
rule @MultiplicationInfinity(F:Float) => @-Infinity when F <Float 0.0

syntax K ::= "@MultiplicationNegativeZero" "(" K /* Number */ ")"
rule @MultiplicationNegativeZero(I:Int  ) => @nz when I >=Int 0
rule @MultiplicationNegativeZero(I:Int  ) => 0   when I  <Int 0
rule @MultiplicationNegativeZero(F:Float) => @nz when F >=Float 0.0
rule @MultiplicationNegativeZero(F:Float) => 0   when F  <Float 0.0

// 11.5.2 Applying the / Operator

rule %bop(%div,V1:Val,V2:Val) => @ResolveOverflow(@DivisionSign(@ToNumber(V1),@ToNumber(V2)))

syntax K ::= "@DivisionSign" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
rule @DivisionSign(N1:Number,N2:Number) => @ResolveNumber(@Division(N1,N2), @XorBool(@IsPositive(N1),@IsPositive(N2)))

syntax K ::= "@Division" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
rule @Division(@NaN,_) => @NaN
rule @Division(_,@NaN) => @NaN
//
rule @Division(0,  N:Number) =>        @DivisionZero(N)  when N =/=K @NaN
rule @Division(0.0,N:Number) =>        @DivisionZero(N)  when N =/=K @NaN
rule @Division(@nz,N:Number) => @Minus(@DivisionZero(N)) when N =/=K @NaN
//
rule @Division(N:Number,0  ) =>        @DivisionByZero(N)  when N =/=K @NaN
rule @Division(N:Number,0.0) =>        @DivisionByZero(N)  when N =/=K @NaN
rule @Division(N:Number,@nz) => @Minus(@DivisionByZero(N)) when N =/=K @NaN
//
rule @Division(@+Infinity,N:Number) =>        @DivisionInfinity(N)  when N =/=K @NaN
rule @Division(@-Infinity,N:Number) => @Minus(@DivisionInfinity(N)) when N =/=K @NaN
//
rule @Division(N:Number,@+Infinity) =>        @DivisionByInfinity(N)  when N =/=K @NaN
rule @Division(N:Number,@-Infinity) => @Minus(@DivisionByInfinity(N)) when N =/=K @NaN
//
rule @Division(I1:Int,  I2:Int    ) => Int2Float(I1) /Float Int2Float(I2) when I1 =/=Int   0   andBool I2 =/=Int   0
rule @Division(I1:Int,  F2:Float  ) => Int2Float(I1) /Float F2            when I1 =/=Int   0   andBool F2 =/=Float 0.0
rule @Division(F1:Float,I2:Int    ) =>           F1  /Float Int2Float(I2) when F1 =/=Float 0.0 andBool I2 =/=Int   0
rule @Division(F1:Float,F2:Float  ) =>           F1  /Float F2            when F1 =/=Float 0.0 andBool F2 =/=Float 0.0

syntax K ::= "@DivisionZero" "(" K /* Number */ ")" [seqstrict(1)]
rule @DivisionZero(@nz    ) => @NaN
rule @DivisionZero(0      ) => @NaN
rule @DivisionZero(I:Int  ) => 0   when I >Int 0
rule @DivisionZero(I:Int  ) => @nz when I <Int 0
rule @DivisionZero(0.0    ) => @NaN
rule @DivisionZero(F:Float) => 0   when F >Float 0.0
rule @DivisionZero(F:Float) => @nz when F <Float 0.0
rule @DivisionZero(@+Infinity) => 0
rule @DivisionZero(@-Infinity) => @nz

syntax K ::= "@DivisionInfinity" "(" K /* Number */ ")" [seqstrict(1)]
rule @DivisionInfinity(@nz    ) => @-Infinity
rule @DivisionInfinity(0      ) => @+Infinity
rule @DivisionInfinity(I:Int  ) => @+Infinity when I >Int 0
rule @DivisionInfinity(I:Int  ) => @-Infinity when I <Int 0
rule @DivisionInfinity(0.0    ) => @+Infinity
rule @DivisionInfinity(F:Float) => @+Infinity when F >Float 0.0
rule @DivisionInfinity(F:Float) => @-Infinity when F <Float 0.0
rule @DivisionInfinity(@+Infinity) => @NaN
rule @DivisionInfinity(@-Infinity) => @NaN

syntax K ::= "@DivisionByZero" "(" K /* Number */ ")" [seqstrict(1)]
rule @DivisionByZero(@nz    ) => @NaN
rule @DivisionByZero(0      ) => @NaN
rule @DivisionByZero(I:Int  ) => @+Infinity when I >Int 0
rule @DivisionByZero(I:Int  ) => @-Infinity when I <Int 0
rule @DivisionByZero(0.0    ) => @NaN
rule @DivisionByZero(F:Float) => @+Infinity when F >Float 0.0
rule @DivisionByZero(F:Float) => @-Infinity when F <Float 0.0
rule @DivisionByZero(@+Infinity) => @+Infinity
rule @DivisionByZero(@-Infinity) => @-Infinity

syntax K ::= "@DivisionByInfinity" "(" K /* Number */ ")" [seqstrict(1)]
rule @DivisionByInfinity(@nz    ) => @nz
rule @DivisionByInfinity(0      ) => 0
rule @DivisionByInfinity(I:Int  ) => 0   when I >Int 0
rule @DivisionByInfinity(I:Int  ) => @nz when I <Int 0
rule @DivisionByInfinity(0.0    ) => 0.0
rule @DivisionByInfinity(F:Float) => 0.0 when F >Float 0.0
rule @DivisionByInfinity(F:Float) => @nz when F <Float 0.0
rule @DivisionByInfinity(@+Infinity) => @NaN
rule @DivisionByInfinity(@-Infinity) => @NaN

// 11.5.3 Applying the % Operator

rule %bop(%mod,V1:Val,V2:Val) => @ResolveOverflow(@ModuloSign(@ToNumber(V1),@ToNumber(V2)))

syntax K ::= "@ModuloSign" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
rule @ModuloSign(N1:Number,N2:Number) => @ResolveNumber(@Modulo(N1,N2), @IsPositive(N1))

syntax K ::= "@Modulo" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
rule @Modulo(@NaN,_) => @NaN
rule @Modulo(_,@NaN) => @NaN
//
rule @Modulo(I1:Int,N2:Number) => @Modulo(Int2Float(I1),N2)
rule @Modulo(N1:Number,I2:Int) => @Modulo(N1,Int2Float(I2))
//
rule @Modulo( _:Float,@nz       ) => @NaN
rule @Modulo( _:Float,0.0       ) => @NaN
rule @Modulo(0.0     , F:Float  ) => 0.0 when F =/=Float 0.0
rule @Modulo(F1:Float,F2:Float  ) => F1 %Float F2 when F1 =/=Float 0.0 andBool F2 =/=Float 0.0
rule @Modulo( F:Float,@+Infinity) => F
rule @Modulo( F:Float,@-Infinity) => F
//
rule @Modulo(@nz     ,0.0       ) => @NaN
rule @Modulo(@nz     ,F:Float   ) => @nz when F =/=Float 0.0
rule @Modulo(@nz     ,@nz       ) => @NaN
rule @Modulo(@nz     ,@+Infinity) => @nz
rule @Modulo(@nz     ,@-Infinity) => @nz
//
rule @Modulo(@+Infinity,_) => @NaN
//
rule @Modulo(@-Infinity,_) => @NaN

// 11.6.1 The Addition operator ( + )

rule %bop(%plus,V1:Val,V2:Val) => @PolymorphicAddition(@ToPrimitive(V1,""), @ToPrimitive(V2,""))

syntax K ::= "@PolymorphicAddition" "(" K /* Val */ "," K /* Val */ ")" [seqstrict(1,2)]
rule @PolymorphicAddition(V1:Val,V2:Val) => @ResolveOverflow(@Addition(@ToNumber(V1), @ToNumber(V2))) when notBool(@IsString(V1) ==K true) andBool notBool(@IsString(V2) ==K true)
rule @PolymorphicAddition(V1:Val,V2:Val) =>              @Concatnation(@ToString(V1), @ToString(V2))  when          isString(V1) ==K true   orBool          isString(V2) ==K true

syntax K ::= "@Concatnation" "(" K /* String */ "," K /* String */ ")" [seqstrict(1,2)]
rule @Concatnation(S1:String,S2:String) => S1 +String S2

// 11.6.2 The Subtraction Operator ( - )

rule %bop(%minus,V1:Val,V2:Val) => @ResolveOverflow(@Subtraction(@ToNumber(V1), @ToNumber(V2)))

// 11.6.3 Applying the Additive Operators to Numbers

syntax K ::= "@Addition" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
rule @Addition(@NaN,_) => @NaN
rule @Addition(_,@NaN) => @NaN
//
rule @Addition(I1:Int,I2:Int    ) => I1 +Int I2
rule @Addition(I1:Int,F2:Float  ) => Int2Float(I1) +Float F2
rule @Addition( I:Int,@nz       ) => I
rule @Addition( _:Int,@+Infinity) => @+Infinity
rule @Addition( _:Int,@-Infinity) => @-Infinity
//
rule @Addition(F1:Float,I2:Int    ) => F1 +Float Int2Float(I2)
rule @Addition(F1:Float,F2:Float  ) => F1 +Float F2
rule @Addition( F:Float,@nz       ) => F
rule @Addition( _:Float,@+Infinity) => @+Infinity
rule @Addition( _:Float,@-Infinity) => @-Infinity
//
rule @Addition(@nz,I:Int     ) => I
rule @Addition(@nz,F:Float   ) => F
rule @Addition(@nz,@nz       ) => @nz
rule @Addition(@nz,@+Infinity) => @+Infinity
rule @Addition(@nz,@-Infinity) => @-Infinity
//
rule @Addition(@+Infinity,_:Int     ) => @+Infinity
rule @Addition(@+Infinity,_:Float   ) => @+Infinity
rule @Addition(@+Infinity,@nz       ) => @+Infinity
rule @Addition(@+Infinity,@+Infinity) => @+Infinity
rule @Addition(@+Infinity,@-Infinity) => @NaN
//
rule @Addition(@-Infinity,_:Int     ) => @-Infinity
rule @Addition(@-Infinity,_:Float   ) => @-Infinity
rule @Addition(@-Infinity,@nz       ) => @-Infinity
rule @Addition(@-Infinity,@+Infinity) => @NaN
rule @Addition(@-Infinity,@-Infinity) => @-Infinity

syntax K ::= "@Subtraction" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
rule @Subtraction(N1:Number,N2:Number) => @Addition(N1,@Minus(N2))

// 11.7.1 The Left Shift Operator ( << )

rule %bop(%lshift,V1:Val,V2:Val) => @LeftShift(@ToInt32(V1),@ToUint32(V2))

syntax K ::= "@LeftShift" "(" K "," K ")" [seqstrict(1,2)]

rule @LeftShift(I1:Int,I2:Int) => iMInt(miMInt(shlMInt(mi(32,I1), I2 &Int 31 /* 0x1F */)))

// 11.7.2 The Signed Right Shift Operator ( >> )

rule %bop(%rshift,V1:Val,V2:Val) => @SignedRightShift(@ToInt32(V1),@ToUint32(V2))

syntax K ::= "@SignedRightShift" "(" K "," K ")" [seqstrict(1,2)]

// TODO: check sign-extending shift: shrMInt
rule @SignedRightShift(I1:Int,I2:Int) => iMInt(miMInt(shrMInt(mi(32,I1), I2 &Int 31 /* 0x1F */)))

// 11.7.3 The Unsigned Right Shift Operator ( >>> )

rule %bop(%rshiftshift,V1:Val,V2:Val) => @UnsignedRightShift(@ToUint32(V1),@ToUint32(V2))

// TODO: check zero-filling shift: ushrMInt
syntax K ::= "@UnsignedRightShift" "(" K "," K ")" [seqstrict(1,2)]

rule @UnsignedRightShift(I1:Int,I2:Int) => iMInt(miMInt(ushrMInt(mi(32,I1), I2 &Int 31 /* 0x1F */)))

// 11.8.1 The Less-than Operator ( < )

syntax Id ::= "$v1" | "$v2" | "$r"

rule %bop(%lt,V1:Val,V2:Val)
  => %Let $v1 = @ToPrimitive(V1,"Number");
     %Let $v2 = @ToPrimitive(V2,"Number");
     %Let $r = @LessThan($v1,$v2);
     %If $r = @Undefined then {
       %Return false;
     } else {
       %Return $r;
     }

// 11.8.2 The Greater-than Operator ( > )

rule %bop(%gt,V1:Val,V2:Val)
  => %Let $v1 = @ToPrimitive(V1,"Number");
     %Let $v2 = @ToPrimitive(V2,"Number");
     %Let $r = @LessThan($v2,$v1);
     %If $r = @Undefined then {
       %Return false;
     } else {
       %Return $r;
     }

// 11.8.3 The Less-than-or-equal Operator ( <= )

rule %bop(%le,V1:Val,V2:Val)
  => %Let $v1 = @ToPrimitive(V1,"Number");
     %Let $v2 = @ToPrimitive(V2,"Number");
     %Let $r = @LessThan($v2,$v1);
     %If $r = @Undefined then {
       %Return false;
     } else {
       %Return @Not($r);
     }

// 11.8.4 The Greater-than-or-equal Operator ( >= )

rule %bop(%ge,V1:Val,V2:Val)
  => %Let $v1 = @ToPrimitive(V1,"Number");
     %Let $v2 = @ToPrimitive(V2,"Number");
     %Let $r = @LessThan($v1,$v2);
     %If $r = @Undefined then {
       %Return false;
     } else {
       %Return @Not($r);
     }

// 11.8.5 The Abstract Relational Comparison Algorithm

syntax K ::= "@LessThan" "(" K "," K ")"
rule @LessThan(V1:Val,V2:Val) => @LessThanNumber(@ToNumber(V1),@ToNumber(V2))
     when notBool(@IsString(V1) andBool @IsString(V2))
rule @LessThan(V1:String,V2:String) => @LessThanString(V1,V2)

syntax K ::= "@LessThanNumber" "(" K "," K ")" [seqstrict(1,2)]
rule @LessThanNumber(@NaN,_) => @Undefined
rule @LessThanNumber(_,@NaN) => @Undefined
//
rule @LessThanNumber(I:Int,N:Number) => @LessThanNumber(Int2Float(I),N)
rule @LessThanNumber(N:Number,I:Int) => @LessThanNumber(N,Int2Float(I))
//
rule @LessThanNumber(F1:Float,F2:Float  ) => F1 <Float F2
rule @LessThanNumber( 0.0    ,@nz       ) => false
rule @LessThanNumber( F:Float,@nz       ) => F <Float 0.0 when F =/=Float 0.0
rule @LessThanNumber( _:Float,@+Infinity) => true
rule @LessThanNumber( _:Float,@-Infinity) => false
//
rule @LessThanNumber(@nz,F:Float   ) => 0.0 <Float F when F =/=Float 0.0
rule @LessThanNumber(@nz,0.0       ) => false // NOTE: unlike intuition, step.3.g is not typo
rule @LessThanNumber(@nz,@nz       ) => false
rule @LessThanNumber(@nz,@+Infinity) => true
rule @LessThanNumber(@nz,@-Infinity) => false
//
rule @LessThanNumber(@+Infinity,_:Float   ) => false
rule @LessThanNumber(@+Infinity,@nz       ) => false
rule @LessThanNumber(@+Infinity,@+Infinity) => false
rule @LessThanNumber(@+Infinity,@-Infinity) => false
//
rule @LessThanNumber(@-Infinity,_:Float   ) => true
rule @LessThanNumber(@-Infinity,@nz       ) => true
rule @LessThanNumber(@-Infinity,@+Infinity) => true
rule @LessThanNumber(@-Infinity,@-Infinity) => false

syntax K ::= "@LessThanString" "(" K "," K ")"

rule @LessThanString(S1:String,S2:String) => S1 <String S2

// 11.8.6 The instanceof operator

rule %bop(%instanceof,V1:Val,V2:Val)
  => %If @IsOid(V2) = true then {
       %If @HasHasInstance(V2) = true then {
         %Return @HasInstance(V2,V1);
       } else {
         %Do @Throw(@TypeError("instanceof not having hasinstance",V2));
       }
     } else {
       %Do @Throw(@TypeError("instanceof not object",V2));
     }

syntax K /* Bool */ ::= "@HasHasInstance" "(" K ")"
rule @HasHasInstance(F:Oid)
  => @EqVal(@GetInternalProperty(F,"Class"), "Function")

// 11.8.7 The in operator

rule %bop(%in,V1:Val,V2:Val)
  => %If @IsOid(V2) = true then {
       %Return @HasProperty(V2,@ToString(V1));
     } else {
       %Do @Throw(@TypeError("in",V2));
     }

// 11.9.1 The Equals Operator ( == )

rule %bop(%eq, V1:Val,V2:Val) =>      @AbstractEquality(V1,V2)

// 11.9.2 The Does-not-equals Operator ( != )

rule %bop(%neq,V1:Val,V2:Val) => @Not(@AbstractEquality(V1,V2))

// 11.9.3 The Abstract Equality Comparison Algorithm

syntax K ::= "@AbstractEquality" "(" K /* Val */ "," K /* Val */ ")" [seqstrict(1,2)]

rule @AbstractEquality(@Undefined,@Undefined) => true
rule @AbstractEquality(@Undefined,@NullVal  ) => true
rule @AbstractEquality(@Undefined,_:Bool    ) => false
rule @AbstractEquality(@Undefined,_:String  ) => false
rule @AbstractEquality(@Undefined,_:Number  ) => false
rule @AbstractEquality(@Undefined,_:Oid     ) => false
//
rule @AbstractEquality(@NullVal,  @Undefined) => true
rule @AbstractEquality(@NullVal,  @NullVal  ) => true
rule @AbstractEquality(@NullVal,  _:Bool    ) => false
rule @AbstractEquality(@NullVal,  _:String  ) => false
rule @AbstractEquality(@NullVal,  _:Number  ) => false
rule @AbstractEquality(@NullVal,  _:Oid     ) => false
//
rule @AbstractEquality(B:Bool,    @Undefined) => false
rule @AbstractEquality(B:Bool,    @NullVal  ) => false
rule @AbstractEquality(B1:Bool,   B2:Bool   ) => B1 ==K B2
rule @AbstractEquality(B:Bool,    S:String  ) => @AbstractEquality(@ToNumber(B), @ToNumber(S))
rule @AbstractEquality(B:Bool,    N:Number  ) => @AbstractEquality(@ToNumber(B), N)
rule @AbstractEquality(B:Bool,    O:Oid     ) => @AbstractEquality(@ToNumber(B), @ToPrimitive(O,""))
//
rule @AbstractEquality(S:String,  @Undefined) => false
rule @AbstractEquality(S:String,  @NullVal  ) => false
rule @AbstractEquality(S:String,  B:Bool    ) => @AbstractEquality(@ToNumber(S), @ToNumber(B))
rule @AbstractEquality(S1:String, S2:String ) => S1 ==K S2
rule @AbstractEquality(S:String,  N:Number  ) => @AbstractEquality(@ToNumber(S), N)
rule @AbstractEquality(S:String,  O:Oid     ) => @AbstractEquality(S, @ToPrimitive(O,""))
//
rule @AbstractEquality(N:Number,  @Undefined) => false
rule @AbstractEquality(N:Number,  @NullVal  ) => false
rule @AbstractEquality(N:Number,  B:Bool    ) => @AbstractEquality(N, @ToNumber(B))
rule @AbstractEquality(N:Number,  S:String  ) => @AbstractEquality(N, @ToNumber(S))
rule @AbstractEquality(N1:Number, N2:Number ) => @AbstractEqualityNumber(N1,N2)
rule @AbstractEquality(N:Number,  O:Oid     ) => @AbstractEquality(N, @ToPrimitive(O,""))
//
rule @AbstractEquality(O:Oid,     @Undefined) => false
rule @AbstractEquality(O:Oid,     @NullVal  ) => false
rule @AbstractEquality(O:Oid,     B:Bool    ) => @AbstractEquality(@ToPrimitive(O,""), @ToNumber(B))
rule @AbstractEquality(O:Oid,     S:String  ) => @AbstractEquality(@ToPrimitive(O,""), S)
rule @AbstractEquality(O:Oid,     N:Number  ) => @AbstractEquality(@ToPrimitive(O,""), N)
rule @AbstractEquality(O1:Oid,    O2:Oid    ) => O1 ==K O2

syntax K ::= "@AbstractEqualityNumber" "(" K /* Val */ "," K /* Val */ ")" [seqstrict(1,2)]

rule @AbstractEqualityNumber(@NaN,_:Number) => false
rule @AbstractEqualityNumber(_:Number,@NaN) => false
//
rule @AbstractEqualityNumber(0,  0  ) => true
rule @AbstractEqualityNumber(0,  0.0) => true
rule @AbstractEqualityNumber(0,  @nz) => true
rule @AbstractEqualityNumber(0.0,0  ) => true
rule @AbstractEqualityNumber(0.0,0.0) => true
rule @AbstractEqualityNumber(0.0,@nz) => true
rule @AbstractEqualityNumber(@nz,0  ) => true
rule @AbstractEqualityNumber(@nz,0.0) => true
rule @AbstractEqualityNumber(@nz,@nz) => true
//
rule @AbstractEqualityNumber(N1:Number,N2:Number) => @SameValue(N1,N2)
     when notBool(N1 ==K @NaN orBool N2 ==K @NaN)
  andBool notBool((N1 ==K 0 orBool N1 ==K 0.0 orBool N1 ==K @nz) andBool
                  (N2 ==K 0 orBool N2 ==K 0.0 orBool N2 ==K @nz))

// 11.9.4 The Strict Equals Operator ( === )

rule %bop(%eqs, V1:Val,V2:Val) =>      @StrictEquality(V1,V2)

// 11.9.5 The Strict Does-not-equal Operator ( !== )

rule %bop(%neqs,V1:Val,V2:Val) => @Not(@StrictEquality(V1,V2))

// 11.9.6 The Strict Equality Comparison Algorithm

syntax K ::= "@StrictEquality" "(" K /* Val */ "," K /* Val */ ")" [seqstrict(1,2)]

rule @StrictEquality(V1:Val,V2:Val) => @SameValue(V1,V2)
     when notBool(V1 ==K @NaN orBool V2 ==K @NaN)
  andBool notBool((V1 ==K 0 orBool V1 ==K 0.0 orBool V1 ==K @nz) andBool
                  (V2 ==K 0 orBool V2 ==K 0.0 orBool V2 ==K @nz))
//
rule @StrictEquality(@NaN,_) => false
rule @StrictEquality(_,@NaN) => false
//
rule @StrictEquality(0,  0  ) => true
rule @StrictEquality(0,  0.0) => true
rule @StrictEquality(0,  @nz) => true
rule @StrictEquality(0.0,0  ) => true
rule @StrictEquality(0.0,0.0) => true
rule @StrictEquality(0.0,@nz) => true
rule @StrictEquality(@nz,0  ) => true
rule @StrictEquality(@nz,0.0) => true
rule @StrictEquality(@nz,@nz) => true

// 11.10 Binary Bitwise Operators

rule %bop(%amp,  V1:Val,V2:Val) => @BitwiseAND(@ToInt32(V1),@ToInt32(V2))
rule %bop(%caret,V1:Val,V2:Val) => @BitwiseXOR(@ToInt32(V1),@ToInt32(V2))
rule %bop(%bar,  V1:Val,V2:Val) => @BitwiseOR (@ToInt32(V1),@ToInt32(V2))

syntax K /* Int32 */ ::= "@BitwiseAND" "(" K /* Int32 */ "," K /* Int32 */ ")" [seqstrict(1,2)]
syntax K /* Int32 */ ::= "@BitwiseXOR" "(" K /* Int32 */ "," K /* Int32 */ ")" [seqstrict(1,2)]
syntax K /* Int32 */ ::= "@BitwiseOR"  "(" K /* Int32 */ "," K /* Int32 */ ")" [seqstrict(1,2)]

rule @BitwiseAND(I1:Int,I2:Int) => I1   &Int I2
rule @BitwiseXOR(I1:Int,I2:Int) => I1 xorInt I2
rule @BitwiseOR (I1:Int,I2:Int) => I1   |Int I2

// 11.11 Binary Logical Operators

context %bop(_:OpShortcut,HOLE,_)

rule %bop(%and,V1:Val,E2:Exp)
  => %If @ToBoolean(V1) = true then {
       %Return E2;
     } else {
       %Return V1;
     }

rule %bop(%or,V1:Val,E2:Exp)
  => %If @ToBoolean(V1) = true then {
       %Return V1;
     } else {
       %Return E2;
     }

// 11.12 Conditional Operator( ? : )

context %cond(HOLE,_,_)
rule %cond(V:Val,E1,E2)
  => %If @ToBoolean(V) = true then {
       %Return E1;
     } else {
       %Return E2;
     }

// 11.13.1 Simple Assignment ( = )
// TODO: Consider Strict mode, Step 4

rule %bop(%assign,L:Exp,E:Exp) => @PutValueAndReturn(@GetReference(L),E)

syntax K /* Val */ ::= "@PutValueAndReturn" "(" K /* Reference */ "," K /* Val */ ")" [seqstrict(1,2)]
rule @PutValueAndReturn(L:Reference,V:Val) => @PutValue(L,V) ~> V

// 11.13.2 Compound Assignment ( op= )

syntax Id ::= "$ref"
rule %bopassign(Op:Op,L:Exp,E:Exp)
  => %Let $ref = @GetReference(L);
     %Do @PutValueAndReturn($ref, %bop(Op, @GetValue($ref), E));

// 11.14 Comma Operator(,)

rule %comma(E1:Exp,E2:Exp) => E1 ~> @Ignore ~> E2

//////////////////////////////////////////////////////////////////////////////
// 12 Statements
//////////////////////////////////////////////////////////////////////////////

// 12.1 Block
// NOTE: Nothing to do

// 12.2 Variable Statement

rule %vdecl(_) => %emptyStmt

// 12.3 Empty Statement

rule %emptyStmt => @Normal

// 12.4 Expression Statement

rule %exp(E:Exp) => @Exp(E)

syntax K ::= "@Exp" "(" K /* Val */ ")" [seqstrict(1)]
rule @Exp(V:Val) => @UpdateStmtValue(V) ~> @Normal

syntax K /* .K */ ::= "@UpdateStmtValue" "(" Val ")"
rule <k> @UpdateStmtValue(V:Val) => . ... </k>
     <lastNonEmptyValue> _ => V </lastNonEmptyValue>
     when V =/=K @Undefined
rule @UpdateStmtValue(@Undefined) => .

// 12.5 The if Statement

context %if(HOLE,_,_)
rule %if(V:Val,S1,S2)
  => %If @ToBoolean(V) = true then {
       %Do S1;
     } else {
       %Do S2;
     }

// 12.6 Iteration Statements

// 12.6.1 The do-while Statement

rule %do(S,E) => %seq(S, %while(E,S))

// 12.6.2 The while Statement

rule %while(E,S) => %if(E, %seq(S, %while(E,S)), %emptyStmt)

// 12.6.3 The for Statement

rule %for(S0,%emptyExp,E2,S) => %seq(S0, %while(%con(true), %seq(S, %exp(E2))))
rule %for(S0,E1,       E2,S) => %seq(S0, %while(E1,         %seq(S, %exp(E2)))) when E1 =/=K %emptyExp

// 12.6.4 The for-in Statement

syntax Id ::= "$e" | "$props"

rule %forin(S0,E1,E2,S) => %seq(S0, @ForIn(E1,E2,S))

syntax Stmt ::= "@ForIn" "(" Exp "," Exp "," Stmt ")"
rule @ForIn(L:Exp,E:Exp,S:Stmt)
  => %Let $e = E;
     %If @OrBool(@EqVal($e, @NullVal), @EqVal($e, @Undefined)) = true then {
       %Return @Normal;
     } else {
       %Let $o = @ToObject($e);
       %Let $props = @EnumerateAllProperties($o::K::Oid, .Set);
       %Do @ForInAux(L, $o::K::Oid, $props, S);
     }

syntax Stmt ::= "@ForInAux" "(" Exp "," Oid "," K "," Stmt ")"
rule @ForInAux(_:Exp, _:Oid, @s(                 .Set), _:Stmt) => @Normal
rule @ForInAux(L:Exp, O:Oid, @s(SetItem(P:Var) Ps:Set), S:Stmt)
  => %Let $desc = @GetProperty(O,P);
     %If $desc = @Undefined then {
       %Do @ForInAux(L,O,@s(Ps),S);
     } else {
       %If $desc."Enumerable" = true then {
         %Do %seq(%exp(%bop(%assign,L,%con(P::String))),
                  %seq(S, @ForInAux(L,O,@s(Ps),S)));
       } else {
         %Do @ForInAux(L,O,@s(Ps),S);
       }
     }

syntax K /* Set */ ::= "@EnumerateAllProperties" "(" Oid "," Set ")"
rule     @EnumerateAllProperties(@NullOid, S:Set) => @s(S)
rule <k> @EnumerateAllProperties(O:Oid, S:Set)
      => @EnumerateAllProperties(Proto, keys(Prop) S) ... </k>
     <obj>
       <oid> O </oid>
       <properties> Prop:Map </properties>
       <internalProperties> "Prototype" |-> Proto:Oid _ </internalProperties>
     </obj>
     when O =/=K @NullOid

// 12.7 The continue Statement

rule %continue(L) => @Continue(L)

// 12.8 The break Statement

rule %break(L) => @Break(L)

// 12.9 The return Statement

context %return(HOLE)
rule %return(V:Val) => @Return(V)

// 12.10 The with Statement

rule <k> %with(E,S)
      => %Do @SetRunningCtx(@NewObjectEnvironment(@ToObject(E),Env,true,false), This);
         %Let $result = S;
         %Do @RestoreRunningCtx;
         %Return $result;
     ... </k>
     <ctx>
       <running>
         <lexicalEnv> Env:Eid </lexicalEnv>
         <thisBinding> This:Val </thisBinding>
         _
       </running>
       _
     </ctx>
     <env>
       <eid> Env </eid>
       <strict> false </strict>
       _
     </env>

rule <k> %with(E,S) => @Throw(@SyntaxError("with",%with(E,S))) ... </k>
     <ctx>
       <running>
         <lexicalEnv> Env:Eid </lexicalEnv>
         _
       </running>
       _
     </ctx>
     <env>
       <eid> Env </eid>
       <strict> true </strict>
       _
     </env>

// 12.11 The switch Statement

// Intuitive Algorithm:
// 
// start to find in C1
// when found in C1, then fall through along remaining C1 followed by D and C2
// when not found in C1, start to find in C2
// when found in C2, then fall through along remaining C2 and finish (without visiting default)
// when not found in C2, go through D

rule %switch(E,C1,D,C2) => @Switch(E,C1,D,C2)

syntax K ::= "@Switch" "(" K /* Val */ "," Stmt "," Stmt "," Stmt ")" [seqstrict(1)]

rule @Switch(Input:Val, %seq(%case(E,S),C1), D, C2)
  => %If @StrictEquality(Input,E) = true then {
       %Do %seq(S,%seq(C1,%seq(D,C2)));
     } else {
       %Do @Switch(Input,C1,D,C2);
     }

rule @Switch(Input:Val, %emptyStmt, D, %seq(%case(E,S),C2))
  => %If @StrictEquality(Input,E) = true then {
       %Do %seq(S,C2);
     } else {
       %Do @Switch(Input,%emptyStmt,D,C2);
     }

rule @Switch(_:Val, %emptyStmt, %default(S), %emptyStmt) => S

rule @Switch(_:Val, %emptyStmt, %emptyStmt, %emptyStmt) => @Normal

rule %case(_,S) => S
rule %default(S) => S

// 12.12 Labelled Statements
// TODO: Move to the first-pass

rule %label(L,S) => %seq(@AddContinueLabel(L,S), %labelBreak(L))

syntax Stmt ::= "@AddContinueLabel" "(" Var "," Stmt ")" [function]
rule @AddContinueLabel(L, %while(E,S)) => %while(E, %seq(S, %labelContinue(L)))
rule @AddContinueLabel(L, %do(S,E))    =>    %do(   %seq(S, %labelContinue(L)), E)
rule @AddContinueLabel(L, %for  (S0,E1,E2,S)) => %for  (S0, E1, E2, %seq(S, %labelContinue(L)))
rule @AddContinueLabel(L, %forin(S0,E1,E2,S)) => %forin(S0, E1, E2, %seq(S, %labelContinue(L)))
rule @AddContinueLabel(L, %label(L',S)) => %label(L', @AddContinueLabel(L,S))
rule @AddContinueLabel(_, S) => S   when getKLabel(S) =/=KLabel '%while`(_`,_`)
                                 andBool getKLabel(S) =/=KLabel '%do`(_`,_`)
                                 andBool getKLabel(S) =/=KLabel '%for`(_`,_`,_`,_`)
                                 andBool getKLabel(S) =/=KLabel '%forin`(_`,_`,_`,_`)
                                 andBool getKLabel(S) =/=KLabel '%label`(_`,_`)

syntax Stmt ::= "%labelContinue" "(" Var ")"
syntax Stmt ::= "%labelBreak"    "(" Var ")"

rule %labelContinue(_) => %emptyStmt
rule %labelBreak(_)    => %emptyStmt

// 12.13 The throw Statement

context %throw(HOLE)
rule %throw(V:Val) => @Throw(V)

// 12.14 The try Statement

/*
rule %try(S:Stmt,X:Var,Catch:Stmt             ) => @TryCatch(S,X,Catch)
*/
rule %try(S:Stmt,                 Finally:Stmt) => @TryFinally(S,Finally)
rule %try(S:Stmt,X:Var,Catch:Stmt,Finally:Stmt) => @TryCatchFinally(S,X,Catch,Finally)

syntax K ::= "@TryCatch" "(" Stmt "," Var "," Stmt ")"
           | "@PopExcTC"

rule <k> (@TryCatch(S:Stmt,X:Var,Catch:Stmt) => S ~> @PopExcTC) ~> K </k>
     <ctrl>
       <excStack> (. => @excTC(X,Catch,K,Ctrl)) _ </excStack>
       Ctrl
     </ctrl>

rule <k> CT:CompletionType ~> @PopExcTC => CT ... </k>
     <ctrl>
       <excStack> (@excTC(_,_,_,_) => .) _ </excStack>
       _
     </ctrl>

rule <k> @Throw(V) ~> _ => @Catch(X,V,Catch) ~> K </k>
     <ctrl>
       <excStack> (@excTC(X,Catch,K,Ctrl) => .) _ </excStack>
       (_ => Ctrl)
     </ctrl>

syntax K ::= "@TryFinally" "(" K "," Stmt ")" // NOTE: the first argument should be of sort K not Stmt because @Catch(...) can be given there
           | "@PopExcTF"

rule <k> (@TryFinally(S:K,Finally:Stmt) => S ~> @PopExcTF) ~> K </k>
     <ctrl>
       <excStack> (. => @excTF(Finally,K,Ctrl)) _ </excStack>
       Ctrl
     </ctrl>

rule <k> CT:CompletionType ~> @PopExcTF => @ResolveFinally(Finally, CT) ... </k>
     <ctrl>
       <excStack> (@excTF(Finally,_,_) => .) _ </excStack>
       _
     </ctrl>

rule <k> @Throw(V) ~> _ => @ResolveFinally(Finally, @Throw(V)) ~> K </k>
     <ctrl>
       <excStack> (@excTF(Finally,K,Ctrl) => .) _ </excStack>
       (_ => Ctrl)
     </ctrl>

syntax K ::= "@TryCatchFinally" "(" Stmt "," Var "," Stmt "," Stmt ")"
           | "@PopExcTCF"

rule <k> (@TryCatchFinally(S:Stmt,X:Var,Catch:Stmt,Finally:Stmt) => S ~> @PopExcTCF) ~> K </k>
     <ctrl>
       <excStack> (. => @excTCF(X,Catch,Finally,K,Ctrl)) _ </excStack>
       Ctrl
     </ctrl>

rule <k> CT:CompletionType ~> @PopExcTCF => @ResolveFinally(Finally, CT) ... </k>
     <ctrl>
       <excStack> (@excTCF(_,_,Finally,_,_) => .) _ </excStack>
       _
     </ctrl>

rule <k> @Throw(V) ~> _ => @TryFinally(@Catch(X,V,Catch), Finally) ~> K </k>
     <ctrl>
       <excStack> (@excTCF(X,Catch,Finally,K,Ctrl) => .) _ </excStack>
       (_ => Ctrl)
     </ctrl>

// NOTE: If the first argument evaluates to 'Throw', then it is handled differently with Throw's rules.
//       The second argument should be non-strict, because it could be 'Throw'.
syntax K ::= "@ResolveFinally" "(" K /* CompletionType */ "," K /* CompletionType or Throw */ ")" [seqstrict(1)]
rule @ResolveFinally( _:CompletionTypeNormal,CT:K) => CT
rule @ResolveFinally(CT:CompletionTypeAbrupt, _:K) => CT

syntax K /* CompletionType */ ::= "@Catch" "(" Var "," Val "," Stmt ")"
syntax Id ::= "$catchEnv" | "$result"
rule <k> @Catch(X:Var,V:Val,Catch:Stmt)
      => %Let $catchEnv = @NewDeclarativeEnvironment(E, Strict);
         %Do @CreateMutableBinding($catchEnv::K::Eid, X, false);
         %Do @SetMutableBinding($catchEnv::K::Eid, X, V, false);
         %Do @SetRunningCtx($catchEnv::K::Eid, This);
         %Let $result = Catch;
         %Do @RestoreRunningCtx;
         %Return $result;
     ... </k>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         <thisBinding> This:Val </thisBinding>
         _
       </running>
       _
     </ctx>
     <env>
       <eid> E </eid>
       <strict> Strict:Bool </strict>
       _
     </env>

//////////////////////////////////////////////////////////////////////////////
// 13 Function Definition
//////////////////////////////////////////////////////////////////////////////

syntax K /* Oid */ ::= "@FunctionDeclaration" "(" Var "," Exps "," Stmt ")"
rule @FunctionDeclaration(_,Params:Exps,FunBody:Stmt)
  => @FunctionExpressionAnonymous(Params,FunBody)

syntax K /* Oid */ ::= "@FunctionExpressionAnonymous" "(" Exps "," Stmt ")"
rule <k> @FunctionExpressionAnonymous(Params:Exps, FunBody:Stmt)
      => @CreateFunctionObject(Params, FunBody, E, @IsStrict(FunBody) orBool Strict) ... </k> // 10.1.1 Strict Mode Code, Case 3
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         _
       </running>
       _
     </ctx>
     <env>
       <eid> E </eid>
       <strict> Strict:Bool </strict>
       _
     </env>

syntax K /* Oid */ ::= "@FunctionExpressionRecursive" "(" Var "," Exps "," Stmt ")"
syntax Id ::= "$funcEnv" | "$closure"
rule <k> @FunctionExpressionRecursive(F:Var, Params:Exps, FunBody:Stmt)
      => %Let $strict = @IsStrict(FunBody) orBool Strict; // 10.1.1 Strict Mode Code, Case 3
         %Let $funcEnv = @NewDeclarativeEnvironment(E, $strict::K::Bool);
         %Do @CreateImmutableBinding($funcEnv::K::Eid, F);
         %Let $closure = @CreateFunctionObject(Params, FunBody, $funcEnv::K::Eid, $strict::K::Bool);
         %Do @InitializeImmutableBinding($funcEnv::K::Eid, F, $closure::K::Val);
         %Return $closure;
     ... </k>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         _
       </running>
       _
     </ctx>
     <env>
       <eid> E </eid>
       <strict> Strict:Bool </strict>
       _
     </env>

// 13.2 Creating Function Objects

// NOTE: (from p.26 of Good Parts): Every function object is created with a 'prototype' property. Its value is an object with a 'constructor' property whose value is the function. This is distinct from the hidden link to 'Function.prototype'.

syntax K /* Oid */ ::= "@CreateFunctionObject" "(" Exps "," Stmt "," Eid "," Bool ")"
rule <k> @CreateFunctionObject(Params:Exps, FunBody:Stmt, Scope:Eid, Strict:Bool) => @CreateFunctionObjectAux(@o(F), Strict) ... </k>
     <objs>
       (. => <obj>
               <oid> @o(F) </oid>
               <properties>
                 "length"           |-> @desc("Value" |-> @Length(Params) "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                 "prototype"        |-> @desc("Value" |-> @o(P)           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> false)
               </properties>
               <internalProperties>
                 "Prototype"        |-> @FunctionProtoOid
                 "Class"            |-> "Function"
                 "Extensible"       |-> true
                 "Scope"            |-> Scope
                 "FormalParameters" |-> Params
                 "Code"             |-> FunBody
                 "Strict"           |-> Strict
               </internalProperties>
             </obj>)
       (. => <obj>
               <oid> @o(P) </oid>
               <properties>
                 "constructor"      |-> @desc("Value" |-> @o(F)           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true)
               </properties>
               <internalProperties>
                 "Prototype"        |-> @ObjectProtoOid
                 "Class"            |-> "Object"
                 "Extensible"       |-> true
               </internalProperties>
             </obj>)
       _
     </objs>
     when fresh(F:Int) andBool
          fresh(P:Int)

syntax K /* Oid */ ::= "@CreateFunctionObjectAux" "(" Oid "," Bool ")"
rule <k> @CreateFunctionObjectAux(O:Oid,false) => O ... </k>
rule <k> @CreateFunctionObjectAux(O:Oid,true ) => O ... </k>
     <obj>
       <oid> O </oid>
       <properties>
         (. => "caller"    |-> @desc("Get" |-> @("ThrowTypeError") "Set" |-> @("ThrowTypeError") "Enumerable" |-> false "Configurable" |-> false))
         (. => "arguments" |-> @desc("Get" |-> @("ThrowTypeError") "Set" |-> @("ThrowTypeError") "Enumerable" |-> false "Configurable" |-> false))
         _
       </properties>
       _
     </obj>

// 13.2.1 [[Call]]

syntax K /* Val */ ::= "@Call" "(" K /* Oid */ "," K /* Val */ "," K /* Vals */ ")" [seqstrict(1,2,3)]
rule <k> @Call(F:Oid, This:Val, Args:Vals)
      => @EnterFunctionCode(F,This,Args) ~> Code ~> @ExitFunctionCode ... </k>
     <obj>
       <oid> F </oid>
       <internalProperties> "Code" |-> Code:Stmt _ </internalProperties>
       _
     </obj>
rule <k> @Call(F:Oid,_,_) => @Undefined ... </k>
     <obj>
       <oid> F </oid>
       <internalProperties> Prop </internalProperties>
       _
     </obj>
     when notBool("Code" in keys(Prop))

syntax K ::= "@ExitFunctionCode"
rule @Return(V:Val) ~> @ExitFunctionCode => @RestoreRunningCtx ~> V
rule @Normal        ~> @ExitFunctionCode => @RestoreRunningCtx ~> @Undefined

// 13.2.2 [[Construct]]

syntax K /* Oid */ ::= "@Construct" "(" K /* Oid */ "," K /* Vals */ ")" [seqstrict(1,2)]
rule <k> @Construct(F:Oid, Args:Vals) => @Call(F,@o(N),Args) ~> @ReturnConstructedObject(@o(N)) ... </k>
     <objs>
       (. => <obj>
               <oid> @o(N) </oid>
               <properties> .Map </properties>
               <internalProperties>
                 "Prototype"  |-> @ResolvePrototype(Prototype)
                 "Class"      |-> "Object"
                 "Extensible" |-> true
               </internalProperties>
             </obj>)
       <obj>
         <oid> F </oid>
         <properties>
           "prototype" |-> @desc("Value" |-> Prototype:Val _)
           _
         </properties>
         _
       </obj>
       _
     </objs>
     when fresh(N:Int)
// TODO: Check correctness of steps 5-7

syntax Oid ::= "@ResolvePrototype" "(" Val ")" [function]
rule @ResolvePrototype(Prototype:Oid) => Prototype
rule @ResolvePrototype(Prototype:Val) => @ObjectProtoOid when notBool(@IsOid(Prototype) ==K true)

// Return the newly created object, but if the previous construct call returns another object, then use it.
// NOTE: (From p.31 of the book, Good Parts): If the function was invoked with the new prefix and the return value is not an object, then this (the new object) is returned instaed.
syntax K /* Oid */ ::= "@ReturnConstructedObject" "(" Oid ")"
rule O:Oid ~> @ReturnConstructedObject(_    ) => O
rule V:Val ~> @ReturnConstructedObject(O:Oid) => O when notBool(@IsOid(V) ==K true)

// 13.2.3 The [[ThrowTypeError]] Function Object

// TODO: check if this simple version works correctly
rule @Call(@("ThrowTypeError"), _:Val, _:Vals) => @Throw(@TypeError("ThrowTypeError",""))

//////////////////////////////////////////////////////////////////////////////
// 14 Program
//////////////////////////////////////////////////////////////////////////////

context %seq(HOLE, _)
context %seq(_:CompletionTypeNormal, HOLE)
rule %seq(   _:CompletionTypeNormal, Tail:CompletionType) => Tail
rule %seq(Head:CompletionTypeReturn,    _:Stmt          ) => Head
rule %seq(Head:CompletionTypeGoto,   Tail:Stmt          ) => @ResolveGoto(Head, Tail)

syntax K ::= "@ResolveGoto" "(" CompletionTypeGoto "," Stmt ")"
rule @ResolveGoto(CT:CompletionTypeGoto, S:Stmt         ) => @Normal             when @IsMatch(CT,S)  ==K true
rule @ResolveGoto(CT:CompletionTypeGoto, S:Stmt         ) => CT                  when @IsMatch(CT,S)  ==K false
//
rule @ResolveGoto(CT:CompletionTypeGoto, %seq(S1,S2)) => S2                  when @IsMatch(CT,S1) ==K true
rule @ResolveGoto(CT:CompletionTypeGoto, %seq(S1,S2)) => @ResolveGoto(CT,S2) when @IsMatch(CT,S1) ==K false
//
rule @ResolveGoto(CT:CompletionTypeGoto, %seq(%seq(S1,S2),S3)) => @ResolveGoto(CT, %seq(S1,%seq(S2,S3)))

syntax Bool ::= "@IsMatch" "(" CompletionTypeGoto "," Stmt ")" [function]
rule @IsMatch(@Break(L:Var),    %labelBreak(L:Var ))    => true
rule @IsMatch(@Break(""   ),    %labelBreak(_     ))    => true
rule @IsMatch(@Break(L:Var),    %labelBreak(L':Var))    => false when L =/=K "" andBool L =/=K L'
rule @IsMatch(@Break(_    ),    S                  )    => false when getKLabel(S) =/=KLabel '%labelBreak`(_`)
                                                              andBool getKLabel(S) =/=KLabel '%seq`(_`,_`)
rule @IsMatch(@Continue(L:Var), %labelContinue(L:Var )) => true
rule @IsMatch(@Continue(""   ), %labelContinue(_     )) => true
rule @IsMatch(@Continue(L:Var), %labelContinue(L':Var)) => false when L =/=K "" andBool L =/=K L' 
rule @IsMatch(@Continue(_    ), S                     ) => false when getKLabel(S) =/=KLabel '%labelContinue`(_`)
                                                              andBool getKLabel(S) =/=KLabel '%seq`(_`,_`)

// NOTE: @FunctionDeclaration is not executed here, but at 10.5 Declaration Binding Instantiation
rule %fdecl(_,_,_) => %emptyStmt

//////////////////////////////////////////////////////////////////////////////
// 14.1 Directive Prologues and the Use Strict Directive

syntax Bool ::= "@IsStrict" "(" Stmt ")" [function]
rule @IsStrict(S:Stmt) => @IsStrictPartial(@SkipPrelude(S)) ==K true

syntax Bool ::= "@IsStrictPartial" "(" Stmt ")" [function]
rule @IsStrictPartial(     %exp(%con("use strict"))   ) => true
rule @IsStrictPartial(%seq(%exp(%con("use strict")),_)) => true
rule @IsStrictPartial(%seq(%exp(%con(C:String    )),S)) => @IsStrictPartial(S) when C =/=String "use strict"

syntax Stmt ::= "@SkipPrelude" "(" Stmt ")" [function]
rule @SkipPrelude(%seq(%exp(%con("BEGIN PRELUDE")),S)) => @SkipPreludeAux(S)
rule @SkipPrelude(%seq(S1,S2)) => %seq(S1,S2) when S1 =/=K %exp(%con("BEGIN PRELUDE"))
rule @SkipPrelude(S) => S when getKLabel(S) =/=KLabel '%seq`(_`,_`)
//
syntax Stmt ::= "@SkipPreludeAux" "(" Stmt ")" [function]
rule @SkipPreludeAux(%seq(%exp(%con("END PRELUDE")),S)) => S
rule @SkipPreludeAux(%seq(S1,S2)) => @SkipPreludeAux(S2) when S1 =/=K %exp(%con("END PRELUDE"))

//////////////////////////////////////////////////////////////////////////////
// 15 Standard Built-in ECMAScript Objects
//////////////////////////////////////////////////////////////////////////////

syntax K /* Bool */ ::= "@IsStandardBuiltinObject" "(" Exp ")" [function]
rule @IsStandardBuiltinObject(E:Exp) => (E ==K %var("Object"))
                                 orBool (E ==K %var("Function"))
                                 orBool (E ==K %var("Array"))
                                 orBool (E ==K %var("String"))
                                 orBool (E ==K %var("Boolean"))
                                 orBool (E ==K %var("Number"))
                                 orBool (E ==K %var("Math"))
                                 orBool (E ==K %var("Date"))
                                 orBool (E ==K %var("RegExp"))
                                 orBool (E ==K %var("Error"))
                                 //
                                 orBool (E ==K %var("EvalError"     ))
                                 orBool (E ==K %var("RangeError"    ))
                                 orBool (E ==K %var("ReferenceError"))
                                 orBool (E ==K %var("SyntaxError"   ))
                                 orBool (E ==K %var("TypeError"     ))
                                 orBool (E ==K %var("URIError"      ))
                                 //
                                 orBool (E ==K %var("JSON"))
                                 //
                                 orBool (E ==K %var("eval")) // TODO: this is quick fix. any better way?

syntax Val ::= "@" "(" String ")"

// TODO: check if it should throw errors or not when more arguements given for builtin functions

//////////////////////////////////////////////////////////////////////////////
// Parse

syntax K /* Stmt or Throw */ ::= "@Parse" "(" String ")" [function]
rule @Parse(P:String) => @ParseAux(#parse(P,"Program"),P)

syntax K /* Stmt or Throw */ ::= "@ParseAux" "(" K /* Program */ "," K /* String */ ")" [function]
rule @ParseAux(P:SourceElements, _) => ^SourceElements(P)
rule @ParseAux(K /* String2K(#noparse) */, P:String) => @Throw(@SyntaxError("#parse",P)) when isSourceElements(K) =/=K true

//////////////////////////////////////////////////////////////////////////////
// 15.1 The Global Object

// 15.1.2.1 eval (x)

rule %call(%var("eval"), Es:Exps) => @Call(@("eval_d"), @Undefined, Es)

rule @Call(@("eval_d"), _, @Cons(V:Val,     @Nil)) => V when @IsString(V) ==K false
rule @Call(@("eval_i"), _, @Cons(V:Val,     @Nil)) => V when @IsString(V) ==K false
//
rule @Call(@("eval_d"), _, @Cons(Pgm:String,@Nil)) => @Eval(@Parse(Pgm), true)
rule @Call(@("eval_i"), _, @Cons(Pgm:String,@Nil)) => @Eval(@Parse(Pgm), false)

syntax K ::= "@Eval" "(" K /* Stmt or Throw */ "," Bool ")"
rule @Eval(Code:Stmt, Direct:Bool) => @EnterEvalCode(Code,Direct) ~> Code ~> @ExitEvalCode
rule @Eval(@Throw(@SyntaxError("#parse",P:String)), _) => @Throw(@SyntaxError("#parse",P))

syntax K ::= "@ExitEvalCode"
rule <k> @Normal ~> @ExitEvalCode => @RestoreRunningCtx ~> V ... </k>
     <lastNonEmptyValue> V:Val </lastNonEmptyValue>

// 15.1.2.2 parseInt (string , radix)
// TODO:

// 15.1.2.3 parseFloat (string)
// TODO:

// 15.1.2.4 isNaN (number)

rule @Call(@("isNaN"), @Undefined, @Cons(V:Val,@Nil))
  => %If @ToNumber(V) = @NaN then {
       %Return true;
     } else {
       %Return false;
     }

// 15.1.2.5 isFinite (number)

rule @Call(@("isFinite"), @Undefined, @Cons(V:Val,@Nil))
  => @IsFinite(@ToNumber(V))

syntax K ::= "@IsFinite" "(" K /* Number */ ")" [seqstrict(1)]
rule @IsFinite(_:Int     ) => true
rule @IsFinite(_:Float   ) => true
rule @IsFinite(@nz       ) => true
rule @IsFinite(@NaN      ) => false
rule @IsFinite(@+Infinity) => false
rule @IsFinite(@-Infinity) => false

//////////////////////////////////////////////////////////////////////////////
// 15.2 Object Objects

// 15.2.1.1 Object ( [ value ] )

rule %call(%var("Object"), Es:Exps) => @CallObject(Es)

syntax K /* Oid */ ::= "@CallObject" "(" K /* Vals */ ")" [seqstrict(1)]
rule @CallObject(@Cons(V:Val,     @Nil)) => @ToObject(V) when V =/=K @NullVal andBool V =/=K @Undefined
rule @CallObject(@Cons(@NullVal,  @Nil)) => @CreateObject
rule @CallObject(@Cons(@Undefined,@Nil)) => @CreateObject
rule @CallObject(                 @Nil ) => @CreateObject

// 15.2.2.1 new Object ( [ value ] )

rule %new(%var("Object"), Es:Exps) => @NewObject(Es)

syntax K /* Oid */ ::= "@NewObject" "(" K /* Vals */ ")" [seqstrict(1)]
rule @NewObject(@Cons(@Undefined,@Nil)) => @CreateObject
rule @NewObject(@Cons(@NullVal,  @Nil)) => @CreateObject
rule @NewObject(@Cons(B:Bool,    @Nil)) => @ToObject(B)
rule @NewObject(@Cons(S:String,  @Nil)) => @ToObject(S)
rule @NewObject(@Cons(N:Number,  @Nil)) => @ToObject(N)
rule @NewObject(@Cons(O:Oid,     @Nil)) => O
rule @NewObject(                 @Nil ) => @CreateObject

syntax K /* Oid */ ::= "@CreateObject"
rule <k> @CreateObject => @o(N) ... </k>
     <objs>
       (. => <obj>
               <oid> @o(N) </oid>
               <properties> .Map </properties>
               <internalProperties>
                 "Prototype"  |-> @ObjectProtoOid // Object prototype object 15.2.4
                 "Class"      |-> "Object"
                 "Extensible" |-> true
               </internalProperties>
             </obj>)
       _
     </objs>
     when fresh(N:Int)

// 15.2.3.2 Object.getPrototypeOf ( O )

rule     @Call(@("Object.getPrototypeOf"), _, @Cons(V:Val,@Nil)) => @Throw(@TypeError("Object.getPrototypeOf",V)) when notBool(@IsOid(V))

rule <k> @Call(@("Object.getPrototypeOf"), _, @Cons(O:Oid,@Nil)) => Prototype ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "Prototype" |-> Prototype:Oid
         _
       </internalProperties>
       _
     </obj>

// 15.2.3.3 Object.getOwnPropertyDescriptor ( O, P )

rule @Call(@("Object.getOwnPropertyDescriptor"), _, @Cons(O:Val,@Cons(P:Val,@Nil)))
  => %If @IsOid(O) = true then {
       %Return @FromPropertyDescriptor(@GetOwnProperty(O,@ToString(P)));
     } else {
       %Do @Throw(@TypeError("Object.getOwnPropertyDescriptor",O));
     }

// 15.2.3.4 Object.getOwnPropertyNames ( O )
// TODO: consider note: when O is string object

rule     @Call(@("Object.getOwnPropertyNames"), _, @Cons(V:Val,@Nil)) => @Throw(@TypeError("Object.getOwnPropertyNames",V)) when notBool(@IsOid(V))

rule <k> @Call(@("Object.getOwnPropertyNames"), _, @Cons(O:Oid,@Nil)) => @MakeArray(@Set2Vals(keys(Prop))) ... </k>
     <obj>
       <oid> O </oid>
       <properties> Prop:Map </properties>
       _
     </obj>

// 15.2.3.5 Object.create ( O [, Properties] )

rule @Call(@("Object.create"), _, @Cons(V:Val,                     @Nil )) => @ObjectCreate(V,@Undefined)
rule @Call(@("Object.create"), _, @Cons(V:Val,@Cons(Properties:Val,@Nil))) => @ObjectCreate(V,Properties)

syntax K ::= "@ObjectCreate" "(" Val "," Val ")"
rule @ObjectCreate(V:Val,Properties:Val)
  => %If @OrBool(@IsOid(V), @EqVal(V,@NullVal)) = true then {
       %Let $obj = @CreateObject;
       %If @IsOid(V) = true then {
         %Do @SetPrototype($obj::K::Oid,V::Oid);
       } else {
         %Do @SetPrototype($obj::K::Oid,@NullOid);
       }
       %If Properties = @Undefined then {
         %Nop;
       } else {
         %DoI @ObjectDefineProperties($obj::K::Oid,Properties);
       }
       %Return $obj;
     } else {
       %Do @Throw(@TypeError("Object.create",V));
     }

syntax K ::= "@SetPrototype" "(" Oid "," Oid ")"
rule <k> @SetPrototype(O:Oid,Prototype:Oid) => . ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "Prototype" |-> (_ => Prototype)
         _
       </internalProperties>
       _
     </obj>

// 15.2.3.6 Object.defineProperty ( O, P, Attributes )

rule @Call(@("Object.defineProperty"), _, @Cons(O:Val,@Cons(P:Val,@Cons(Attributes:Val,@Nil))))
  => %If @IsOid(O) = false then {
       %Do @Throw(@TypeError("Object.defineProperty",O));
     } else {
       %DoI @DefineOwnProperty(O,@ToString(P),@ToPropertyDescriptor(Attributes),true);
       %Return O;
     }

// 15.2.3.7 Object.defineProperties ( O, Properties )
// TODO: check correctness of this simplified version

rule @Call(@("Object.defineProperties"), _, @Cons(V:Val,@Cons(Properties:Val,@Nil)))
  => %If @IsOid(V) = true then {
       %Do @ObjectDefineProperties(V::Oid, Properties);
     } else {
       %Do @Throw(@TypeError("Object.defineProperties",V));
     }

syntax K /* Oid */ ::= "@ObjectDefineProperties" "(" Oid "," Val ")"
rule @ObjectDefineProperties(O:Oid,Properties:Val)
  => @ObjectDefinePropertiesAux(O, @GetPropertiesMap(@ToObject(Properties)))

syntax K /* Oid */ ::= "@ObjectDefinePropertiesAux" "(" Oid "," K /* Map */ ")"
rule @ObjectDefinePropertiesAux(O:Oid, @m(.Map)) => O
rule @ObjectDefinePropertiesAux(O:Oid, @m(P:Var |-> Desc:PropertyDescriptor Prop:Map))
  => @DefineOwnProperty(O,P,Desc,true) ~> @Ignore ~> @ObjectDefinePropertiesAux(O,@m(Prop))

syntax K /* Map */ ::= "@GetPropertiesMap" "(" K /* Oid */ ")" [seqstrict(1)]
rule <k> @GetPropertiesMap(O:Oid) => @m(Prop) ... </k>
     <obj>
       <oid> O </oid>
       <properties> Prop:Map </properties>
       _
     </obj>

// 15.2.3.8 Object.seal ( O )
// TODO:

// 15.2.3.9 Object.freeze ( O )
// TODO:

// 15.2.3.10 Object.preventExtensions ( O )

rule @Call(@("Object.preventExtensions"), _, @Cons(V:Val,@Nil))
  => @Throw(@TypeError("Object.preventExtensions",V))
     when notBool(@IsOid(V))

rule <k> @Call(@("Object.preventExtensions"), _, @Cons(O:Oid,@Nil)) => O ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "Extensible" |-> (_ => false)
         _
       </internalProperties>
       _
     </obj>

// 15.2.3.11 Object.isSealed ( O )
// TODO:

// 15.2.3.12 Object.isFrozen ( O )
// TODO:

// 15.2.3.13 Object.isExtensible ( O )

rule @Call(@("Object.isExtensible"), _, @Cons(V:Val,@Nil))
  => @Throw(@TypeError("Object.isExtensible",V))
     when notBool(@IsOid(V))

rule <k> @Call(@("Object.isExtensible"), _, @Cons(O:Oid,@Nil)) => Extensible ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "Extensible" |-> Extensible:Bool
         _
       </internalProperties>
       _
     </obj>

// 15.2.3.14 Object.keys ( O )
// TODO

// 15.2.4.2 Object.prototype.toString ( )

rule @Call(@("Object.prototype.toString"), @Undefined, @Nil) => "[object Undefined]"
rule @Call(@("Object.prototype.toString"), @NullVal,   @Nil) => "[object Null]"
rule <k>
     @Call(@("Object.prototype.toString"), O:Oid,      @Nil) => "[object " +String Class +String "]"
     ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "Class" |-> Class:String
         _
       </internalProperties>
       _
     </obj>

// 15.2.4.3 Object.prototype.toLocaleString ( )
// TODO:

// 15.2.4.4 Object.prototype.valueOf ( )

rule @Call(@("Object.prototype.valueOf"), This:Val, @Nil) => @ToObject(This)

// 15.2.4.5 Object.prototype.hasOwnProperty (V)

rule @Call(@("Object.prototype.hasOwnProperty"), This:Val, @Cons(V:Val,@Nil))
  => @HasOwnProperty(@ToObject(This), @ToString(V))

// 15.2.4.6 Object.prototype.isPrototypeOf (V)

rule @Call(@("Object.prototype.isPrototypeOf"), This:Val, @Cons(V:Val,@Nil))
  => %If @IsOid(V) = true then {
       %Let $o = @ToObject(This);
       %Return @IsPrototypeOf($o::K::Oid, V::Oid);
     } else {
       %Return false;
     }

syntax K /* Bool */ ::= "@IsPrototypeOf" "(" Oid "," Oid ")"
rule @IsPrototypeOf(O:Oid,V:Oid)
  => @IsPrototypeOfAux(O,@GetInternalProperty(V,"Prototype"))

syntax K /* Bool */ ::= "@IsPrototypeOfAux" "(" K "," K ")" [seqstrict(1,2)]
rule @IsPrototypeOfAux(O:Oid,V:Oid)
  => %If V = @NullOid then {
       %Return false;
     } else {
       %If O = V then {
         %Return true;
       } else {
         %Do @IsPrototypeOfAux(O,@GetInternalProperty(V,"Prototype"));
       }
     }

// 15.2.4.7 Object.prototype.propertyIsEnumerable (V)
// TODO

//////////////////////////////////////////////////////////////////////////////
// 15.3 Function Objects

// 15.3.1.1 Function (p1, p2, ... , pn, body)

rule %call(%var("Function"), Es:Exps) => @NewFunction(Es)

// 15.3.2.1 new Function (p1, p2, ... , pn, body)

rule %new(%var("Function"), Es:Exps) => @NewFunction(Es)

// TODO: it was ad-hoc, temporary implementation
syntax K /* Oid */ ::= "@NewFunction" "(" K /* Vals */ ")" [seqstrict(1)]
rule @NewFunction(@Nil) => @CreateFunction(%nil, %emptyStmt)
syntax Id ::= "$p1" | "$body"
rule @NewFunction(@Cons(P1:Val,@Cons(Body:Val,@Nil)))
  => %Let $p1 = @ToString(P1);
     %Let $body = @ToString(Body);
     %Do @CreateFunction(%cons(%var($p1::K::Var),%nil), @Parse($body::K::String));
rule @NewFunction(@Cons(Body:Val,@Nil))
  => %Let $body = @ToString(Body);
     %Do @CreateFunction(%nil, @Parse($body::K::String));

syntax K /* Oid */ ::= "@CreateFunction" "(" Exps "," Stmt ")"
rule <k> @CreateFunction(Params:Exps,FunBody:Stmt)
      => %Let $strict = @IsStrict(FunBody); // 10.1.1 Strict Mode Code, Case 4
         %Do @CheckEarlyErrors($strict::K::Bool, FunBody);
         %Do @CreateFunctionObject(Params, FunBody, E, $strict::K::Bool);
     ... </k>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         _
       </running>
       _
     </ctx>

// 15.3.4.2 Function.prototype.toString ( )

// TODO: ad-hoc, temorary implementation
rule @Call(@("Function.prototype.toString"), @o(F), @Nil) => "[function ...]"

// 15.3.4.3 Function.prototype.apply (thisArg, argArray)

rule @Call(@("Function.prototype.apply"), Func:Val, @Cons(ThisArg:Val,@Cons(@NullVal,  @Nil))) => @Call(Func,ThisArg,@Nil)
rule @Call(@("Function.prototype.apply"), Func:Val, @Cons(ThisArg:Val,@Cons(@Undefined,@Nil))) => @Call(Func,ThisArg,@Nil)

// 15.3.4.4 Function.prototype.call (thisArg [ , arg1 [ , arg2, ... ] ] )

rule @Call(@("Function.prototype.call"), Func:Val, @Cons(ThisArg:Val,Args:Vals))
  => %If @IsCallable(Func) = false then {
       %Do @Throw(@TypeError("Function.prototype.call",Func));
     } else {
       %Do @Call(Func,ThisArg,Args);
     }

// 15.3.4.5 Function.prototype.bind (thisArg [, arg1 [, arg2, ...]])
// TODO:

// 15.3.5.3 [[HasInstance]] (V)

syntax K /* Bool */ ::= "@HasInstance" "(" K "," K ")" [seqstrict(1,2)]
syntax Id ::= "$o"
rule @HasInstance(F:Oid,V:Val)
  => %If @IsOid(V) = true then {
       %Let $o = @Get(F,"prototype");
       %If @IsOid($o::K::Val) = true then {
         %Return @IsPrototypeOf($o::K::Oid, V::Oid);
       } else {
         %Do @Throw(@TypeError("HasInstance",F));
       }
     } else {
       %Return false;
     }

//////////////////////////////////////////////////////////////////////////////
// 15.4 Array Objects

// 15.4.1.1 Array ( [ item1 [ , item2 [ , ... ] ] ] )

rule %call(%var("Array"), Es:Exps) => @NewArray(Es)

// 15.4.2.1 new Array ( [ item0 [ , item1 [ , ... ] ] ] )

rule %new(%var("Array"), Es:Exps) => @NewArray(Es)

syntax K /* Oid */ ::= "@NewArray" "(" K /* Vals */ ")" [seqstrict(1)]
rule @NewArray(Vs:Vals) => @CreateArray(@LengthVals(Vs), Vs) when @LengthVals(Vs) =/=Int 1
rule @NewArray(@Cons(V:Val,@Nil)) => @CreateArray(1, @Cons(V:Val,@Nil)) when notBool(isInt(V) ==K true)

syntax K /* Oid */ ::= "@CreateArray" "(" Int "," Vals ")"
rule <k> @CreateArray(Len:Int, Vs:Vals) => @CreateArray@InsertElements(@o(N),Vs,0) ... </k>
     <objs>
       (. => <obj>
               <oid> @o(N) </oid>
               <properties>
                 "length" |-> @desc("Value" |-> Len "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
               </properties>
               <internalProperties>
                 "Prototype"      |-> @ArrayProtoOid
                 "Class"          |-> "Array"
                 "Extensible"     |-> true
               </internalProperties>
             </obj>)
       _
     </objs>
     when fresh(N:Int)

syntax K /* Oid */ ::= "@CreateArray@InsertElements" "(" Oid "," Vals "," Int ")"
rule     @CreateArray@InsertElements(O:Oid, @Nil, _) => O
rule <k> @CreateArray@InsertElements(O:Oid, @Cons(V:Val,Vs:Vals), I:Int) => @CreateArray@InsertElements(O, Vs, I +Int 1) ... </k>
     <obj>
       <oid> O </oid>
       <properties>
         (. => Int2String(I) |-> @desc("Value" |-> V "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true))
         _
       </properties>
       _
     </obj>

// 15.4.2.2 new Array (len)
// TODO: more correctly: ToUint32(len) = len, o.w. throw RangeError

rule @NewArray(@Cons(Len:Int,@Nil)) => @CreateArray(Len, @Nil)

// 15.4.X make Array
// NOTE: @MakeArray differs from @NewArray in that it simply creates array object given arguments instead of distinguishing the single argument case

syntax K /* Oid */ ::= "@MakeArray" "(" K /* Vals */ ")" [seqstrict(1)]
rule @MakeArray(Vs:Vals) => @CreateArray(@LengthVals(Vs), Vs)

// 15.4.3.2 Array.isArray ( arg )

rule @Call(@("Array.isArray"), _, @Cons(V:Val,@Nil)) => false when notBool(@IsOid(V))

rule <k> @Call(@("Array.isArray"), _, @Cons(O:Oid,@Nil))
      => Class ==String "Array" ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "Class" |-> Class:String
         _
       </internalProperties>
       _
     </obj>

// 15.4.4 Properties of the Array Prototype Object
// TODO:

// 15.4.4.2 Array.prototype.toString ( )

// TODO: do correctly
rule @Call(@("Array.prototype.toString"), This:Val, @Nil) => "[array ...]"

//////////////////////////////////////////////////////////////////////////////
// 15.5 String Objects

// 15.5.1.1 String ( [ value ] )

rule %call(%var("String"), Es:Exps) => @CallString(Es)

syntax K /* String */ ::= "@CallString" "(" K /* Vals */ ")" [seqstrict(1)]
rule @CallString(@Cons(V:Val,@Nil)) => @ToString(V)
rule @CallString(@Nil) => ""

// 15.5.2.1 new String ( [ value ] )

rule %new(%var("String"), Es:Exps) => @NewString(Es)

syntax K /* Oid */ ::= "@NewString" "(" K /* Vals */ ")" [seqstrict(1)]
rule @NewString(@Cons(V:Val,@Nil)) => @CreateString(@ToString(V))
rule @NewString(@Nil) => @CreateString("")

syntax K /* Oid */ ::= "@CreateString" "(" K /* String */ ")" [seqstrict(1)]
rule <k> @CreateString(S:String) => @o(N) ... </k>
     <objs>
       (. => <obj>
               <oid> @o(N) </oid>
               <properties>
                 // 15.5.5.1 length
                 "length" |-> @desc("Value" |-> lengthString(S) "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                 // 15.5.5.2 [[GetOwnProperty]] ( P )
                 // TODO:
               </properties>
               <internalProperties>
                 "Prototype"      |-> @StringProtoOid
                 "Class"          |-> "String"
                 "Extensible"     |-> true
                 "PrimitiveValue" |-> S
               </internalProperties>
             </obj>)
       _
     </objs>
     when fresh(N:Int)

// 15.5.3 Properties of the String Constructor
// TODO:

// 15.5.4.2 String.prototype.toString ( )

rule     @Call(@("String.prototype.toString"), S:String, @Nil) => S
rule <k> @Call(@("String.prototype.toString"), O:Oid,    @Nil) => S ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "Class" |-> "String"
         "PrimitiveValue" |-> S:String
         _
       </internalProperties>
       _
     </obj>
rule @Call(@("String.prototype.toString"), V:Val, @Nil) => @Throw(@TypeError("String.prototype.toString",V))
     when @IsString(V) ==K false andBool @IsOid(V) ==K false

// 15.5.4.3 String.prototype.valueOf ( )

rule     @Call(@("String.prototype.valueOf"), S:String, @Nil) => S
rule <k> @Call(@("String.prototype.valueOf"), O:Oid,    @Nil) => S ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "Class" |-> "String"
         "PrimitiveValue" |-> S:String
         _
       </internalProperties>
       _
     </obj>
rule @Call(@("String.prototype.valueOf"), V:Val, @Nil) => @Throw(@TypeError("String.prototype.valueOf",V))
     when @IsString(V) ==K false andBool @IsOid(V) ==K false

//////////////////////////////////////////////////////////////////////////////
// 15.6 Boolean Objects

// 15.6.1.1 Boolean (value)

rule %call(%var("Boolean"),Es:Exps) => @CallBoolean(Es)

syntax K /* Boolean */ ::= "@CallBoolean" "(" K /* Vals */ ")" [seqstrict(1)]
rule @CallBoolean(@Cons(V:Val,@Nil)) => @ToBoolean(V)
rule @CallBoolean(            @Nil ) => false

// 15.6.2.1 new Boolean (value)

rule %new(%var("Boolean"),Es:Exps) => @NewBoolean(Es)

syntax K /* Oid */ ::= "@NewBoolean" "(" K /* Vals */ ")" [seqstrict(1)]
rule @NewBoolean(@Cons(V:Val,@Nil)) => @CreateBoolean(@ToBoolean(V))
rule @NewBoolean(            @Nil ) => @CreateBoolean(false) // TODO: Report: This is not specified in standard.

syntax K /* Oid */ ::= "@CreateBoolean" "(" K /* Bool */ ")" [seqstrict(1)]
rule <k> @CreateBoolean(B:Bool) => @o(N) ... </k>
     <objs>
       (. => <obj>
               <oid> @o(N) </oid>
               <properties> .Map </properties>
               <internalProperties>
                 "Prototype"      |-> @BooleanProtoOid
                 "Class"          |-> "Boolean"
                 "Extensible"     |-> true
                 "PrimitiveValue" |-> B
               </internalProperties>
             </obj>)
       _
     </objs>
     when fresh(N:Int)

// 15.6.4.2 Boolean.prototype.toString ( )

rule     @Call(@("Boolean.prototype.toString"), B:Bool, @Nil) => @ToString(B)
rule <k> @Call(@("Boolean.prototype.toString"), O:Oid,  @Nil) => @ToString(B) ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "Class" |-> "Boolean"
         "PrimitiveValue" |-> B:Bool
         _
       </internalProperties>
       _
     </obj>
rule @Call(@("Boolean.prototype.toString"), V:Val, @Nil) => @Throw(@TypeError("Boolean.prototype.toString",V))
     when @IsBool(V) ==K false andBool @IsOid(V) ==K false

// 15.6.4.3 Boolean.prototype.valueOf ( )

rule     @Call(@("Boolean.prototype.valueOf"), B:Bool, @Nil) => B
rule <k> @Call(@("Boolean.prototype.valueOf"), O:Oid,  @Nil) => B ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "Class" |-> "Boolean"
         "PrimitiveValue" |-> B:Bool
         _
       </internalProperties>
       _
     </obj>
rule @Call(@("Boolean.prototype.valueOf"), V:Val, @Nil) => @Throw(@TypeError("Boolean.prototype.valueOf",V))
     when @IsBool(V) ==K false andBool @IsOid(V) ==K false

//////////////////////////////////////////////////////////////////////////////
// 15.7 Number Objects

// 15.7.1.1 Number ( [ value ] )

rule %call(%var("Number"), Es:Exps) => @CallNumber(Es)

syntax K /* Number */ ::= "@CallNumber" "(" K /* Vals */ ")" [seqstrict(1)]
rule @CallNumber(@Cons(V:Val,@Nil)) => @ToNumber(V)
rule @CallNumber(@Nil) => 0

// 15.7.2.1 new Number ( [ value ] )

rule %new(%var("Number"), Es:Exps) => @NewNumber(Es)

syntax K /* Oid */ ::= "@NewNumber" "(" K /* Val */ ")" [seqstrict(1)]
rule @NewNumber(@Cons(V:Val,@Nil)) => @CreateNumber(@ToNumber(V))
rule @NewNumber(@Nil) => @CreateNumber(0)

syntax K /* Oid */ ::= "@CreateNumber" "(" K /* Bool */ ")" [seqstrict(1)]
rule <k> @CreateNumber(V:Number) => @o(N) ... </k>
     <objs>
       (. => <obj>
               <oid> @o(N) </oid>
               <properties> .Map </properties>
               <internalProperties>
                 "Prototype"      |-> @NumberProtoOid
                 "Class"          |-> "Number"
                 "Extensible"     |-> true
                 "PrimitiveValue" |-> V
               </internalProperties>
             </obj>)
       _
     </objs>
     when fresh(N:Int)

// 15.7.4 Properties of the Number Prototype Object
// TODO:

// 15.7.4.2 Number.prototype.toString ( [ radix ] )
// TODO: consider radix

rule     @Call(@("Number.prototype.toString"), N:Number, @Nil) => @ToString(N)
rule <k> @Call(@("Number.prototype.toString"), O:Oid,    @Nil) => @ToString(N) ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "Class" |-> "Number"
         "PrimitiveValue" |-> N:Number
         _
       </internalProperties>
       _
     </obj>
rule @Call(@("Number.prototype.toString"), V:Val, @Nil) => @Throw(@TypeError("Number.prototype.toString",V))
     when @IsNumber(V) ==K false andBool @IsOid(V) ==K false

// 15.7.4.4 Number.prototype.valueOf ( )

rule     @Call(@("Number.prototype.valueOf"), N:Number, @Nil) => N
rule <k> @Call(@("Number.prototype.valueOf"), O:Oid,    @Nil) => N ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "Class" |-> "Number"
         "PrimitiveValue" |-> N:Number
         _
       </internalProperties>
       _
     </obj>
rule @Call(@("Number.prototype.valueOf"), V:Val, @Nil) => @Throw(@TypeError("Number.prototype.valueOf",V))
     when @IsNumber(V) ==K false andBool @IsOid(V) ==K false

//////////////////////////////////////////////////////////////////////////////
// 15.8 The Math Object
// TODO:

//////////////////////////////////////////////////////////////////////////////
// 15.9 Date Objects
// TODO:

//////////////////////////////////////////////////////////////////////////////
// 15.10 RegExp (RegularExpression) Objects
// TODO:

//////////////////////////////////////////////////////////////////////////////
// 15.11 ErrorObjects

// 15.11.1.1 Error (message)

rule %call(%var("Error"), Es:Exps) => @NewError(Es)

// 15.11.2.1 new Error (message)

rule %new(%var("Error"), Es:Exps) => @NewError(Es)

syntax K /* Oid */ ::= "@NewError" "(" K /* Vals */ ")" [seqstrict(1)]
rule @NewError(@Cons(V:Val,@Nil)) => @CreateError(@ToString(V))
rule @NewError(@Nil)              => @CreateError("")

syntax K /* Oid */ ::= "@CreateError" "(" K /* String */ ")" [seqstrict(1)]
rule <k> @CreateError(Msg:String) => @o(N) ... </k>
     <objs>
       (. => <obj>
               <oid> @o(N) </oid>
               <properties>
                 "message"    |-> @desc("Value" |-> Msg "Writable" |-> true "Enumerable" |-> false "Configurable" |-> true)
               </properties>
               <internalProperties>
                 "Prototype"  |-> @ErrorProtoOid
                 "Class"      |-> "Error"
                 "Extensible" |-> true
               </internalProperties>
             </obj>)
       _
     </objs>
     when fresh(N:Int)

// 15.11.4.4 Error.prototype.toString ( )

// TODO:
// rule @Call(@("Error.prototype.toString"), V:Val, @Nil) =>

//////////////////////////////////////////////////////////////////////////////
// 15.11.6 Native Error Types Used in This Standard
// 15.11.7 NativeError Object Structure

// 15.11.7.2 NativeError (message)

rule %call(%var(NativeError:Var), Es:Exps) => @NewNativeError(NativeError, Es)
     when (NativeError ==K "EvalError"     )
   orBool (NativeError ==K "RangeError"    )
   orBool (NativeError ==K "ReferenceError")
   orBool (NativeError ==K "SyntaxError"   )
   orBool (NativeError ==K "TypeError"     )
   orBool (NativeError ==K "URIError"      )

// 15.11.7.4 new NativeError (message)

rule %new(%var(NativeError:Var), Es:Exps) => @NewNativeError(NativeError, Es)
     when (NativeError ==K "EvalError"     )
   orBool (NativeError ==K "RangeError"    )
   orBool (NativeError ==K "ReferenceError")
   orBool (NativeError ==K "SyntaxError"   )
   orBool (NativeError ==K "TypeError"     )
   orBool (NativeError ==K "URIError"      )

syntax K /* Oid */ ::= "@NewNativeError" "(" K /* String */ "," K /* Vals */ ")" [seqstrict(1,2)]
rule @NewNativeError(NativeError:String, @Cons(V:Val,@Nil)) => @CreateNativeError(NativeError, @ToString(V), "@NewNativeError")
rule @NewNativeError(NativeError:String, @Nil)              => @CreateNativeError(NativeError, "",           "@NewNativeError")

// NOTE: The third argument is only for debugging purpose, not a language standard. It should be non-strict.
syntax K /* Oid */ ::= "@CreateNativeError" "(" K /* String */ "," K /* String */ "," K ")" [seqstrict(1,2)]
rule <k> @CreateNativeError(NativeError:String, Msg:String, KDebug:K) => @o(N) ... </k>
     <objs>
       (. => <obj>
               <oid> @o(N) </oid>
               <properties>
                 "message"    |-> @desc("Value" |-> Msg "Writable" |-> true "Enumerable" |-> false "Configurable" |-> true)
               </properties>
               <internalProperties>
                 "Prototype"  |-> @ResolveNativeError(NativeError)
                 "Class"      |-> "Error"
                 "Extensible" |-> true
                 "KDebug"     |-> KDebug // NOTE: For debug
               </internalProperties>
             </obj>)
       _
     </objs>
     when fresh(N:Int)

syntax Oid ::= "@ResolveNativeError" "(" String ")" [function]
rule @ResolveNativeError("EvalError"     ) => @EvalErrorProtoOid
rule @ResolveNativeError("RangeError"    ) => @RangeErrorProtoOid
rule @ResolveNativeError("ReferenceError") => @ReferenceErrorProtoOid
rule @ResolveNativeError("SyntaxError"   ) => @SyntaxErrorProtoOid
rule @ResolveNativeError("TypeError"     ) => @TypeErrorProtoOid
rule @ResolveNativeError("URIError"      ) => @URIErrorProtoOid

// TODO: more elegantly
syntax K /* Oid */ ::= "@ReferenceError" "(" String "," K ")"
syntax K /* Oid */ ::= "@SyntaxError"    "(" String "," K ")"
syntax K /* Oid */ ::= "@TypeError"      "(" String "," K ")"
rule @ReferenceError(Msg:String, KDebug:K) => @CreateNativeError("ReferenceError", Msg, KDebug)
rule @SyntaxError   (Msg:String, KDebug:K) => @CreateNativeError("SyntaxError"   , Msg, KDebug)
rule @TypeError     (Msg:String, KDebug:K) => @CreateNativeError("TypeError"     , Msg, KDebug)

//////////////////////////////////////////////////////////////////////////////
// 15.12 The JSON Object
// TODO:

//////////////////////////////////////////////////////////////////////////////
// 16 Errors
//////////////////////////////////////////////////////////////////////////////

syntax K ::= "@CheckEarlyErrors" "(" Bool "," Stmt ")"
rule @CheckEarlyErrors(Strict:Bool, Code:Stmt) => @CEE(Strict, .Set, Code)

syntax K ::= "@CEE" /* Check Early Errors */ "(" Bool "," Set "," K /* Stmt or Exp or Exps */ ")"
//
rule @CEE(Strict:Bool, Ls:Set, %fdecl(F:Var,Es:Exps,S:Stmt))            => @CheckReserved(Strict,F) ~> @SMRFun(Strict,F,Es,S) ~> @CEE(Strict,Ls,Es) ~> @CEE(Strict orBool @IsStrict(S), .Set, S)
rule @CEE(Strict:Bool, Ls:Set, %vdecl(N:Var))                           => @CheckReserved(Strict,N) ~> @SMRVar(Strict,N)
rule @CEE(Strict:Bool, Ls:Set, %seq(S1:Stmt,S2:Stmt))                   => @CEE(Strict,Ls,S1) ~> @CEE(Strict,Ls,S2)
rule @CEE(Strict:Bool, Ls:Set, %exp(E))                                 => @CEE(Strict,Ls,E)
rule @CEE(Strict:Bool, Ls:Set, %if(E:Exp,S1:Stmt,S2:Stmt))              => @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,S1) ~> @CEE(Strict,Ls,S2)
rule @CEE(Strict:Bool, Ls:Set, %do(S:Stmt,E:Exp))                       => @CEE(Strict,Ls,S) ~> @CEE(Strict,Ls,E)
rule @CEE(Strict:Bool, Ls:Set, %while(E:Exp,S:Stmt))                    => @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,S)
rule @CEE(Strict:Bool, Ls:Set, %for  (S1:Stmt,E1:Exp,E2:Exp,S2:Stmt))   => @CEE(Strict,Ls,S1) ~> @CEE(Strict,Ls,E1) ~> @CEE(Strict,Ls,E2) ~> @CEE(Strict,Ls,S2)
rule @CEE(Strict:Bool, Ls:Set, %forin(S1:Stmt,E1:Exp,E2:Exp,S2:Stmt))   => @CEE(Strict,Ls,S1) ~> @CEE(Strict,Ls,E1) ~> @CEE(Strict,Ls,E2) ~> @CEE(Strict,Ls,S2)
rule @CEE(Strict:Bool, Ls:Set, %continue(L:Var))                        => @CheckReserved(Strict,L) ~> @CheckGoto(Ls,L)
rule @CEE(Strict:Bool, Ls:Set, %break(L:Var))                           => @CheckReserved(Strict,L) ~> @CheckGoto(Ls,L)
rule @CEE(Strict:Bool, Ls:Set, %label(L:Var,S:Stmt))                    => @CheckReserved(Strict,L) ~> @CEE(Strict, SetItem(L) Ls, S)
rule @CEE(Strict:Bool, Ls:Set, %return(E:Exp))                          => @CEE(Strict,Ls,E)
rule @CEE(Strict:Bool, Ls:Set, %throw(E:Exp))                           => @CEE(Strict,Ls,E)
rule @CEE(Strict:Bool, Ls:Set, %try(S1:Stmt,X:Var,S2:Stmt,S3:Stmt))     => @CheckReserved(Strict,X) ~> @SMRVar(Strict,X) ~> @CEE(Strict,Ls,S1) ~> @CEE(Strict,Ls,S2) ~> @CEE(Strict,Ls,S3)
rule @CEE(Strict:Bool, Ls:Set, %try(S1:Stmt,              S3:Stmt))     =>                                                  @CEE(Strict,Ls,S1) ~>                       @CEE(Strict,Ls,S3)
rule @CEE(Strict:Bool, Ls:Set, %with(E:Exp,S:Stmt))                     => @CheckWith(Strict) ~> @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,S)
rule @CEE(Strict:Bool, Ls:Set, %emptyStmt)                              => .
rule @CEE(Strict:Bool, Ls:Set, %print(_))                               => .
rule @CEE(Strict:Bool, Ls:Set, %switch(E:Exp,S1:Stmt,S2:Stmt,S3:Stmt))  => @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,S1) ~> @CEE(Strict,Ls,S2) ~> @CEE(Strict,Ls,S3)
rule @CEE(Strict:Bool, Ls:Set, %case(E:Exp,S:Stmt))                     => @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,S)
rule @CEE(Strict:Bool, Ls:Set, %default(S:Stmt))                        => @CEE(Strict,Ls,S)
//
rule @CEE(Strict:Bool, Ls:Set, %con(_:Const))                           => .
rule @CEE(Strict:Bool, Ls:Set, %var(N:Var))                             => @CheckReserved(Strict,N)
rule @CEE(Strict:Bool, Ls:Set, %arr(Es:Exps))                           => @CEE(Strict,Ls,Es)
rule @CEE(Strict:Bool, Ls:Set, %obj(Es:Exps))                           => @CheckDuplicatedProp(Strict,Es) ~> @CEE(Strict,Ls,Es)
rule @CEE(Strict:Bool, Ls:Set, %prop(P:Var,E:Exp))                      => /* @CheckReserved(Strict,P) ~> */ @CEE(Strict,Ls,E)
rule @CEE(Strict:Bool, Ls:Set, %get(P:Var,      S:Stmt))                => /* @CheckReserved(Strict,P) ~> */                                                                       @CEE(Strict orBool @IsStrict(S), .Set, S)
rule @CEE(Strict:Bool, Ls:Set, %set(P:Var,X:Var,S:Stmt))                => /* @CheckReserved(Strict,P) ~> */ @CheckReserved(Strict,X) ~> @SMRVar(Strict orBool @IsStrict(S), X) ~> @CEE(Strict orBool @IsStrict(S), .Set, S)
rule @CEE(Strict:Bool, Ls:Set, %mem(E1:Exp,E2:Exp))                     => @CEE(Strict,Ls,E1) ~> @CEE(Strict,Ls,E2)
rule @CEE(Strict:Bool, Ls:Set, %new(E:Exp,Es:Exps))                     => @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,Es)
rule @CEE(Strict:Bool, Ls:Set, %call(E:Exp,Es:Exps))                    => @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,Es)
rule @CEE(Strict:Bool, Ls:Set, %comma(E1:Exp,E2:Exp))                   => @CEE(Strict,Ls,E1) ~> @CEE(Strict,Ls,E2)
rule @CEE(Strict:Bool, Ls:Set, %pre(O:Op,E:Exp))                        => @CheckInvalidLValue(Strict,%pre(O,E))           ~> @CEE(Strict,Ls,E)
rule @CEE(Strict:Bool, Ls:Set, %post(E:Exp,O:Op))                       => @CheckInvalidLValue(Strict,%post(E,O))          ~> @CEE(Strict,Ls,E)
rule @CEE(Strict:Bool, Ls:Set, %bop(O:Op,E1:Exp,E2:Exp))                => @CheckInvalidLValue(Strict,%bop(O,E1,E2))       ~> @CEE(Strict,Ls,E1) ~> @CEE(Strict,Ls,E2)
rule @CEE(Strict:Bool, Ls:Set, %bopassign(O:Op,E1:Exp,E2:Exp))          => @CheckInvalidLValue(Strict,%bopassign(O,E1,E2)) ~> @CEE(Strict,Ls,E1) ~> @CEE(Strict,Ls,E2)
rule @CEE(Strict:Bool, Ls:Set, %cond(E1:Exp,E2:Exp,E3:Exp))             => @CEE(Strict,Ls,E1) ~> @CEE(Strict,Ls,E2) ~> @CEE(Strict,Ls,E3)
rule @CEE(Strict:Bool, Ls:Set, %emptyExp)                               => .
rule @CEE(Strict:Bool, Ls:Set, %fun(X:Var,Es:Exps,S:Stmt))              => @CheckReserved(Strict,X) ~> @SMRFun(Strict,X, Es,S) ~> @CEE(Strict,Ls,Es) ~> @CEE(Strict orBool @IsStrict(S), .Set, S)
rule @CEE(Strict:Bool, Ls:Set, %fun(      Es:Exps,S:Stmt))              =>                             @SMRFun(Strict,"",Es,S) ~> @CEE(Strict,Ls,Es) ~> @CEE(Strict orBool @IsStrict(S), .Set, S)
//
rule @CEE(Strict:Bool, Ls:Set, %cons(E:Exp,Es:Exps))                    => @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,Es)
rule @CEE(Strict:Bool, Ls:Set, %nil)                                    => .

syntax K ::= "@CheckDuplicatedProp" "(" Bool "," Exps ")"
rule @CheckDuplicatedProp(Strict:Bool, Es:Exps)
  => %If @DuplicatedProp(Strict,Es) = true then {
       %Do @Throw(@SyntaxError("Duplicated properties",Es));
     };
//
syntax K ::= "@DuplicatedProp" "(" Bool "," Exps ")"
rule @DuplicatedProp(Strict:Bool,Es:Exps) => @DuplicatedPropAux(Strict,Es,.Set,.Set,.Set)
//
syntax K ::= "@DuplicatedPropAux" "(" Bool "," Exps "," Set "," Set "," Set ")"
rule @DuplicatedPropAux(Strict:Bool, %cons(%prop(D:Var,_), Es:Exps), DS:Set, GS:Set, SS:Set) => true when D in GS orBool D in SS
rule @DuplicatedPropAux(Strict:Bool, %cons(%prop(D:Var,_), Es:Exps), DS:Set, GS:Set, SS:Set) => true when D in DS andBool Strict ==K true
rule @DuplicatedPropAux(Strict:Bool, %cons(%prop(D:Var,_), Es:Exps), DS:Set, GS:Set, SS:Set) => @DuplicatedPropAux(Strict, Es, SetItem(D) DS, GS, SS) when notBool(D in GS orBool D in SS)
                                                                                                                                                   andBool notBool(D in DS andBool Strict ==K true)
//
rule @DuplicatedPropAux(Strict:Bool, %cons(%get(G:Var,_),  Es:Exps), DS:Set, GS:Set, SS:Set) => true when G in GS orBool G in DS
rule @DuplicatedPropAux(Strict:Bool, %cons(%get(G:Var,_),  Es:Exps), DS:Set, GS:Set, SS:Set) => @DuplicatedPropAux(Strict, Es, DS, SetItem(G) GS, SS) when notBool(G in GS orBool G in DS)
//
rule @DuplicatedPropAux(Strict:Bool, %cons(%set(S:Var,_,_),Es:Exps), DS:Set, GS:Set, SS:Set) => true when S in SS orBool S in DS
rule @DuplicatedPropAux(Strict:Bool, %cons(%set(S:Var,_,_),Es:Exps), DS:Set, GS:Set, SS:Set) => @DuplicatedPropAux(Strict, Es, DS, GS, SetItem(S) SS) when notBool(S in SS orBool S in DS)
//
rule @DuplicatedPropAux(Strict:Bool, %nil, _, _, _) => false

syntax K ::= "@CheckInvalidLValue" "(" Bool "," Exp ")"
rule @CheckInvalidLValue(Strict:Bool, E:Exp)
  => %If @InvalidLValue(Strict,E) = true then {
       %Do @Throw(@SyntaxError("In strict mode, 'eval' or 'arguments' cannot be updated",E));
     };
//
syntax Bool ::= "@InvalidLValue" "(" Bool "," Exp ")" [function]
rule @InvalidLValue(Strict:Bool, E:Exp) => @InvalidLValueAux(Strict,E) ==K true
//
syntax Bool ::= "@InvalidLValueAux" "(" Bool "," Exp ")" [function]
rule @InvalidLValueAux(true, %bop(%assign,%var("eval"     ),_)) => true
rule @InvalidLValueAux(true, %bop(%assign,%var("arguments"),_)) => true
//
rule @InvalidLValueAux(true, %bopassign(_,%var("eval"     ),_)) => true
rule @InvalidLValueAux(true, %bopassign(_,%var("arguments"),_)) => true
//
rule @InvalidLValueAux(true, %pre(%inc,%var("eval"     ))) => true
rule @InvalidLValueAux(true, %pre(%inc,%var("arguments"))) => true
//
rule @InvalidLValueAux(true, %pre(%dec,%var("eval"     ))) => true
rule @InvalidLValueAux(true, %pre(%dec,%var("arguments"))) => true
//
rule @InvalidLValueAux(true, %post(%var("eval"     ),%inc)) => true
rule @InvalidLValueAux(true, %post(%var("arguments"),%inc)) => true
//
rule @InvalidLValueAux(true, %post(%var("eval"     ),%dec)) => true
rule @InvalidLValueAux(true, %post(%var("arguments"),%dec)) => true

syntax K ::= "@CheckWith" "(" Bool ")"
rule @CheckWith(Strict:Bool)
  => %If Strict = true then {
       %Do @Throw(@SyntaxError("In strict mode, with cannot be used",""));
     };

syntax K ::= "@CheckGoto" "(" Set "," Var ")"
rule @CheckGoto(Ls:Set, L:Var)
  => %If notBool(L in Ls) = true then {
       %Do @Throw(@SyntaxError("continue or break without nested iteration or switch stmt",L));
     };

//////////////////////////////////////////////////////////////////////////////
// Strict Mode Restrictions
//////////////////////////////////////////////////////////////////////////////

// 11.1.5, PropertyAssignment : set PropertyName ( PropertySetParameterList ) { FunctionBody } 
// 12.2.1 Strict Mode Restrictions
// 12.10.1 Strict Mode Restrictions
// 12.14.1 Strict Mode Restrictions
// 13.1 Strict Mode Restrictions

syntax K ::= "@SMRVar" "(" Bool "," Var ")"
rule @SMRVar(Strict:Bool, P:Var)
  => %If @AndBool(Strict ==K true, @OrBool(P ==K "eval", P ==K "arguments")) = true then {
       %Do @Throw(@SyntaxError("Strict Mode Restrictions, eval or arguments as a variable",P));
     };

syntax K ::= "@SMRFun" "(" Bool "," Var "," Exps "," Stmt ")"
rule @SMRFun(Strict:Bool, F:Var, Ps:Exps, FB:Stmt)
  => %Let $strict = @IsStrict(FB) orBool Strict;
     %Do @SMRVar($strict::K::Bool,F);
     %Do @SMRVars($strict::K::Bool,Ps);
     %Do @SMRParams($strict::K::Bool,Ps);
//
syntax K ::= "@SMRVars" "(" Bool "," Exps ")"
rule @SMRVars(Strict:Bool, %cons(%var(X:Var),Ps:Exps)) => @SMRVar(Strict,X) ~> @SMRVars(Strict,Ps)
rule @SMRVars(Strict:Bool, %nil) => .
//
syntax K ::= "@SMRParams" "(" Bool "," Exps ")"
rule @SMRParams(Strict:Bool, Ps:Exps)
  => %If @AndBool(Strict, @DuplicatedParams(Ps)) = true then {
       %Do @Throw(@SyntaxError("Strict Mode Restrictions, duplicated parameters",Ps));
     };
//
syntax K ::= "@DuplicatedParams" "(" Exps ")"
rule @DuplicatedParams(Ps:Exps) => @DuplicatedParamsAux(Ps,.Set)
//
syntax K ::= "@DuplicatedParamsAux" "(" Exps "," Set ")"
rule @DuplicatedParamsAux(%cons(%var(X:Var),Ps:Exps),S:Set) => true when X in S
rule @DuplicatedParamsAux(%cons(%var(X:Var),Ps:Exps),S:Set) => @DuplicatedParamsAux(Ps, SetItem(X) S) when notBool(X in S)
rule @DuplicatedParamsAux(%nil,_) => false

//////////////////////////////////////////////////////////////////////////////
// Pseudo-code evaluation
//////////////////////////////////////////////////////////////////////////////

syntax PseudoCodes ::= PseudoCode PseudoCodes
                     | PseudoCode
syntax PseudoCode  ::= "%Let" Id "=" K ";" [seqstrict(2)]
                     | "%Do"  K ";"
                     | "%DoI" K ";"
                     | "%If" K "=" K "then" "{" PseudoCodes "}" "else" "{" PseudoCodes "}" [seqstrict(1,2)]
                     | "%If" K "=" K "then" "{" PseudoCodes "}" ";"                        [seqstrict(1,2)]
                     | "%Return" K ";" [seqstrict(1)]
                     | "%Return"   ";"
                     | "%Nop" ";"
syntax Exp ::= Id

rule PC:PseudoCode PCs:PseudoCodes => PC ~> PCs
rule %Let X:Id = V:KResult; ~> PCs:PseudoCodes => PCs[V / X]
rule %Do  K; => K
rule %DoI K; => K ~> @Ignore
rule %If V1:KResult = V2:KResult then { PCs } else { _   } => PCs when V1 ==K  V2
rule %If V1:KResult = V2:KResult then { _   } else { PCs } => PCs when V1 =/=K V2
rule %If V1:KResult = V2:KResult then { PCs } ;            => PCs when V1 ==K  V2
rule %If V1:KResult = V2:KResult then { _   } ;            => .K  when V1 =/=K V2
rule %Return V:KResult; => V
rule %Return; => .K
rule %Nop; => .K

syntax K ::= "%BEGIN" PseudoCodes "%END"
syntax PseudoCode ::= "%Exit" ";"

rule <k> %BEGIN PCs:PseudoCodes %END ~> K => PCs ~> %Exit; </k>
     <pseudoStack> (. => @pseudo(K)) _ </pseudoStack>

rule <k> V:KResult ~> %Exit; ~> _ => V ~> K </k> <pseudoStack> (@pseudo(K) => .) _ </pseudoStack>
rule <k>              %Exit; ~> _ =>      K </k> <pseudoStack> (@pseudo(K) => .) _ </pseudoStack>

//////////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////////

syntax K /* .K */ ::= "@True?" | "@False?"
rule true  ~> @True?  => .
rule false ~> @False? => .

syntax K /* .K */ ::= "@Ignore"
rule _:Val ~> @Ignore => .

syntax Int ::= "@Length" "(" Exps ")" [function]
rule @Length(%cons(_,Es)) => 1 +Int @Length(Es)
rule @Length(%nil) => 0

syntax Int ::= "@LengthVals" "(" Vals ")" [function]
rule @LengthVals(@Cons(_,Vs)) => 1 +Int @LengthVals(Vs)
rule @LengthVals(@Nil) => 0

syntax Exp ::= Exp /* PropertyDescriptor */ "." Var [function]
rule @desc(X |-> V:Val _) . X => V
rule @desc(M:Map        ) . X => @Undefined when notBool(X in keys(M))

syntax Bool ::= "@SubDesc" "(" PropertyDescriptor "," PropertyDescriptor ")" [function]
rule @SubDesc(@desc(                 .Map), @desc(               _     )) => true
rule @SubDesc(@desc(               M1:Map), @desc(                 .Map)) => false                         when M1 =/=Map .Map
rule @SubDesc(@desc((X |-> V1:Val) M1:Map), @desc((X |-> V2:Val) M2:Map)) => @SubDesc(@desc(M1),@desc(M2)) when         @SameValue(V1,V2)
rule @SubDesc(@desc((X |-> V1:Val) _     ), @desc((X |-> V2:Val) _     )) => false                         when notBool(@SameValue(V1,V2))
rule @SubDesc(@desc((X |-> _     ) _     ), @desc(               M2:Map)) => false                         when notBool(X in keys(M2))
rule @SubDesc(@desc(               M1:Map), @desc((X |-> V2:Val) M2:Map)) => @SubDesc(@desc(M1),@desc(M2)) when notBool(X in keys(M2))

syntax Map ::= "@AddMap" "(" K "," K "," Map ")" [function]
rule @AddMap(X, V,           M:Map) => (X |-> V) M when notBool(X in keys(M))
rule @AddMap(X, V, (X |-> _) M:Map) => (X |-> V) M when notBool(X in keys(M))

syntax K /* .K */ ::= "@AddDesc" "(" K /* Var */ "," K /* Val */ "," K /* PropertyDescriptor */ ")" [seqstrict(1,2,3)]
rule @AddDesc(X:Var,V:Val,@desc(Desc)) => @desc(@AddMap(X,V,Desc))

syntax Bool ::= "@MemDesc" "(" PropertyDescriptor "," Var ")" [function]
rule @MemDesc(@desc(Desc),X:Var) => X in keys(Desc)

syntax K ::= "@GenDesc" "(" K "," K                                     ")" [function]
           | "@GenDesc" "(" K "," K "," K "," K                         ")" [function]
           | "@GenDesc" "(" K "," K "," K "," K "," K "," K             ")" [function]
           | "@GenDesc" "(" K "," K "," K "," K "," K "," K "," K "," K ")" [function]
rule @GenDesc(X1:Var,V1:Val                                          ) => @desc(X1 |-> V1                              )
rule @GenDesc(X1:Var,V1:Val,X2:Var,V2:Val                            ) => @desc(X1 |-> V1 X2 |-> V2                    )
rule @GenDesc(X1:Var,V1:Val,X2:Var,V2:Val,X3:Var,V3:Val              ) => @desc(X1 |-> V1 X2 |-> V2 X3 |-> V3          )
rule @GenDesc(X1:Var,V1:Val,X2:Var,V2:Val,X3:Var,V3:Val,X4:Var,V4:Val) => @desc(X1 |-> V1 X2 |-> V2 X3 |-> V3 X4 |-> V4)

// NOTE: Set of Values => Vals
syntax Vals ::= "@Set2Vals" "(" Set ")" [function]
rule @Set2Vals(SetItem(V:Val) Vs:Set) => @Cons(V, @Set2Vals(Vs))
rule @Set2Vals(                 .Set) => @Nil

context %print(HOLE)
rule %print(V:Val) => @Print(@ToString(V))
syntax K ::= "@Print" "(" K ")" [seqstrict(1)]
rule <k> @Print(S:String) => @Normal ... </k>
     <out> ... (. => ListItem(S)) </out>

syntax K ::= "@LOG" "(" K ")"
rule <k> @LOG(K) => . ... </k>
     <log> _ (. => ListItem(K)) </log>

syntax Bool ::= "@IsPrimitive" "(" Val ")" [function]
rule @IsPrimitive(V:Val) => @IsBool(V) orBool @IsString(V) orBool @IsNumber(V)

syntax Bool ::= "@IsBool" "(" Val ")" [function]
rule @IsBool(@Undefined) => false
rule @IsBool(@NullVal  ) => false
rule @IsBool(_:Bool    ) => true
rule @IsBool(_:String  ) => false
rule @IsBool(_:Number  ) => false
rule @IsBool(_:Oid     ) => false

syntax Bool ::= "@IsString" "(" Val ")" [function]
rule @IsString(@Undefined) => false
rule @IsString(@NullVal  ) => false
rule @IsString(_:Bool    ) => false
rule @IsString(_:String  ) => true
rule @IsString(_:Number  ) => false
rule @IsString(_:Oid     ) => false

syntax Bool ::= "@IsNumber" "(" Val ")" [function]
rule @IsNumber(@Undefined) => false
rule @IsNumber(@NullVal  ) => false
rule @IsNumber(_:Bool    ) => false
rule @IsNumber(_:String  ) => false
rule @IsNumber(_:Number  ) => true
rule @IsNumber(_:Oid     ) => false

syntax Bool ::= "@IsOid" "(" Val ")" [function]
rule @IsOid(@Undefined) => false
rule @IsOid(@NullVal  ) => false
rule @IsOid(_:Bool    ) => false
rule @IsOid(_:String  ) => false
rule @IsOid(_:Number  ) => false
rule @IsOid(_:Oid     ) => true

syntax K /* Bool */ ::= "@AndBool" "(" K /* Bool */ "," K /* Bool */ ")" [seqstrict(1,2)]
rule @AndBool(B1:Bool,B2:Bool) => B1 andBool B2

syntax K /* Bool */ ::= "@OrBool" "(" K /* Bool */ "," K /* Bool */ ")" [seqstrict(1,2)]
rule @OrBool(B1:Bool,B2:Bool) => B1 orBool B2

syntax K /* Bool */ ::= "@XorBool" "(" K /* Bool */ "," K /* Bool */ ")" [seqstrict(1,2)]
rule @XorBool(B1:Bool,B2:Bool) => B1 ==K B2

syntax K /* Bool */ ::= "@NotBool" "(" K /* Bool */ ")" [seqstrict(1)]
rule @NotBool(B:Bool) => notBool(B)

syntax K /* Bool */ ::= "@EqVal" "(" K /* Val */ "," K /* Val */ ")" [seqstrict(1,2)]
rule @EqVal(V1:Val,V2:Val) => V1 ==K V2

syntax K /* Bool */ ::= "@NeqVal" "(" K /* Val */ "," K /* Val */ ")" [seqstrict(1,2)]
rule @NeqVal(V1:Val,V2:Val) => V1 =/=K V2

endmodule
