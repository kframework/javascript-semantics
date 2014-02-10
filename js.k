require "modules/substitution.k"
require "js-trans.k"

module JS

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
      <properties> .Map </properties> // Var -> PropertyAttribute
      <internalProperties> .Map </internalProperties> // Var -> PropertyAttribute
    </obj>
  </objs>
  <envs>
    // 10.2 Lexical Environments
    <env multiplicity="*">
      <eid> .K </eid> // Eid
      <outer> .K </outer> // Eid // Reference to an outer Lexical Environment
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
  // 10.3 Execution Contexts
  <ctx>
    // Active Execution Contexts
    <activeStack> .List </activeStack>
    // Running Execution Context
    <running>
      // Table 19 Execution Context State Components
      <lexicalEnv> .K </lexicalEnv> // Eid
      <thisBinding> .K </thisBinding> // Oid
      <strict> .K </strict> // Bool
      <lastNonEmptyValue> .K </lastNonEmptyValue> // Val // last non-empty stmt value to be used by eval
    </running>
  </ctx>
  <excStack> .List </excStack>
  <in stream="stdin"> .List </in>
  <out stream="stdout"> .List </out>
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
syntax ListItem ::= "@exc" "(" K ")"

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
              // 15 Standard Built-in ECMAScript Objects
              | "@GlobalOid"
              | "@ObjectOid"   | "@ObjectProtoOid"
              | "@FunctionOid" | "@FunctionProtoOid"
              | "@ArrayOid"    | "@ArrayProtoOid"
              | "@StringOid"   | "@StringProtoOid"
              | "@BooleanOid"  | "@BooleanProtoOid"
              | "@NumberOid"   | "@NumberProtoOid"
              // 15.11.6 Native Error Types Used in This Standard
              | "@EvalErrorOid"     
              | "@RangeErrorOid"    
              | "@ReferenceErrorOid"
              | "@SyntaxErrorOid"   
              | "@TypeErrorOid"     
              | "@URIErrorOid"      
// 8.11 The Lexical Environment and Environment Record Specification Types
syntax Eid  ::= "@e" "(" Int ")"
              | "@NullEid"
              | "@GlobalEid" // 10.2.3 The Global Environment

syntax Primitive ::= Bool // 8.3 The Boolean Type
                   | String // 8.4 The String Type
                   | Number
// 8.5 The Number Type
syntax Number    ::= Int
                   | Float
                   | "@NaN"
                 //| "@+Infinity" // TODO: Support these
                 //| "@-Infinity"

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
                              | CompletionTypeJump
syntax CompletionTypeGoto   ::= "@Break"    "(" Var ")"
                              | "@Continue" "(" Var ")"
syntax CompletionTypeJump   ::= "@Return"   "(" Val ")"
                              | "@Throw"    "(" Val ")"

syntax KResult ::= CompletionType
syntax Stmt    ::= CompletionType

//////////////////////////////////////////////////////////////////////////////
// Initializing Configuration
//////////////////////////////////////////////////////////////////////////////

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
                 "window"     |-> @desc("Value" |-> @GlobalOid "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1 The Global Object
                 "NaN"        |-> @desc("Value" |-> @NaN       "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.1.1.1 NaN
               //"Infinity"   |-> @desc("Value" |-> @Infinity  "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.1.1.2 Infinity // TODO:
                 "undefined"  |-> @desc("Value" |-> @Undefined "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.1.1.3 undefined
                 // 15.1.2 Function Properties of the Global Object // TODO:
                 "eval"       |-> @desc("Value" |-> @("eval")  "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.1.2.1 eval (x)
                 // 15.1.3 URI Handling Function Properties // TODO:
                 // 15.1.4 Constructor Properties of the Global Object
                 "Object"     |-> @desc("Value" |-> @ObjectOid   "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.1 Object ( . . . )
                 "Function"   |-> @desc("Value" |-> @FunctionOid "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.2 Function ( . . . )
                 "Array"      |-> @desc("Value" |-> @ArrayOid    "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.3 Array ( . . . )
                 "String"     |-> @desc("Value" |-> @StringOid   "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.4 String ( . . . )
                 "Boolean"    |-> @desc("Value" |-> @BooleanOid  "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.5 Boolean ( . . . )
                 "Number"     |-> @desc("Value" |-> @NumberOid   "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.6 Number ( . . . )
                 // TODO: others: 15.1.4.7 - 15.1.4.15
                 "EvalError"      |-> @desc("Value" |-> @EvalErrorOid      "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.10 EvalError      ( . . . ) 
                 "RangeError"     |-> @desc("Value" |-> @RangeErrorOid     "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.11 RangeError     ( . . . )
                 "ReferenceError" |-> @desc("Value" |-> @ReferenceErrorOid "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.12 ReferenceError ( . . . )
                 "SyntaxError"    |-> @desc("Value" |-> @SyntaxErrorOid    "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.13 SyntaxError    ( . . . )
                 "TypeError"      |-> @desc("Value" |-> @TypeErrorOid      "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.14 TypeError      ( . . . )
                 "URIError"       |-> @desc("Value" |-> @URIErrorOid       "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true ) // 15.1.4.15 URIError       ( . . . )
                 // 15.1.5 Other Properties of the Global Object // TODO:
               </properties>
               <internalProperties>
                 "Prototype"  |-> @NullOid
                 "Class"      |-> "Object"
                 "Extensible" |-> true
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
                 "length"            |-> @desc("Value" |-> 1                "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                 "prototype"         |-> @desc("Value" |-> @NumberProtoOid  "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.7.3.1 Number.prototype
               //"MAX_VALUE"         |-> @desc("Value" |-> ...              "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.7.3.2 Number.MAX_VALUE
               //"MIN_VALUE"         |-> @desc("Value" |-> ...              "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.7.3.3 Number.MIN_VALUE
                 "NaN"               |-> @desc("Value" |-> @NaN             "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.7.3.4 Number.NaN
               //"NEGATIVE_INFINITY" |-> @desc("Value" |-> @+Infinity       "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.7.3.5 Number.NEGATIVE_INFINITY
               //"POSITIVE_INFINITY" |-> @desc("Value" |-> @-Infinity       "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.7.3.6 Number.POSITIVE_INFINITY
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
               </properties>
               <internalProperties>
                 "Prototype"      |-> @ObjectProtoOid
                 "Class"          |-> "Number"
                 "Extensible"     |->  true
                 "PrimitiveValue" |-> 0
               </internalProperties>
             </obj>)
     </objs>
     <envs>
       // 10.2.3 The Global Environment
       (. => <env>
               <eid> @GlobalEid </eid>
               <objEnvRec>
                 <bindingObj> @GlobalOid </bindingObj>
                 <provideThis> false </provideThis>
               </objEnvRec>
               <outer> @NullEid </outer>
             </env>)
     </envs>

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

syntax Bool ::= "@HasPrimitiveBase" "(" Reference ")" [function]
rule @HasPrimitiveBase(@Ref(_:Primitive,_,_)) => true

syntax Bool ::= "@IsPropertyReference" "(" Reference ")" [function]
rule @IsPropertyReference(@Ref(_:Oid,      _,_)) => true
rule @IsPropertyReference(@Ref(_:Primitive,_,_)) => true

syntax Bool ::= "@IsUnresolvableReference" "(" Reference ")" [function]
rule @IsUnresolvableReference(@Ref(Base:Base,_,_)) => Base ==K @Undefined

// 8.7.1 GetValue (V)

syntax K /* Val */ ::= "@GetValue" "(" K /* Reference */ ")" [seqstrict(1)]

rule @GetValue(@Ref(E:Eid,      N:Var, Strict:Bool)) => @GetBindingValue(E,N,Strict)
rule @GetValue(@Ref(O:Oid,      P:Var, _          )) => @Get(O,P)

rule @GetValue(@Ref(B:Bool,     P:Var, Strict:Bool)) => @GetValue(@Ref(@ToObject(B),P,Strict))
rule @GetValue(@Ref(S:String,   P:Var, Strict:Bool)) => @GetValue(@Ref(@ToObject(S),P,Strict))
rule @GetValue(@Ref(N:Number,   P:Var, Strict:Bool)) => @GetValue(@Ref(@ToObject(N),P,Strict))

rule @GetValue(@Ref(@Undefined, _,     _          )) => @Escape(@ReferenceError)

// 8.7.2 PutValue (V, W)
// TODO: other cases

syntax K /* .K */ ::= "@PutValue" "(" K /* Reference */ "," K /* Val */ ")" [seqstrict(1,2)]

rule @PutValue(@Ref(E:Eid,      N:Var, Strict:Bool), V:Val) => @SetMutableBinding(E,N,V,Strict)
rule @PutValue(@Ref(O:Oid,      P:Var, Strict:Bool), V:Val) => @Put(O,         P,V,Strict)
rule @PutValue(@Ref(@Undefined, P:Var, false      ), V:Val) => @Put(@GlobalOid,P,V,false)
rule @PutValue(@Ref(@Undefined, _,     true       ), _    ) => @Escape(@ReferenceError)

//////////////////////////////////////////////////////////////////////////////
// 8.10 The Property Descriptor and Property Identifier Specification Types
//////////////////////////////////////////////////////////////////////////////

// 8.10.1 IsAccessorDescriptor ( Desc )

syntax Bool ::= "@IsAccessorDescriptor" "(" Val ")" [function]

rule @IsAccessorDescriptor(@Undefined) => false
rule @IsAccessorDescriptor(@desc(Desc)) => "Get" in keys(Desc) orBool
                                           "Set" in keys(Desc)

// 8.10.2 IsDataDescriptor ( Desc )

syntax Bool ::= "@IsDataDescriptor" "(" Val ")" [function]

rule @IsDataDescriptor(@Undefined) => false
rule @IsDataDescriptor(@desc(Desc)) => "Value"    in keys(Desc) orBool
                                       "Writable" in keys(Desc)

// 8.10.3 IsGenericDescriptor ( Desc )

syntax Bool ::= "@IsGenericDescriptor" "(" Val ")" [function]

rule @IsGenericDescriptor(@Undefined) => false
rule @IsGenericDescriptor(@desc(Desc)) => notBool("Get"      in keys(Desc)) andBool
                                          notBool("Set"      in keys(Desc)) andBool
                                          notBool("Value"    in keys(Desc)) andBool
                                          notBool("Writable" in keys(Desc))

// 8.10.4 FromPropertyDescriptor ( Desc )
// TODO:

syntax K /* Val */ ::= "@FromPropertyDescriptor" "(" K /* PropertyDescriptor */ ")" [seqstrict(1)]

rule @FromPropertyDescriptor(@Undefined) => @Undefined
syntax Id ::= "$obj"
rule @FromPropertyDescriptor(Desc:PropertyDescriptor)
  => %Let $obj = @CreateObject;
     %DoI @DefineOwnProperty($obj, "value",        @desc("Value" |-> Desc."Value"        "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     %DoI @DefineOwnProperty($obj, "writable",     @desc("Value" |-> Desc."Writable"     "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     %DoI @DefineOwnProperty($obj, "enumerable",   @desc("Value" |-> Desc."Enumerable"   "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     %DoI @DefineOwnProperty($obj, "configurable", @desc("Value" |-> Desc."Configurable" "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);

// 8.10.5 ToPropertyDescriptor ( Obj )
// TODO:

syntax K /* PropertyDescriptor */ ::= "@ToPropertyDescriptor" "(" Val ")"

rule @ToPropertyDescriptor(V:Val) => @Escape(@TypeError) when @IsOid(V) ==K false
syntax Id ::= "$enum" | "$conf" | "$value" | "$writable"
rule @ToPropertyDescriptor(O:Oid)
  => %Let $enum     = @ToBoolean(@Get(O,"enumerable"));
     %Let $conf     = @ToBoolean(@Get(O,"configurable"));
     %Let $value    =            @Get(O,"value");
     %Let $writable = @ToBoolean(@Get(O,"writable"));
     %Return @desc("Value" |-> $value "Writable" |-> $writable "Enumerable" |-> $enum "Configurable" |-> $conf);

//////////////////////////////////////////////////////////////////////////////
// 8.12 Algorithms for Object Internal Methods
//////////////////////////////////////////////////////////////////////////////

// 8.12.1 [[GetOwnProperty]] (P)

syntax K /* Val */ ::= "@GetOwnProperty" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict(1,2)]

rule <k> @GetOwnProperty(O:Oid,P:Var) => V ... </k>
     <obj>
       <oid> O </oid>
       <properties> P |-> V:Val _ </properties>
       _
     </obj>
rule <k> @GetOwnProperty(O:Oid,P:Var) => @Undefined ... </k>
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
/* TODO: check if it is needed
rule <k> @GetInternalProperty(O:Oid,P:Var) => @Undefined ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties> Prop </internalProperties>
       _
     </obj>
     when notBool(P in keys(Prop))
*/

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

syntax Id ::= "$desc" | "$getter"
rule @Get(O:Oid,P:Var)
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

syntax K /* .K */ ::= "@Put" "(" Oid "," Var "," Val "," Bool ")"

syntax Id ::= "$ownDesc" | "$valueDesc" | "$setter" | "$newDesc"
rule @Put(O:Oid,P:Var,V:Val,Throw:Bool)
  => %If @CanPut(O,P) = false then {
       %If Throw = true then {
         %Do @Escape(@TypeError);
       } else {
         %Return;
       }
     } else {
       %Let $ownDesc = @GetOwnProperty(O,P);
       %If @IsDataDescriptor($ownDesc::K::Val) = true then {
         %Let $valueDesc = @desc("Value" |-> V "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true); // TODO: Figure out why the specification mentioned only the "Value" attribute
         %DoI @DefineOwnProperty(O,P,$valueDesc::K::Val,Throw);
       } else {
         %Let $desc = @GetProperty(O,P);
         %If @IsAccessorDescriptor($desc::K::Val) = true then {
           %Let $setter = $desc."Set";
           %DoI @Call($setter::K::Oid,O,@Cons(V,@Nil));
         } else {
           %Let $newDesc = @desc("Value" |-> V "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true);
           %DoI @DefineOwnProperty(O,P,$newDesc::K::Val,Throw);
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

syntax K /* Bool */ ::= "@HasProperty" "(" Oid "," Var ")"

rule @HasProperty(O:Oid,P:Var)
  => %If @GetProperty(O,P) = @Undefined then {
       %Return false;
     } else {
       %Return true;
     }

// 8.12.7 [[Delete]] (P, Throw)

syntax K /* Bool */ ::= "@Delete" "(" Oid "," Var "," Bool ")" 

rule <k> @Delete(O:Oid,P:Var,Throw:Bool) => true ... </k>
     <obj>
       <oid> O </oid>
       <properties> Prop:Map </properties>
       _
     </obj>
     when notBool(P in keys(Prop))
rule <k> @Delete(O:Oid,P:Var,Throw:Bool) => true ... </k>
     <obj>
       <oid> O </oid>
       <properties>
         (P |-> @desc("Configurable" |-> true _) => .)
         _
       </properties>
       _
     </obj>
rule <k> @Delete(O:Oid,P:Var,Throw:Bool) => @Reject(Throw) ... </k>
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

syntax Id ::= "$toString" | "$valueOf"

rule @DefaultValue(O:Oid,"String")
  => %Let $toString = @Get(O,"toString");
     %If @IsCallable($toString) = true then {
       %Return @Call($toString,O,@Nil); // TODO: check if return value is primitive 
     } else {
       %Let $valueOf = @Get(O,"valueOf");
       %If @IsCallable($valueOf) = true then {
         %Return @Call($valueOf,O,@Nil); // TODO: check if return value is primitive 
       } else {
         %Do @Escape(@TypeError);
       }
     }

rule @DefaultValue(O:Oid,"Number")
  => %Let $valueOf = @Get(O,"valueOf");
     %If @IsCallable($valueOf) = true then {
       %Return @Call($valueOf,O,@Nil); // TODO: check if return value is primitive 
     } else {
       %Let $toString = @Get(O,"toString");
       %If @IsCallable($toString) = true then {
         %Return @Call($toString,O,@Nil); // TODO: check if return value is primitive 
       } else {
         %Do @Escape(@TypeError);
       }
     }

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
     when Class =/=K "Date"

// 8.12.9 [[DefineOwnProperty]] (P, Desc, Throw)

syntax K /* Bool */ ::= "@DefineOwnProperty" "(" K /* Oid */ "," K /* Var */ "," K /* Val */ "," K /* Bool */ ")" [seqstrict(1,2,3,4)]
// TODO: Revise defineownproperty.k

syntax Id ::= "$current" | "$extensible"
rule @DefineOwnProperty(O:Oid,P:Var,Desc:Val,Throw:Bool)
  => %Let $current = @GetOwnProperty(O,P);
     %Let $extensible = @GetInternalProperty(O,"Extensible");
     %If $current = @Undefined then {
       %If $extensible = false then {
         %Return @Reject(Throw);
       } else {
         %Do @SetOwnProperty(O,P,Desc);
         %Return true;
       }
     } else {
       // TODO: HACK:
       %Do @SetOwnProperty(O,P,Desc);
       %Return true;
       /* TODO: HACK: More correctly
       %If $current."Configurable" = true then {
         %Do @SetOwnProperty(O,P,Desc);
         %Return true;
       } else {
         %If Desc."Configurable" = true then {
           %Return @Reject(Throw);
         } else {
           %If $current."Enumerable" = Desc."Enumerable" then {
             %Do @SetOwnProperty(O,P,Desc);
             %Return true;
           } else {
             %Return @Reject(Throw);
           }
         }
       }
       */
     }

syntax K /* .K */ ::= "@SetOwnProperty" "(" Oid "," Var "," Val ")"
rule <k> @SetOwnProperty(O:Oid,P:Var,V:Val) => . ... </k>
     <obj>
       <oid> O </oid>
       <properties> Prop => @AddMap(P,V,Prop) </properties>
       _
     </obj>

syntax K /* Bool */ ::= "@Reject" "(" Bool ")"
rule @Reject(true)  => @Escape(@TypeError)
rule @Reject(false) => false

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
rule @ToBoolean(S:String  ) => true when S =/=K ""
rule @ToBoolean(""        ) => false
rule @ToBoolean(N:Number  ) => true when N =/=K 0 andBool N =/=K @NaN
rule @ToBoolean(0         ) => false
rule @ToBoolean(@NaN      ) => false
rule @ToBoolean(O:Oid     ) => true

// 9.3 ToNumber

syntax K /* Number */ ::= "@ToNumber" "(" K /* Val */ ")" [seqstrict(1)]

rule @ToNumber(@Undefined) => @NaN
rule @ToNumber(@NullVal  ) => 0
rule @ToNumber(true      ) => 1
rule @ToNumber(false     ) => 0
rule @ToNumber(S:String  ) => String2Int(S) when S =/=K "" // TODO: Consider floating point numbers
rule @ToNumber(""        ) => 0
rule @ToNumber(N:Number  ) => N
rule @ToNumber(O:Oid     ) => @ToNumber(@ToPrimitive(O,"Number"))

// 9.4 ToInteger

syntax K /* Val */ ::= "@ToInteger" "(" Val ")"

rule @ToInteger(V:Val) => @NumberToInteger(@ToNumber(V))

// TODO: Do more correctly
syntax K /* Int */ ::= "@NumberToInteger" "(" K /* Number */ ")" [seqstrict(1)]
rule @NumberToInteger(I:Int  ) => I
rule @NumberToInteger(F:Float) => Float2Int(F)
rule @NumberToInteger(@NaN   ) => 0

// 9.5 ToInt32: (Signed 32 Bit Integer)
// TODO:

syntax K /* Val */ ::= "@ToInt32" "(" Val ")"

// 9.6 ToUint32: (Unsigned 32 Bit Integer)
// TODO:

syntax K /* Val */ ::= "@ToUint32" "(" Val ")"

// 9.7 ToUint16: (Unsigned 16 Bit Integer)
// TODO:

syntax K /* Val */ ::= "@ToUint16" "(" Val ")"

// 9.8 ToString

syntax K /* Val */ ::= "@ToString" "(" K /* Val */ ")" [seqstrict(1)]

rule @ToString(@Undefined) => "undefined"
rule @ToString(@NullVal  ) => "null"
rule @ToString(true      ) => "true"
rule @ToString(false     ) => "false"
rule @ToString(S:String  ) => S
rule @ToString(I:Int     ) => Int2String(I)
rule @ToString(F:Float   ) => Float2String(F)
rule @ToString(@NaN      ) => "NaN"
rule @ToString(O:Oid     ) => @ToString(@ToPrimitive(O,"String"))

// 9.9 ToObject

syntax K /* Val */ ::= "@ToObject" "(" Val ")"

rule @ToObject(@Undefined) => @Escape(@TypeError)
rule @ToObject(@NullVal  ) => @Escape(@TypeError)
rule @ToObject(B:Bool    ) => @NewBoolean(@Cons(B,@Nil))
rule @ToObject(S:String  ) => @NewString(@Cons(S,@Nil))
rule @ToObject(N:Number  ) => @NewNumber(@Cons(N,@Nil))
rule @ToObject(O:Oid) => O

// 9.10 CheckObjectCoercible

syntax K /* .K */ ::= "@CheckObjectCoercible" "(" Val ")"
rule <k> @CheckObjectCoercible(V:Val) => . ... </k>
     when (V =/=K @Undefined) andBool
          (V =/=K @NullVal)
rule @CheckObjectCoercible(@Undefined) => @Escape(@TypeError)
rule @CheckObjectCoercible(@NullVal  ) => @Escape(@TypeError)

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

syntax K /* Bool */ ::= "@SameValue" "(" K /* Val */ "," K /* Val */ ")" [seqstrict(1,2)]

// TODO: Do more correctly Step 4 of Number
rule @SameValue(V1:Val,V2:Val) => V1 ==K V2

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
     when notBool(S ==K true andBool Initialized ==K false andBool Mutable ==K false)
rule <k> @GetBindingValue(E:Eid,N:Var,true) => @Undefined ... </k>
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
             %Do @Escape(@ReferenceError);
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
// TODO: other cases
rule <k> @DeleteBinding(E:Eid,N:Var) => true ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> ... (N |-> @ve(_,_,_,true) => .) ... </declEnvRec>
       _
     </env>
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

syntax K /* Eid */ ::= "@NewDeclarativeEnvironment" "(" Eid ")" 

rule <k> @NewDeclarativeEnvironment(E:Eid) => @e(N) ... </k>
     <envs>
       (. => <env>
               <eid> @e(N) </eid>
               <outer> E </outer>
               <declEnvRec> .Map </declEnvRec>
             </env>)
       _
     </envs>
     when fresh(N:Int)

// 10.2.2.3 NewObjectEnvironment (O, E)

syntax K /* Eid */ ::= "@NewObjectEnvironment" "(" Oid "," Eid ")" 

rule <k> @NewObjectEnvironment(O:Oid,E:Eid) => @e(N) ... </k>
     <envs>
       (. => <env>
               <eid> @e(N) </eid>
               <outer> E </outer>
               <objEnvRec>
                 <bindingObj> O </bindingObj>
                 <provideThis> false </provideThis>
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
rule <k> @EnterGlobalCode(Code:Stmt) => @BindDeclarations(Code) ... </k>
     <ctx>
       <activeStack> . </activeStack>
       <running>
         <lexicalEnv>  . => @GlobalEid </lexicalEnv>
         <thisBinding> . => @GlobalOid </thisBinding>
         <strict>      . => @IsStrict(Code) </strict>
         <lastNonEmptyValue> . => @Undefined </lastNonEmptyValue>
       </running>
     </ctx>

// 10.4.2 Entering Eval Code
// TODO: Step 1: no calling context or not direct call

syntax K /* .K */ ::= "@EnterEvalCode" "(" Stmt ")"
syntax Id ::= "$strict"
rule <k> @EnterEvalCode(Code:Stmt)
      => %Let $strict = @IsStrict(Code) orBool Strict;
         %Do @SetRunningCtx(@NewDeclarativeEnvironmentForEval(E,$strict::K::Bool), This, $strict);
         %Do @BindDeclarations(Code);
     ... </k>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         <thisBinding> This:Oid </thisBinding>
         <strict> Strict:Bool </strict>
         _
       </running>
       _
     </ctx>

syntax K /* Eid */ ::= "@NewDeclarativeEnvironmentForEval" "(" Eid "," Bool ")"
rule @NewDeclarativeEnvironmentForEval(E,true ) => @NewDeclarativeEnvironment(E)
rule @NewDeclarativeEnvironmentForEval(E,false) => E

// 10.4.3 Entering Function Code
// TODO: Step 1: strict code

syntax K /* .K */ ::= "@EnterFunctionCode" "(" Oid "," Val "," Vals ")"
rule <k> @EnterFunctionCode(F:Oid,This:Val,Args:Vals)
      => @SetRunningCtx(@NewDeclarativeEnvironment(E), @ResolveThis(This), @IsStrict(Code) orBool Strict)
      ~> @BindFunctionParameters(F,Args)
      ~> @BindDeclarations(Code)
     ... </k>
     <obj>
       <oid> F </oid>
       <internalProperties>
         "Scope" |-> E:Eid
         "Code" |-> Code:Stmt
         _
       </internalProperties>
       _
     </obj>
     <ctx>
       <running>
         <strict> Strict:Bool </strict>
         _
       </running>
       _
     </ctx>

syntax K /* Oid */ ::= "@ResolveThis" "(" Val ")"
rule @ResolveThis(O:Oid) => O                   // NOTE: Method call or function call under the 'with'
rule @ResolveThis(@Undefined) => @GlobalOid     // NOTE: Function call without the 'with' (from p.28 of Good Parts)
rule @ResolveThis(@NullVal  ) => @GlobalOid     // NOTE: Apply call with 'null' as a 'this' value (from p.30 of Good Parts)
rule @ResolveThis(V:Val) => @ToObject(V) when isPrimitive(V) ==K true

syntax K /* .K */ ::= "@SetRunningCtx" "(" K /* Eid */ "," K /* Oid */ "," K /* Bool */ ")" [seqstrict(1,2,3)]
rule <k> @SetRunningCtx(E:Eid,This:Oid,Strict:Bool) => . ... </k>
     <ctx>
       <activeStack> (. => @active(R)) _ </activeStack>
       <running>
         (R => <lexicalEnv> E </lexicalEnv>
               <thisBinding> This </thisBinding>
               <strict> Strict </strict>
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
// TODO: other cases: 'arguments' object, Step 6 & 7

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
      => @BindVariableDeclaration(N) 
      ~> @SetMutableBinding(E,N,V,Strict) ... </k>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         <strict> Strict:Bool </strict>
         _
       </running>
       _
     </ctx>

// 10.5: Step 5 & 8: Function/Variable Declarations Binding Instantiation
// Visitor function
syntax K /* .K */ ::= "@BindDeclarations" "(" Stmt ")"
rule @BindDeclarations(%fdecl(F:Var,Ps:Exps,FB:Stmt))   => @BindFunctionDeclaration(F,Ps,FB)
rule @BindDeclarations(%vdecl(N:Var))                   => @BindVariableDeclaration(N)
rule @BindDeclarations(%seq(S1:Stmt,S2:Stmt))           => @BindDeclarations(S1) ~> @BindDeclarations(S2)
rule @BindDeclarations(%exp(_))                         => .
rule @BindDeclarations(%if(_,S1:Stmt,S2:Stmt))          => @BindDeclarations(S1) ~> @BindDeclarations(S2)
rule @BindDeclarations(%do(S:Stmt,_))                   => @BindDeclarations(S)
rule @BindDeclarations(%while(_,S:Stmt))                => @BindDeclarations(S)
rule @BindDeclarations(%for  (S1:Stmt,_,_,S2:Stmt))     => @BindDeclarations(S1) ~> @BindDeclarations(S2)
rule @BindDeclarations(%forin(S1:Stmt,_,_,S2:Stmt))     => @BindDeclarations(S1) ~> @BindDeclarations(S2)
rule @BindDeclarations(%continue(_))                    => .
rule @BindDeclarations(%break(_))                       => .
rule @BindDeclarations(%label(_,S:Stmt))                => @BindDeclarations(S)
rule @BindDeclarations(%return(_))                      => .
rule @BindDeclarations(%throw(_))                       => .
rule @BindDeclarations(%try(S1:Stmt,_,S2:Stmt,S3:Stmt)) => @BindDeclarations(S1) ~> @BindDeclarations(S2) ~> @BindDeclarations(S3)
rule @BindDeclarations(%try(S1:Stmt,          S3:Stmt)) => @BindDeclarations(S1) ~>                          @BindDeclarations(S3)
rule @BindDeclarations(%with(_,S:Stmt))                 => @BindDeclarations(S)
rule @BindDeclarations(%emptyStmt)                      => .
rule @BindDeclarations(%print(_))                       => .

// 10.5: Step 5: Function Declaration Binding Instantiation
syntax K /* .K */ ::= "@BindFunctionDeclaration" "(" Var "," Exps "," Stmt ")"
rule <k> @BindFunctionDeclaration(N:Var, Params:Exps, FunBody:Stmt)
      => @HasBinding(E,N) ~> @False?
      ~> @CreateMutableBinding(E,N,true) // TODO: Figure out why the specification said the third argument should be false
      ~> @SetMutableBinding(E, N, @FunctionDeclaration(N,Params,FunBody), Strict) ... </k>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         <strict> Strict:Bool </strict>
         _
       </running>
       _
     </ctx>
// TODO: Consider step e

// 10.5: Step 8: Variable Declaration Binding Instantiation
syntax K /* .K */ ::= "@BindVariableDeclaration" "(" Var ")"
rule <k> @BindVariableDeclaration(N:Var)
      => %If @HasBinding(E,N) = true then {
           %Return;
         } else {
           %Do @CreateMutableBinding(E,N,true); // TODO: Figure out why the specification said the third argument should be false
           %Do @SetMutableBinding(E,N,@Undefined,Strict);
         }
     ... </k>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         <strict> Strict:Bool </strict>
         _
       </running>
       _
     </ctx>

// 10.6 Arguments Object
// TODO:

//////////////////////////////////////////////////////////////////////////////
// 11 Expressions
//////////////////////////////////////////////////////////////////////////////

syntax K /* Reference */ ::= "@GetReference" "(" Exp ")"

rule <k> @GetReference(%var(N:Var)) => @GetIdentifierReference(E,N,Strict) ... </k>
     <running>
       <lexicalEnv> E:Eid </lexicalEnv>
       <strict> Strict:Bool </strict>
       _
     </running>

context @GetReference(%mem(HOLE,_))
context @GetReference(%mem(_:Val,HOLE))
rule <k> @GetReference(%mem(O:Val,N:Val)) // NOTE: O does not need to be an Oid
      => @CheckObjectCoercible(O) ~> @Ref(O, @ToString(N), Strict) ... </k>
     <running>
       <strict> Strict:Bool </strict>
       _
     </running>

syntax K /* Bool */ ::= "@IsReferenceExp" "(" Exp ")" [function]

rule @IsReferenceExp(E:Exp) => getKLabel(E) ==KLabel '%var`(_`)
                        orBool getKLabel(E) ==KLabel '%mem`(_`,_`)

rule %emptyExp => @Undefined

// 11.1.1 The this Keyword

rule <k> %this => O ... </k>
     <running>
       <thisBinding> O:Oid </thisBinding>
       _
     </running>

// 11.1.2 Identifier Reference
// 10.3.1 Identifier Resolution

rule %var(N:Var) => @GetValue(@GetReference(%var(N)))

// 11.1.3 Literal Reference
// TODO: Numeric, Regular Expressions

rule %con(C) => C

// 11.1.4 Array Initialiser
// TODO:

// 11.1.5 Object Initialiser

rule %obj(PAs:Exps) => @AssignProps(@CreateObject,PAs)

syntax K /* Oid */ ::= "@AssignProps" "(" K /* Oid */ "," Exps ")" [seqstrict(1)]
rule @AssignProps(O:Oid, %nil) => O
rule @AssignProps(O:Oid, %cons(PA:Exp, PAs:Exps)) => @AssignProp(O,PA) ~> @AssignProps(O,PAs)

syntax K /* .K */ ::= "@AssignProp" "(" Oid "," Exp ")" 
// TODO: Consider get, set properties
context @AssignProp(_,%prop(_,HOLE))
rule @AssignProp(O:Oid, %prop(P:Var,V:Val))
  => @DefineOwnProperty(O, P, @desc("Value" |-> V "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false) ~> @Ignore

// 11.1.6 The Grouping Operator
// NOTE: Nothing to do

// 11.2.1 Property Accessors

rule %mem(E1:Exp,E2:Exp) => @GetValue(@GetReference(%mem(E1,E2)))

// 11.2.2 The new Operator

rule %new(F:Exp,Es:Exps) => @Construct(F,Es)
     when @IsStandardBuiltinObject(F) ==K false // TODO: could it be made in uniform way?

// 11.2.3 Function Calls

rule %call(F:Exp,Es:Exps) => @Call(F, @DetermineThis(F), Es)
     when @IsStandardBuiltinObject(F) ==K false // TODO: could it be made in uniform way?

syntax K /* Val */ ::= "@DetermineThis" "(" Exp ")"

rule @DetermineThis(F) => @FindThis(@GetReference(F)) when @IsReferenceExp(F) ==K true
rule @DetermineThis(F) => @Undefined                  when @IsReferenceExp(F) ==K false

syntax K /* Val */ ::= "@FindThis" "(" K /* Reference */ ")" [seqstrict(1)]

rule @FindThis(@Ref(O:Oid,_,_)) => O
rule @FindThis(@Ref(E:Eid,_,_)) => @ImplicitThisValue(E)
rule @FindThis(@Ref(I:Primitive,_,_)) => I // NOTE: This will be resolved by @ResolveThis
rule @FindThis(@Ref(@Undefined,_,_)) => @Undefined

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
// TODO:

// 11.4.2 The void Operator

rule %pre(%void,E:Exp) => E ~> @Ignore ~> @Undefined

// 11.4.3 The typeof Operator

rule %pre(%typeof,E:Exp) => @TypeOf(%Try E;)

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
//
// Case 2.a
// NOTE: We don't need to consider the case that the reference value of E is an unresolvable reference. If the case happens, evaluating E throws an ReferenceError and we can catch the case.
rule @TypeOf(@Throw(@ReferenceError)) => "undefined"
//
// TODO: is there any better way?
rule @TypeOf(@(_)      ) => "function"

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
// TODO:

// 11.4.8 Bitwise NOT Operator ( ~ )
// TODO:

// 11.4.9 Logical NOT Operator ( ! )

rule %pre(%bang,E:Exp) => @Not(@ToBoolean(E))

syntax K ::= "@Not" "(" K /* Bool */ ")" [seqstrict(1)]
rule @Not(true) => false
rule @Not(false) => true

// 11.? Binary Operator

context %bop(OpNormal,HOLE,_)
context %bop(OpNormal,_:Val,HOLE)

// 11.5 Multiplicative Operators
// TODO:

// 11.6.1 The Addition operator ( + )

rule %bop(%plus,V1:Val,V2:Val) => @PolymorphicAddition(@ToPrimitive(V1,""), @ToPrimitive(V2,""))

syntax K ::= "@PolymorphicAddition" "(" K /* Val */ "," K /* Val */ ")" [seqstrict(1,2)]
rule @PolymorphicAddition(V1:Val,V2:Val) =>     @Addition(@ToNumber(V1), @ToNumber(V2)) when notBool(@IsString(V1) ==K true) andBool notBool(@IsString(V2) ==K true)
rule @PolymorphicAddition(V1:Val,V2:Val) => @Concatnation(@ToString(V1), @ToString(V2)) when          isString(V1) ==K true   orBool          isString(V2) ==K true

syntax K ::= "@Concatnation" "(" K /* String */ "," K /* String */ ")" [seqstrict(1,2)]
rule @Concatnation(S1:String,S2:String) => S1 +String S2

// 11.6.2 The Subtraction Operator ( - )

rule %bop(%minus,V1:Val,V2:Val) => @Subtraction(@ToNumber(V1), @ToNumber(V2))

// 11.6.3 Applying the Additive Operators to Numbers

syntax K ::= "@Addition" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
rule @Addition(I1:Int,I2:Int) => I1 +Int I2
rule @Addition(F1:Float,F2:Float) => F1 +Float F2
rule @Addition(@NaN,_) => @NaN
rule @Addition(_,@NaN) => @NaN
// TODO: other cases

syntax K ::= "@Subtraction" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
rule @Subtraction(I1:Int,I2:Int) => I1 -Int I2
rule @Subtraction(F1:Float,F2:Float) => F1 -Float F2
rule @Subtraction(@NaN,_) => @NaN
rule @Subtraction(_,@NaN) => @NaN

// 11.7 Bitwise Shift Operators
// TODO:

// 11.8 Relational Operators
// TODO:

// 11.8.6 The instanceof operator
// TODO:

// TODO: HACK:
rule %bop(%instanceof,@EvalError,     @EvalErrorOid     ) => true
rule %bop(%instanceof,@RangeError,    @RangeErrorOid    ) => true
rule %bop(%instanceof,@ReferenceError,@ReferenceErrorOid) => true
rule %bop(%instanceof,@SyntaxError,   @SyntaxErrorOid   ) => true
rule %bop(%instanceof,@TypeError,     @TypeErrorOid     ) => true
rule %bop(%instanceof,@URIError,      @URIErrorOid      ) => true

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
rule @AbstractEquality(N1:Number, N2:Number ) => N1 ==K N2 andBool N1 =/=K @NaN andBool N2 =/=K @NaN
rule @AbstractEquality(N:Number,  O:Oid     ) => @AbstractEquality(N, @ToPrimitive(O,""))
//
rule @AbstractEquality(O:Oid,     @Undefined) => false
rule @AbstractEquality(O:Oid,     @NullVal  ) => false
rule @AbstractEquality(O:Oid,     _:Bool    ) => false
rule @AbstractEquality(O:Oid,     S:String  ) => @AbstractEquality(@ToPrimitive(O,""), S)
rule @AbstractEquality(O:Oid,     N:Number  ) => @AbstractEquality(@ToPrimitive(O,""), N)
rule @AbstractEquality(O:Oid,     _:Oid     ) => false

// 11.9.4 The Strict Equals Operator ( === )

rule %bop(%eqs, V1:Val,V2:Val) =>      @StrictEquality(V1,V2)

// 11.9.5 The Strict Does-not-equal Operator ( !== )

rule %bop(%neqs,V1:Val,V2:Val) => @Not(@StrictEquality(V1,V2))

// 11.9.6 The Strict Equality Comparison Algorithm

syntax K ::= "@StrictEquality" "(" K /* Val */ "," K /* Val */ ")" [seqstrict(1,2)]

rule @StrictEquality(V1:Val,V2:Val) => V1 ==K V2 when V1 =/=K @NaN andBool V2 =/=K @NaN
rule @StrictEquality(@NaN,_) => false
rule @StrictEquality(_,@NaN) => false

// 11.10 Binary Bitwise Operators
// TODO:

// 11.11 Binary Logical Operators

context %bop(_:OpShortcut,HOLE,_)

rule %bop(%and,V1:Exp,E2:Exp)
  => %If @ToBoolean(V1) = true then {
       %Return E2;
     } else {
       %Return V1;
     }

rule %bop(%or,V1:Exp,E2:Exp)
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
// TODO:

syntax Id ::= "$ref"
rule %bop(%plusassign,L:Exp,E:Exp)
  => %Let $ref = @GetReference(L);
     %Do @PutValueAndReturn($ref, %bop(%plus, @GetValue($ref), E));

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

rule %exp(E:Exp) => @Exp(%Try E;)

syntax K ::= "@Exp" "(" K /* Val */ ")" [seqstrict(1)]
rule @Exp(V:Val) => @UpdateStmtValue(V) ~> @Normal
rule @Exp(@Throw(V:Val)) => @Throw(V)

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

rule %for(S0,E1,E2,S) => %seq(S0, %while(E1, %seq(S, %exp(E2))))

// 12.6.4 The for-in Statement
// TODO:

// 12.7 The continue Statement

rule %continue(L) => @Continue(L)

// 12.8 The break Statement

rule %break(L) => @Break(L)

// 12.9 The return Statement

context %return(HOLE)
rule %return(V:Val) => @Return(V)

// 12.10 The with Statement
// TODO:

// 12.11 The switch Statement
// TODO:

// 12.12 Labelled Statements
// TODO: Move to the first-pass

syntax Stmt ::= "%labelContinue" "(" Var ")"
syntax Stmt ::= "%labelBreak"    "(" Var ")"

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

// 12.13 The throw Statement

context %throw(HOLE)
rule %throw(V:Val) => @Throw(V)

// 12.14 The try Statement

context %try(HOLE,_,_,_)
rule %try(CT:CompletionType,           Finally) => @ResolveFinally(CT,                Finally)
rule %try(CT:CompletionType, _, _,     Finally) => @ResolveFinally(CT,                Finally) when getKLabel(CT) =/=KLabel '@Throw`(_`)
rule %try(@Throw(V),         X, Catch, Finally) => @ResolveFinally(@Catch(X,V,Catch), Finally)

syntax K /* CompletionType */ ::= "@Catch" "(" Var "," Val "," Stmt ")"
syntax Id ::= "$catchEnv" | "$result"
rule <k> @Catch(X:Var,V:Val,Catch:Stmt)
      => %Let $catchEnv = @NewDeclarativeEnvironment(E);
         %Do @CreateMutableBinding($catchEnv::K::Eid, X, true); // TODO: check true or false as the third argument
         %Do @SetMutableBinding($catchEnv::K::Eid, X, V, false);
         %Do @SetRunningCtx($catchEnv::K::Eid, This, Strict);
         %Let $result = Catch;
         %Do @RestoreRunningCtx;
         %Return $result;
     ... </k>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         <thisBinding> This:Oid </thisBinding>
         <strict> Strict:Bool </strict>
         _
       </running>
       _
     </ctx>

// If the finally block has an abrupted result, the first block's result is ignored even if it is either return or throw.
syntax K /* CompletionType */ ::= "@ResolveFinally" "(" K /* CompletionType */ "," K /* CompletionType */ ")" [seqstrict(1,2)]
rule @ResolveFinally(CT:CompletionType,  _:CompletionTypeNormal) => CT
rule @ResolveFinally( _:CompletionType, CT:CompletionTypeAbrupt) => CT

//////////////////////////////////////////////////////////////////////////////
// 13 Function Definition
//////////////////////////////////////////////////////////////////////////////

syntax K /* Oid */ ::= "@FunctionDeclaration" "(" Var "," Exps "," Stmt ")"
rule @FunctionDeclaration(_,Params:Exps,FunBody:Stmt)
  => @FunctionExpressionAnonymous(Params,FunBody)

syntax K /* Oid */ ::= "@FunctionExpressionAnonymous" "(" Exps "," Stmt ")"
rule <k> @FunctionExpressionAnonymous(Params:Exps, FunBody:Stmt)
      => @CreateFunctionObject(Params,FunBody,E,Strict) ... </k>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         <strict> Strict:Bool </strict>
         _
       </running>
       _
     </ctx>

syntax K /* Oid */ ::= "@FunctionExpressionRecursive" "(" Var "," Exps "," Stmt ")"
syntax Id ::= "$funcEnv" | "$closure"
rule <k> @FunctionExpressionRecursive(F:Var, Params:Exps, FunBody:Stmt)
      => %Let $funcEnv = @NewDeclarativeEnvironment(E);
         %Do @CreateImmutableBinding($funcEnv::K::Eid, F);
         %Let $closure = @CreateFunctionObject(Params, FunBody, $funcEnv::K::Eid, Strict);
         %Do @InitializeImmutableBinding($funcEnv::K::Eid, F, $closure::K::Val);
         %Return $closure;
     ... </k>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         <strict> Strict:Bool </strict>
         _
       </running>
       _
     </ctx>

// 13.2 Creating Function Objects
// TODO: Consider Strict

// NOTE: (from p.26 of Good Parts): Every function object is created with a 'prototype' property. Its value is an object with a 'constructor' property whose value is the function. This is distinct from the hidden link to 'Function.prototype'.

syntax K /* Oid */ ::= "@CreateFunctionObject" "(" Exps "," Stmt "," Eid "," Bool ")"
rule <k> @CreateFunctionObject(Params:Exps, FunBody:Stmt, Scope:Eid, Strict:Bool) => @o(F) ... </k>
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
rule @Throw(V:Val)  ~> @ExitFunctionCode => @RestoreRunningCtx ~> @Throw(V)

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
           "prototype" |-> @desc("Value" |-> Prototype:Oid _)
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
// TODO:

//////////////////////////////////////////////////////////////////////////////
// 14 Program
//////////////////////////////////////////////////////////////////////////////

context %seq(HOLE, _)
context %seq(_:CompletionTypeNormal, HOLE)
rule %seq(   _:CompletionTypeNormal, Tail:CompletionType) => Tail
rule %seq(Head:CompletionTypeJump,      _:Stmt          ) => Head
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
                                 orBool (E ==K %var("JSON"))

syntax Val ::= "@" "(" String ")"

// TODO: check if it should throw errors or not when more arguements given for builtin functions

// 15.1 The Global Object

// 15.1.2.1 eval (x)

rule @Call(@("eval"), @Undefined, @Cons(V:Val,     @Nil)) => V when @IsString(V) ==K false
rule @Call(@("eval"), @Undefined, @Cons(Pgm:String,@Nil)) => @Eval(^SourceElements(#parse(Pgm,"Program"))) // @Eval(#parse(Pgm,"Stmt"))

syntax K ::= "@Eval" "(" K /* Stmt */ ")" [seqstrict(1)]
rule @Eval(Code:Stmt) => @EnterEvalCode(Code) ~> Code ~> @ExitEvalCode

// TODO: check why it does not work!!!
rule #noparse ~> @Eval(HOLE) => @Escape(@SyntaxError)

syntax K ::= "@ExitEvalCode"
rule <k> @Normal        ~> @ExitEvalCode => @RestoreRunningCtx ~> V ... </k> <lastNonEmptyValue> V:Val </lastNonEmptyValue>
rule     @Throw(V:Val)  ~> @ExitEvalCode => @RestoreRunningCtx ~> @Escape(V)

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
       %Do @Escape(@TypeError);
     }

// 15.2.3.4 Object.getOwnPropertyNames ( O )
// TODO:

// 15.2.3.5 Object.create ( O [, Properties] )

// TODO: consider step 1 more correctly
rule @Call(@("Object.create"), _, @Cons(O:Val,@Nil))
  => %If @IsOid(O) = false then {
       %Do @Escape(@TypeError);
     } else {
       %Let $obj = @CreateObject;
       %Do @SetPrototype($obj::K::Oid,O::Oid);
       %Return $obj;
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

// rule @Call(@("Object.create"), _, @Cons(O:Val,@Cons(Properties:Val,@Nil)))
// TODO:

// 15.2.3.6 Object.defineProperty ( O, P, Attributes )

rule @Call(@("Object.defineProperty"), _, @Cons(O:Val,@Cons(P:Val,@Cons(Attributes:Val,@Nil))))
  => %If @IsOid(O) = false then {
       %Do @Escape(@TypeError);
     } else {
       %DoI @DefineOwnProperty(O,@ToString(P),@ToPropertyDescriptor(Attributes),true);
       %Return O;
     }

// 15.2.3.7 Object.defineProperties ( O, Properties )
// TODO:

// 15.2.3.8 Object.seal ( O )
// TODO:

// 15.2.3.9 Object.freeze ( O )
// TODO:

// 15.2.3.10 Object.preventExtensions ( O )

rule <k> @Call(@("Object.preventExtensions"), _, @Cons(O:Val,@Nil))
      => %If @IsOid(O) = false then {
           %Do @Escape(@TypeError);
         } else {
           %Return O;
         }
     ... </k>
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

rule <k> @Call(@("Object.isExtensible"), _, @Cons(O:Val,@Nil))
      => %If @IsOid(O) = false then {
           %Do @Escape(@TypeError);
         } else {
           %Return Extensible;
         }
     ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "Extensible" |-> Extensible:Bool
         _
       </internalProperties>
       _
     </obj>

// 15.2.3.14 Object.keys ( O )
// TODO:

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
// TODO:

// 15.2.4.7 Object.prototype.propertyIsEnumerable (V
// TODO:

// 15.3 Function Objects

// 15.3.1.1 Function (p1, p2, ... , pn, body)
// TODO:

// 15.3.2.1 new Function (p1, p2, ... , pn, body)
// TODO:

// 15.3.4.2 Function.prototype.toString ( )
// TODO:

// 15.3.4.3 Function.prototype.apply (thisArg, argArray)

rule @Call(@("Function.prototype.apply"), Func:Val, @Cons(ThisArg:Val,@Cons(@NullVal,  @Nil))) => @Call(Func,ThisArg,@Nil)
rule @Call(@("Function.prototype.apply"), Func:Val, @Cons(ThisArg:Val,@Cons(@Undefined,@Nil))) => @Call(Func,ThisArg,@Nil)

// 15.3.4.4 Function.prototype.call (thisArg [ , arg1 [ , arg2, ... ] ] )

rule @Call(@("Function.prototype.call"), Func:Val, @Cons(ThisArg:Val,Args:Vals))
  => %If @IsCallable(Func) = false then {
       %Do @Escape(@TypeError);
     } else {
       %Do @Call(Func,ThisArg,Args);
     }

// 15.3.4.5 Function.prototype.bind (thisArg [, arg1 [, arg2, ...]])
// TODO:

// 15.4 Array Objects
// TODO:

// 15.5 String Objects

// 15.5.1.1 String ( [ value ] )

rule %call(%var("String"), Es:Exps) => @CallString(Es)

syntax K /* String */ ::= "@CallString" "(" K /* Vals */ ")" [seqstrict(1)]
rule @CallString(@Cons(V:Val,@Nil)) => @ToString(V)
rule @CallString(@Nil) => ""

// 15.5.2.1 new String ( [ value ] )

rule %new(%var("String"), Es:Exps) => @NewString(Es)

syntax K /* Oid */ ::= "@NewString" "(" K /* Vals */ ")" [seqstrict(1)]
rule @NewString(@Cons(V:Val,@Nil)) => @NewStringAux(@ToString(V))
rule @NewString(@Nil) => @NewStringAux("")

syntax K /* Oid */ ::= "@NewStringAux" "(" K /* String */ ")" [seqstrict(1)]
rule <k> @NewStringAux(S:String) => @o(N) ... </k>
     <objs>
       (. => <obj>
               <oid> @o(N) </oid>
               <properties> .Map
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

rule @Call(@("String.prototype.toString"), S:String, @Nil) => S
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
rule @Call(@("String.prototype.toString"), V:Val, @Nil) => @Escape(@TypeError)
     when @IsString(V) ==K false andBool @IsOid(V) ==K false

// 15.5.4.3 String.prototype.valueOf ( )

rule @Call(@("String.prototype.valueOf"), S:String, @Nil) => S
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
rule @Call(@("String.prototype.valueOf"), V:Val, @Nil) => @Escape(@TypeError)
     when @IsString(V) ==K false andBool @IsOid(V) ==K false

// 15.6 Boolean Objects

// 15.6.1.1 Boolean (value)

rule %call(%var("Boolean"),Es:Exps) => @CallBoolean(Es)

syntax K /* Boolean */ ::= "@CallBoolean" "(" K /* Vals */ ")" [seqstrict(1)]
rule @CallBoolean(@Cons(V:Val,@Nil)) => @ToBoolean(V)

// 15.6.2.1 new Boolean (value)

rule %new(%var("Boolean"),Es:Exps) => @NewBoolean(Es)

syntax K /* Oid */ ::= "@NewBoolean" "(" K /* Vals */ ")" [seqstrict(1)]
rule @NewBoolean(@Cons(V:Val,@Nil)) => @NewBooleanAux(@ToBoolean(V))

syntax K /* Oid */ ::= "@NewBooleanAux" "(" K /* Bool */ ")" [seqstrict(1)]
rule <k> @NewBooleanAux(B:Bool) => @o(N) ... </k>
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

rule @Call(@("Boolean.prototype.toString"), B:Bool, @Nil) => @ToString(B)
rule <k> @Call(@("Boolean.prototype.toString"), O:Oid,     @Nil) => @ToString(B) ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "Class" |-> "Boolean"
         "PrimitiveValue" |-> B:Bool
         _
       </internalProperties>
       _
     </obj>
rule @Call(@("Boolean.prototype.toString"), V:Val, @Nil) => @Escape(@TypeError)
     when @IsBool(V) ==K false andBool @IsOid(V) ==K false

// 15.6.4.3 Boolean.prototype.valueOf ( )

rule @Call(@("Boolean.prototype.valueOf"), B:Bool, @Nil) => B
rule <k> @Call(@("Boolean.prototype.valueOf"), O:Oid,     @Nil) => B ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "Class" |-> "Boolean"
         "PrimitiveValue" |-> B:Bool
         _
       </internalProperties>
       _
     </obj>
rule @Call(@("Boolean.prototype.valueOf"), V:Val, @Nil) => @Escape(@TypeError)
     when @IsBool(V) ==K false andBool @IsOid(V) ==K false

// 15.7 Number Objects

// 15.7.1.1 Number ( [ value ] )

rule %call(%var("Number"), Es:Exps) => @CallNumber(Es)

syntax K /* Number */ ::= "@CallNumber" "(" K /* Vals */ ")" [seqstrict(1)]
rule @CallNumber(@Cons(V:Val,@Nil)) => @ToNumber(V)
rule @CallNumber(@Nil) => 0

// 15.7.2.1 new Number ( [ value ] )

rule %new(%var("Number"), Es:Exps) => @NewNumber(Es)

syntax K /* Oid */ ::= "@NewNumber" "(" K /* Val */ ")" [seqstrict(1)]
rule @NewNumber(@Cons(V:Val,@Nil)) => @NewNumberAux(@ToNumber(V))
rule @NewNumber(@Nil) => @NewNumberAux(0)

syntax K /* Oid */ ::= "@NewNumberAux" "(" K /* Bool */ ")" [seqstrict(1)]
rule <k> @NewNumberAux(V:Number) => @o(N) ... </k>
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

// 15.8 The Math Object
// TODO:

// 15.9 Date Objects
// TODO:

// 15.10 RegExp (RegularExpression) Objects
// TODO:

// 15.11 ErrorObjects
// TODO:

// 15.11.6 Native Error Types Used in This Standard
// TODO: HACK:
syntax Val ::= "@EvalError"
syntax Val ::= "@RangeError"
syntax Val ::= "@ReferenceError"
syntax Val ::= "@SyntaxError"
syntax Val ::= "@TypeError"
syntax Val ::= "@URIError"

// 15.12 The JSON Object
// TODO:

//////////////////////////////////////////////////////////////////////////////
// Pseudo-code evaluation
//////////////////////////////////////////////////////////////////////////////

syntax PseudoCodes ::= PseudoCode PseudoCodes
                     | PseudoCode
syntax PseudoCode  ::= "%Let" Id "=" K ";" [seqstrict(2)]
                     | "%Do"  K ";"
                     | "%DoI" K ";"
                     | "%If" K "=" K "then" "{" PseudoCodes "}" "else" "{" PseudoCodes "}" [seqstrict(1,2)]
                     | "%Return" K ";" [seqstrict(1)]
                     | "%Return"   ";"
                     | "%Try" K ";"
syntax Exp ::= Id

rule PC:PseudoCode PCs:PseudoCodes => PC ~> PCs
rule %Let X:Id = V:KResult; ~> PCs:PseudoCodes => PCs[V / X]
rule %Do  K; => K
rule %DoI K; => K ~> @Ignore
rule %If V1:Val = V2:Val then { PCs } else { _   } => PCs when V1 ==K  V2
rule %If V1:Val = V2:Val then { _   } else { PCs } => PCs when V1 =/=K V2
rule %Return V:KResult; => V
rule %Return; => .K

rule <k> (%Try E; => E ~> @ExitTry) ~> K </k>
     <excStack> (. => @exc(K)) _ </excStack>

syntax K ::= "@ExitTry"
rule <k> V:Val ~> @ExitTry => V ... </k>
     <excStack> (@exc(_) => .) _ </excStack>

syntax K ::= "@Escape" "(" Val ")"
rule <k> @Escape(V:Val) ~> _ => @Throw(V) ~> K </k>
     <excStack> (@exc(K) => .) _ </excStack>

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

syntax Exp ::= Exp /* PropertyDescriptor */ "." Var [function]
rule @desc(X |-> V:Val _) . X => V
rule @desc(M:Map        ) . X => @Undefined when notBool(X in keys(M))

syntax Map ::= "@AddMap" "(" K "," K "," Map ")" [function]
rule @AddMap(X, V,           M:Map) => (X |-> V) M when notBool(X in keys(M))
rule @AddMap(X, V, (X |-> _) M:Map) => (X |-> V) M when notBool(X in keys(M))

context %print(HOLE)
rule %print(V:Val) => @Print(@ToString(V))
syntax K ::= "@Print" "(" K ")" [seqstrict(1)]
rule <k> @Print(S:String) => @Normal ...</k>
     <out> ... (. => ListItem(S)) </out>

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

rule %pre(%minus, I:Int) => 0 -Int I
rule %pre(%bang,  T:Bool) => notBool(T)
rule %bop(%times, I1:Int, I2:Int) => I1 *Int I2
rule %bop(%div,   I1:Int, I2:Int) => I1 /Int I2 when I2 =/=K 0
rule %bop(%mod,   I1:Int, I2:Int) => I1 %Int I2 when I2 =/=K 0
rule %bop(%minus, I1:Int, I2:Int) => I1 -Int I2
rule %bop(%lt,    I1:Int, I2:Int) => I1 <Int I2
rule %bop(%gt,    I1:Int, I2:Int) => I1 >Int I2
rule %bop(%le,    I1:Int, I2:Int) => I1 <=Int I2
rule %bop(%ge,    I1:Int, I2:Int) => I1 >=Int I2
rule %bop(%eq,    V1:Val, V2:Val) => V1 ==K V2
rule %bop(%neq,   V1:Val, V2:Val) => V1 =/=K V2
rule %bop(%and,   true  , E:Exp ) => E
rule %bop(%and,   false , _     ) => false
rule %bop(%or,    true  , _     ) => true
rule %bop(%or,    false , E:Exp ) => E
// TODO: other cases

syntax Bool ::= "@IsStrict" "(" Stmt ")" [function]
rule @IsStrict(%seq(%exp(%con("use strict")),_)) => true
rule @IsStrict(%seq(%exp(%con(C:String    )),S)) => @IsStrict(S) when C =/=K "use strict"
rule @IsStrict(%seq(%exp(%con(_:Float     )),_)) => false
rule @IsStrict(%seq(%exp(%con(_:Int       )),_)) => false
rule @IsStrict(%seq(%exp(%con(_:Bool      )),_)) => false
rule @IsStrict(%seq(%exp(%con(%null       )),_)) => false
rule @IsStrict(%seq(%exp(%con(%this       )),_)) => false
rule @IsStrict(%seq(%exp(E                 ),_)) => false when getKLabel(E) =/=KLabel '%con`(_`)
rule @IsStrict(%seq(S                       ,_)) => false when getKLabel(S) =/=KLabel '%exp`(_`)
//
rule @IsStrict(%emptyStmt                      ) => false
rule @IsStrict(S:Stmt                          ) => false when getKLabel(S) =/=KLabel '%seq`(_`,_`) // NOTE: Even if the only statement is "use strict", it cannot affect in any way.
                                                       andBool getKLabel(S) =/=KLabel '%emptyStmt
//
/* TODO: We can define as follows once the otherwise case is supported
rule @IsStrict(%seq(%exp(%con("use strict")),_)) => true
rule @IsStrict(%seq(%exp(%con(_:String    )),S)) => @IsStrict(S)
rule @IsStrict(%seq(_                       ,_)) => false
*/

endmodule
