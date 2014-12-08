           require "builtins/mint.k"
           //require "modules/substitution.k"
           require "modules/k-functional-visitor.k"
           require "js-trans.k"
           require "js-str-numeric-literal.k"
           
           module JS-SYNTAX
           imports JS-ORIG-SYNTAX
           imports JS-STR-NUMERIC-LITERAL
           endmodule
           
           module JS
           
           imports MINT
           //imports SUBSTITUTION
           imports K-FUNCTIONAL-VISITOR
           imports JS-SYNTAX
           imports JS-TRANS
           
           //////////////////////////////////////////////////////////////////////////////
           // Configuration
           //////////////////////////////////////////////////////////////////////////////
           
           syntax KItem ::= "@Run" "(" Stmt ")"
     6835  rule @Run(Pgm:Stmt) => @EnterGlobalCode(Pgm) ~> Pgm
           
           configuration
           <T>
             <k> @InitConfig ~> @LoadConfig ~> @RegisterAPIs ~> @Run(^SourceElements($PGM:SourceElements)) </k>
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
                   <thisBinding> .K </thisBinding> // Oid + Undefined
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
           syntax KItem ::= "@active" "(" RunningCellFragment ")"
           
           // <excStack>
           syntax KItem ::= "@excTC"  "(" Var "," Stmt ","          K "," CtrlCellFragment ")"
                             | "@excTF"  "("                  Stmt "," K "," CtrlCellFragment ")"
                             | "@excTCF" "(" Var "," Stmt "," Stmt "," K "," CtrlCellFragment ")"
           
           // <pseudoStack>
           syntax KItem ::= "@pseudo" "(" K ")"
           
           //////////////////////////////////////////////////////////////////////////////
           // Values
           //////////////////////////////////////////////////////////////////////////////
           
           // KResult            8    Types
           // Undefined         8.1  The Undefined Type
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
           syntax Val  ::= UndefinedType // "Undefined" // 8.1 The Undefined Type
                         | NullType // "@NullVal" // 8.2 The Null Type
                         | Primitive
                         | Oid
                       //| Reference // NOTE: We made it using isVal
           // 8.6 The Object Type
           syntax Oid  ::= "@o" "(" Int ")"
                         | "@NullOid"
           // 8.11 The Lexical Environment and Environment Record Specification Types
           syntax Eid  ::= "@e" "(" Int ")"
                         | "@NullEid"
           
           syntax UndefinedType ::= "Undefined" // 8.1 The Undefined Type
           syntax NullType ::= "@NullVal" // 8.2 The Null Type
           
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
     2674  syntax KItem                    ::= "@Throw"    "(" K /* Val */ ")" [seqstrict(1)] // NOTE: @Throw is no longer a completion type. Rather, we use another exception handling mechanism.
           
           syntax KResult ::= CompletionType
           syntax Stmt    ::= CompletionType
           
           // TODO: check if we can describe without following
           syntax KResult ::= "@m" "(" Map ")"
           syntax KResult ::= "@s" "(" Set ")"
           
           //////////////////////////////////////////////////////////////////////////////
           // Initializing Configuration
           //////////////////////////////////////////////////////////////////////////////
           
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
     6835  rule <k> @InitConfig => . ... </k>
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
           
           syntax KItem /* .K */ ::= "@LoadConfig"
     6835  rule <k> @LoadConfig => . ... </k>
           <objs> ( _ =>
                   <obj>
                       <oid>
                           @ArrayOid
                       </oid>
                       <properties>
                           "isArray" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 67 )
                               "Writable" |-> true )
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                           "prototype" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ArrayProtoOid
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Extensible" |-> true
                           "Prototype" |-> @FunctionProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @ArrayProtoOid
                       </oid>
                       <properties>
                           "concat" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 73 )
                               "Writable" |-> true )
                           "constructor" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ArrayOid
                               "Writable" |-> true )
                           "every" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 97 )
                               "Writable" |-> true )
                           "filter" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 105 )
                               "Writable" |-> true )
                           "forEach" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 101 )
                               "Writable" |-> true )
                           "indexOf" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 93 )
                               "Writable" |-> true )
                           "join" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 75 )
                               "Writable" |-> true )
                           "lastIndexOf" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 95 )
                               "Writable" |-> true )
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> true )
                           "map" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 103 )
                               "Writable" |-> true )
                           "pop" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 77 )
                               "Writable" |-> true )
                           "push" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 79 )
                               "Writable" |-> true )
                           "reduce" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 107 )
                               "Writable" |-> true )
                           "reduceRight" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 109 )
                               "Writable" |-> true )
                           "reverse" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 81 )
                               "Writable" |-> true )
                           "shift" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 83 )
                               "Writable" |-> true )
                           "slice" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 85 )
                               "Writable" |-> true )
                           "some" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 99 )
                               "Writable" |-> true )
                           "sort" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 87 )
                               "Writable" |-> true )
                           "splice" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 89 )
                               "Writable" |-> true )
                           "toLocaleString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 71 )
                               "Writable" |-> true )
                           "toString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 69 )
                               "Writable" |-> true )
                           "unshift" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 91 )
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Array"
                           "Extensible" |-> true
                           "Prototype" |-> @ObjectProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @BooleanOid
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                           "prototype" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @BooleanProtoOid
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Extensible" |-> true
                           "Prototype" |-> @FunctionProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @BooleanProtoOid
                       </oid>
                       <properties>
                           "constructor" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @BooleanOid
                               "Writable" |-> true )
                           "toString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 151 )
                               "Writable" |-> true )
                           "valueOf" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 153 )
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Boolean"
                           "Extensible" |-> true
                           "PrimitiveValue" |-> false
                           "Prototype" |-> @ObjectProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @DateOid
                       </oid>
                       <properties>
                           "UTC" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.UTC" )
                               "Writable" |-> true )
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 7
                               "Writable" |-> false )
                           "now" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.now" )
                               "Writable" |-> true )
                           "parse" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.parse" )
                               "Writable" |-> true )
                           "prototype" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @DateProtoOid
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Extensible" |-> true
                           "Prototype" |-> @FunctionProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @DateProtoOid
                       </oid>
                       <properties>
                           "constructor" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @DateOid
                               "Writable" |-> true )
                           "getDate" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.getDate" )
                               "Writable" |-> true )
                           "getDay" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.getDay" )
                               "Writable" |-> true )
                           "getFullYear" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.getFullYear" )
                               "Writable" |-> true )
                           "getHours" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.getHours" )
                               "Writable" |-> true )
                           "getMilliseconds" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.getMilliseconds" )
                               "Writable" |-> true )
                           "getMinutes" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.getMinutes" )
                               "Writable" |-> true )
                           "getMonth" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.getMonth" )
                               "Writable" |-> true )
                           "getSeconds" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.getSeconds" )
                               "Writable" |-> true )
                           "getTime" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.getTime" )
                               "Writable" |-> true )
                           "getTimezoneOffset" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.getTimezoneOffset" )
                               "Writable" |-> true )
                           "getUTCDate" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.getUTCDate" )
                               "Writable" |-> true )
                           "getUTCDay" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.getUTCDay" )
                               "Writable" |-> true )
                           "getUTCFullYear" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.getUTCFullYear" )
                               "Writable" |-> true )
                           "getUTCHours" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.getUTCHours" )
                               "Writable" |-> true )
                           "getUTCMilliseconds" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.getUTCMilliseconds" )
                               "Writable" |-> true )
                           "getUTCMinutes" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.getUTCMinutes" )
                               "Writable" |-> true )
                           "getUTCMonth" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.getUTCMonth" )
                               "Writable" |-> true )
                           "getUTCSeconds" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.getUTCSeconds" )
                               "Writable" |-> true )
                           "setDate" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.setDate" )
                               "Writable" |-> true )
                           "setFullYear" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.setFullYear" )
                               "Writable" |-> true )
                           "setHours" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.setHours" )
                               "Writable" |-> true )
                           "setMilliseconds" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.setMilliseconds" )
                               "Writable" |-> true )
                           "setMinutes" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.setMinutes" )
                               "Writable" |-> true )
                           "setMonth" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.setMonth" )
                               "Writable" |-> true )
                           "setSeconds" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.setSeconds" )
                               "Writable" |-> true )
                           "setTime" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.setTime" )
                               "Writable" |-> true )
                           "setUTCDate" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.setUTCDate" )
                               "Writable" |-> true )
                           "setUTCFullYear" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.setUTCFullYear" )
                               "Writable" |-> true )
                           "setUTCHours" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.setUTCHours" )
                               "Writable" |-> true )
                           "setUTCMilliseconds" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.setUTCMilliseconds" )
                               "Writable" |-> true )
                           "setUTCMinutes" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.setUTCMinutes" )
                               "Writable" |-> true )
                           "setUTCMonth" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.setUTCMonth" )
                               "Writable" |-> true )
                           "setUTCSeconds" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.setUTCSeconds" )
                               "Writable" |-> true )
                           "toDateString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.toDateString" )
                               "Writable" |-> true )
                           "toISOString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.toISOString" )
                               "Writable" |-> true )
                           "toJSON" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.toJSON" )
                               "Writable" |-> true )
                           "toLocaleDateString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.toLocaleDateString" )
                               "Writable" |-> true )
                           "toLocaleString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.toLocaleString" )
                               "Writable" |-> true )
                           "toLocaleTimeString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.toLocaleTimeString" )
                               "Writable" |-> true )
                           "toString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 203 )
                               "Writable" |-> true )
                           "toTimeString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.toTimeString" )
                               "Writable" |-> true )
                           "toUTCString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Date.prototype.toUTCString" )
                               "Writable" |-> true )
                           "valueOf" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 205 )
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Date"
                           "Extensible" |-> true
                           "PrimitiveValue" |-> @NaN
                           "Prototype" |-> @ObjectProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @ErrorOid
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                           "prototype" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ErrorProtoOid
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Extensible" |-> true
                           "Prototype" |-> @FunctionProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @ErrorProtoOid
                       </oid>
                       <properties>
                           "constructor" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ErrorOid
                               "Writable" |-> true )
                           "message" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> ""
                               "Writable" |-> true )
                           "name" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> "Error"
                               "Writable" |-> true )
                           "toString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 209 )
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Error"
                           "Extensible" |-> true
                           "Prototype" |-> @ObjectProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @EvalErrorOid
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                           "prototype" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @EvalErrorProtoOid
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Extensible" |-> true
                           "Prototype" |-> @FunctionProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @EvalErrorProtoOid
                       </oid>
                       <properties>
                           "constructor" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @EvalErrorOid
                               "Writable" |-> true )
                           "message" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> ""
                               "Writable" |-> true )
                           "name" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> "EvalError"
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Error"
                           "Extensible" |-> true
                           "Prototype" |-> @ErrorProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @FunctionOid
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                           "prototype" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @FunctionProtoOid
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Extensible" |-> true
                           "Prototype" |-> @FunctionProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @FunctionProtoOid
                       </oid>
                       <properties>
                           "apply" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 61 )
                               "Writable" |-> true )
                           "bind" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 65 )
                               "Writable" |-> true )
                           "call" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 63 )
                               "Writable" |-> true )
                           "constructor" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @FunctionOid
                               "Writable" |-> true )
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                           "toString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 59 )
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Extensible" |-> true
                           "Prototype" |-> @ObjectProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @GlobalOid
                       </oid>
                       <properties>
                           "Array" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ArrayOid
                               "Writable" |-> true )
                           "Boolean" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @BooleanOid
                               "Writable" |-> true )
                           "Char2Int" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Char2Int" )
                               "Writable" |-> false )
                           "CharAt" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "CharAt" )
                               "Writable" |-> false )
                           "CheckObjectCoercible" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "CheckObjectCoercible" )
                               "Writable" |-> false )
                           "CurrentTimeMillis" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "CurrentTimeMillis" )
                               "Writable" |-> false )
                           "Date" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @DateOid
                               "Writable" |-> true )
                           "DatePrototypeToString" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "DatePrototypeToString" )
                               "Writable" |-> false )
                           "DefineOwnProperty" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "DefineOwnProperty" )
                               "Writable" |-> false )
                           "Error" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ErrorOid
                               "Writable" |-> true )
                           "EvalError" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @EvalErrorOid
                               "Writable" |-> true )
                           "FindString" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "FindString" )
                               "Writable" |-> false )
                           "FromPropertyDescriptor" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "FromPropertyDescriptor" )
                               "Writable" |-> false )
                           "Function" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @FunctionOid
                               "Writable" |-> true )
                           "FunctionPrototypeApply" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "FunctionPrototypeApply" )
                               "Writable" |-> false )
                           "FunctionPrototypeBind" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "FunctionPrototypeBind" )
                               "Writable" |-> false )
                           "FunctionPrototypeToString" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "FunctionPrototypeToString" )
                               "Writable" |-> false )
                           "GetInternalProperty" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "GetInternalProperty" )
                               "Writable" |-> false )
                           "GetOwnProperty" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "GetOwnProperty" )
                               "Writable" |-> false )
                           "Infinity" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @+Infinity
                               "Writable" |-> false )
                           "Int2Char" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Int2Char" )
                               "Writable" |-> false )
                           "IsCallable" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "IsCallable" )
                               "Writable" |-> false )
                           "IsFunction" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "IsFunction" )
                               "Writable" |-> false )
                           "IsNaN" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "IsNaN" )
                               "Writable" |-> false )
                           "IsNegativeZero" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "IsNegativeZero" )
                               "Writable" |-> false )
                           "IsObject" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "IsObject" )
                               "Writable" |-> false )
                           "IsPositiveZero" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "IsPositiveZero" )
                               "Writable" |-> false )
                           "JSON" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @JSONOid
                               "Writable" |-> true )
                           "LengthString" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "LengthString" )
                               "Writable" |-> false )
                           "Math" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @MathOid
                               "Writable" |-> true )
                           "MathFloor" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "MathFloor" )
                               "Writable" |-> false )
                           "MathPow" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "MathPow" )
                               "Writable" |-> false )
                           "MathSin" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "MathSin" )
                               "Writable" |-> false )
                           "NaN" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @NaN
                               "Writable" |-> false )
                           "NoConstructor" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "NoConstructor" )
                               "Writable" |-> false )
                           "Number" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @NumberOid
                               "Writable" |-> true )
                           "NumberPrototypeToFixed" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "NumberPrototypeToFixed" )
                               "Writable" |-> false )
                           "NumberToString" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "NumberToString" )
                               "Writable" |-> false )
                           "Object" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ObjectOid
                               "Writable" |-> true )
                           "ObjectGetOwnPropertyNames" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "ObjectGetOwnPropertyNames" )
                               "Writable" |-> false )
                           "Print" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Print" )
                               "Writable" |-> false )
                           "RangeError" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @RangeErrorOid
                               "Writable" |-> true )
                           "ReferenceError" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ReferenceErrorOid
                               "Writable" |-> true )
                           "RegExp" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @RegExpOid
                               "Writable" |-> true )
                           "SetInternalProperty" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "SetInternalProperty" )
                               "Writable" |-> false )
                           "String" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @StringOid
                               "Writable" |-> true )
                           "SubstrString" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "SubstrString" )
                               "Writable" |-> false )
                           "SyntaxError" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @SyntaxErrorOid
                               "Writable" |-> true )
                           "ToInteger" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "ToInteger" )
                               "Writable" |-> false )
                           "ToNumber" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "ToNumber" )
                               "Writable" |-> false )
                           "ToObject" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "ToObject" )
                               "Writable" |-> false )
                           "ToPropertyDescriptor" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "ToPropertyDescriptor" )
                               "Writable" |-> false )
                           "ToString" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "ToString" )
                               "Writable" |-> false )
                           "ToUint16" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "ToUint16" )
                               "Writable" |-> false )
                           "ToUint32" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "ToUint32" )
                               "Writable" |-> false )
                           "Trim" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ ( "Trim" )
                               "Writable" |-> false )
                           "TypeError" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @TypeErrorOid
                               "Writable" |-> true )
                           "URIError" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @URIErrorOid
                               "Writable" |-> true )
                           "console" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> true
                               "Value" |-> @oo ( 1 )
                               "Writable" |-> true )
                           "decodeURI" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 13 )
                               "Writable" |-> true )
                           "decodeURIComponent" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 15 )
                               "Writable" |-> true )
                           "encodeURI" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 17 )
                               "Writable" |-> true )
                           "encodeURIComponent" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 19 )
                               "Writable" |-> true )
                           "eval" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "eval_i" )
                               "Writable" |-> true )
                           "isFinite" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 11 )
                               "Writable" |-> true )
                           "isNaN" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 9 )
                               "Writable" |-> true )
                           "parseFloat" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 7 )
                               "Writable" |-> true )
                           "parseInt" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 5 )
                               "Writable" |-> true )
                           "undefined" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> Undefined
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Object"
                           "Extensible" |-> true
                           "Prototype" |-> @ObjectProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @JSONOid
                       </oid>
                       <properties>
                           "parse" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "parse" )
                               "Writable" |-> true )
                           "stringify" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "stringify" )
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "JSON"
                           "Extensible" |-> true
                           "Prototype" |-> @ObjectProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @MathOid
                       </oid>
                       <properties>
                           "E" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 2.7182818284590451e+00
                               "Writable" |-> false )
                           "LN2" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 6.9314718055994529e-01
                               "Writable" |-> false )
                           "LN10" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 2.3025850929940459e+00
                               "Writable" |-> false )
                           "LOG2E" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1.4426950408889634e+00
                               "Writable" |-> false )
                           "LOG10E" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 4.3429448190325182e-01
                               "Writable" |-> false )
                           "PI" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 3.1415926535897931e+00
                               "Writable" |-> false )
                           "SQRT1_2" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 7.0710678118654757e-01
                               "Writable" |-> false )
                           "SQRT2" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1.4142135623730951e+00
                               "Writable" |-> false )
                           "abs" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 167 )
                               "Writable" |-> true )
                           "acos" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 169 )
                               "Writable" |-> true )
                           "asin" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 171 )
                               "Writable" |-> true )
                           "atan2" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 175 )
                               "Writable" |-> true )
                           "atan" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 173 )
                               "Writable" |-> true )
                           "ceil" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 177 )
                               "Writable" |-> true )
                           "cos" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 179 )
                               "Writable" |-> true )
                           "exp" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 181 )
                               "Writable" |-> true )
                           "floor" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 183 )
                               "Writable" |-> true )
                           "log" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 185 )
                               "Writable" |-> true )
                           "max" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 187 )
                               "Writable" |-> true )
                           "min" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 189 )
                               "Writable" |-> true )
                           "pow" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 191 )
                               "Writable" |-> true )
                           "random" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 193 )
                               "Writable" |-> true )
                           "round" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 195 )
                               "Writable" |-> true )
                           "sin" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 197 )
                               "Writable" |-> true )
                           "sqrt" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 199 )
                               "Writable" |-> true )
                           "tan" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 201 )
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Math"
                           "Extensible" |-> true
                           "Prototype" |-> @ObjectProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @NumberOid
                       </oid>
                       <properties>
                           "MAX_VALUE" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1.7976931348623157e+308
                               "Writable" |-> false )
                           "MIN_VALUE" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 4.9406564584124654e-324
                               "Writable" |-> false )
                           "NEGATIVE_INFINITY" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @-Infinity
                               "Writable" |-> false )
                           "NaN" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @NaN
                               "Writable" |-> false )
                           "POSITIVE_INFINITY" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @+Infinity
                               "Writable" |-> false )
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                           "prototype" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @NumberProtoOid
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Extensible" |-> true
                           "Prototype" |-> @FunctionProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @NumberProtoOid
                       </oid>
                       <properties>
                           "constructor" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @NumberOid
                               "Writable" |-> true )
                           "toExponential" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 163 )
                               "Writable" |-> true )
                           "toFixed" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 161 )
                               "Writable" |-> true )
                           "toLocaleString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 157 )
                               "Writable" |-> true )
                           "toPrecision" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 165 )
                               "Writable" |-> true )
                           "toString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 155 )
                               "Writable" |-> true )
                           "valueOf" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 159 )
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Number"
                           "Extensible" |-> true
                           "PrimitiveValue" |-> 0
                           "Prototype" |-> @ObjectProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @ObjectOid
                       </oid>
                       <properties>
                           "create" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 27 )
                               "Writable" |-> true )
                           "defineProperties" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 31 )
                               "Writable" |-> true )
                           "defineProperty" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 29 )
                               "Writable" |-> true )
                           "freeze" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 35 )
                               "Writable" |-> true )
                           "getOwnPropertyDescriptor" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 23 )
                               "Writable" |-> true )
                           "getOwnPropertyNames" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 25 )
                               "Writable" |-> true )
                           "getPrototypeOf" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 21 )
                               "Writable" |-> true )
                           "isExtensible" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 43 )
                               "Writable" |-> true )
                           "isFrozen" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 41 )
                               "Writable" |-> true )
                           "isSealed" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 39 )
                               "Writable" |-> true )
                           "keys" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 45 )
                               "Writable" |-> true )
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                           "preventExtensions" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 37 )
                               "Writable" |-> true )
                           "prototype" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ObjectProtoOid
                               "Writable" |-> false )
                           "seal" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 33 )
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Extensible" |-> true
                           "Prototype" |-> @FunctionProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @ObjectProtoOid
                       </oid>
                       <properties>
                           "constructor" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ObjectOid
                               "Writable" |-> true )
                           "hasOwnProperty" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 53 )
                               "Writable" |-> true )
                           "isPrototypeOf" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 55 )
                               "Writable" |-> true )
                           "propertyIsEnumerable" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 57 )
                               "Writable" |-> true )
                           "toLocaleString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 49 )
                               "Writable" |-> true )
                           "toString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 47 )
                               "Writable" |-> true )
                           "valueOf" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 51 )
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Object"
                           "Extensible" |-> true
                           "Prototype" |-> @NullOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @RangeErrorOid
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                           "prototype" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @RangeErrorProtoOid
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Extensible" |-> true
                           "Prototype" |-> @FunctionProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @RangeErrorProtoOid
                       </oid>
                       <properties>
                           "constructor" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @RangeErrorOid
                               "Writable" |-> true )
                           "message" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> ""
                               "Writable" |-> true )
                           "name" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> "RangeError"
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Error"
                           "Extensible" |-> true
                           "Prototype" |-> @ErrorProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @ReferenceErrorOid
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                           "prototype" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @ReferenceErrorProtoOid
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Extensible" |-> true
                           "Prototype" |-> @FunctionProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @ReferenceErrorProtoOid
                       </oid>
                       <properties>
                           "constructor" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ReferenceErrorOid
                               "Writable" |-> true )
                           "message" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> ""
                               "Writable" |-> true )
                           "name" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> "ReferenceError"
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Error"
                           "Extensible" |-> true
                           "Prototype" |-> @ErrorProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @RegExpOid
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 2
                               "Writable" |-> false )
                           "prototype" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @RegExpProtoOid
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Extensible" |-> true
                           "Prototype" |-> @FunctionProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @RegExpProtoOid
                       </oid>
                       <properties>
                           "constructor" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @RegExpOid
                               "Writable" |-> true )
                           "exec" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 207 )
                               "Writable" |-> true )
                           "global" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> false
                               "Writable" |-> false )
                           "ignoreCase" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> false
                               "Writable" |-> false )
                           "lastIndex" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> true )
                           "multiline" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> false
                               "Writable" |-> false )
                           "source" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> ""
                               "Writable" |-> false )
                           "test" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "RegExp.prototype.test" )
                               "Writable" |-> true )
                           "toString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @ ( "RegExp.prototype.toString" )
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "RegExp"
                           "Extensible" |-> true
                           "Prototype" |-> @ObjectProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @StringOid
                       </oid>
                       <properties>
                           "fromCharCode" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 111 )
                               "Writable" |-> true )
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                           "prototype" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @StringProtoOid
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Extensible" |-> true
                           "Prototype" |-> @FunctionProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @StringProtoOid
                       </oid>
                       <properties>
                           "charAt" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 117 )
                               "Writable" |-> true )
                           "charCodeAt" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 119 )
                               "Writable" |-> true )
                           "concat" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 121 )
                               "Writable" |-> true )
                           "constructor" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @StringOid
                               "Writable" |-> true )
                           "indexOf" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 123 )
                               "Writable" |-> true )
                           "lastIndexOf" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 125 )
                               "Writable" |-> true )
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                           "localeCompare" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 127 )
                               "Writable" |-> true )
                           "match" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 129 )
                               "Writable" |-> true )
                           "replace" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 131 )
                               "Writable" |-> true )
                           "search" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 133 )
                               "Writable" |-> true )
                           "slice" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 135 )
                               "Writable" |-> true )
                           "split" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 137 )
                               "Writable" |-> true )
                           "substring" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 139 )
                               "Writable" |-> true )
                           "toLocaleLowerCase" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 143 )
                               "Writable" |-> true )
                           "toLocaleUpperCase" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 147 )
                               "Writable" |-> true )
                           "toLowerCase" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 141 )
                               "Writable" |-> true )
                           "toString" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 113 )
                               "Writable" |-> true )
                           "toUpperCase" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 145 )
                               "Writable" |-> true )
                           "trim" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 149 )
                               "Writable" |-> true )
                           "valueOf" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 115 )
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "String"
                           "Extensible" |-> true
                           "PrimitiveValue" |-> ""
                           "Prototype" |-> @ObjectProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @SyntaxErrorOid
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                           "prototype" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @SyntaxErrorProtoOid
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Extensible" |-> true
                           "Prototype" |-> @FunctionProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @SyntaxErrorProtoOid
                       </oid>
                       <properties>
                           "constructor" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @SyntaxErrorOid
                               "Writable" |-> true )
                           "message" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> ""
                               "Writable" |-> true )
                           "name" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> "SyntaxError"
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Error"
                           "Extensible" |-> true
                           "Prototype" |-> @ErrorProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @TypeErrorOid
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                           "prototype" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @TypeErrorProtoOid
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Extensible" |-> true
                           "Prototype" |-> @FunctionProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @TypeErrorProtoOid
                       </oid>
                       <properties>
                           "constructor" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @TypeErrorOid
                               "Writable" |-> true )
                           "message" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> ""
                               "Writable" |-> true )
                           "name" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> "TypeError"
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Error"
                           "Extensible" |-> true
                           "Prototype" |-> @ErrorProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @URIErrorOid
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                           "prototype" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @URIErrorProtoOid
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Extensible" |-> true
                           "Prototype" |-> @FunctionProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @URIErrorProtoOid
                       </oid>
                       <properties>
                           "constructor" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @URIErrorOid
                               "Writable" |-> true )
                           "message" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> ""
                               "Writable" |-> true )
                           "name" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> "URIError"
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Error"
                           "Extensible" |-> true
                           "Prototype" |-> @ErrorProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 1 )
                       </oid>
                       <properties>
                           "log" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> true
                               "Value" |-> @oo ( 3 )
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Object"
                           "Extensible" |-> true
                           "Prototype" |-> @ObjectProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 2 )
                       </oid>
                       <properties>
                           "constructor" |-> @desc ( 
                               "Configurable" |-> true
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 3 )
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Object"
                           "Extensible" |-> true
                           "Prototype" |-> @ObjectProtoOid
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 3 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                           "prototype" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> @oo ( 2 )
                               "Writable" |-> true )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %exp ( %call ( %var ( "Print" ) , %cons ( %call ( 
                             %var ( "ToString" ) , %cons ( %var ( "v" ) , %nil ) ) , %nil
                              ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "v" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 5 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 2
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( "NotImplemented: parseInt" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "string" ) , %cons ( 
                             %var ( "radix" ) , %nil ) )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 7 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( "NotImplemented: parseFloat" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "string" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 9 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %return ( %call ( %var ( "IsNaN" ) , %cons ( %call 
                             ( %var ( "ToNumber" ) , %cons ( %var ( "number" ) , %nil ) )
                              , %nil ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "number" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 11 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %seq ( %vdecl ( "n" ) , %exp ( %bop ( 
                             %assign , %var ( "n" ) , %call ( %var ( "ToNumber" ) , %cons
                              ( %var ( "number" ) , %nil ) ) ) ) ) , %return ( %pre ( 
                             %bang , %bop ( %or , %bop ( %or , %call ( %var ( "IsNaN" ) ,
                              %cons ( %var ( "n" ) , %nil ) ) , %bop ( %eqs , %var ( "n" 
                             ) , %pre ( %plus , %var ( "Infinity" ) ) ) ) , %bop ( %eqs ,
                              %var ( "n" ) , %pre ( %minus , %var ( "Infinity" ) ) ) ) ) 
                             ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "number" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 13 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( "NotImplemented: decodeURI" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "encodedURI" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 15 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: decodeURIComponent" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "encodedURIComponent" ) 
                             , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 17 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( "NotImplemented: encodeURI" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "uri" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 19 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: encodeURIComponent" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "uriComponent" ) , %nil 
                             )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 21 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsObject" ) , %cons ( %var ( "O" ) , %nil ) ) ) , %throw ( 
                             %call ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Invalid arguments: Object.getPrototypeOf" ) , %nil ) ) ) , 
                             %emptyStmt ) , %return ( %call ( %var ( 
                             "GetInternalProperty" ) , %cons ( %var ( "O" ) , %cons ( 
                             %con ( "Prototype" ) , %nil ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "O" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 23 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 2
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsObject" ) , %cons ( %var ( "O" ) , %nil ) ) ) , %throw ( 
                             %call ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Invalid arguments: Object.getOwnPropertyDescriptor" ) , 
                             %nil ) ) ) , %emptyStmt ) , %return ( %call ( %var ( 
                             "FromPropertyDescriptor" ) , %cons ( %call ( %var ( 
                             "GetOwnProperty" ) , %cons ( %var ( "O" ) , %cons ( %call ( 
                             %var ( "ToString" ) , %cons ( %var ( "P" ) , %nil ) ) , %nil
                              ) ) ) , %nil ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "O" ) , %cons ( %var ( 
                             "P" ) , %nil ) )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 25 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsObject" ) , %cons ( %var ( "O" ) , %nil ) ) ) , %throw ( 
                             %call ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Invalid arguments: Object.getOwnPropertyNames" ) , %nil ) )
                              ) , %emptyStmt ) , %return ( %call ( %var ( 
                             "ObjectGetOwnPropertyNames" ) , %cons ( %var ( "O" ) , %nil 
                             ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "O" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 27 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 2
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %bop ( %or , %call ( 
                             %var ( "IsObject" ) , %cons ( %var ( "O" ) , %nil ) ) , %bop
                              ( %eqs , %var ( "O" ) , %con ( %null ) ) ) ) , %throw ( 
                             %call ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Invalid arguments: Object.create" ) , %nil ) ) ) , 
                             %emptyStmt ) , %seq ( %seq ( %vdecl ( "obj" ) , %exp ( %bop 
                             ( %assign , %var ( "obj" ) , %new ( %var ( "Object" ) , %nil
                              ) ) ) ) , %seq ( %exp ( %call ( %var ( 
                             "SetInternalProperty" ) , %cons ( %var ( "obj" ) , %cons ( 
                             %con ( "Prototype" ) , %cons ( %var ( "O" ) , %nil ) ) ) ) )
                              , %seq ( %if ( %bop ( %neqs , %var ( "Properties" ) , %var 
                             ( "undefined" ) ) , %exp ( %call ( %mem ( %var ( "Object" ) 
                             , %con ( "defineProperties" ) ) , %cons ( %var ( "obj" ) , 
                             %cons ( %var ( "Properties" ) , %nil ) ) ) ) , %emptyStmt ) 
                             , %return ( %var ( "obj" ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "O" ) , %cons ( %var ( 
                             "Properties" ) , %nil ) )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 29 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 3
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsObject" ) , %cons ( %var ( "O" ) , %nil ) ) ) , %throw ( 
                             %call ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Invalid arguments: Object.defineProperty" ) , %nil ) ) ) , 
                             %emptyStmt ) , %seq ( %exp ( %call ( %var ( 
                             "DefineOwnProperty" ) , %cons ( %var ( "O" ) , %cons ( %call
                              ( %var ( "ToString" ) , %cons ( %var ( "P" ) , %nil ) ) , 
                             %cons ( %call ( %var ( "ToPropertyDescriptor" ) , %cons ( 
                             %var ( "Attributes" ) , %nil ) ) , %cons ( %con ( true ) , 
                             %nil ) ) ) ) ) ) , %return ( %var ( "O" ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "O" ) , %cons ( %var ( 
                             "P" ) , %cons ( %var ( "Attributes" ) , %nil ) ) )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 31 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 2
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsObject" ) , %cons ( %var ( "O" ) , %nil ) ) ) , %throw ( 
                             %call ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Invalid arguments: Object.defineProperties" ) , %nil ) ) ) 
                             , %emptyStmt ) , %seq ( %label ( "" , %forin ( %vdecl ( 
                             "name" ) , %var ( "name" ) , %var ( "Properties" ) , %if ( 
                             %call ( %mem ( %var ( "Properties" ) , %con ( 
                             "hasOwnProperty" ) ) , %cons ( %var ( "name" ) , %nil ) ) , 
                             %exp ( %call ( %mem ( %var ( "Object" ) , %con ( 
                             "defineProperty" ) ) , %cons ( %var ( "O" ) , %cons ( %var (
                              "name" ) , %cons ( %mem ( %var ( "Properties" ) , %var ( 
                             "name" ) ) , %nil ) ) ) ) ) , %emptyStmt ) ) ) , %return ( 
                             %var ( "O" ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "O" ) , %cons ( %var ( 
                             "Properties" ) , %nil ) )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 33 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsObject" ) , %cons ( %var ( "O" ) , %nil ) ) ) , %throw ( 
                             %call ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Invalid arguments: Object.seal" ) , %nil ) ) ) , %emptyStmt
                              ) , %seq ( %seq ( %vdecl ( "names" ) , %exp ( %bop ( 
                             %assign , %var ( "names" ) , %call ( %mem ( %var ( "Object" 
                             ) , %con ( "getOwnPropertyNames" ) ) , %cons ( %var ( "O" ) 
                             , %nil ) ) ) ) ) , %seq ( %label ( "" , %for ( %seq ( %vdecl
                              ( "i" ) , %exp ( %bop ( %assign , %var ( "i" ) , %con ( 0 )
                              ) ) ) , %bop ( %lt , %var ( "i" ) , %mem ( %var ( "names" )
                              , %con ( "length" ) ) ) , %pre ( %inc , %var ( "i" ) ) , 
                             %seq ( %seq ( %vdecl ( "desc" ) , %exp ( %bop ( %assign , 
                             %var ( "desc" ) , %call ( %mem ( %var ( "Object" ) , %con ( 
                             "getOwnPropertyDescriptor" ) ) , %cons ( %var ( "O" ) , 
                             %cons ( %mem ( %var ( "names" ) , %var ( "i" ) ) , %nil ) ) 
                             ) ) ) ) , %seq ( %exp ( %bop ( %assign , %mem ( %var ( 
                             "desc" ) , %con ( "configurable" ) ) , %con ( false ) ) ) , 
                             %exp ( %call ( %mem ( %var ( "Object" ) , %con ( 
                             "defineProperty" ) ) , %cons ( %var ( "O" ) , %cons ( %mem (
                              %var ( "names" ) , %var ( "i" ) ) , %cons ( %var ( "desc" )
                              , %nil ) ) ) ) ) ) ) ) ) , %seq ( %exp ( %call ( %var ( 
                             "SetInternalProperty" ) , %cons ( %var ( "O" ) , %cons ( 
                             %con ( "Extensible" ) , %cons ( %con ( false ) , %nil ) ) ) 
                             ) ) , %return ( %var ( "O" ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "O" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 35 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsObject" ) , %cons ( %var ( "O" ) , %nil ) ) ) , %throw ( 
                             %call ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Invalid arguments: Object.freeze" ) , %nil ) ) ) , 
                             %emptyStmt ) , %seq ( %seq ( %vdecl ( "names" ) , %exp ( 
                             %bop ( %assign , %var ( "names" ) , %call ( %mem ( %var ( 
                             "Object" ) , %con ( "getOwnPropertyNames" ) ) , %cons ( %var
                              ( "O" ) , %nil ) ) ) ) ) , %seq ( %label ( "" , %for ( %seq
                              ( %vdecl ( "i" ) , %exp ( %bop ( %assign , %var ( "i" ) , 
                             %con ( 0 ) ) ) ) , %bop ( %lt , %var ( "i" ) , %mem ( %var (
                              "names" ) , %con ( "length" ) ) ) , %pre ( %inc , %var ( 
                             "i" ) ) , %seq ( %seq ( %vdecl ( "desc" ) , %exp ( %bop ( 
                             %assign , %var ( "desc" ) , %call ( %mem ( %var ( "Object" )
                              , %con ( "getOwnPropertyDescriptor" ) ) , %cons ( %var ( 
                             "O" ) , %cons ( %mem ( %var ( "names" ) , %var ( "i" ) ) , 
                             %nil ) ) ) ) ) ) , %seq ( %if ( %bop ( %or , %call ( %mem ( 
                             %var ( "desc" ) , %con ( "hasOwnProperty" ) ) , %cons ( %con
                              ( "value" ) , %nil ) ) , %call ( %mem ( %var ( "desc" ) , 
                             %con ( "hasOwnProperty" ) ) , %cons ( %con ( "writable" ) , 
                             %nil ) ) ) , %exp ( %bop ( %assign , %mem ( %var ( "desc" ) 
                             , %con ( "writable" ) ) , %con ( false ) ) ) , %emptyStmt ) 
                             , %seq ( %exp ( %bop ( %assign , %mem ( %var ( "desc" ) , 
                             %con ( "configurable" ) ) , %con ( false ) ) ) , %exp ( 
                             %call ( %mem ( %var ( "Object" ) , %con ( "defineProperty" )
                              ) , %cons ( %var ( "O" ) , %cons ( %mem ( %var ( "names" ) 
                             , %var ( "i" ) ) , %cons ( %var ( "desc" ) , %nil ) ) ) ) ) 
                             ) ) ) ) ) , %seq ( %exp ( %call ( %var ( 
                             "SetInternalProperty" ) , %cons ( %var ( "O" ) , %cons ( 
                             %con ( "Extensible" ) , %cons ( %con ( false ) , %nil ) ) ) 
                             ) ) , %return ( %var ( "O" ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "O" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 37 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsObject" ) , %cons ( %var ( "O" ) , %nil ) ) ) , %throw ( 
                             %call ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Invalid arguments: Object.preventExtensions" ) , %nil ) ) )
                              , %emptyStmt ) , %seq ( %exp ( %call ( %var ( 
                             "SetInternalProperty" ) , %cons ( %var ( "O" ) , %cons ( 
                             %con ( "Extensible" ) , %cons ( %con ( false ) , %nil ) ) ) 
                             ) ) , %return ( %var ( "O" ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "O" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 39 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsObject" ) , %cons ( %var ( "O" ) , %nil ) ) ) , %throw ( 
                             %call ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Invalid arguments: Object.isSealed" ) , %nil ) ) ) , 
                             %emptyStmt ) , %seq ( %seq ( %vdecl ( "names" ) , %exp ( 
                             %bop ( %assign , %var ( "names" ) , %call ( %mem ( %var ( 
                             "Object" ) , %con ( "getOwnPropertyNames" ) ) , %cons ( %var
                              ( "O" ) , %nil ) ) ) ) ) , %seq ( %label ( "" , %for ( %seq
                              ( %vdecl ( "i" ) , %exp ( %bop ( %assign , %var ( "i" ) , 
                             %con ( 0 ) ) ) ) , %bop ( %lt , %var ( "i" ) , %mem ( %var (
                              "names" ) , %con ( "length" ) ) ) , %pre ( %inc , %var ( 
                             "i" ) ) , %seq ( %seq ( %vdecl ( "desc" ) , %exp ( %bop ( 
                             %assign , %var ( "desc" ) , %call ( %mem ( %var ( "Object" )
                              , %con ( "getOwnPropertyDescriptor" ) ) , %cons ( %var ( 
                             "O" ) , %cons ( %mem ( %var ( "names" ) , %var ( "i" ) ) , 
                             %nil ) ) ) ) ) ) , %if ( %mem ( %var ( "desc" ) , %con ( 
                             "configurable" ) ) , %return ( %con ( false ) ) , %emptyStmt
                              ) ) ) ) , %seq ( %if ( %call ( %var ( "GetInternalProperty"
                              ) , %cons ( %var ( "O" ) , %cons ( %con ( "Extensible" ) , 
                             %nil ) ) ) , %return ( %con ( false ) ) , %emptyStmt ) , 
                             %return ( %con ( true ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "O" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 41 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsObject" ) , %cons ( %var ( "O" ) , %nil ) ) ) , %throw ( 
                             %call ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Invalid arguments: Object.isFrozen" ) , %nil ) ) ) , 
                             %emptyStmt ) , %seq ( %seq ( %vdecl ( "names" ) , %exp ( 
                             %bop ( %assign , %var ( "names" ) , %call ( %mem ( %var ( 
                             "Object" ) , %con ( "getOwnPropertyNames" ) ) , %cons ( %var
                              ( "O" ) , %nil ) ) ) ) ) , %seq ( %label ( "" , %for ( %seq
                              ( %vdecl ( "i" ) , %exp ( %bop ( %assign , %var ( "i" ) , 
                             %con ( 0 ) ) ) ) , %bop ( %lt , %var ( "i" ) , %mem ( %var (
                              "names" ) , %con ( "length" ) ) ) , %pre ( %inc , %var ( 
                             "i" ) ) , %seq ( %seq ( %vdecl ( "desc" ) , %exp ( %bop ( 
                             %assign , %var ( "desc" ) , %call ( %mem ( %var ( "Object" )
                              , %con ( "getOwnPropertyDescriptor" ) ) , %cons ( %var ( 
                             "O" ) , %cons ( %mem ( %var ( "names" ) , %var ( "i" ) ) , 
                             %nil ) ) ) ) ) ) , %seq ( %if ( %bop ( %or , %call ( %mem ( 
                             %var ( "desc" ) , %con ( "hasOwnProperty" ) ) , %cons ( %con
                              ( "value" ) , %nil ) ) , %call ( %mem ( %var ( "desc" ) , 
                             %con ( "hasOwnProperty" ) ) , %cons ( %con ( "writable" ) , 
                             %nil ) ) ) , %if ( %mem ( %var ( "desc" ) , %con ( 
                             "writable" ) ) , %return ( %con ( false ) ) , %emptyStmt ) ,
                              %emptyStmt ) , %if ( %mem ( %var ( "desc" ) , %con ( 
                             "configurable" ) ) , %return ( %con ( false ) ) , %emptyStmt
                              ) ) ) ) ) , %seq ( %if ( %call ( %var ( 
                             "GetInternalProperty" ) , %cons ( %var ( "O" ) , %cons ( 
                             %con ( "Extensible" ) , %nil ) ) ) , %return ( %con ( false 
                             ) ) , %emptyStmt ) , %return ( %con ( true ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "O" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 43 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsObject" ) , %cons ( %var ( "O" ) , %nil ) ) ) , %throw ( 
                             %call ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Invalid arguments: Object.isExtensible" ) , %nil ) ) ) , 
                             %emptyStmt ) , %return ( %call ( %var ( 
                             "GetInternalProperty" ) , %cons ( %var ( "O" ) , %cons ( 
                             %con ( "Extensible" ) , %nil ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "O" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 45 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsObject" ) , %cons ( %var ( "O" ) , %nil ) ) ) , %throw ( 
                             %call ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Invalid arguments: Object.keys" ) , %nil ) ) ) , %emptyStmt
                              ) , %seq ( %seq ( %vdecl ( "names" ) , %exp ( %bop ( 
                             %assign , %var ( "names" ) , %new ( %var ( "Array" ) , %nil 
                             ) ) ) ) , %seq ( %label ( "" , %forin ( %vdecl ( "name" ) , 
                             %var ( "name" ) , %var ( "O" ) , %if ( %call ( %mem ( %var (
                              "O" ) , %con ( "hasOwnProperty" ) ) , %cons ( %var ( "name"
                              ) , %nil ) ) , %exp ( %call ( %mem ( %var ( "names" ) , 
                             %con ( "push" ) ) , %cons ( %var ( "name" ) , %nil ) ) ) , 
                             %emptyStmt ) ) ) , %return ( %var ( "names" ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "O" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 47 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %label ( "" , %switch ( %con ( %this ) , %seq ( 
                             %case ( %var ( "undefined" ) , %return ( %con ( 
                             "[object Undefined]" ) ) ) , %seq ( %case ( %con ( %null ) ,
                              %return ( %con ( "[object Null]" ) ) ) , %emptyStmt ) ) , 
                             %default ( %return ( %bop ( %plus , %bop ( %plus , %con ( 
                             "[object " ) , %call ( %var ( "GetInternalProperty" ) , 
                             %cons ( %call ( %var ( "ToObject" ) , %cons ( %con ( %this )
                              , %nil ) ) , %cons ( %con ( "Class" ) , %nil ) ) ) ) , %con
                              ( "]" ) ) ) ) , %emptyStmt ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 49 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %return ( %call ( %mem ( %call ( %var ( "ToObject" 
                             ) , %cons ( %con ( %this ) , %nil ) ) , %con ( "toString" ) 
                             ) , %nil ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 51 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %return ( %call ( %var ( "ToObject" ) , %cons ( 
                             %con ( %this ) , %nil ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 53 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %seq ( %vdecl ( "desc" ) , %exp ( %bop ( 
                             %assign , %var ( "desc" ) , %call ( %mem ( %var ( "Object" )
                              , %con ( "getOwnPropertyDescriptor" ) ) , %cons ( %call ( 
                             %var ( "ToObject" ) , %cons ( %con ( %this ) , %nil ) ) , 
                             %cons ( %call ( %var ( "ToString" ) , %cons ( %var ( "V" ) ,
                              %nil ) ) , %nil ) ) ) ) ) ) , %seq ( %if ( %bop ( %eqs , 
                             %var ( "desc" ) , %var ( "undefined" ) ) , %return ( %con ( 
                             false ) ) , %emptyStmt ) , %return ( %con ( true ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "V" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 55 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsObject" ) , %cons ( %var ( "V" ) , %nil ) ) ) , %return (
                              %con ( false ) ) , %emptyStmt ) , %seq ( %seq ( %vdecl ( 
                             "o" ) , %exp ( %bop ( %assign , %var ( "o" ) , %call ( %var 
                             ( "ToObject" ) , %cons ( %con ( %this ) , %nil ) ) ) ) ) , 
                             %label ( "" , %while ( %con ( true ) , %seq ( %exp ( %bop ( 
                             %assign , %var ( "V" ) , %call ( %mem ( %var ( "Object" ) , 
                             %con ( "getPrototypeOf" ) ) , %cons ( %var ( "V" ) , %nil ) 
                             ) ) ) , %seq ( %if ( %bop ( %eqs , %var ( "V" ) , %con ( 
                             %null ) ) , %return ( %con ( false ) ) , %emptyStmt ) , %if 
                             ( %bop ( %eqs , %var ( "V" ) , %var ( "o" ) ) , %return ( 
                             %con ( true ) ) , %emptyStmt ) ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "V" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 57 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %seq ( %vdecl ( "desc" ) , %exp ( %bop ( 
                             %assign , %var ( "desc" ) , %call ( %mem ( %var ( "Object" )
                              , %con ( "getOwnPropertyDescriptor" ) ) , %cons ( %call ( 
                             %var ( "ToObject" ) , %cons ( %con ( %this ) , %nil ) ) , 
                             %cons ( %call ( %var ( "ToString" ) , %cons ( %var ( "V" ) ,
                              %nil ) ) , %nil ) ) ) ) ) ) , %seq ( %if ( %bop ( %eqs , 
                             %var ( "desc" ) , %var ( "undefined" ) ) , %return ( %con ( 
                             false ) ) , %emptyStmt ) , %return ( %mem ( %var ( "desc" ) 
                             , %con ( "enumerable" ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "V" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 59 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsFunction" ) , %cons ( %con ( %this ) , %nil ) ) ) , 
                             %throw ( %call ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Invalid arguments: Function.prototype.toString" ) , %nil ) 
                             ) ) , %emptyStmt ) , %return ( %call ( %var ( 
                             "FunctionPrototypeToString" ) , %cons ( %con ( %this ) , 
                             %nil ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 61 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 2
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsFunction" ) , %cons ( %con ( %this ) , %nil ) ) ) , 
                             %throw ( %call ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Invalid arguments: Function.prototype.apply" ) , %nil ) ) )
                              , %emptyStmt ) , %return ( %call ( %var ( 
                             "FunctionPrototypeApply" ) , %cons ( %con ( %this ) , %cons 
                             ( %var ( "thisArg" ) , %cons ( %var ( "argArray" ) , %nil ) 
                             ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "thisArg" ) , %cons ( 
                             %var ( "argArray" ) , %nil ) )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 63 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsFunction" ) , %cons ( %con ( %this ) , %nil ) ) ) , 
                             %throw ( %call ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Invalid arguments: Function.prototype.call" ) , %nil ) ) ) 
                             , %emptyStmt ) , %seq ( %seq ( %vdecl ( "argArray" ) , %exp 
                             ( %bop ( %assign , %var ( "argArray" ) , %arr ( %nil ) ) ) )
                              , %seq ( %label ( "" , %for ( %seq ( %vdecl ( "i" ) , %exp 
                             ( %bop ( %assign , %var ( "i" ) , %con ( 1 ) ) ) ) , %bop ( 
                             %lt , %var ( "i" ) , %mem ( %var ( "arguments" ) , %con ( 
                             "length" ) ) ) , %pre ( %inc , %var ( "i" ) ) , %exp ( %call
                              ( %mem ( %var ( "argArray" ) , %con ( "push" ) ) , %cons ( 
                             %mem ( %var ( "arguments" ) , %var ( "i" ) ) , %nil ) ) ) ) 
                             ) , %return ( %call ( %mem ( %con ( %this ) , %con ( "apply"
                              ) ) , %cons ( %var ( "thisArg" ) , %cons ( %var ( 
                             "argArray" ) , %nil ) ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "thisArg" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 65 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsFunction" ) , %cons ( %con ( %this ) , %nil ) ) ) , 
                             %throw ( %call ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Invalid arguments: Function.prototype.bind" ) , %nil ) ) ) 
                             , %emptyStmt ) , %seq ( %seq ( %vdecl ( "argArray" ) , %exp 
                             ( %bop ( %assign , %var ( "argArray" ) , %arr ( %nil ) ) ) )
                              , %seq ( %label ( "" , %for ( %seq ( %vdecl ( "i" ) , %exp 
                             ( %bop ( %assign , %var ( "i" ) , %con ( 1 ) ) ) ) , %bop ( 
                             %lt , %var ( "i" ) , %mem ( %var ( "arguments" ) , %con ( 
                             "length" ) ) ) , %pre ( %inc , %var ( "i" ) ) , %exp ( %call
                              ( %mem ( %var ( "argArray" ) , %con ( "push" ) ) , %cons ( 
                             %mem ( %var ( "arguments" ) , %var ( "i" ) ) , %nil ) ) ) ) 
                             ) , %return ( %call ( %var ( "FunctionPrototypeBind" ) , 
                             %cons ( %con ( %this ) , %cons ( %var ( "thisArg" ) , %cons 
                             ( %var ( "argArray" ) , %nil ) ) ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "thisArg" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 67 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsObject" ) , %cons ( %var ( "arg" ) , %nil ) ) ) , %return
                              ( %con ( false ) ) , %emptyStmt ) , %return ( %bop ( %eqs ,
                              %call ( %var ( "GetInternalProperty" ) , %cons ( %var ( 
                             "arg" ) , %cons ( %con ( "Class" ) , %nil ) ) ) , %con ( 
                             "Array" ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "arg" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 69 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %seq ( %vdecl ( "array" ) , %exp ( %bop ( 
                             %assign , %var ( "array" ) , %call ( %var ( "ToObject" ) , 
                             %cons ( %con ( %this ) , %nil ) ) ) ) ) , %seq ( %seq ( 
                             %vdecl ( "func" ) , %exp ( %bop ( %assign , %var ( "func" ) 
                             , %mem ( %var ( "array" ) , %con ( "join" ) ) ) ) ) , %seq (
                              %if ( %pre ( %bang , %call ( %var ( "IsCallable" ) , %cons 
                             ( %var ( "func" ) , %nil ) ) ) , %exp ( %bop ( %assign , 
                             %var ( "func" ) , %mem ( %mem ( %var ( "Object" ) , %con ( 
                             "prototype" ) ) , %con ( "toString" ) ) ) ) , %emptyStmt ) ,
                              %return ( %call ( %mem ( %var ( "func" ) , %con ( "call" ) 
                             ) , %cons ( %var ( "array" ) , %nil ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 71 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Array.prototype.toLocaleString" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 73 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %seq ( %vdecl ( "o" ) , %exp ( %bop ( 
                             %assign , %var ( "o" ) , %call ( %var ( "ToObject" ) , %cons
                              ( %con ( %this ) , %nil ) ) ) ) ) , %seq ( %seq ( %vdecl ( 
                             "a" ) , %exp ( %bop ( %assign , %var ( "a" ) , %new ( %var (
                              "Array" ) , %nil ) ) ) ) , %seq ( %exp ( %call ( %var ( 
                             "merge" ) , %cons ( %var ( "a" ) , %cons ( %var ( "o" ) , 
                             %nil ) ) ) ) , %seq ( %label ( "" , %for ( %seq ( %vdecl ( 
                             "i" ) , %exp ( %bop ( %assign , %var ( "i" ) , %con ( 0 ) ) 
                             ) ) , %bop ( %lt , %var ( "i" ) , %mem ( %var ( "arguments" 
                             ) , %con ( "length" ) ) ) , %pre ( %inc , %var ( "i" ) ) , 
                             %exp ( %call ( %var ( "merge" ) , %cons ( %var ( "a" ) , 
                             %cons ( %mem ( %var ( "arguments" ) , %var ( "i" ) ) , %nil 
                             ) ) ) ) ) ) , %seq ( %fdecl ( "merge" , %cons ( %var ( "arr"
                              ) , %cons ( %var ( "elem" ) , %nil ) ) , %if ( %call ( %mem
                              ( %var ( "Array" ) , %con ( "isArray" ) ) , %cons ( %var ( 
                             "elem" ) , %nil ) ) , %label ( "" , %for ( %seq ( %vdecl ( 
                             "k" ) , %exp ( %bop ( %assign , %var ( "k" ) , %con ( 0 ) ) 
                             ) ) , %bop ( %lt , %var ( "k" ) , %mem ( %var ( "elem" ) , 
                             %con ( "length" ) ) ) , %pre ( %inc , %var ( "k" ) ) , %exp 
                             ( %call ( %mem ( %var ( "arr" ) , %con ( "push" ) ) , %cons 
                             ( %mem ( %var ( "elem" ) , %var ( "k" ) ) , %nil ) ) ) ) ) ,
                              %exp ( %call ( %mem ( %var ( "arr" ) , %con ( "push" ) ) , 
                             %cons ( %var ( "elem" ) , %nil ) ) ) ) ) , %return ( %var ( 
                             "a" ) ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "_" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 75 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %seq ( %vdecl ( "o" ) , %exp ( %bop ( 
                             %assign , %var ( "o" ) , %call ( %var ( "ToObject" ) , %cons
                              ( %con ( %this ) , %nil ) ) ) ) ) , %seq ( %seq ( %vdecl ( 
                             "len" ) , %exp ( %bop ( %assign , %var ( "len" ) , %call ( 
                             %var ( "ToUint32" ) , %cons ( %mem ( %var ( "o" ) , %con ( 
                             "length" ) ) , %nil ) ) ) ) ) , %seq ( %if ( %bop ( %eqs , 
                             %var ( "separator" ) , %var ( "undefined" ) ) , %exp ( %bop 
                             ( %assign , %var ( "separator" ) , %con ( "," ) ) ) , %exp (
                              %bop ( %assign , %var ( "separator" ) , %call ( %var ( 
                             "ToString" ) , %cons ( %var ( "separator" ) , %nil ) ) ) ) )
                              , %seq ( %if ( %bop ( %eqs , %var ( "len" ) , %con ( 0 ) ) 
                             , %return ( %con ( "" ) ) , %emptyStmt ) , %seq ( %seq ( 
                             %vdecl ( "r" ) , %exp ( %bop ( %assign , %var ( "r" ) , 
                             %call ( %var ( "get" ) , %cons ( %var ( "o" ) , %cons ( %con
                              ( 0 ) , %nil ) ) ) ) ) ) , %seq ( %label ( "" , %for ( %seq
                              ( %vdecl ( "i" ) , %exp ( %bop ( %assign , %var ( "i" ) , 
                             %con ( 1 ) ) ) ) , %bop ( %lt , %var ( "i" ) , %var ( "len" 
                             ) ) , %pre ( %inc , %var ( "i" ) ) , %exp ( %bopassign ( 
                             %plus , %var ( "r" ) , %bop ( %plus , %var ( "separator" ) ,
                              %call ( %var ( "get" ) , %cons ( %var ( "o" ) , %cons ( 
                             %var ( "i" ) , %nil ) ) ) ) ) ) ) ) , %seq ( %fdecl ( "get" 
                             , %cons ( %var ( "o" ) , %cons ( %var ( "i" ) , %nil ) ) , 
                             %return ( %cond ( %bop ( %or , %bop ( %eqs , %mem ( %var ( 
                             "o" ) , %var ( "i" ) ) , %var ( "undefined" ) ) , %bop ( 
                             %eqs , %mem ( %var ( "o" ) , %var ( "i" ) ) , %con ( %null )
                              ) ) , %con ( "" ) , %call ( %var ( "ToString" ) , %cons ( 
                             %mem ( %var ( "o" ) , %var ( "i" ) ) , %nil ) ) ) ) ) , 
                             %return ( %var ( "r" ) ) ) ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "separator" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 77 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Array.prototype.pop" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 79 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %seq ( %vdecl ( "o" ) , %exp ( %bop ( 
                             %assign , %var ( "o" ) , %call ( %var ( "ToObject" ) , %cons
                              ( %con ( %this ) , %nil ) ) ) ) ) , %seq ( %seq ( %vdecl ( 
                             "len" ) , %exp ( %bop ( %assign , %var ( "len" ) , %call ( 
                             %var ( "ToUint32" ) , %cons ( %mem ( %var ( "o" ) , %con ( 
                             "length" ) ) , %nil ) ) ) ) ) , %seq ( %label ( "" , %for ( 
                             %seq ( %vdecl ( "i" ) , %exp ( %bop ( %assign , %var ( "i" )
                              , %con ( 0 ) ) ) ) , %bop ( %lt , %var ( "i" ) , %mem ( 
                             %var ( "arguments" ) , %con ( "length" ) ) ) , %pre ( %inc ,
                              %var ( "i" ) ) , %exp ( %bop ( %assign , %mem ( %var ( "o" 
                             ) , %bop ( %plus , %var ( "len" ) , %var ( "i" ) ) ) , %mem 
                             ( %var ( "arguments" ) , %var ( "i" ) ) ) ) ) ) , %return ( 
                             %mem ( %var ( "o" ) , %con ( "length" ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "_" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 81 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Array.prototype.reverse" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 83 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Array.prototype.shift" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 85 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 2
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Array.prototype.slice" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "start" ) , %cons ( %var
                              ( "end" ) , %nil ) )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 87 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %seq ( %vdecl ( "o" ) , %exp ( %bop ( 
                             %assign , %var ( "o" ) , %call ( %var ( "ToObject" ) , %cons
                              ( %con ( %this ) , %nil ) ) ) ) ) , %seq ( %seq ( %vdecl ( 
                             "len" ) , %exp ( %bop ( %assign , %var ( "len" ) , %mem ( 
                             %var ( "o" ) , %con ( "length" ) ) ) ) ) , %seq ( %if ( %bop
                              ( %eqs , %var ( "comparefn" ) , %var ( "undefined" ) ) , 
                             %exp ( %bop ( %assign , %var ( "comparefn" ) , %fun ( %cons 
                             ( %var ( "x" ) , %cons ( %var ( "y" ) , %nil ) ) , %if ( 
                             %bop ( %gt , %call ( %var ( "String" ) , %cons ( %var ( "x" 
                             ) , %nil ) ) , %call ( %var ( "String" ) , %cons ( %var ( 
                             "y" ) , %nil ) ) ) , %return ( %con ( 1 ) ) , %return ( %con
                              ( -1 ) ) ) ) ) ) , %emptyStmt ) , %seq ( %if ( %bop ( %ge ,
                              %var ( "len" ) , %con ( 2 ) ) , %seq ( %label ( "" , %for (
                              %seq ( %vdecl ( "start" ) , %exp ( %bop ( %assign , %var ( 
                             "start" ) , %bop ( %lshift , %bop ( %rshift , %bop ( %minus 
                             , %var ( "len" ) , %con ( 2 ) ) , %con ( 1 ) ) , %con ( 1 ) 
                             ) ) ) ) , %bop ( %ge , %var ( "start" ) , %con ( 0 ) ) , 
                             %bopassign ( %minus , %var ( "start" ) , %con ( 2 ) ) , %if 
                             ( %bop ( %gt , %call ( %var ( "comparefn" ) , %cons ( %mem (
                              %var ( "o" ) , %var ( "start" ) ) , %cons ( %mem ( %var ( 
                             "o" ) , %bop ( %plus , %var ( "start" ) , %con ( 1 ) ) ) , 
                             %nil ) ) ) , %con ( 0 ) ) , %seq ( %seq ( %vdecl ( "tmp" ) ,
                              %exp ( %bop ( %assign , %var ( "tmp" ) , %mem ( %var ( "o" 
                             ) , %var ( "start" ) ) ) ) ) , %seq ( %exp ( %bop ( %assign 
                             , %mem ( %var ( "o" ) , %var ( "start" ) ) , %mem ( %var ( 
                             "o" ) , %bop ( %plus , %var ( "start" ) , %con ( 1 ) ) ) ) )
                              , %exp ( %bop ( %assign , %mem ( %var ( "o" ) , %bop ( 
                             %plus , %var ( "start" ) , %con ( 1 ) ) ) , %var ( "tmp" ) )
                              ) ) ) , %emptyStmt ) ) ) , %if ( %bop ( %gt , %var ( "len" 
                             ) , %con ( 2 ) ) , %seq ( %seq ( %vdecl ( "a1" ) , %exp ( 
                             %bop ( %assign , %var ( "a1" ) , %var ( "o" ) ) ) ) , %seq (
                              %seq ( %vdecl ( "a2" ) , %exp ( %bop ( %assign , %var ( 
                             "a2" ) , %new ( %var ( "Array" ) , %cons ( %var ( "len" ) , 
                             %nil ) ) ) ) ) , %seq ( %seq ( %vdecl ( "k" ) , %exp ( %bop 
                             ( %assign , %var ( "k" ) , %con ( 1 ) ) ) ) , %seq ( %seq ( 
                             %vdecl ( "size" ) , %exp ( %bop ( %assign , %var ( "size" ) 
                             , %con ( 2 ) ) ) ) , %seq ( %label ( "" , %do ( %seq ( %seq 
                             ( %vdecl ( "start" ) , %exp ( %bop ( %assign , %var ( 
                             "start" ) , %bop ( %lshift , %bop ( %rshift , %bop ( %minus 
                             , %var ( "len" ) , %con ( 1 ) ) , %bop ( %plus , %var ( "k" 
                             ) , %con ( 1 ) ) ) , %bop ( %plus , %var ( "k" ) , %con ( 1 
                             ) ) ) ) ) ) , %seq ( %seq ( %vdecl ( "j_end" ) , %exp ( %bop
                              ( %assign , %var ( "j_end" ) , %var ( "len" ) ) ) ) , %seq 
                             ( %seq ( %vdecl ( "i_end" ) , %exp ( %bop ( %assign , %var (
                              "i_end" ) , %bop ( %plus , %var ( "start" ) , %var ( "size"
                              ) ) ) ) ) , %seq ( %if ( %bop ( %gt , %var ( "i_end" ) , 
                             %var ( "len" ) ) , %exp ( %bop ( %assign , %var ( "i_end" ) 
                             , %var ( "len" ) ) ) , %emptyStmt ) , %seq ( %label ( "" , 
                             %while ( %bop ( %ge , %var ( "start" ) , %con ( 0 ) ) , %seq
                              ( %seq ( %vdecl ( "i" ) , %exp ( %bop ( %assign , %var ( 
                             "i" ) , %var ( "start" ) ) ) ) , %seq ( %seq ( %vdecl ( "j" 
                             ) , %exp ( %bop ( %assign , %var ( "j" ) , %var ( "i_end" ) 
                             ) ) ) , %seq ( %seq ( %vdecl ( "x" ) , %exp ( %bop ( %assign
                              , %var ( "x" ) , %var ( "start" ) ) ) ) , %seq ( %label ( 
                             "" , %for ( %exp ( %emptyExp ) , %emptyExp , %emptyExp , %if
                              ( %bop ( %lt , %var ( "i" ) , %var ( "i_end" ) ) , %if ( 
                             %bop ( %lt , %var ( "j" ) , %var ( "j_end" ) ) , %if ( %bop 
                             ( %gt , %call ( %var ( "comparefn" ) , %cons ( %mem ( %var (
                              "a1" ) , %var ( "i" ) ) , %cons ( %mem ( %var ( "a1" ) , 
                             %var ( "j" ) ) , %nil ) ) ) , %con ( 0 ) ) , %exp ( %bop ( 
                             %assign , %mem ( %var ( "a2" ) , %post ( %var ( "x" ) , %inc
                              ) ) , %mem ( %var ( "a1" ) , %post ( %var ( "j" ) , %inc ) 
                             ) ) ) , %exp ( %bop ( %assign , %mem ( %var ( "a2" ) , %post
                              ( %var ( "x" ) , %inc ) ) , %mem ( %var ( "a1" ) , %post ( 
                             %var ( "i" ) , %inc ) ) ) ) ) , %seq ( %label ( "" , %while 
                             ( %bop ( %lt , %var ( "i" ) , %var ( "i_end" ) ) , %exp ( 
                             %bop ( %assign , %mem ( %var ( "a2" ) , %post ( %var ( "x" )
                              , %inc ) ) , %mem ( %var ( "a1" ) , %post ( %var ( "i" ) , 
                             %inc ) ) ) ) ) ) , %break ( "" ) ) ) , %seq ( %label ( "" , 
                             %while ( %bop ( %lt , %var ( "j" ) , %var ( "j_end" ) ) , 
                             %exp ( %bop ( %assign , %mem ( %var ( "a2" ) , %post ( %var 
                             ( "x" ) , %inc ) ) , %mem ( %var ( "a1" ) , %post ( %var ( 
                             "j" ) , %inc ) ) ) ) ) ) , %break ( "" ) ) ) ) ) , %seq ( 
                             %exp ( %bop ( %assign , %var ( "j_end" ) , %var ( "start" ) 
                             ) ) , %seq ( %exp ( %bopassign ( %minus , %var ( "start" ) ,
                              %bop ( %times , %con ( 2 ) , %var ( "size" ) ) ) ) , %exp (
                              %bop ( %assign , %var ( "i_end" ) , %bop ( %plus , %var ( 
                             "start" ) , %var ( "size" ) ) ) ) ) ) ) ) ) ) ) ) , %seq ( 
                             %seq ( %vdecl ( "t" ) , %exp ( %bop ( %assign , %var ( "t" )
                              , %var ( "a1" ) ) ) ) , %seq ( %exp ( %bop ( %assign , %var
                              ( "a1" ) , %var ( "a2" ) ) ) , %seq ( %exp ( %bop ( %assign
                              , %var ( "a2" ) , %var ( "t" ) ) ) , %seq ( %exp ( %post ( 
                             %var ( "k" ) , %inc ) ) , %exp ( %bopassign ( %times , %var 
                             ( "size" ) , %con ( 2 ) ) ) ) ) ) ) ) ) ) ) ) , %bop ( %gt ,
                              %var ( "len" ) , %var ( "size" ) ) ) ) , %if ( %bop ( %eqs 
                             , %bop ( %amp , %var ( "k" ) , %con ( 1 ) ) , %con ( 0 ) ) ,
                              %label ( "" , %for ( %seq ( %vdecl ( "i" ) , %exp ( %bop ( 
                             %assign , %var ( "i" ) , %bop ( %minus , %var ( "len" ) , 
                             %con ( 1 ) ) ) ) ) , %bop ( %ge , %var ( "i" ) , %con ( 0 ) 
                             ) , %post ( %var ( "i" ) , %dec ) , %exp ( %bop ( %assign , 
                             %mem ( %var ( "o" ) , %var ( "i" ) ) , %mem ( %var ( "a1" ) 
                             , %var ( "i" ) ) ) ) ) ) , %emptyStmt ) ) ) ) ) ) , 
                             %emptyStmt ) ) , %emptyStmt ) , %return ( %var ( "o" ) ) ) )
                              ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "comparefn" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 89 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 2
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Array.prototype.splice" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "start" ) , %cons ( %var
                              ( "deleteCount" ) , %nil ) )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 91 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Array.prototype.unshift" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "_" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 93 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Array.prototype.indexOf" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "searchElement" ) , %nil
                              )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 95 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Array.prototype.lastIndexOf" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "searchElement" ) , %nil
                              )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 97 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Array.prototype.every" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "callbackfn" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 99 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Array.prototype.some" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "callbackfn" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 101 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Array.prototype.forEach" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "callbackfn" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 103 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Array.prototype.map" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "callbackfn" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 105 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Array.prototype.filter" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "callbackfn" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 107 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Array.prototype.reduce" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "callbackfn" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 109 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Array.prototype.reduceRight" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "callbackfn" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 111 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %seq ( %vdecl ( "s" ) , %exp ( %bop ( 
                             %assign , %var ( "s" ) , %con ( "" ) ) ) ) , %seq ( %label (
                              "" , %for ( %seq ( %vdecl ( "i" ) , %exp ( %bop ( %assign ,
                              %var ( "i" ) , %con ( 0 ) ) ) ) , %bop ( %lt , %var ( "i" )
                              , %mem ( %var ( "arguments" ) , %con ( "length" ) ) ) , 
                             %pre ( %inc , %var ( "i" ) ) , %exp ( %bopassign ( %plus , 
                             %var ( "s" ) , %call ( %var ( "Int2Char" ) , %cons ( %call (
                              %var ( "ToUint16" ) , %cons ( %mem ( %var ( "arguments" ) ,
                              %var ( "i" ) ) , %nil ) ) , %nil ) ) ) ) ) ) , %return ( 
                             %var ( "s" ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "_" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 113 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %return ( %call ( %mem ( %mem ( %mem ( %var ( 
                             "String" ) , %con ( "prototype" ) ) , %con ( "valueOf" ) ) ,
                              %con ( "call" ) ) , %cons ( %con ( %this ) , %nil ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 115 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %if ( %bop ( %eqs , %pre ( %typeof , %con ( %this )
                              ) , %con ( "string" ) ) , %return ( %con ( %this ) ) , %if 
                             ( %bop ( %and , %call ( %var ( "IsObject" ) , %cons ( %con (
                              %this ) , %nil ) ) , %bop ( %eqs , %call ( %var ( 
                             "GetInternalProperty" ) , %cons ( %con ( %this ) , %cons ( 
                             %con ( "Class" ) , %nil ) ) ) , %con ( "String" ) ) ) , 
                             %return ( %call ( %var ( "GetInternalProperty" ) , %cons ( 
                             %con ( %this ) , %cons ( %con ( "PrimitiveValue" ) , %nil ) 
                             ) ) ) , %throw ( %call ( %var ( "TypeError" ) , %cons ( %con
                              ( "Invalid arguments: String.prototype.valueOf" ) , %nil ) 
                             ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 117 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %exp ( %call ( %var ( "CheckObjectCoercible"
                              ) , %cons ( %con ( %this ) , %nil ) ) ) , %seq ( %seq ( 
                             %vdecl ( "s" ) , %exp ( %bop ( %assign , %var ( "s" ) , 
                             %call ( %var ( "ToString" ) , %cons ( %con ( %this ) , %nil 
                             ) ) ) ) ) , %seq ( %seq ( %vdecl ( "position" ) , %exp ( 
                             %bop ( %assign , %var ( "position" ) , %call ( %var ( 
                             "ToInteger" ) , %cons ( %var ( "pos" ) , %nil ) ) ) ) ) , 
                             %seq ( %seq ( %vdecl ( "size" ) , %exp ( %bop ( %assign , 
                             %var ( "size" ) , %call ( %var ( "LengthString" ) , %cons ( 
                             %var ( "s" ) , %nil ) ) ) ) ) , %if ( %bop ( %or , %bop ( 
                             %lt , %var ( "position" ) , %con ( 0 ) ) , %bop ( %ge , %var
                              ( "position" ) , %var ( "size" ) ) ) , %return ( %con ( "" 
                             ) ) , %return ( %call ( %var ( "CharAt" ) , %cons ( %var ( 
                             "s" ) , %cons ( %var ( "position" ) , %nil ) ) ) ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "pos" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 119 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %exp ( %call ( %var ( "CheckObjectCoercible"
                              ) , %cons ( %con ( %this ) , %nil ) ) ) , %seq ( %seq ( 
                             %vdecl ( "s" ) , %exp ( %bop ( %assign , %var ( "s" ) , 
                             %call ( %var ( "ToString" ) , %cons ( %con ( %this ) , %nil 
                             ) ) ) ) ) , %seq ( %seq ( %vdecl ( "position" ) , %exp ( 
                             %bop ( %assign , %var ( "position" ) , %call ( %var ( 
                             "ToInteger" ) , %cons ( %var ( "pos" ) , %nil ) ) ) ) ) , 
                             %seq ( %seq ( %vdecl ( "size" ) , %exp ( %bop ( %assign , 
                             %var ( "size" ) , %call ( %var ( "LengthString" ) , %cons ( 
                             %var ( "s" ) , %nil ) ) ) ) ) , %if ( %bop ( %or , %bop ( 
                             %lt , %var ( "position" ) , %con ( 0 ) ) , %bop ( %ge , %var
                              ( "position" ) , %var ( "size" ) ) ) , %return ( %var ( 
                             "NaN" ) ) , %return ( %call ( %var ( "Char2Int" ) , %cons ( 
                             %call ( %var ( "CharAt" ) , %cons ( %var ( "s" ) , %cons ( 
                             %var ( "position" ) , %nil ) ) ) , %nil ) ) ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "pos" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 121 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %exp ( %call ( %var ( "CheckObjectCoercible"
                              ) , %cons ( %con ( %this ) , %nil ) ) ) , %seq ( %seq ( 
                             %vdecl ( "s" ) , %exp ( %bop ( %assign , %var ( "s" ) , 
                             %call ( %var ( "ToString" ) , %cons ( %con ( %this ) , %nil 
                             ) ) ) ) ) , %seq ( %seq ( %vdecl ( "r" ) , %exp ( %bop ( 
                             %assign , %var ( "r" ) , %var ( "s" ) ) ) ) , %seq ( %label 
                             ( "" , %for ( %seq ( %vdecl ( "i" ) , %exp ( %bop ( %assign 
                             , %var ( "i" ) , %con ( 0 ) ) ) ) , %bop ( %lt , %var ( "i" 
                             ) , %mem ( %var ( "arguments" ) , %con ( "length" ) ) ) , 
                             %pre ( %inc , %var ( "i" ) ) , %exp ( %bopassign ( %plus , 
                             %var ( "r" ) , %call ( %var ( "ToString" ) , %cons ( %mem ( 
                             %var ( "arguments" ) , %var ( "i" ) ) , %nil ) ) ) ) ) ) , 
                             %return ( %var ( "r" ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "_" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 123 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %seq ( %vdecl ( "position" ) , %exp ( %bop (
                              %assign , %var ( "position" ) , %mem ( %var ( "arguments" )
                              , %con ( 1 ) ) ) ) ) , %seq ( %exp ( %call ( %var ( 
                             "CheckObjectCoercible" ) , %cons ( %con ( %this ) , %nil ) )
                              ) , %seq ( %seq ( %vdecl ( "s" ) , %exp ( %bop ( %assign , 
                             %var ( "s" ) , %call ( %var ( "ToString" ) , %cons ( %con ( 
                             %this ) , %nil ) ) ) ) ) , %seq ( %seq ( %vdecl ( 
                             "searchStr" ) , %exp ( %bop ( %assign , %var ( "searchStr" )
                              , %call ( %var ( "ToString" ) , %cons ( %var ( 
                             "searchString" ) , %nil ) ) ) ) ) , %seq ( %seq ( %vdecl ( 
                             "pos" ) , %exp ( %bop ( %assign , %var ( "pos" ) , %cond ( 
                             %bop ( %eqs , %var ( "position" ) , %var ( "undefined" ) ) ,
                              %con ( 0 ) , %call ( %var ( "ToInteger" ) , %cons ( %var ( 
                             "position" ) , %nil ) ) ) ) ) ) , %seq ( %seq ( %vdecl ( 
                             "len" ) , %exp ( %bop ( %assign , %var ( "len" ) , %call ( 
                             %var ( "LengthString" ) , %cons ( %var ( "s" ) , %nil ) ) ) 
                             ) ) , %seq ( %seq ( %vdecl ( "start" ) , %exp ( %bop ( 
                             %assign , %var ( "start" ) , %call ( %mem ( %var ( "Math" ) 
                             , %con ( "min" ) ) , %cons ( %call ( %mem ( %var ( "Math" ) 
                             , %con ( "max" ) ) , %cons ( %var ( "pos" ) , %cons ( %con (
                              0 ) , %nil ) ) ) , %cons ( %var ( "len" ) , %nil ) ) ) ) ) 
                             ) , %return ( %call ( %var ( "FindString" ) , %cons ( %var (
                              "s" ) , %cons ( %var ( "searchStr" ) , %cons ( %var ( 
                             "start" ) , %nil ) ) ) ) ) ) ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "searchString" ) , %nil 
                             )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 125 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: String.prototype.lastIndexOf" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "searchString" ) , %nil 
                             )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 127 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: String.prototype.localeCompare" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "that" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 129 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: String.prototype.match" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "regexp" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 131 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 2
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %bop ( %eqs , %pre ( %typeof , %var ( 
                             "searchValue" ) ) , %con ( "string" ) ) , %seq ( %seq ( 
                             %vdecl ( "pos" ) , %exp ( %bop ( %assign , %var ( "pos" ) , 
                             %call ( %mem ( %con ( %this ) , %con ( "indexOf" ) ) , %cons
                              ( %var ( "searchValue" ) , %nil ) ) ) ) ) , %if ( %bop ( 
                             %eqs , %pre ( %typeof , %var ( "replaceValue" ) ) , %con ( 
                             "function" ) ) , %seq ( %seq ( %vdecl ( "ret" ) , %exp ( 
                             %bop ( %assign , %var ( "ret" ) , %call ( %var ( 
                             "replaceValue" ) , %cons ( %var ( "searchValue" ) , %cons ( 
                             %var ( "pos" ) , %cons ( %call ( %mem ( %con ( %this ) , 
                             %con ( "toString" ) ) , %nil ) , %nil ) ) ) ) ) ) ) , 
                             %return ( %call ( %mem ( %call ( %mem ( %con ( %this ) , 
                             %con ( "substring" ) ) , %cons ( %con ( 0 ) , %cons ( %var (
                              "pos" ) , %nil ) ) ) , %con ( "concat" ) ) , %cons ( %call 
                             ( %mem ( %new ( %var ( "String" ) , %cons ( %var ( "ret" ) ,
                              %nil ) ) , %con ( "toString" ) ) , %nil ) , %cons ( %call (
                              %mem ( %con ( %this ) , %con ( "substring" ) ) , %cons ( 
                             %bop ( %plus , %var ( "pos" ) , %call ( %var ( 
                             "LengthString" ) , %cons ( %var ( "searchValue" ) , %nil ) )
                              ) , %nil ) ) , %nil ) ) ) ) ) , %return ( %call ( %mem ( 
                             %call ( %mem ( %con ( %this ) , %con ( "substring" ) ) , 
                             %cons ( %con ( 0 ) , %cons ( %var ( "pos" ) , %nil ) ) ) , 
                             %con ( "concat" ) ) , %cons ( %call ( %mem ( %var ( 
                             "replaceValue" ) , %con ( "toString" ) ) , %nil ) , %cons ( 
                             %call ( %mem ( %con ( %this ) , %con ( "substring" ) ) , 
                             %cons ( %bop ( %plus , %var ( "pos" ) , %call ( %var ( 
                             "LengthString" ) , %cons ( %var ( "searchValue" ) , %nil ) )
                              ) , %nil ) ) , %nil ) ) ) ) ) ) , %if ( %bop ( %instanceof 
                             , %var ( "searchValue" ) , %var ( "RegExp" ) ) , %throw ( 
                             %con ( "NotImplemented: String.prototype.replace" ) ) , 
                             %emptyStmt ) ) , %return ( %call ( %mem ( %con ( %this ) , 
                             %con ( "toString" ) ) , %nil ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "searchValue" ) , %cons 
                             ( %var ( "replaceValue" ) , %nil ) )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 133 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: String.prototype.search" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "regexp" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 135 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 2
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: String.prototype.slice" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "start" ) , %cons ( %var
                              ( "end" ) , %nil ) )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 137 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 2
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %seq ( %vdecl ( "res" ) , %exp ( %bop ( 
                             %assign , %var ( "res" ) , %new ( %var ( "Array" ) , %nil ) 
                             ) ) ) , %seq ( %if ( %bop ( %eqs , %var ( "limit" ) , %con (
                              0 ) ) , %return ( %var ( "res" ) ) , %emptyStmt ) , %seq ( 
                             %seq ( %vdecl ( "len" ) , %exp ( %bop ( %assign , %var ( 
                             "len" ) , %mem ( %con ( %this ) , %con ( "length" ) ) ) ) ) 
                             , %seq ( %if ( %bop ( %eqs , %var ( "len" ) , %con ( 0 ) ) ,
                              %return ( %var ( "res" ) ) , %emptyStmt ) , %seq ( %if ( 
                             %bop ( %eqs , %var ( "separator" ) , %var ( "undefined" ) ) 
                             , %return ( %arr ( %cons ( %con ( %this ) , %nil ) ) ) , 
                             %emptyStmt ) , %seq ( %seq ( %vdecl ( "pos" ) , %exp ( %bop 
                             ( %assign , %var ( "pos" ) , %call ( %mem ( %con ( %this ) ,
                              %con ( "indexOf" ) ) , %cons ( %var ( "separator" ) , %nil 
                             ) ) ) ) ) , %seq ( %seq ( %vdecl ( "start" ) , %exp ( %bop (
                              %assign , %var ( "start" ) , %con ( 0 ) ) ) ) , %seq ( %seq
                              ( %vdecl ( "sepLen" ) , %exp ( %bop ( %assign , %var ( 
                             "sepLen" ) , %mem ( %var ( "separator" ) , %con ( "length" )
                              ) ) ) ) , %seq ( %label ( "" , %while ( %bop ( %ge , %var (
                              "pos" ) , %con ( 0 ) ) , %seq ( %exp ( %call ( %mem ( %var 
                             ( "res" ) , %con ( "push" ) ) , %cons ( %call ( %mem ( %con 
                             ( %this ) , %con ( "substring" ) ) , %cons ( %var ( "start" 
                             ) , %cons ( %var ( "pos" ) , %nil ) ) ) , %nil ) ) ) , %seq 
                             ( %if ( %bop ( %eqs , %mem ( %var ( "res" ) , %con ( 
                             "length" ) ) , %var ( "limit" ) ) , %return ( %var ( "res" )
                              ) , %emptyStmt ) , %seq ( %exp ( %bop ( %assign , %var ( 
                             "start" ) , %bop ( %plus , %var ( "pos" ) , %var ( "sepLen" 
                             ) ) ) ) , %exp ( %bop ( %assign , %var ( "pos" ) , %call ( 
                             %mem ( %con ( %this ) , %con ( "indexOf" ) ) , %cons ( %var 
                             ( "separator" ) , %cons ( %bop ( %plus , %var ( "pos" ) , 
                             %var ( "sepLen" ) ) , %nil ) ) ) ) ) ) ) ) ) ) , %seq ( %if 
                             ( %bop ( %le , %var ( "start" ) , %var ( "len" ) ) , %exp ( 
                             %call ( %mem ( %var ( "res" ) , %con ( "push" ) ) , %cons ( 
                             %call ( %mem ( %con ( %this ) , %con ( "substring" ) ) , 
                             %cons ( %var ( "start" ) , %nil ) ) , %nil ) ) ) , 
                             %emptyStmt ) , %return ( %var ( "res" ) ) ) ) ) ) ) ) ) ) ) 
                             )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "separator" ) , %cons ( 
                             %var ( "limit" ) , %nil ) )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 139 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 2
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %exp ( %call ( %var ( "CheckObjectCoercible"
                              ) , %cons ( %con ( %this ) , %nil ) ) ) , %seq ( %seq ( 
                             %vdecl ( "s" ) , %exp ( %bop ( %assign , %var ( "s" ) , 
                             %call ( %var ( "ToString" ) , %cons ( %con ( %this ) , %nil 
                             ) ) ) ) ) , %seq ( %seq ( %vdecl ( "len" ) , %exp ( %bop ( 
                             %assign , %var ( "len" ) , %call ( %var ( "LengthString" ) ,
                              %cons ( %var ( "s" ) , %nil ) ) ) ) ) , %seq ( %seq ( 
                             %vdecl ( "intStart" ) , %exp ( %bop ( %assign , %var ( 
                             "intStart" ) , %call ( %var ( "ToInteger" ) , %cons ( %var (
                              "start" ) , %nil ) ) ) ) ) , %seq ( %seq ( %vdecl ( 
                             "intEnd" ) , %exp ( %bop ( %assign , %var ( "intEnd" ) , 
                             %cond ( %bop ( %eqs , %var ( "end" ) , %var ( "undefined" ) 
                             ) , %var ( "len" ) , %call ( %var ( "ToInteger" ) , %cons ( 
                             %var ( "end" ) , %nil ) ) ) ) ) ) , %seq ( %seq ( %vdecl ( 
                             "finalStart" ) , %exp ( %bop ( %assign , %var ( "finalStart"
                              ) , %call ( %mem ( %var ( "Math" ) , %con ( "min" ) ) , 
                             %cons ( %call ( %mem ( %var ( "Math" ) , %con ( "max" ) ) , 
                             %cons ( %var ( "intStart" ) , %cons ( %con ( 0 ) , %nil ) ) 
                             ) , %cons ( %var ( "len" ) , %nil ) ) ) ) ) ) , %seq ( %seq 
                             ( %vdecl ( "finalEnd" ) , %exp ( %bop ( %assign , %var ( 
                             "finalEnd" ) , %call ( %mem ( %var ( "Math" ) , %con ( "min"
                              ) ) , %cons ( %call ( %mem ( %var ( "Math" ) , %con ( "max"
                              ) ) , %cons ( %var ( "intEnd" ) , %cons ( %con ( 0 ) , %nil
                              ) ) ) , %cons ( %var ( "len" ) , %nil ) ) ) ) ) ) , %seq ( 
                             %seq ( %vdecl ( "from" ) , %exp ( %bop ( %assign , %var ( 
                             "from" ) , %call ( %mem ( %var ( "Math" ) , %con ( "min" ) )
                              , %cons ( %var ( "finalStart" ) , %cons ( %var ( "finalEnd"
                              ) , %nil ) ) ) ) ) ) , %seq ( %seq ( %vdecl ( "to" ) , %exp
                              ( %bop ( %assign , %var ( "to" ) , %call ( %mem ( %var ( 
                             "Math" ) , %con ( "max" ) ) , %cons ( %var ( "finalStart" ) 
                             , %cons ( %var ( "finalEnd" ) , %nil ) ) ) ) ) ) , %return (
                              %call ( %var ( "SubstrString" ) , %cons ( %var ( "s" ) , 
                             %cons ( %var ( "from" ) , %cons ( %var ( "to" ) , %nil ) ) )
                              ) ) ) ) ) ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "start" ) , %cons ( %var
                              ( "end" ) , %nil ) )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 141 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: String.prototype.toLowerCase" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 143 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: String.prototype.toLocaleLowerCase" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 145 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: String.prototype.toUpperCase" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 147 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: String.prototype.toLocaleUpperCase" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 149 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %exp ( %call ( %var ( "CheckObjectCoercible"
                              ) , %cons ( %con ( %this ) , %nil ) ) ) , %seq ( %seq ( 
                             %vdecl ( "s" ) , %exp ( %bop ( %assign , %var ( "s" ) , 
                             %call ( %var ( "ToString" ) , %cons ( %con ( %this ) , %nil 
                             ) ) ) ) ) , %return ( %call ( %var ( "Trim" ) , %cons ( %var
                              ( "s" ) , %nil ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 151 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %seq ( %vdecl ( "b" ) , %exp ( %bop ( 
                             %assign , %var ( "b" ) , %call ( %mem ( %mem ( %mem ( %var (
                              "Boolean" ) , %con ( "prototype" ) ) , %con ( "valueOf" ) )
                              , %con ( "call" ) ) , %cons ( %con ( %this ) , %nil ) ) ) )
                              ) , %if ( %var ( "b" ) , %return ( %con ( "true" ) ) , 
                             %return ( %con ( "false" ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 153 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %vdecl ( "b" ) , %seq ( %if ( %bop ( %eqs , 
                             %pre ( %typeof , %con ( %this ) ) , %con ( "boolean" ) ) , 
                             %exp ( %bop ( %assign , %var ( "b" ) , %con ( %this ) ) ) , 
                             %if ( %bop ( %and , %call ( %var ( "IsObject" ) , %cons ( 
                             %con ( %this ) , %nil ) ) , %bop ( %eqs , %call ( %var ( 
                             "GetInternalProperty" ) , %cons ( %con ( %this ) , %cons ( 
                             %con ( "Class" ) , %nil ) ) ) , %con ( "Boolean" ) ) ) , 
                             %exp ( %bop ( %assign , %var ( "b" ) , %call ( %var ( 
                             "GetInternalProperty" ) , %cons ( %con ( %this ) , %cons ( 
                             %con ( "PrimitiveValue" ) , %nil ) ) ) ) ) , %throw ( %call 
                             ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Invalid arguments: Boolean.prototype.valueOf" ) , %nil ) ) 
                             ) ) ) , %return ( %var ( "b" ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 155 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %seq ( %vdecl ( "n" ) , %exp ( %bop ( 
                             %assign , %var ( "n" ) , %call ( %mem ( %mem ( %mem ( %var (
                              "Number" ) , %con ( "prototype" ) ) , %con ( "valueOf" ) ) 
                             , %con ( "call" ) ) , %cons ( %con ( %this ) , %nil ) ) ) ) 
                             ) , %seq ( %vdecl ( "r" ) , %seq ( %if ( %bop ( %eqs , %var 
                             ( "radix" ) , %var ( "undefined" ) ) , %exp ( %bop ( %assign
                              , %var ( "r" ) , %con ( 10 ) ) ) , %seq ( %exp ( %bop ( 
                             %assign , %var ( "r" ) , %call ( %var ( "ToInteger" ) , 
                             %cons ( %var ( "radix" ) , %nil ) ) ) ) , %if ( %pre ( %bang
                              , %bop ( %and , %bop ( %ge , %var ( "r" ) , %con ( 2 ) ) , 
                             %bop ( %le , %var ( "r" ) , %con ( 36 ) ) ) ) , %throw ( 
                             %call ( %var ( "RangeError" ) , %cons ( %con ( 
                             "Invalid arguments: Number.prototype.toString" ) , %nil ) ) 
                             ) , %emptyStmt ) ) ) , %return ( %call ( %var ( 
                             "NumberToString" ) , %cons ( %var ( "n" ) , %cons ( %var ( 
                             "r" ) , %nil ) ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "radix" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 157 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Number.prototype.toLocaleString" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 159 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %if ( %bop ( %eqs , %pre ( %typeof , %con ( %this )
                              ) , %con ( "string" ) ) , %return ( %con ( %this ) ) , %if 
                             ( %bop ( %and , %call ( %var ( "IsObject" ) , %cons ( %con (
                              %this ) , %nil ) ) , %bop ( %eqs , %call ( %var ( 
                             "GetInternalProperty" ) , %cons ( %con ( %this ) , %cons ( 
                             %con ( "Class" ) , %nil ) ) ) , %con ( "Number" ) ) ) , 
                             %return ( %call ( %var ( "GetInternalProperty" ) , %cons ( 
                             %con ( %this ) , %cons ( %con ( "PrimitiveValue" ) , %nil ) 
                             ) ) ) , %throw ( %call ( %var ( "TypeError" ) , %cons ( %con
                              ( "Invalid arguments: Number.prototype.valueOf" ) , %nil ) 
                             ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 161 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %return ( %call ( %var ( "NumberPrototypeToFixed" )
                              , %cons ( %con ( %this ) , %cons ( %var ( "fractionDigits" 
                             ) , %nil ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "fractionDigits" ) , 
                             %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 163 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Number.prototype.toExponential" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "fractionDigits" ) , 
                             %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 165 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( 
                             "NotImplemented: Number.prototype.toPrecision" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "precision" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 167 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %exp ( %bop ( %assign , %var ( "x" ) , %call
                              ( %var ( "ToNumber" ) , %cons ( %var ( "x" ) , %nil ) ) ) )
                              , %if ( %bop ( %lt , %var ( "x" ) , %con ( 0 ) ) , %return 
                             ( %pre ( %minus , %var ( "x" ) ) ) , %return ( %var ( "x" ) 
                             ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "x" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 169 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( "NotImplemented: Math.acos" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "x" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 171 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( "NotImplemented: Math.asin" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "x" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 173 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( "NotImplemented: Math.atan" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "x" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 175 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 2
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( "NotImplemented: Math.atan2" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "y" ) , %cons ( %var ( 
                             "x" ) , %nil ) )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 177 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %return ( %pre ( %minus , %call ( %mem ( %var ( 
                             "Math" ) , %con ( "floor" ) ) , %cons ( %pre ( %minus , %var
                              ( "x" ) ) , %nil ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "x" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 179 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( "NotImplemented: Math.cos" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "x" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 181 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( "NotImplemented: Math.exp" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "x" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 183 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %exp ( %bop ( %assign , %var ( "x" ) , %call
                              ( %var ( "ToNumber" ) , %cons ( %var ( "x" ) , %nil ) ) ) )
                              , %return ( %call ( %var ( "MathFloor" ) , %cons ( %var ( 
                             "x" ) , %nil ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "x" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 185 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( "NotImplemented: Math.log" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "x" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 187 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 2
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %seq ( %vdecl ( "max" ) , %exp ( %bop ( 
                             %assign , %var ( "max" ) , %pre ( %minus , %var ( "Infinity"
                              ) ) ) ) ) , %seq ( %label ( "" , %for ( %seq ( %vdecl ( "i"
                              ) , %exp ( %bop ( %assign , %var ( "i" ) , %con ( 0 ) ) ) )
                              , %bop ( %lt , %var ( "i" ) , %mem ( %var ( "arguments" ) ,
                              %con ( "length" ) ) ) , %pre ( %inc , %var ( "i" ) ) , %seq
                              ( %seq ( %vdecl ( "value" ) , %exp ( %bop ( %assign , %var 
                             ( "value" ) , %call ( %var ( "ToNumber" ) , %cons ( %mem ( 
                             %var ( "arguments" ) , %var ( "i" ) ) , %nil ) ) ) ) ) , %if
                              ( %call ( %var ( "isNaN" ) , %cons ( %var ( "value" ) , 
                             %nil ) ) , %return ( %var ( "NaN" ) ) , %if ( %bop ( %gt , 
                             %var ( "value" ) , %var ( "max" ) ) , %exp ( %bop ( %assign 
                             , %var ( "max" ) , %var ( "value" ) ) ) , %if ( %bop ( %and 
                             , %call ( %var ( "IsPositiveZero" ) , %cons ( %var ( "value"
                              ) , %nil ) ) , %call ( %var ( "IsNegativeZero" ) , %cons ( 
                             %var ( "max" ) , %nil ) ) ) , %exp ( %bop ( %assign , %var (
                              "max" ) , %var ( "value" ) ) ) , %emptyStmt ) ) ) ) ) ) , 
                             %return ( %var ( "max" ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "value1" ) , %cons ( 
                             %var ( "value2" ) , %nil ) )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 189 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 2
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %seq ( %vdecl ( "min" ) , %exp ( %bop ( 
                             %assign , %var ( "min" ) , %pre ( %plus , %var ( "Infinity" 
                             ) ) ) ) ) , %seq ( %label ( "" , %for ( %seq ( %vdecl ( "i" 
                             ) , %exp ( %bop ( %assign , %var ( "i" ) , %con ( 0 ) ) ) ) 
                             , %bop ( %lt , %var ( "i" ) , %mem ( %var ( "arguments" ) , 
                             %con ( "length" ) ) ) , %pre ( %inc , %var ( "i" ) ) , %seq 
                             ( %seq ( %vdecl ( "value" ) , %exp ( %bop ( %assign , %var (
                              "value" ) , %call ( %var ( "ToNumber" ) , %cons ( %mem ( 
                             %var ( "arguments" ) , %var ( "i" ) ) , %nil ) ) ) ) ) , %if
                              ( %call ( %var ( "isNaN" ) , %cons ( %var ( "value" ) , 
                             %nil ) ) , %return ( %var ( "NaN" ) ) , %if ( %bop ( %lt , 
                             %var ( "value" ) , %var ( "min" ) ) , %exp ( %bop ( %assign 
                             , %var ( "min" ) , %var ( "value" ) ) ) , %if ( %bop ( %and 
                             , %call ( %var ( "IsNegativeZero" ) , %cons ( %var ( "value"
                              ) , %nil ) ) , %call ( %var ( "IsPositiveZero" ) , %cons ( 
                             %var ( "min" ) , %nil ) ) ) , %exp ( %bop ( %assign , %var (
                              "min" ) , %var ( "value" ) ) ) , %emptyStmt ) ) ) ) ) ) , 
                             %return ( %var ( "min" ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "value1" ) , %cons ( 
                             %var ( "value2" ) , %nil ) )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 191 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 2
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %exp ( %bop ( %assign , %var ( "x" ) , %call
                              ( %var ( "ToNumber" ) , %cons ( %var ( "x" ) , %nil ) ) ) )
                              , %seq ( %exp ( %bop ( %assign , %var ( "y" ) , %call ( 
                             %var ( "ToNumber" ) , %cons ( %var ( "y" ) , %nil ) ) ) ) , 
                             %return ( %call ( %var ( "MathPow" ) , %cons ( %var ( "x" ) 
                             , %cons ( %var ( "y" ) , %nil ) ) ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "x" ) , %cons ( %var ( 
                             "y" ) , %nil ) )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 193 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( "NotImplemented: Math.random" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 195 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( "NotImplemented: Math.round" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "x" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 197 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %exp ( %bop ( %assign , %var ( "x" ) , %call
                              ( %var ( "ToNumber" ) , %cons ( %var ( "x" ) , %nil ) ) ) )
                              , %if ( %call ( %var ( "isFinite" ) , %cons ( %var ( "x" ) 
                             , %nil ) ) , %return ( %call ( %var ( "MathSin" ) , %cons ( 
                             %var ( "x" ) , %nil ) ) ) , %return ( %var ( "NaN" ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "x" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 199 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( "NotImplemented: Math.sqrt" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "x" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 201 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %throw ( %con ( "NotImplemented: Math.tan" ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "x" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 203 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %return ( %call ( %var ( "DatePrototypeToString" ) 
                             , %cons ( %con ( %this ) , %nil ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 205 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %return ( %call ( %var ( "GetInternalProperty" ) , 
                             %cons ( %con ( %this ) , %cons ( %con ( "PrimitiveValue" ) ,
                              %nil ) ) ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 207 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 1
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %return ( %con ( %null ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %cons ( %var ( "string" ) , %nil )
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
                   <obj>
                       <oid>
                           @oo ( 209 )
                       </oid>
                       <properties>
                           "length" |-> @desc ( 
                               "Configurable" |-> false
                               "Enumerable" |-> false
                               "Value" |-> 0
                               "Writable" |-> false )
                       </properties>
                       <internalProperties>
                           "Class" |-> "Function"
                           "Code" |-> %seq ( %if ( %pre ( %bang , %call ( %var ( 
                             "IsObject" ) , %cons ( %con ( %this ) , %nil ) ) ) , %throw 
                             ( %call ( %var ( "TypeError" ) , %cons ( %con ( 
                             "Error.prototype.toString" ) , %nil ) ) ) , %emptyStmt ) , 
                             %seq ( %seq ( %vdecl ( "name" ) , %exp ( %bop ( %assign , 
                             %var ( "name" ) , %cond ( %bop ( %eqs , %mem ( %con ( %this 
                             ) , %con ( "name" ) ) , %var ( "undefined" ) ) , %con ( 
                             "Error" ) , %call ( %var ( "ToString" ) , %cons ( %mem ( 
                             %con ( %this ) , %con ( "name" ) ) , %nil ) ) ) ) ) ) , %seq
                              ( %seq ( %vdecl ( "msg" ) , %exp ( %bop ( %assign , %var ( 
                             "msg" ) , %cond ( %bop ( %eqs , %mem ( %con ( %this ) , %con
                              ( "message" ) ) , %var ( "undefined" ) ) , %con ( "" ) , 
                             %call ( %var ( "ToString" ) , %cons ( %mem ( %con ( %this ) 
                             , %con ( "message" ) ) , %nil ) ) ) ) ) ) , %seq ( %if ( 
                             %bop ( %eqs , %var ( "name" ) , %con ( "" ) ) , %return ( 
                             %var ( "msg" ) ) , %emptyStmt ) , %seq ( %if ( %bop ( %eqs ,
                              %var ( "msg" ) , %con ( "" ) ) , %return ( %var ( "name" ) 
                             ) , %emptyStmt ) , %return ( %bop ( %plus , %bop ( %plus , 
                             %var ( "name" ) , %con ( ": " ) ) , %var ( "msg" ) ) ) ) ) )
                              ) )
                           "Extensible" |-> true
                           "FormalParameters" |-> %nil
                           "Prototype" |-> @FunctionProtoOid
                           "Scope" |-> @GlobalEid
                           "Strict" |-> false
                       </internalProperties>
                   </obj>
           ) </objs>
           syntax Oid ::= "@oo" "(" Int ")"
           
           //////////////////////////////////////////////////////////////////////////////
           // 7.6.1 Reserved Words
           //////////////////////////////////////////////////////////////////////////////
           // TODO: This should have been used by a front-end such as 'js-trans.k' so that we can distinguish between 'Name' and 'String', both are 'PropertyName'.
           
           syntax KItem ::= "@CheckReserved" "(" Bool "," Var ")"
  2071284  rule @CheckReserved(Strict:Bool, X:Var)
  2071284    => If @IsReservedWord(Strict,X) = true then {
       21         Do @Throw(@SyntaxError("A reserved word cannot be used as an identifier",X));
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
     1415  rule %null => @NullVal
           
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
           
   180488  syntax Reference    ::= "@Ref" "(" K /* Base */ "," K /* Var */ "," K /* Bool */ ")" [seqstrict(1,2,3)]
           syntax ReferenceVal ::= "@Ref" "("      Base    ","      Var    ","      Bool    ")" [seqstrict(1,2,3)]
           syntax Reference ::= ReferenceVal
           syntax Val ::= ReferenceVal
           //rule isVal(@Ref(B:Base,N:Var,S:Bool)) => true
           //rule isVal(@Ref(B,N,S)) => isBase(B) ==K true andBool isVar(N) ==K true andBool isBool(S) ==K true
           
           syntax Base ::= UndefinedType
                         | Primitive
                         | Oid
                         | Eid
           /* FIXME:
           syntax Base
           rule isBase(Undefined) => true
           rule isBase(_:Primitive) => true
           rule isBase(_:Oid) => true
           rule isBase(_:Eid) => true
           */
           
           syntax KItem /* Base */ ::= "GetBase" "(" K /* Reference */ ")" [function]
           rule GetBase(@Ref(Base:Base,_,_)) => Base
           
           syntax Var ::= "GetReferencedName" "(" K /* Reference */ ")" [function]
           rule GetReferencedName(@Ref(_,Name:Var,_)) => Name
           
           syntax Bool ::= "IsStrictReference" "(" K /* Reference */ ")" [function]
           rule IsStrictReference(@Ref(_,_,Strict:Bool)) => Strict
           
           syntax Bool ::= "HasPrimitiveBase" "(" K /* Reference */ ")" [function]
           rule HasPrimitiveBase(@Ref(Undefined, _,_)) => false
           rule HasPrimitiveBase(@Ref(_:Primitive,_,_)) => true
           rule HasPrimitiveBase(@Ref(_:Oid,      _,_)) => false
           rule HasPrimitiveBase(@Ref(_:Eid,      _,_)) => false
           
           syntax Bool ::= "IsPropertyReference" "(" K /* Reference */ ")" [function]
           rule IsPropertyReference(@Ref(Undefined, _,_)) => false
           rule IsPropertyReference(@Ref(_:Primitive,_,_)) => true
           rule IsPropertyReference(@Ref(_:Oid,      _,_)) => true
           rule IsPropertyReference(@Ref(_:Eid,      _,_)) => false
           
           syntax Bool ::= "IsUnresolvableReference" "(" K /* Reference */ ")" [function]
           rule IsUnresolvableReference(@Ref(Base:Base,_,_)) => Base ==K Undefined
           
           // 8.7.1 GetValue (V)
           // TODO: Do we need to consider step 1?
           
   821096  syntax KItem /* Val */ ::= "GetValue" "(" K /* Reference */ ")" [seqstrict(1)]
           
   363762  rule GetValue(@Ref(E:Eid,      N:Var, Strict:Bool)) => GetBindingValue(E,N,Strict)
    56872  rule GetValue(@Ref(O:Oid,      P:Var, _          )) => Get(O,P)
           
      303  rule GetValue(@Ref(Undefined, P:Var, _          )) => @Throw(@ReferenceError("GetValue",P))
           
           /* NOTE: This does not work!!! [[Get]] with 'ToObject' differs from [[Get]] for Primitive base.
           rule GetValue(@Ref(B:Bool,     P:Var, Strict:Bool)) => GetValue(@Ref(ToObject(B),P,Strict))
           rule GetValue(@Ref(S:String,   P:Var, Strict:Bool)) => GetValue(@Ref(ToObject(S),P,Strict))
           rule GetValue(@Ref(N:Number,   P:Var, Strict:Bool)) => GetValue(@Ref(ToObject(N),P,Strict))
           */
           
      335  rule GetValue(@Ref(B:Primitive,P:Var, _          )) => GetPrimitive(B,P)
           
           syntax KItem /* Val */ ::= "GetPrimitive" "(" Primitive "," Var ")"
      335  rule GetPrimitive(Base:Primitive,P:Var)
      670    => Let $o = ToObject(Base);
      670       Let $desc = GetProperty($o:>Oid,P);
      335       If $desc = Undefined then {
       14         Return Undefined;
                } else {
      321         If IsDataDescriptor($desc:>Val) = true then {
      315           Return $desc."Value";
                  } else {
        6           Let $getter = $desc."Get";
        6           If $getter = Undefined then {
        0             Return Undefined;
                    } else {
       12             Return Call($getter,Base,@Nil); // NOTE: Only difference from Get@Default: 'Base' is used, instead of '$o'.
                    }
                  }
                }
           
           // 8.7.2 PutValue (V, W)
           
           // NOTE: Step 1 is covered by @GetReference that raise ReferenceError for non-reference expressions
           syntax KItem /* .K */ ::= "PutValue" "(" K /* Reference */ "," K /* Val */ ")" [seqstrict(1,2)]
           
    97677  rule PutValue(@Ref(E:Eid,      N:Var, Strict:Bool), V:Val) => SetMutableBinding(E,N,V,Strict) when (N =/=K "eval" andBool N =/=K "arguments") orBool Strict =/=K true
    12078  rule PutValue(@Ref(O:Oid,      P:Var, Strict:Bool), V:Val) => Put(O,         P,V,Strict)
      712  rule PutValue(@Ref(Undefined, P:Var, false      ), V:Val) => Put(@GlobalOid,P,V,false)
        3  rule PutValue(@Ref(Undefined, P:Var, true       ), _    ) => @Throw(@ReferenceError("PutValue",P))
           
           // NOTE: Handled by this: 11.13.1 step 4, 11.13.2 step 6, 11.3.1, 11.3.2, 11.4.4, 11.4.5
           rule PutValue(@Ref(_:Eid,      N:Var, true       ), _    ) => @Throw(@SyntaxError("PutValue",N)) when N ==K "eval" orBool N ==K "arguments"
           
           /*
           /* NOTE: This does not work!!! [[Put]] with 'ToObject' differs from [[Put]] for Primitive base.
           rule PutValue(@Ref(B:Bool,     P:Var, Strict:Bool), V:Val) => PutValue(@Ref(ToObject(B),P,Strict),V)
           rule PutValue(@Ref(S:String,   P:Var, Strict:Bool), V:Val) => PutValue(@Ref(ToObject(S),P,Strict),V)
           rule PutValue(@Ref(N:Number,   P:Var, Strict:Bool), V:Val) => PutValue(@Ref(ToObject(N),P,Strict),V)
           */
           
        8  rule PutValue(@Ref(B:Primitive,P:Var, Strict:Bool), V:Val) => PutPrimitive(B,P,V,Strict)
           
           syntax KItem /* Val */ ::= "PutPrimitive" "(" Primitive "," Var "," Val "," Bool ")"
        8  rule PutPrimitive(Base:Primitive,P:Var,V:Val,Throw:Bool)
       16    => Let $o = ToObject(Base);
       16       If CanPut($o:>Oid,P) = false then {
                  If Throw = true then {
        0           Do @Throw(@TypeError("PutPrimitive, cannot put",PutPrimitive(Base,P,V,Throw)));
                  } else {
        0           Return;
                  }
                } else {
       16         Let $ownDesc = GetOwnProperty($o:>Oid,P);
        8         If IsDataDescriptor($ownDesc:>Val) = true then {
                    // NOTE: different from [[Put]]: do not put value
                    If Throw = true then {
        0             Do @Throw(@TypeError("PutPrimitive, own Desc is a data descriptor",PutPrimitive(Base,P,V,Throw)));
                    } else {
        0             Return;
                    }
                  } else {
       16           Let $desc = GetProperty($o:>Oid,P);
        8           If IsAccessorDescriptor($desc:>Val) = true then {
        0             Let $setter = $desc."Set";
        0             DoI Call($setter:>Oid,Base,@Cons(V,@Nil)); // NOTE: different from [[Put]]: use 'Base' instead of '$o'
                    } else {
                      // NOTE: different from [[Put]]: do not put value
        8             If Throw = true then {
        0               Do @Throw(@TypeError("PutPrimitive, inherited Desc is a data descriptor",PutPrimitive(Base,P,V,Throw)));
                      } else {
        8               Return;
                      }
                    }
                  }
                }
           
           //////////////////////////////////////////////////////////////////////////////
           // 8.10 The Property Descriptor and Property Identifier Specification Types
           //////////////////////////////////////////////////////////////////////////////
           
           // 8.10.1 IsAccessorDescriptor ( Desc )
           
           syntax Bool ::= "IsAccessorDescriptor" "(" Val ")" [function]
           
           rule IsAccessorDescriptor(Undefined) => false
           rule IsAccessorDescriptor(@desc(Desc)) => ("Get" in keys(Desc)) orBool
                                                      ("Set" in keys(Desc))
           
           // 8.10.2 IsDataDescriptor ( Desc )
           
           syntax Bool ::= "IsDataDescriptor" "(" Val ")" [function]
           
           rule IsDataDescriptor(Undefined) => false
           rule IsDataDescriptor(@desc(Desc)) => ("Value"    in keys(Desc)) orBool
                                                  ("Writable" in keys(Desc))
           
           // 8.10.3 IsGenericDescriptor ( Desc )
           
           syntax Bool ::= "IsGenericDescriptor" "(" Val ")" [function]
           
           rule IsGenericDescriptor(Undefined) => false
           rule IsGenericDescriptor(@desc(Desc)) => notBool("Get"      in keys(Desc)) andBool
                                                     notBool("Set"      in keys(Desc)) andBool
                                                     notBool("Value"    in keys(Desc)) andBool
                                                     notBool("Writable" in keys(Desc))
           
           // 8.10.? IsValidDescriptor ( Desc )
           
           syntax Bool ::= "IsValidDescriptor" "(" PropertyDescriptor ")" [function]
           
           rule IsValidDescriptor(Desc:PropertyDescriptor) => notBool(IsAccessorDescriptor(Desc) andBool IsDataDescriptor(Desc))
           
           // 8.10.? IsFullyPopulatedDescriptor ( Desc )
           
           syntax Bool ::= "IsFullyPopulatedDescriptor" "(" PropertyDescriptor ")" [function]
           
           rule IsFullyPopulatedDescriptor(@desc("Value" |-> _ "Writable" |-> _ "Enumerable" |-> _ "Configurable" |-> _)) => true
           rule IsFullyPopulatedDescriptor(@desc("Get"   |-> _ "Set"      |-> _ "Enumerable" |-> _ "Configurable" |-> _)) => true
           
           // 8.10.? MakeFullyPopulatedDescriptor ( Desc )
           
           syntax PropertyDescriptor ::= "MakeFullyPopulatedDataDescriptor1" "(" PropertyDescriptor ")" [function]
           rule MakeFullyPopulatedDataDescriptor1(Desc:PropertyDescriptor) => MakeFullyPopulatedDataDescriptor2(Desc,@desc("Value" |-> Undefined "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false))
           
           syntax PropertyDescriptor ::= "MakeFullyPopulatedAccessorDescriptor1" "(" PropertyDescriptor ")" [function]
           rule MakeFullyPopulatedAccessorDescriptor1(Desc:PropertyDescriptor) => MakeFullyPopulatedAccessorDescriptor2(Desc,@desc("Get" |-> Undefined "Set" |-> Undefined "Enumerable" |-> false "Configurable" |-> false))
           
           syntax PropertyDescriptor ::= "MakeFullyPopulatedDataDescriptor2" "(" PropertyDescriptor "," PropertyDescriptor ")" [function]
           rule MakeFullyPopulatedDataDescriptor2(@desc(Desc),Default:PropertyDescriptor) => MakeFullyPopulatedDataDescriptor2(@desc(@AddMap("Value",       Default."Value",       Desc)),Default) when notBool("Value"        in keys(Desc))
           rule MakeFullyPopulatedDataDescriptor2(@desc(Desc),Default:PropertyDescriptor) => MakeFullyPopulatedDataDescriptor2(@desc(@AddMap("Writable",    Default."Writable",    Desc)),Default) when notBool("Writable"     in keys(Desc))
           rule MakeFullyPopulatedDataDescriptor2(@desc(Desc),Default:PropertyDescriptor) => MakeFullyPopulatedDataDescriptor2(@desc(@AddMap("Enumerable",  Default."Enumerable",  Desc)),Default) when notBool("Enumerable"   in keys(Desc))
           rule MakeFullyPopulatedDataDescriptor2(@desc(Desc),Default:PropertyDescriptor) => MakeFullyPopulatedDataDescriptor2(@desc(@AddMap("Configurable",Default."Configurable",Desc)),Default) when notBool("Configurable" in keys(Desc))
           rule MakeFullyPopulatedDataDescriptor2(@desc(Desc),Default:PropertyDescriptor) => @desc(Desc) when IsFullyPopulatedDescriptor(@desc(Desc))
           
           syntax PropertyDescriptor ::= "MakeFullyPopulatedAccessorDescriptor2" "(" PropertyDescriptor "," PropertyDescriptor ")" [function]
           rule MakeFullyPopulatedAccessorDescriptor2(@desc(Desc),Default:PropertyDescriptor) => MakeFullyPopulatedAccessorDescriptor2(@desc(@AddMap("Get",         Default."Get",         Desc)),Default) when notBool("Get"          in keys(Desc))
           rule MakeFullyPopulatedAccessorDescriptor2(@desc(Desc),Default:PropertyDescriptor) => MakeFullyPopulatedAccessorDescriptor2(@desc(@AddMap("Set",         Default."Set",         Desc)),Default) when notBool("Set"          in keys(Desc))
           rule MakeFullyPopulatedAccessorDescriptor2(@desc(Desc),Default:PropertyDescriptor) => MakeFullyPopulatedAccessorDescriptor2(@desc(@AddMap("Enumerable",  Default."Enumerable",  Desc)),Default) when notBool("Enumerable"   in keys(Desc))
           rule MakeFullyPopulatedAccessorDescriptor2(@desc(Desc),Default:PropertyDescriptor) => MakeFullyPopulatedAccessorDescriptor2(@desc(@AddMap("Configurable",Default."Configurable",Desc)),Default) when notBool("Configurable" in keys(Desc))
           rule MakeFullyPopulatedAccessorDescriptor2(@desc(Desc),Default:PropertyDescriptor) => @desc(Desc) when IsFullyPopulatedDescriptor(@desc(Desc))
           
           // 8.10.4 FromPropertyDescriptor ( Desc )
           
           syntax KItem /* Val */ ::= "FromPropertyDescriptor" "(" K /* PropertyDescriptor */ ")" [seqstrict(1)]
           
      680  rule FromPropertyDescriptor(Undefined) => Undefined
           
           syntax Id ::= "$obj"
           
     3595  rule FromPropertyDescriptor(Desc:PropertyDescriptor)
     7190    => Let $obj = @CreateObject;
     3595       DoI DefineOwnProperty($obj, "value",        @desc("Value" |-> Desc."Value"        "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     3595       DoI DefineOwnProperty($obj, "writable",     @desc("Value" |-> Desc."Writable"     "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     3595       DoI DefineOwnProperty($obj, "enumerable",   @desc("Value" |-> Desc."Enumerable"   "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     3595       DoI DefineOwnProperty($obj, "configurable", @desc("Value" |-> Desc."Configurable" "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     3595       Return $obj;
                when IsDataDescriptor(Desc) ==K true
             andBool IsFullyPopulatedDescriptor(Desc) ==K true
           
     1052  rule FromPropertyDescriptor(Desc:PropertyDescriptor)
     2104    => Let $obj = @CreateObject;
     1052       DoI DefineOwnProperty($obj, "get",          @desc("Value" |-> Desc."Get"          "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     1052       DoI DefineOwnProperty($obj, "set",          @desc("Value" |-> Desc."Set"          "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     1052       DoI DefineOwnProperty($obj, "enumerable",   @desc("Value" |-> Desc."Enumerable"   "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     1052       DoI DefineOwnProperty($obj, "configurable", @desc("Value" |-> Desc."Configurable" "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     1052       Return $obj;
                when IsAccessorDescriptor(Desc) ==K true
             andBool IsFullyPopulatedDescriptor(Desc) ==K true
           
           // 8.10.5 ToPropertyDescriptor ( Obj )
           // TODO: make it more elegant
           
           syntax KItem /* PropertyDescriptor */ ::= "ToPropertyDescriptor" "(" Val ")"
           
       18  rule ToPropertyDescriptor(V:Val) => @Throw(@TypeError("ToPropertyDescriptor",V)) when @IsOid(V) ==K false
           
           syntax Id ::= "$desc0" | "$desc1" | "$desc2" | "$desc3" | "$desc4" | "$desc5" | "$desc6"
           
     3315  rule ToPropertyDescriptor(O:Oid)
     3315    => Let $desc0 = @desc(.Map);
     6630       Let $desc1 = ToPropertyDescriptorAux(O,"enumerable",  $desc0:>PropertyDescriptor,"Enumerable");
     6630       Let $desc2 = ToPropertyDescriptorAux(O,"configurable",$desc1:>PropertyDescriptor,"Configurable");
     6630       Let $desc3 = ToPropertyDescriptorAux(O,"value",       $desc2:>PropertyDescriptor,"Value");
     6630       Let $desc4 = ToPropertyDescriptorAux(O,"writable",    $desc3:>PropertyDescriptor,"Writable");
     6615       Let $desc5 = ToPropertyDescriptorAux(O,"get",         $desc4:>PropertyDescriptor,"Get");
     6584       Let $desc6 = ToPropertyDescriptorAux(O,"set",         $desc5:>PropertyDescriptor,"Set");
     3284       If IsValidDescriptor($desc6:>PropertyDescriptor) = true then {
     3272         Return $desc6;
                } else {
       12         Do @Throw(@TypeError("ToPropertyDescriptor InvalidDescriptor",$desc6));
                }
           
           syntax KItem /* PropertyDescriptor */ ::= "ToPropertyDescriptorAux" "(" Oid "," Var "," PropertyDescriptor "," String ")"
           
           syntax Id ::= "$value"
           
     9945  rule ToPropertyDescriptorAux(O:Oid,P:Var,Desc:PropertyDescriptor,Attr:String) =>
    19890       If HasProperty(O,P) = true then {
     6536         Let $value = ToBoolean(Get(O,P));
     6536         Return @AddDesc(Attr, $value, Desc);
                } else {
     6677         Return Desc;
                }
                when (P ==K "enumerable"   andBool Attr ==K "Enumerable")
              orBool (P ==K "configurable" andBool Attr ==K "Configurable")
              orBool (P ==K "writable"     andBool Attr ==K "Writable")
           
     3315  rule ToPropertyDescriptorAux(O:Oid,P:Var,Desc:PropertyDescriptor,Attr:String) =>
     6630       If HasProperty(O,P) = true then {
     2324         Let $value = Get(O,P);
     2324         Return @AddDesc(Attr, $value, Desc);
                } else {
     2153         Return Desc;
                }
                when P ==K "value" andBool Attr ==K "Value"
           
     6615  rule ToPropertyDescriptorAux(O:Oid,P:Var,Desc:PropertyDescriptor,Attr:String) =>
    13230       If HasProperty(O,P) = true then {
     3304         Let $value = Get(O,P);
     3304         If IsCallable($value) = true then {
     1377           Nop;
                  } else {
      275           If $value = Undefined then {
      244             Nop;
                    } else {
       31             Do @Throw(@TypeError("ToPropertyDescriptorAux",$value));
                    }
                  }
     3242         Return @AddDesc(Attr, $value, Desc);
                } else {
     4963         Return Desc;
                }
                when (P ==K "get" andBool Attr ==K "Get")
              orBool (P ==K "set" andBool Attr ==K "Set")
           
           //////////////////////////////////////////////////////////////////////////////
           // 8.12 Algorithms for Object Internal Methods
           //////////////////////////////////////////////////////////////////////////////
           
           // 8.12.1 [[GetOwnProperty]] (P)
           
           syntax KItem /* Val */ ::= "GetOwnProperty" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict(1,2)]
           
  3160031  rule GetOwnProperty(O:Oid,P:Var)
  6320058    => If @IsArgumentsObjectNonStrictWithFormalParams(O) = true then {
    34384         Do GetOwnProperty@Arguments(O,P);
                } else {
  6251283         If @IsStringObject(O) = true then {
     5075           Do GetOwnProperty@String(O,P);
                  } else {
  3120565           Do GetOwnProperty@Default(O,P);
                  }
                }
           
           syntax KItem /* Val */ ::= "GetOwnProperty@Default" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict(1,2)]
           
  1873169  rule <k> GetOwnProperty@Default(O:Oid,P:Var) => V ... </k>
                <obj>
                  <oid> O </oid>
                  <properties> P |-> V:Val _:Map </properties>
                  _
                </obj>
  1286851  rule <k> GetOwnProperty@Default(O:Oid,P:Var) => Undefined ... </k>
                <obj>
                  <oid> O </oid>
                  <properties> Prop:Map </properties>
                  _
                </obj>
                when notBool(P in keys(Prop))
           
           // 8.12.? [[GetInternalProperty]] (P)
           
           syntax KItem /* Val */ ::= "GetInternalProperty" "(" Oid "," Var ")"
           
   737886  rule <k> GetInternalProperty(O:Oid,P:Var) => V ... </k>
                <obj>
                  <oid> O </oid>
                  <internalProperties> P |-> V:Val _:Map </internalProperties>
                  _
                </obj>
           rule <k> GetInternalProperty(O:Oid,P:Var) => Undefined ... </k>
                <obj>
                  <oid> O </oid>
                  <internalProperties> Prop:Map </internalProperties>
                  _
                </obj>
                when notBool(P in keys(Prop))
           
           // 8.12.? [[SetInternalProperty]] (P,V)
           
           syntax KItem /* .K */ ::= "SetInternalProperty" "(" Oid "," Var "," Val ")"
           
   124145  rule <k> SetInternalProperty(O:Oid,P:Var,V:Val) => . ... </k>
                <obj>
                  <oid> O </oid>
                  <internalProperties> Prop:Map => @AddMap(P,V,Prop) </internalProperties>
                  _
                </obj>
           
           // 8.12.? [[GetInheritedProperty]] (P)
           
           syntax KItem /* Val */ ::= "GetInheritedProperty" "(" Oid "," Var ")"
           
   414665  rule <k> GetInheritedProperty(O:Oid,P:Var) => GetProperty(O',P) ... </k>
                <obj>
                  <oid> O </oid>
                  <internalProperties> "Prototype" |-> O':Oid _:Map </internalProperties>
                  _
                </obj>
                when O' =/=K @NullOid
   393016  rule <k> GetInheritedProperty(O:Oid,_) => Undefined ... </k>
                <obj>
                  <oid> O </oid>
                  <internalProperties> "Prototype" |-> @NullOid _:Map </internalProperties>
                  _
                </obj>
           
           // 8.12.? [[GetInheritedPropertyOwner]] (P)
           
           syntax KItem /* Val */ ::= "GetInheritedPropertyOwner" "(" Oid "," Var ")"
           
       28  rule <k> GetInheritedPropertyOwner(O:Oid,P:Var) => GetPropertyOwner(O',P) ... </k>
                <obj>
                  <oid> O </oid>
                  <internalProperties> "Prototype" |-> O':Oid _:Map </internalProperties>
                  _
                </obj>
                when O' =/=K @NullOid
           rule <k> GetInheritedPropertyOwner(O:Oid,_) => @NullOid ... </k>
                <obj>
                  <oid> O </oid>
                  <internalProperties> "Prototype" |-> @NullOid _:Map </internalProperties>
                  _
                </obj>
           
           // 8.12.2 [[GetProperty]] (P)
           
           syntax KItem /* Val */ ::= "GetProperty" "(" Oid "," Var ")"
           
           syntax Id ::= "$prop"
  1673652  rule GetProperty(O:Oid,P:Var)
  3347293    => Let $prop = GetOwnProperty(O,P);
  1673641       If $prop = Undefined then {
  1615362         Return GetInheritedProperty(O,P);
                } else {
   865960         Return $prop;
                }
           
           // 8.12.? [[GetPropertyOwner]] (P)
           
           syntax KItem /* Val */ ::= "GetPropertyOwner" "(" Oid "," Var ")"
           
     4339  rule GetPropertyOwner(O:Oid,P:Var)
     8678    => Let $prop = GetOwnProperty(O,P);
     4339       If $prop = Undefined then {
       56         Return GetInheritedPropertyOwner(O,P);
                } else {
     4311         Return O;
                }
           
           // 8.12.3 [[Get]] (P)
           
      306  syntax KItem /* Val */ ::= "Get" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict(1,2)]
           
   281423  rule Get(O:Oid,P:Var)
   562843    => If @IsArgumentsObjectNonStrictWithFormalParams(O) = true then {
     8510         Do Get@Arguments(O,P);
                } else {
   272910         Do Get@Default(O,P);
                }
           
           syntax KItem /* Val */ ::= "Get@Default" "(" Oid "," Var ")" 
           
           syntax Id ::= "$desc" | "$getter"
   278941  rule Get@Default(O:Oid,P:Var)
   557879    => Let $desc = GetProperty(O,P);
   278937       If $desc = Undefined then {
      734         Return Undefined;
                } else {
   278203         If IsDataDescriptor($desc:>Val) = true then {
   274771           Return $desc."Value";
                  } else {
     3432           Let $getter = $desc."Get";
     3432           If $getter = Undefined then {
      154             Return Undefined;
                    } else {
     6510             Return Call($getter,O,@Nil);
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
           
           syntax KItem /* Bool */ ::= "CanPut" "(" Oid "," Var ")"
           
           syntax Id ::= "$proto" | "$inherited"
   258792  rule CanPut(O:Oid,P:Var)
   517584    => Let $desc = GetOwnProperty(O,P);
   258792       If $desc = Undefined then {
    22216         Let $proto = GetInternalProperty(O,"Prototype");
    11108         If $proto = @NullOid then {
       60           Return GetInternalProperty(O,"Extensible");
                  } else {
    22156           Let $inherited = GetProperty($proto:>Oid,P);
    11078           If $inherited = Undefined then {
     8352             Return GetInternalProperty(O,"Extensible");
                    } else {
     6902             If IsAccessorDescriptor($inherited:>Val) = true then {
       13               If $inherited."Set" = Undefined then {
        6                 Return false;
                        } else {
        7                 Return true;
                        }
                      } else {
    13778               If GetInternalProperty(O,"Extensible") = false then {
        0                 Return false;
                        } else {
     6889                 Return $inherited."Writable";
                        }
                      }
                    }
                  }
                } else {
   247684         If IsAccessorDescriptor($desc:>Val) = true then {
      325           If $desc."Set" = Undefined then {
       25             Return false;
                    } else {
      300             Return true;
                    }
                  } else {
   247359           Return $desc."Writable";
                  }
                }
           
           // 8.12.5 [[Put]] ( P, V, Throw )
           
           syntax KItem /* .K */ ::= "Put" "(" K /* Oid */ "," K /* Var */ "," K /* Val */ "," K /* Bool */ ")" [seqstrict(1,2,3,4)]
           
           syntax Id ::= "$ownDesc" | "$valueDesc" | "$setter" | "$newDesc"
   258784  rule Put(O:Oid,P:Var,V:Val,Throw:Bool)
   517568    => If CanPut(O,P) = false then {
      461         If Throw = true then {
       49           Do @Throw(@TypeError("Put",Put(O,P,V,Throw)));
                  } else {
      412           Return;
                  }
                } else {
   516646         Let $ownDesc = GetOwnProperty(O,P);
   258323         If IsDataDescriptor($ownDesc:>Val) = true then {
   246977           Let $valueDesc = @desc("Value" |-> V);
   246977           DoI DefineOwnProperty(O,P,$valueDesc:>PropertyDescriptor,Throw);
                  } else {
    22692           Let $desc = GetProperty(O,P);
    11346           If IsAccessorDescriptor($desc:>Val) = true then {
      307             Let $setter = $desc."Set";
      307             DoI Call($setter:>Oid,O,@Cons(V,@Nil));
                    } else {
    11039             Let $newDesc = @desc("Value" |-> V "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true);
    11039             DoI DefineOwnProperty(O,P,$newDesc:>PropertyDescriptor,Throw);
                    }
                  }
                }
           
           // 8.12.? [[HasOwnProperty]] (P)
           
           syntax KItem /* Bool */ ::= "HasOwnProperty" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict(1,2)]
           
           rule HasOwnProperty(O:Oid,P:Var)
             => If GetOwnProperty(O,P) = Undefined then {
                  Return false;
                } else {
                  Return true;
                }
           
           // 8.12.6 [[HasProperty]] (P)
           
      114  syntax KItem /* Bool */ ::= "HasProperty" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict(1,2)]
           
   952958  rule HasProperty(O:Oid,P:Var)
  1905906    => If GetProperty(O,P) = Undefined then {
   383917         Return false;
                } else {
   569030         Return true;
                }
           
           // 8.12.7 [[Delete]] (P, Throw)
           
    11267  syntax KItem /* Bool */ ::= "Delete" "(" K /* Oid */ "," K /* Var */ "," K /* Bool */ ")" [seqstrict(1,2,3)]
           
     5731  rule Delete(O:Oid,P:Var,Throw:Bool)
    11462    => If @IsArgumentsObjectNonStrictWithFormalParams(O) = true then {
       39         Do Delete@Arguments(O,P,Throw);
                } else {
     5692         Do Delete@Default(O,P,Throw);
                }
           
           syntax KItem /* Bool */ ::= "Delete@Default" "(" Oid "," Var "," Bool ")" 
           
     4424  rule <k> Delete@Default(O:Oid,P:Var,Throw:Bool) => true ... </k>
                <obj>
                  <oid> O </oid>
                  <properties> Prop:Map </properties>
                  _
                </obj>
                when notBool(P in keys(Prop))
      741  rule <k> Delete@Default(O:Oid,P:Var,Throw:Bool) => true ... </k>
                <obj>
                  <oid> O </oid>
                  <properties>
                    (P |-> @desc("Configurable" |-> true _) => .Map)
                    _:Map
                  </properties>
                  _
                </obj>
      566  rule <k> Delete@Default(O:Oid,P:Var,Throw:Bool) => Reject(Throw,"Delete@Default",Delete@Default(O,P,Throw)) ... </k>
                <obj>
                  <oid> O </oid>
                  <properties>
                    P |-> @desc("Configurable" |-> false _)
                    _:Map
                  </properties>
                  _
                </obj>
           
           // 8.12.8 [[DefaultValue]] (hint)
           
           syntax KItem /* Val */ ::= "DefaultValue" "(" Oid "," String ")" 
           // TODO: Can we make it more elegant?
           
           syntax Id ::= "$toString" | "$valueOf" | "$str" | "$val"
           
      647  rule DefaultValue(O:Oid,"String")
             => BEGIN
     1293       Let $toString = Get(O,"toString");
     1292       If IsCallable($toString) = true then {
     1269         Let $str = Call($toString,O,@Nil);
      626         If @IsPrimitive($str:>Val) = true then {
      601           Return $str; Exit;
                  };
                };
       56       Let $valueOf = Get(O,"valueOf");
       56       If IsCallable($valueOf) = true then {
       54         Let $val = Call($valueOf,O,@Nil);
       26         If @IsPrimitive($val:>Val) = true then {
       15           Return $val; Exit;
                  };
                };
       11       Do @Throw(@TypeError("DefaultValue String",O));
                END
           
     1999  rule DefaultValue(O:Oid,"Number")
             => BEGIN
     3998       Let $valueOf = Get(O,"valueOf");
     3998       If IsCallable($valueOf) = true then {
     3949         Let $val = Call($valueOf,O,@Nil);
     1950         If @IsPrimitive($val:>Val) = true then {
     1637           Return $val; Exit;
                  };
                };
      626       Let $toString = Get(O,"toString");
      626       If IsCallable($toString) = true then {
      621         Let $str = Call($toString,O,@Nil);
      308         If @IsPrimitive($str:>Val) = true then {
      274           Return $str; Exit;
                  };
                };
       34       Do @Throw(@TypeError("DefaultValue Number",O));
                END
           
        5  rule <k> DefaultValue(O:Oid,"") => DefaultValue(O,"String") ... </k>
                <obj>
                  <oid> O </oid>
                  <internalProperties> "Class" |-> "Date" _:Map </internalProperties>
                  _
                </obj>
           
      308  rule <k> DefaultValue(O:Oid,"") => DefaultValue(O,"Number") ... </k>
                <obj>
                  <oid> O </oid>
                  <internalProperties> "Class" |-> Class:String _:Map </internalProperties>
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
           
   186630  syntax KItem /* Bool */ ::= "DefineOwnProperty" "(" K /* Oid */ "," K /* Var */ "," K /* PropertyDescriptor */ "," K /* Bool */ ")" [seqstrict(1,2,3,4)]
           
   664387  rule DefineOwnProperty(O:Oid,P:Var,Desc:PropertyDescriptor,Throw:Bool)
  1328772    => If @IsArgumentsObjectNonStrictWithFormalParams(O) = true then {
    27859         Do DefineOwnProperty@Arguments(O,P,Desc,Throw);
                } else {
  1273052         If @IsArrayObject(O) = true then {
     3031           Do DefineOwnProperty@Array(O,P,Desc,Throw);
                  } else {
   633495           Do DefineOwnProperty@Default(O,P,Desc,Throw);
                  }
                }
           
     1930  syntax KItem /* Bool */ ::= "DefineOwnProperty@Default" "(" K /* Oid */ "," K /* Var */ "," K /* PropertyDescriptor */ "," K /* Bool */ ")" [seqstrict(1,2,3,4)]
           
           syntax Id ::= "$current" | "$current2" | "$extensible"
   665319  rule DefineOwnProperty@Default(O:Oid,P:Var,Desc:PropertyDescriptor,Throw:Bool) =>
              //@LOG(DefineOwnProperty@Default(O,P,Desc,Throw)) ~>
                BEGIN
  1330635       Let $current = GetOwnProperty(O,P);
              //Do @LOG($current);
              //Do @LOG(IsDataDescriptor($current:>PropertyDescriptor));
              //Do @LOG(IsDataDescriptor(Desc));
  1330632       Let $extensible = GetInternalProperty(O,"Extensible");
   665316       If $current = Undefined then {
   416444         If $extensible = false then {
        7           Return Reject(Throw,"DefineOwnProperty@Default not extensible",DefineOwnProperty@Default(O,P,Desc,Throw)); Exit;
                  } else {
   832878           If @OrBool(IsGenericDescriptor(Desc), IsDataDescriptor(Desc)) = true then {
                    //Do @LOG("Data");
                    //Do @LOG(Desc);
   361846             Do SetOwnProperty(O,P,MakeFullyPopulatedDataDescriptor1(Desc));
                    } else {
                    //Do @LOG("Accessor");
                    //Do @LOG(Desc);
    54593             Do SetOwnProperty(O,P,MakeFullyPopulatedAccessorDescriptor1(Desc));
                    }
   416439           Return true;
                  }
                } else {
   248872         If @SubDesc(Desc,$current:>PropertyDescriptor) = true then {
       10           Return true;
                  } else {
   248862           If $current."Configurable" = false then {
   243441             If Desc."Configurable" = true then {
      100               Return Reject(Throw,"DefineOwnProperty@Default conflict configurable",DefineOwnProperty@Default(O,P,Desc,Throw)); Exit;
                      };
   486718             If @OrBool(@AndBool(@EqVal($current."Enumerable", true ), @EqVal(Desc."Enumerable", false)),
                                  @AndBool(@EqVal($current."Enumerable", false), @EqVal(Desc."Enumerable", true ))) = true then {
       46               Return Reject(Throw,"DefineOwnProperty@Default conflict enumerable",DefineOwnProperty@Default(O,P,Desc,Throw)); Exit;
                      };
                    };
   248740           If IsGenericDescriptor(Desc) = true then {
      100             Nop;
                    } else {
   497280             If @OrBool(@AndBool(IsDataDescriptor($current:>PropertyDescriptor), IsAccessorDescriptor(Desc)),
                                  @AndBool(IsAccessorDescriptor($current:>PropertyDescriptor), IsDataDescriptor(Desc))) = true then {
       91               If $current."Configurable" = false then {
       36                 Return Reject(Throw,"DefineOwnProperty@Default conflict descriptor type",DefineOwnProperty@Default(O,P,Desc,Throw)); Exit;
                        };
                      //Do @LOG("convert");
       61               Do ConvertDescriptorType(O,P);
                      } else {
   497098               If @AndBool(IsDataDescriptor($current:>PropertyDescriptor), IsDataDescriptor(Desc)) = true then {
   248370                 If $current."Configurable" = false then {
   486400                   If @AndBool(@EqVal($current."Writable", false), @EqVal(Desc."Writable", true)) = true then {
       23                     Return Reject(Throw,"DefineOwnProperty@Default conflict writable",DefineOwnProperty@Default(O,P,Desc,Throw)); Exit;
                            };
   486364                   If @AndBool(@AndBool(@EqVal($current."Writable", false), @NeqVal(Desc."Value", Undefined)), @NotBool(SameValue(Desc."Value",$current."Value"))) = true then {
       89                     Return Reject(Throw,"DefineOwnProperty@Default not writable",DefineOwnProperty@Default(O,P,Desc,Throw)); Exit;
                            };
                          };
                        } else {
      179                 If $current."Configurable" = false then {
      164                   If @AndBool(@NeqVal(Desc."Set", Undefined), @NotBool(SameValue(Desc."Set",$current."Set"))) = true then {
       31                     Return Reject(Throw,"DefineOwnProperty@Default conflict set",DefineOwnProperty@Default(O,P,Desc,Throw)); Exit;
                            };
      112                   If @AndBool(@NeqVal(Desc."Get", Undefined), @NotBool(SameValue(Desc."Get",$current."Get"))) = true then {
       27                     Return Reject(Throw,"DefineOwnProperty@Default conflict get",DefineOwnProperty@Default(O,P,Desc,Throw)); Exit;
                            };
                          };
                        }
                      }
                    }
   497166           Let $current2 = GetOwnProperty(O,P);
   497166           If @OrBool(IsGenericDescriptor($current2:>PropertyDescriptor), IsDataDescriptor($current2:>PropertyDescriptor)) = true then {
                    //Do @LOG("Data");
                    //Do @LOG(Desc);
                    //Do @LOG($current2);
   248386             Do SetOwnProperty(O,P,MakeFullyPopulatedDataDescriptor2(Desc,$current2:>PropertyDescriptor));
                    } else {
                    //Do @LOG("Accessor");
                    //Do @LOG(Desc);
                    //Do @LOG($current2);
      197             Do SetOwnProperty(O,P,MakeFullyPopulatedAccessorDescriptor2(Desc,$current2:>PropertyDescriptor));
                    }
   248583           Return true;
                  }
                }
                END
           
           syntax KItem /* .K */ ::= "ConvertDescriptorType" "(" Oid "," Var ")"
       40  rule <k> ConvertDescriptorType(O:Oid,P:Var) => . ... </k>
                <obj>
                  <oid> O </oid>
                  <properties>
                    P |-> ( @desc(                                               "Enumerable" |-> Enumerable:Bool "Configurable" |-> Configurable:Bool  M:Map)
                         => @desc("Get"   |-> Undefined "Set"      |-> Undefined "Enumerable" |-> Enumerable      "Configurable" |-> Configurable     ) )
                    _:Map
                  </properties>
                  _
                </obj>
                when "Value" in keys(M) andBool "Writable" in keys(M)
       21  rule <k> ConvertDescriptorType(O:Oid,P:Var) => . ... </k>
                <obj>
                  <oid> O </oid>
                  <properties>
                    P |-> ( @desc(                                                "Enumerable" |-> Enumerable:Bool "Configurable" |-> Configurable:Bool  M:Map)
                         => @desc("Value" |-> Undefined "Writable" |-> false      "Enumerable" |-> Enumerable      "Configurable" |-> Configurable     ) )
                    _:Map
                  </properties>
                  _
                </obj>
                when "Get" in keys(M) andBool "Set" in keys(M)
           
           syntax KItem /* .K */ ::= "SetOwnProperty" "(" K /* Oid */ "," K /* Var */ "," K /* Val */ ")" [seqstrict(1,2,3)]
   665022  rule <k> SetOwnProperty(O:Oid,P:Var,V:Val) => . ... </k>
                <obj>
                  <oid> O </oid>
                  <properties> Prop:Map => @AddMap(P,V,Prop) </properties>
                  _
                </obj>
           
           syntax KItem /* Bool */ ::= "Reject" "(" Bool "," String "," K ")"
      301  rule Reject(true, S:String,K:K) => @Throw(@TypeError("Reject" +String S, K))
      633  rule Reject(false,_,       _  ) => false
           
           //////////////////////////////////////////////////////////////////////////////
           // 9 Type Conversion and Testing
           //////////////////////////////////////////////////////////////////////////////
           
           // 9.1 ToPrimitive
           
           syntax KItem /* Val */ ::= "ToPrimitive" "(" K /* Val */ "," String ")" [seqstrict(1)]
           
      108  rule ToPrimitive(Undefined,               _) => Undefined
       97  rule ToPrimitive(@NullVal,                 _) => @NullVal
      108  rule ToPrimitive(B:Bool,                   _) => B
    35180  rule ToPrimitive(S:String,                 _) => S
    50769  rule ToPrimitive(N:Number,                 _) => N
     2646  rule ToPrimitive(O:Oid, PreferredType:String) => DefaultValue(O,PreferredType)
           
           // 9.2 ToBoolean
           
    38700  syntax KItem /* Bool */ ::= "ToBoolean" "(" K /* Val */ ")" [seqstrict(1)]
           
      128  rule ToBoolean(Undefined) => false
       21  rule ToBoolean(@NullVal  ) => false
   100194  rule ToBoolean(B:Bool    ) => B
      192  rule ToBoolean(S:String  ) => true when S =/=String ""
       23  rule ToBoolean(""        ) => false
       98  rule ToBoolean(N:Number  ) => true when N =/=K 0 andBool N =/=K @NaN andBool N =/=K @nz
       61  rule ToBoolean(0         ) => false
       16  rule ToBoolean(@nz       ) => false
       19  rule ToBoolean(@NaN      ) => false
      249  rule ToBoolean(O:Oid     ) => true
           
           // 9.3 ToNumber
           
    31614  syntax KItem /* Number */ ::= "ToNumber" "(" K /* Val */ ")" [seqstrict(1)]
           
      468  rule ToNumber(Undefined) => @NaN
      446  rule ToNumber(@NullVal  ) => 0
      977  rule ToNumber(true      ) => 1
       78  rule ToNumber(false     ) => 0
     9057  rule ToNumber(S:String  ) => @StringToNumber(trim(replaceAll(S,"\n","")))
   105074  rule ToNumber(N:Number  ) => N
     1411  rule ToNumber(O:Oid     ) => ToNumber(ToPrimitive(O,"Number"))
           
           // 9.3.1 ToNumber Applied to the String Type
           
           syntax KItem /* Bool */ ::= "@IsStrNumericLiteral" "(" String ")" [function]
           rule @IsStrNumericLiteral(N:String) => @IsStrNumericLiteralAux(#parse(N,"StrNumericLiteral"))
           
           syntax KItem /* Bool */ ::= "@IsStrNumericLiteralAux" "(" K /* StrNumericLiteral */ ")" [function]
           rule @IsStrNumericLiteralAux(K) => isStrNumericLiteral(K) ==K true
           /*
           rule @IsStrNumericLiteralAux(_:StrNumericLiteral) => true
           rule @IsStrNumericLiteralAux(#noparse) => false
           */
           
           syntax KItem /* Number */ ::= "@StringToNumber" "(" String ")"
           syntax Id ::= "$isMinus" | "$num" | "$num2"
     9057  rule @StringToNumber(S:String)
     9057    => If lengthString(S) ==Int 0 = true then {
       76         Return 0;
                } else {
     8981         If @IsStrNumericLiteral(S) = true then {
     6394           Let $isMinus = @IsMinus(S);
    12788           Let $str = @RemoveLeadingZeros(@RemoveLeadingSign(S));
    12787           Let $num = @ResolveOverflow(@StringToNumber@Core($str:>String));
     6393           If $isMinus = true then {
      204             Return %bop(%times, -1, $num:>Number);
                    } else {
     6291             Return $num;
                    }
                  } else {
     2587           Return @NaN;
                  }
                }
           
           syntax KItem /* Number */ ::= "@StringToNumber@Core" "(" String ")"
           syntax Id ::= "$s"
     6394  rule @StringToNumber@Core(S:String)
     6394    => If S = "Infinity" then {
       44         Return @+Infinity;
                } else {
     6350         If @IsHexIntegerLiteral(S) = true then {
      100           Let $s = @SubstrString(S,1,lengthString(S));
      100           Return @String2Base($s:>String, 16);
                  } else {
     6300           If @IsFloatLiteral(S) = true then {
      176             Return @String2Float(S);
                    } else {
    12424             Return @String2Int(S);
                    }
                  }
                }
           
           syntax Bool ::= "@IsMinus" "(" String ")" [function]
           rule @IsMinus(S:String) => substrString(S,0,1) ==String "-"
           
           syntax KItem /* String */ ::= "@RemoveLeadingSign" "(" K /* String */ ")" [seqstrict(1)]
           syntax Id ::= "$prefix"
     6394  rule @RemoveLeadingSign(S:String)
     6394    => If lengthString(S) >=Int 2 = true then {
     6314         Let $prefix = @SubstrString(S,0,1);
     6314         If @OrBool($prefix:>String ==String "+", $prefix:>String ==String "-") = true then {
      296           Return @SubstrString(S,1,lengthString(S));
                  } else {
     3009           Return S;
                  }
                } else {
     3237         Return S;
                }
           
    12914  syntax KItem /* String */ ::= "@RemoveLeadingZeros" "(" K /* String */ ")" [seqstrict(1)]
     6457  rule @RemoveLeadingZeros(S:String)
     6457    => If lengthString(S) >=Int 2 = true then {
     6300         If @SubstrString(S,0,1) = "0" then {
      142           If @SubstrString(S,1,2) = "." then {
        8             Return S;
                    } else {
      126             Return @RemoveLeadingZeros(@SubstrString(S,1,lengthString(S)));
                    }
                  } else {
     3079           Return S;
                  }
                } else {
     3307         Return S;
                }
           
           syntax Bool ::= "@IsHexIntegerLiteral" "(" String ")" [function]
           rule @IsHexIntegerLiteral(S:String) => substrString(S,0,1) ==String "x"
                                           orBool substrString(S,0,1) ==String "X"
           
           syntax Bool ::= "@IsFloatLiteral" "(" String ")" [function]
           rule @IsFloatLiteral(S:String) => @HasPoint(S) orBool @HasExponentPart(S)
           
           syntax Bool ::= "@HasExponentPart" "(" String ")" [function]
           rule @HasExponentPart(S:String) => findString(S, "e", 0) =/=Int -1
                                       orBool findString(S, "E", 0) =/=Int -1
           
           syntax Bool ::= "@HasPoint" "(" String ")" [function]
           rule @HasPoint(S:String) => findString(S, ".", 0) =/=Int -1
           
           // 9.4 ToInteger
           
           syntax KItem /* Val */ ::= "ToInteger" "(" Val ")"
           
     2576  rule ToInteger(V:Val) => @NumberToInteger(ToNumber(V))
           
           // TODO: Do more correctly
     5147  syntax KItem /* Int */ ::= "@NumberToInteger" "(" K /* Number */ ")" [seqstrict(1)]
      422  rule @NumberToInteger(I:Int  ) => I
       13  rule @NumberToInteger(F:Float) => Float2Int(F)
        2  rule @NumberToInteger(@nz    ) => @nz
     2114  rule @NumberToInteger(@NaN   ) => 0
       14  rule @NumberToInteger(@+Infinity) => @+Infinity
        6  rule @NumberToInteger(@-Infinity) => @-Infinity
           
           // 9.5 ToInt32: (Signed 32 Bit Integer)
           
      209  syntax KItem /* Int32 */ ::= "ToInt32" "(" K /* Val */ ")" [seqstrict(1)]
           
     6045  rule ToInt32(V:Val) => @NumberToInt32(ToNumber(V))
           
    12075  syntax KItem /* Int32 */ ::= "@NumberToInt32" "(" K /* Number */ ")" [seqstrict(1)]
     5789  rule @NumberToInt32(I:Int  )    => @IntToInt32(I)
       28  rule @NumberToInt32(F:Float)    => @IntToInt32(Float2Int(F))
        2  rule @NumberToInt32(@nz    )    => 0
      206  rule @NumberToInt32(@NaN   )    => 0
        3  rule @NumberToInt32(@+Infinity) => 0
        2  rule @NumberToInt32(@-Infinity) => 0
           
           syntax KItem /* Int32 */ ::= "@IntToInt32" "(" Int ")"
     5817  rule @IntToInt32(I:Int) => svalueMInt(mi(32,I))
           
           // 9.6 ToUint32: (Unsigned 32 Bit Integer)
           
           syntax KItem /* Val */ ::= "ToUint32" "(" K /* Val */ ")" [seqstrict(1)]
           
    16568  rule ToUint32(V:Val) => @NumberToUint32(ToNumber(V))
           
    33118  syntax KItem /* Int32 */ ::= "@NumberToUint32" "(" K /* Number */ ")" [seqstrict(1)]
    15951  rule @NumberToUint32(I:Int  )    => @IntToUint32(I)
      225  rule @NumberToUint32(F:Float)    => @IntToUint32(Float2Int(F))
        5  rule @NumberToUint32(@nz    )    => 0
      351  rule @NumberToUint32(@NaN   )    => 0
        9  rule @NumberToUint32(@+Infinity) => 0
        9  rule @NumberToUint32(@-Infinity) => 0
           
           syntax KItem /* Uint32 */ ::= "@IntToUint32" "(" Int ")"
    16176  rule @IntToUint32(I:Int) => uvalueMInt(mi(32,I))
           
           // 9.7 ToUint16: (Unsigned 16 Bit Integer)
           
           syntax KItem /* Val */ ::= "ToUint16" "(" Val ")"
           
      122  rule ToUint16(V:Val) => @NumberToUint16(ToNumber(V))
           
      244  syntax KItem /* Int32 */ ::= "@NumberToUint16" "(" K /* Number */ ")" [seqstrict(1)]
      108  rule @NumberToUint16(I:Int  )    => @IntToUint16(I)
        4  rule @NumberToUint16(F:Float)    => @IntToUint16(Float2Int(F))
        2  rule @NumberToUint16(@nz    )    => 0
        4  rule @NumberToUint16(@NaN   )    => 0
        2  rule @NumberToUint16(@+Infinity) => 0
        2  rule @NumberToUint16(@-Infinity) => 0
           
           syntax KItem /* Uint16 */ ::= "@IntToUint16" "(" Int ")"
      112  rule @IntToUint16(I:Int) => uvalueMInt(mi(16,I))
           
           // 9.8 ToString
           
    11189  syntax KItem /* Val */ ::= "ToString" "(" K /* Val */ ")" [seqstrict(1)]
           
       55  rule ToString(Undefined) => "undefined"
       35  rule ToString(@NullVal  ) => "null"
       48  rule ToString(true      ) => "true"
       18  rule ToString(false     ) => "false"
   142824  rule ToString(S:String  ) => S
   115406  rule ToString(I:Int     ) => #external("node\x01-p\x01-e\x01String(" +String Int2String(I)   +String ")")
      121  rule ToString(F:Float   ) => #external("node\x01-p\x01-e\x01String(" +String Float2String(F) +String ")")
        5  rule ToString(@nz       ) => "0"
       28  rule ToString(@NaN      ) => "NaN"
       23  rule ToString(@+Infinity) =>  "Infinity"
       12  rule ToString(@-Infinity) => "-Infinity"
      642  rule ToString(O:Oid     ) => ToString(ToPrimitive(O,"String"))
           
           // 9.9 ToObject
           
      392  syntax KItem /* Val */ ::= "ToObject" "(" K /* Val */ ")" [seqstrict(1)]
           
        1  rule ToObject(Undefined) => @Throw(@TypeError("ToObject","Undefined"))
        1  rule ToObject(@NullVal  ) => @Throw(@TypeError("ToObject","Null"))
       42  rule ToObject(B:Bool    ) => @NewBoolean(@Cons(B,@Nil))
      620  rule ToObject(S:String  ) => @NewString(@Cons(S,@Nil))
      149  rule ToObject(N:Number  ) => @NewNumber(@Cons(N,@Nil))
     8552  rule ToObject(O:Oid) => O
           
           // 9.10 CheckObjectCoercible
           
           syntax KItem /* .K */ ::= "CheckObjectCoercible" "(" Val ")"
    90741  rule <k> CheckObjectCoercible(V:Val) => . ... </k>
                when (V =/=K Undefined) andBool
                     (V =/=K @NullVal)
       63  rule CheckObjectCoercible(Undefined) => @Throw(@TypeError("CheckObjectCoercible","Undefined"))
        3  rule CheckObjectCoercible(@NullVal  ) => @Throw(@TypeError("CheckObjectCoercible","Null"))
           
           // 9.11 IsCallable
           
           syntax KItem /* Bool */ ::= "IsCallable" "(" K /* Val */ ")" [seqstrict(1)]
           
      263  rule IsCallable(Undefined) => false
        8  rule IsCallable(@NullVal  ) => false
        8  rule IsCallable(B:Bool    ) => false
        9  rule IsCallable(S:String  ) => false
       12  rule IsCallable(N:Number  ) => false
    58094  rule <k> IsCallable(O:Oid ) => Class ==K "Function" ... </k> // TODO: Do more correctly
                <obj>
                  <oid> O </oid>
                  <internalProperties> "Class" |-> Class:String _:Map </internalProperties>
                  _
                </obj>
    69949  rule IsCallable(@(_)) => true
           
           // 9.12 The SameValue Algorithm
           
           syntax Bool ::= "SameValue" "(" K /* Val */ "," K /* Val */ ")" [function]
           
           // TODO: Do more correctly Step 4 of Number
           rule SameValue(V1:Val,V2:Val) => V1 ==K V2 when notBool(isInt(V1)   ==K true andBool isFloat(V2) ==K true)
                                                    andBool notBool(isFloat(V1) ==K true andBool isInt(V2)   ==K true)
           rule SameValue(I1:Int,  F2:Float) => @Int2Float(I1) ==Float F2
           rule SameValue(F1:Float,I2:Int  ) =>            F1 ==Float @Int2Float(I2)
           
           //////////////////////////////////////////////////////////////////////////////
           // 10.2.1 Environment Records
           //////////////////////////////////////////////////////////////////////////////
           
           syntax KItem /* Bool */ ::= "HasBinding" "(" Eid "," Var ")"
           // 10.2.1.1.1 HasBinding(N)
   505338  rule <k> HasBinding(E:Eid,N:Var) => N in keys(Record) ... </k>
                <env>
                  <eid> E </eid>
                  <declEnvRec> Record:Map </declEnvRec>
                  _
                </env>
           // 10.2.1.2.1 HasBinding(N)
   538622  rule <k> HasBinding(E:Eid,N:Var) => HasProperty(O,N) ... </k>
                <env>
                  <eid> E </eid>
                  <objEnvRec>
                    <bindingObj> O:Oid </bindingObj>
                    _
                  </objEnvRec>
                  _
                </env>
           
           syntax KItem /* .K */ ::= "CreateMutableBinding" "(" Eid "," Var "," Bool ")" 
           // 10.2.1.1.2 CreateMutableBinding (N, D)
   120344  rule <k> CreateMutableBinding(E:Eid,N:Var,D:Bool) => . ... </k>
                <env>
                  <eid> E </eid>
                  <declEnvRec> (.Map => N |-> @ve(Undefined,false,true,D)) Record:Map </declEnvRec>
                  _
                </env>
                when notBool(N in keys(Record))
           // 10.2.1.2.2 CreateMutableBinding (N, D)
   184097  rule <k> CreateMutableBinding(E:Eid,N:Var,D:Bool)
                 => HasProperty(O,N) ~> @False?
                 ~> DefineOwnProperty(O, N, @desc("Value" |-> Undefined "Writable" |-> true "Enumerable" |-> true "Configurable" |-> D), true) ~> @Ignore
                ... </k>
                <env>
                  <eid> E </eid>
                  <objEnvRec>
                    <bindingObj> O:Oid </bindingObj>
                    _
                  </objEnvRec>
                  _
                </env>
           
   268044  syntax KItem /* .K */ ::= "SetMutableBinding" "(" K /* Eid */ "," K /* Var */ "," K /* Val */ "," K /* Bool */ ")" [seqstrict(1,2,3,4)]
           // 10.2.1.1.3 SetMutableBinding (N,V,S)
   202928  rule <k> SetMutableBinding(E:Eid,N:Var,V:Val,S:Bool) => . ... </k>
                <env>
                  <eid> E </eid>
                  <declEnvRec> N |-> @ve((_ => V),(_ => true),true,_) _:Map </declEnvRec>
                  _
                </env>
        0  rule <k> SetMutableBinding(E:Eid,N:Var,_:Val,true) => @Throw(@TypeError("SetMutableBinding",N)) ... </k> // TODO: what if S is false? undefined behavior?
                <env>
                  <eid> E </eid>
                  <declEnvRec> N |-> @ve(_,_,false,_) _:Map </declEnvRec>
                  _
                </env>
           // 10.2.1.2.3 SetMutableBinding (N,V,S)
   245979  rule <k> SetMutableBinding(E:Eid,N:Var,V:Val,S:Bool) => Put(O,N,V,S) ... </k>
                <env>
                  <eid> E </eid>
                  <objEnvRec>
                    <bindingObj> O:Oid </bindingObj>
                    _
                  </objEnvRec>
                  _
                </env>
           
           syntax KItem /* Val */ ::= "GetBindingValue" "(" Eid "," Var "," Bool ")" 
           // 10.2.1.1.4 GetBindingValue(N,S)
   153454  rule <k> GetBindingValue(E:Eid,N:Var,S:Bool) => V ... </k>
                <env>
                  <eid> E </eid>
                  <declEnvRec> N |-> @ve(V:Val,Initialized:Bool,Mutable:Bool,_) _:Map </declEnvRec>
                  _
                </env>
                when notBool(Initialized ==K false andBool Mutable ==K false)
        0  rule <k> GetBindingValue(E:Eid,N:Var,S:Bool)
                 => If S = true then {
        0             Do @Throw(@ReferenceError("GetBindingValue, DeclEnv", N));
                    } else {
        0             Return Undefined;
                    }
                 ... </k>
                <env>
                  <eid> E </eid>
                  <declEnvRec> N |-> @ve(_,false,false,_) _:Map </declEnvRec>
                  _
                </env>
           // 10.2.1.2.4 GetBindingValue(N,S)
   210308  rule <k> GetBindingValue(E:Eid,N:Var,S:Bool)
   420615        => If HasProperty(O,N) = true then {
   420611             Return Get(O,N);
                    } else {
        0             If S = true then {
        0               Do @Throw(@ReferenceError("GetBindingValue, ObjEnv", N));
                      } else {
        0               Return Undefined;
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
           
           syntax KItem /* Bool */ ::= "DeleteBinding" "(" Eid "," Var ")" 
           // 10.2.1.1.5 DeleteBinding (N)
        0  rule <k> DeleteBinding(E:Eid,N:Var) => true ... </k>
                <env>
                  <eid> E </eid>
                  <declEnvRec> (N |-> @ve(_,_,_,true) => .Map) _:Map </declEnvRec>
                  _
                </env>
       15  rule <k> DeleteBinding(E:Eid,N:Var) => false ... </k>
                <env>
                  <eid> E </eid>
                  <declEnvRec> N |-> @ve(_,_,_,false) _:Map </declEnvRec>
                  _
                </env>
        0  rule <k> DeleteBinding(E:Eid,N:Var) => true ... </k>
                <env>
                  <eid> E </eid>
                  <declEnvRec> Record:Map </declEnvRec>
                  _
                </env>
                when notBool(N in keys(Record))
           // 10.2.1.2.5 DeleteBinding (N)
       66  rule <k> DeleteBinding(E:Eid,N:Var) => Delete(O,N,false) ... </k>
                <env>
                  <eid> E </eid>
                  <objEnvRec>
                    <bindingObj> O:Oid </bindingObj>
                    _
                  </objEnvRec>
                  _
                </env>
           
           syntax KItem /* Val */ ::= "ImplicitThisValue" "(" Eid ")" 
           // 10.2.1.1.6 ImplicitThisValue()
     4624  rule <k> ImplicitThisValue(E:Eid) => Undefined ... </k>
                <env>
                  <eid> E </eid>
                  <declEnvRec> _:Map </declEnvRec>
                  _
                </env>
           // 10.2.1.2.6 ImplicitThisValue()
       11  rule <k> ImplicitThisValue(E:Eid) => O ... </k>
                <env>
                  <eid> E </eid>
                  <objEnvRec>
                    <bindingObj> O:Oid </bindingObj>
                    <provideThis> true </provideThis>
                  </objEnvRec>
                  _
                </env>
    85839  rule <k> ImplicitThisValue(E:Eid) => Undefined ... </k>
                <env>
                  <eid> E </eid>
                  <objEnvRec>
                    <provideThis> false </provideThis>
                    _
                  </objEnvRec>
                  _
                </env>
           
           syntax KItem /* .K */ ::= "CreateImmutableBinding" "(" Eid "," Var ")" 
           // 10.2.1.1.7 CreateImmutableBinding (N)
     3610  rule <k> CreateImmutableBinding(E:Eid,N:Var) => . ... </k>
                <env>
                  <eid> E </eid>
                  <declEnvRec> (.Map => N |-> @ve(Undefined,false,false,false)) Record:Map </declEnvRec>
                  _
                </env>
                when notBool(N in keys(Record))
           
           syntax KItem /* .K */ ::= "InitializeImmutableBinding" "(" Eid "," Var "," Val ")" 
           // 10.2.1.1.8 InitializeImmutableBinding (N,V)
     3610  rule <k> InitializeImmutableBinding(E:Eid,N:Var,V:Val) => . ... </k>
                <env>
                  <eid> E </eid>
                  <declEnvRec> N |-> @ve((_ => V),(false => true),false,_) _:Map </declEnvRec>
                  _
                </env>
           
           //////////////////////////////////////////////////////////////////////////////
           // 10.2.2 Lexical Environment Operations
           //////////////////////////////////////////////////////////////////////////////
           
           // 10.2.2.1 GetIdentifierReference (lex, name, strict)
           
           syntax KItem /* Reference */ ::= "GetIdentifierReference" "(" Eid "," Var "," Bool ")"
           
     1047  rule GetIdentifierReference(@NullEid,N:Var,Strict:Bool) => @Ref(Undefined,N,Strict)
   737038  rule <k> GetIdentifierReference(E:Eid,N:Var,Strict:Bool)
  1474062        => If HasBinding(E,N) = true then {
   541642             Return @Ref(E,N,Strict);
                    } else {
   390752             Return GetIdentifierReference(E',N,Strict);
                    }
                ... </k>
                <env>
                  <eid> E </eid>
                  <outer> E' </outer>
                  _
                </env>
                when E =/=K @NullEid
           
           // 10.2.2.2 NewDeclarativeEnvironment (E)
           
           syntax KItem /* Eid */ ::= "NewDeclarativeEnvironment" "(" Eid "," Bool ")" 
           
    49460  rule <k> NewDeclarativeEnvironment(E:Eid, Strict:Bool) => @e(!N) ... </k>
                <envs>
                  (. => <env>
                          <eid> @e(!N:Int) </eid>
                          <outer> E </outer>
                          <strict> Strict </strict>
                          <declEnvRec> .Map </declEnvRec>
                        </env>)
                  _
                </envs>
           
           // 10.2.2.3 NewObjectEnvironment (O, E)
           
      390  syntax KItem /* Eid */ ::= "NewObjectEnvironment" "(" K /* Oid */ "," K /* Eid */ "," K /* Bool */ "," Bool ")" [seqstrict(1,2,3)]
           
      194  rule <k> NewObjectEnvironment(O:Oid,E:Eid,ProvideThis:Bool,Strict:Bool) => @e(!N) ... </k>
                <envs>
                  (. => <env>
                          <eid> @e(!N:Int) </eid>
                          <outer> E </outer>
                          <strict> Strict </strict>
                          <objEnvRec>
                            <bindingObj> O </bindingObj>
                            <provideThis> ProvideThis </provideThis>
                          </objEnvRec>
                        </env>)
                  _
                </envs>
           
           //////////////////////////////////////////////////////////////////////////////
           // 10.4 Establishing an Execution Context
           //////////////////////////////////////////////////////////////////////////////
           
           // 10.4.1 Entering Global Code
           
           syntax KItem /* .K */ ::= "@EnterGlobalCode" "(" Stmt ")"
     6835  rule <k> @EnterGlobalCode(Code:Stmt)
                 => @CheckEarlyErrors(@IsStrict(Code), Code)
                 ~> @BindDeclarations("function",false,@IsStrict(Code),Code)
                 ~> @BindDeclarations("variable",false,@IsStrict(Code),Code)
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
                  <activeStack> .List </activeStack>
                  <running>
                    <lexicalEnv>  . => @GlobalEid </lexicalEnv>
                    <thisBinding> . => @GlobalOid </thisBinding>
                    <lastNonEmptyValue> . => Undefined </lastNonEmptyValue>
                  </running>
                </ctx>
           
           // 10.4.2 Entering Eval Code
           
           syntax KItem /* .K */ ::= "@EnterEvalCode" "(" Stmt "," Bool /* Direct? */ ")"
           syntax Id ::= "$strict"
      939  rule <k> @EnterEvalCode(Code:Stmt, true)
      939        => Let $strict = @IsStrict(Code) orBool Strict; // 10.1.1 Strict Mode Code, Case 2 (direct call to eval)
      939           Do @CheckEarlyErrors($strict:>Bool, Code);
      776           Do @SetRunningCtx(@NewDeclarativeEnvironmentForEval(E,$strict:>Bool), This);
      776           Do @BindDeclarations("function",true,$strict:>Bool,Code);
      776           Do @BindDeclarations("variable",true,$strict:>Bool,Code);
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
       16  rule @EnterEvalCode(Code:Stmt, false)
       16    => Let $strict = @IsStrict(Code); // 10.1.1 Strict Mode Code, Case 2 (NOT direct call to eval)
       16       Do @CheckEarlyErrors($strict:>Bool, Code);
       15       Do @SetRunningCtx(@NewDeclarativeEnvironmentForEval(@GlobalEid,$strict:>Bool), @GlobalOid);
       15       Do @BindDeclarations("function",true,$strict:>Bool,Code);
       15       Do @BindDeclarations("variable",true,$strict:>Bool,Code);
           
           syntax KItem /* Eid */ ::= "@NewDeclarativeEnvironmentForEval" "(" Eid "," Bool /* Strict? */ ")"
       59  rule @NewDeclarativeEnvironmentForEval(E,true ) => NewDeclarativeEnvironment(E, true)
      732  rule @NewDeclarativeEnvironmentForEval(E,false) => E
           
           // 10.4.3 Entering Function Code
           
           syntax KItem /* .K */ ::= "@EnterFunctionCode" "(" Oid "," Val "," Vals ")"
    47607  rule <k> @EnterFunctionCode(F:Oid,This:Val,Args:Vals)
    47607        => Do @SetRunningCtx(NewDeclarativeEnvironment(E,Strict), @ResolveThis(Strict,This));
    47607           Do @BindFunctionParameters(F,Args,Strict);
    47605           Do @BindDeclarations("function",false,Strict,Code);
    47605           Do @BindArgumentsObject(F,Args,Strict);
    47596           Do @BindDeclarations("variable",false,Strict,Code);
                ... </k>
                <obj>
                  <oid> F </oid>
                  <internalProperties>
                    "Scope" |-> E:Eid
                    "Code" |-> Code:Stmt
                    "Strict" |-> Strict:Bool
                    _:Map
                  </internalProperties>
                  _
                </obj>
           
           syntax KItem /* Oid */ ::= "@ResolveThis" "(" Bool "," Val ")"
     3543  rule @ResolveThis(true, V:Val) => V
    24511  rule @ResolveThis(false,O:Oid) => O                   // NOTE: Method call or function call under the 'with'
    19181  rule @ResolveThis(false,Undefined) => @GlobalOid     // NOTE: Function call without the 'with' (from p.28 of Good Parts)
       36  rule @ResolveThis(false,@NullVal  ) => @GlobalOid     // NOTE: Apply call with 'null' as a 'this' value (from p.30 of Good Parts)
      336  rule @ResolveThis(false,V:Val) => ToObject(V) when isPrimitive(V) ==K true
           
   192400  syntax KItem /* .K */ ::= "@SetRunningCtx" "(" K /* Eid */ "," K /* Oid */ ")" [seqstrict(1,2)]
    50318  rule <k> @SetRunningCtx(E:Eid,This:Val) => . ... </k>
                <ctx>
                  <activeStack> (.List => ListItem(@active(R))) _:List </activeStack>
                  <running>
                    (R => <lexicalEnv> E </lexicalEnv>
                          <thisBinding> This </thisBinding>
                          <lastNonEmptyValue> Undefined </lastNonEmptyValue>)
                  </running>
                </ctx>
           
           syntax KItem /* Val */ ::= "@RestoreRunningCtx"
    48336  rule <k> @RestoreRunningCtx => . ... </k>
                <ctx>
                  <activeStack> (ListItem(@active(R)) => .List) _:List </activeStack>
                  <running> _ => R </running>
                </ctx>
           
           // 10.5 Declaration Binding Instantiation
           
           // 10.5: Step 4: Function Parameter Binding Instantiation
           syntax KItem /* .K */ ::= "@BindFunctionParameters" "(" Oid "," Vals "," Bool ")" 
    47607  rule <k> @BindFunctionParameters(F:Oid,Args:Vals,Strict:Bool) => @SetParams(Ns,Args,Strict) ... </k>
                <obj>
                  <oid> F </oid>
                  <internalProperties> "FormalParameters" |-> Ns:Exps _:Map </internalProperties>
                  _
                </obj>
           //
           syntax KItem /* .K */ ::= "@SetParams" "(" Exps "," Vals "," Bool ")" 
    47605  rule @SetParams(%nil, _:Vals, _) => .
      494  rule @SetParams(%cons(%var(N:Var), Ns:Exps), @Nil                 , Strict:Bool) => @SetParam(N, Undefined, Strict) ~> @SetParams(Ns, @Nil, Strict)
    46286  rule @SetParams(%cons(%var(N:Var), Ns:Exps), @Cons(V:Val, Vs:Vals), Strict:Bool) => @SetParam(N, V         , Strict) ~> @SetParams(Ns, Vs,   Strict)
           //
           syntax KItem /* .K */ ::= "@SetParam" "(" Var "," Val "," Bool ")"
    46780  rule <k> @SetParam(N,V,Strict:Bool)
                 => @BindVariableDeclaration(N,false,Strict) // TODO: check if it is correct that the configurableBindings is false: Unspecified at Step 4.d.iv.
                 ~> SetMutableBinding(E,N,V,Strict) ... </k>
                <ctx>
                  <running>
                    <lexicalEnv> E:Eid </lexicalEnv>
                    _
                  </running>
                  _
                </ctx>
           
           // 10.5: Step 5 & 8: Function/Variable Declarations Binding Instantiation
           // Visitor function
           // NOTE: the second boolean argument indicates whether it is eval code or not
           syntax KItem /* .K */ ::= "@BindDeclarations" "(" String "," Bool "," Bool "," Stmt ")"
   670110  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %fdecl(F:Var,Ps:Exps,FB:Stmt))      => If Mode = "function" then { Do @BindFunctionDeclaration(F,Ps,FB,CB,Strict); };
   392579  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %vdecl(N:Var))                      => If Mode = "variable" then { Do @BindVariableDeclaration(N,CB,Strict); };
   726977  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %seq(S1:Stmt,S2:Stmt))              => @BindDeclarations(Mode,CB,Strict,S1) ~> @BindDeclarations(Mode,CB,Strict,S2)
   306332  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %exp(_))                            => .
   110311  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %if(_,S1:Stmt,S2:Stmt))             => @BindDeclarations(Mode,CB,Strict,S1) ~> @BindDeclarations(Mode,CB,Strict,S2)
      152  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %do(S:Stmt,_))                      => @BindDeclarations(Mode,CB,Strict,S)
      282  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %while(_,S:Stmt))                   => @BindDeclarations(Mode,CB,Strict,S)
     6382  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %for  (S1:Stmt,_,_,S2:Stmt))        => @BindDeclarations(Mode,CB,Strict,S1) ~> @BindDeclarations(Mode,CB,Strict,S2)
     4044  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %forin(S1:Stmt,_,_,S2:Stmt))        => @BindDeclarations(Mode,CB,Strict,S1) ~> @BindDeclarations(Mode,CB,Strict,S2)
      106  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %continue(_))                       => .
      590  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %break(_))                          => .
    11548  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %label(_,S:Stmt))                   => @BindDeclarations(Mode,CB,Strict,S)
   103353  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %return(_))                         => .
    32813  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %throw(_))                          => .
     5902  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %try(S1:Stmt,_,S2:Stmt,S3:Stmt))    => @BindDeclarations(Mode,CB,Strict,S1) ~> @BindDeclarations(Mode,CB,Strict,S2) ~> @BindDeclarations(Mode,CB,Strict,S3)
      574  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %try(S1:Stmt,          S3:Stmt))    => @BindDeclarations(Mode,CB,Strict,S1) ~>                                         @BindDeclarations(Mode,CB,Strict,S3)
      366  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %with(_,S:Stmt))                    => @BindDeclarations(Mode,CB,Strict,S)
   103329  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %emptyStmt)                         => .
      566  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %switch(_,S1:Stmt,S2:Stmt,S3:Stmt)) => @BindDeclarations(Mode,CB,Strict,S1) ~> @BindDeclarations(Mode,CB,Strict,S2) ~> @BindDeclarations(Mode,CB,Strict,S3)
     1608  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %case(_,S:Stmt))                    => @BindDeclarations(Mode,CB,Strict,S)
      560  rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %default(S:Stmt))                   => @BindDeclarations(Mode,CB,Strict,S)
           
           // 10.5: Step 5: Function Declaration Binding Instantiation
           syntax KItem /* .K */ ::= "@BindFunctionDeclaration" "(" Var "," Exps "," Stmt "," Bool "," Bool ")"
           syntax Id ::= "$existingProp"
   134022  rule <k> @BindFunctionDeclaration(N:Var, Params:Exps, FunBody:Stmt, ConfigurableBindings:Bool, Strict:Bool)
   268044        => If HasBinding(E,N) = false then {
   134011             Do CreateMutableBinding(E,N,ConfigurableBindings);
                    } else {
       11             If E = @GlobalEid then {
       16               Let $existingProp = GetProperty(@GlobalOid,N);
        8               If $existingProp."Configurable" = true then {
        0                 DoI DefineOwnProperty(@GlobalOid, N, @desc("Value" |-> Undefined "Writable" |-> true "Enumerable" |-> true "Configurable" |-> ConfigurableBindings), true);
                        } else {
        8                 If IsAccessorDescriptor($existingProp:>Val) = true then {
        0                   Do @Throw(@TypeError("BindFunctionDeclaration accessor",$existingProp));
                          };
       16                 If @AndBool($existingProp."Writable", $existingProp."Enumerable") = false then {
        0                   Do @Throw(@TypeError("BindFunctionDeclaration writable/enumerable",$existingProp));
                          };
                        }
                      };
                    }
   134022           Do SetMutableBinding(E, N, @FunctionDeclaration(N,Params,FunBody), Strict);
                ... </k>
                <ctx>
                  <running>
                    <lexicalEnv> E:Eid </lexicalEnv>
                    _
                  </running>
                  _
                </ctx>
           
           // 10.5: Step 8: Variable Declaration Binding Instantiation
           syntax KItem /* .K */ ::= "@BindVariableDeclaration" "(" Var "," Bool "," Bool ")"
   125295  rule <k> @BindVariableDeclaration(N:Var, ConfigurableBindings:Bool, Strict:Bool)
   250589        => If HasBinding(E,N) = true then {
      639             Return;
                    } else {
   124655             Do CreateMutableBinding(E,N,ConfigurableBindings);
   124654             Do SetMutableBinding(E,N,Undefined,Strict);
                    }
                ... </k>
                <ctx>
                  <running>
                    <lexicalEnv> E:Eid </lexicalEnv>
                    _
                  </running>
                  _
                </ctx>
           
           syntax KItem /* .K */ ::= "@BindArgumentsObject" "(" Oid "," Vals "," Bool ")"
           syntax Id ::= "$argsObj"
    47605  rule <k> @BindArgumentsObject(F:Oid,Args:Vals,Strict:Bool)
    95210        => If HasBinding(E,"arguments") = false then {
    95193             Let $argsObj = @CreateArgumentsObject(F,Names,Args,E,Strict);
    47592             If Strict = true then {
     3542               Do CreateImmutableBinding(E,"arguments");
     3542               Do InitializeImmutableBinding(E,"arguments",$argsObj:>Val);
                      } else {
    44050               Do CreateMutableBinding(E,"arguments",false); // TODO: check if the third argument is false or not (not mentioned in the specification)
    44050               Do SetMutableBinding(E,"arguments",$argsObj:>Val,false);
                      }
                    };
                ... </k>
                <obj>
                  <oid> F </oid>
                  <internalProperties>
                    "FormalParameters" |-> Names:Exps
                    _:Map
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
           
           // 10.6 Arguments Object
           
           syntax KItem /* Oid */ ::= "@CreateArgumentsObject" "(" Oid "," Exps "," Vals "," Eid "," Bool ")"
           syntax Id ::= "$len" | "$map"
    47601  rule @CreateArgumentsObject(Func:Oid, Names:Exps, Args:Vals, Env:Eid, Strict:Bool)
    47601    => Let $len = @LengthVals(Args);
    95202       Let $obj = @CreateObject;
    47601       Do SetInternalProperty($obj:>Oid, "Class", "Arguments");
    47601       Do SetInternalProperty($obj:>Oid, "Strict", Strict); // NOTE: This is not specified in language standard, but added for our own @IsArgumentsObjectNonStrictWithFormalParams
    47600       DoI DefineOwnProperty($obj, "length", @GenDesc("Value", $len, "Writable", true, "Enumerable", false, "Configurable", true), false);
    95194       Let $map = @CreateObject;
    47597       Do @BindActualParams($obj:>Oid, Args, 0);
    47594       If Strict = false then {
    44052         Do @BindFormalParams($map:>Oid, Names, Args, Env, 0);
                };
    47593       If @Length(Names) >Int 0 = true then {
    27812         Do SetInternalProperty($obj:>Oid, "ParameterMap", $map:>Val);
                };
    47593       If Strict = true then {
     3542         DoI DefineOwnProperty($obj, "caller", @desc("Get" |-> @("ThrowTypeError") "Set" |-> @("ThrowTypeError") "Enumerable" |-> false "Configurable" |-> false), false);
     3542         DoI DefineOwnProperty($obj, "callee", @desc("Get" |-> @("ThrowTypeError") "Set" |-> @("ThrowTypeError") "Enumerable" |-> false "Configurable" |-> false), false);
                } else {
    44051         DoI DefineOwnProperty($obj, "callee", @desc("Value" |-> Func "Writable" |-> true "Enumerable" |-> false "Configurable" |-> true), false);
                }
    47592       Return $obj;
           
           syntax KItem /* .K */ ::= "@BindActualParams" "(" Oid "," Vals "," Int ")"
    47594  rule @BindActualParams(O:Oid, @Nil, _) => .
    47095  rule @BindActualParams(O:Oid, @Cons(V:Val,Vs:Vals), I:Int)
             => DefineOwnProperty(O, ToString(I), @desc("Value" |-> V "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false) ~> @Ignore ~>
                @BindActualParams(O, Vs, I +Int 1)
           
           syntax KItem /* .K */ ::= "@BindFormalParams" "(" Oid "," Exps "," Vals "," Eid "," Int ")"
           // TODO: consider step 11.c.ii 2nd condition: "name is not an element of mappedNames". what if duplicated names?
    43602  rule @BindFormalParams(M:Oid, %nil, _, _, _) => .
      449  rule @BindFormalParams(M:Oid, _, @Nil, _, _) => .
    46220  rule @BindFormalParams(M:Oid, %cons(%var(Name:Var),Names:Exps), @Cons(Arg:Val,Args:Vals), Env:Eid, I:Int)
    92440    => Let $getter = @MakeArgGetter(Name,Env);
    92440       Let $setter = @MakeArgSetter(Name,Env);
    46220       DoI DefineOwnProperty(M, ToString(I), @GenDesc("Get", $getter, "Set", $setter, "Configurable", true), false);
    46219       Do @BindFormalParams(M, Names, Args, Env, I +Int 1);
           
           syntax KItem /* Oid */ ::= "@MakeArgGetter" "(" Var "," Eid ")"
    46220  rule @MakeArgGetter(N:Var,E:Eid) => @CreateFunctionObject(%nil, %return(%var(N)), E, true) // TODO: in what case? // 10.1.1 Strict Mode Code, Case ?
           
           syntax KItem /* Oid */ ::= "@MakeArgSetter" "(" Var "," Eid ")"
           syntax Id ::= "$param"
    46220  rule @MakeArgSetter(N:Var,E:Eid)
    46220    => Let $param = N:>String +String "_arg";
    92440       Return @CreateFunctionObject(%cons(%var($param:>Var),%nil), %exp(%bop(%assign,%var(N),%var($param:>Var))), E, true); // TODO: in what case? // 10.1.1 Strict Mode Code, Case ?
           
           syntax KItem /* Bool */ ::= "@IsArgumentsObjectNonStrictWithFormalParams" "(" Oid ")"
   331178  rule <k> @IsArgumentsObjectNonStrictWithFormalParams(O:Oid)
                 => Class ==String "Arguments" andBool notBool(Strict) andBool "ParameterMap" in keys(InternalProperties) ... </k>
                <obj>
                  <oid> O </oid>
                  <internalProperties>
                    "Class" |-> Class:String
                    "Strict" |-> Strict:Bool
                    InternalProperties:Map
                  </internalProperties>
                  _
                </obj>
  3780385  rule <k> @IsArgumentsObjectNonStrictWithFormalParams(O:Oid) => false ... </k>
                <obj>
                  <oid> O </oid>
                  <internalProperties>
                    InternalProperties:Map
                  </internalProperties>
                  _
                </obj>
                when notBool("Strict" in keys(InternalProperties))
           
           syntax Id ::= "$isMapped" | "$allowed"
           
           syntax KItem /* Val */ ::= "Get@Arguments" "(" Oid "," Var ")" 
           
     8510  rule Get@Arguments(O:Oid,P:Var)
    17020    => Let $map = GetInternalProperty(O,"ParameterMap");
    17020       Let $isMapped = GetOwnProperty($map,P);
     8510       If $isMapped = Undefined then {
    12061         Return Get@Default(O,P); // TODO: consider step 3.b
                } else {
     4957         Return Get($map:>Oid,P);
                }
           
           syntax KItem /* Val */ ::= "GetOwnProperty@Arguments" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict(1,2)]
           
    34384  rule GetOwnProperty@Arguments(O:Oid,P:Var)
    68768    => Let $desc = GetOwnProperty@Default(O,P);
    34384       If $desc = Undefined then {
    28133         Return $desc;
                } else {
    12502         Let $map = GetInternalProperty(O,"ParameterMap");
    12502         Let $isMapped = GetOwnProperty($map,P);
     6251         If $isMapped = Undefined then {
     5959           Return $desc;
                  } else {
      584           Return @AddDesc("Value", Get($map:>Oid,P), $desc);
                  }
                }
           
           syntax KItem /* Bool */ ::= "DefineOwnProperty@Arguments" "(" K /* Oid */ "," K /* Var */ "," K /* PropertyDescriptor */ "," K /* Bool */ ")" [seqstrict(1,2,3,4)]
           
    27859  rule DefineOwnProperty@Arguments(O:Oid,P:Var,Desc:PropertyDescriptor,Throw:Bool)
    55718    => Let $map = GetInternalProperty(O,"ParameterMap");
    55718       Let $isMapped = GetOwnProperty($map,P);
    55718       Let $allowed = DefineOwnProperty@Default(O,P,Desc,false);
    27859       If $allowed = false then {
       16         If Throw = true then {
       16           Do @Throw(@TypeError("DefineOwnProperty for Arguments",DefineOwnProperty(O,P,Desc,Throw)));
                  } else {
        0           Return false;
                  }
                } else {
    27843         If $isMapped = Undefined then {
    27817           Nop;
                  } else {
       26           If IsAccessorDescriptor(Desc) = true then {
       11             DoI Delete($map:>Oid, P, false);
                    } else {
       15             If @MemDesc(Desc,"Value") = true then {
       15               Do Put($map:>Oid, P, Desc."Value", Throw);
                      };
       15             If Desc."Writable" = false then {
       11               DoI Delete($map:>Oid, P, false);
                      };
                    }
                  }
    27843         Return true;
                }
           
           syntax KItem /* Bool */ ::= "Delete@Arguments" "(" Oid "," Var "," Bool ")" 
           
       39  rule Delete@Arguments(O:Oid,P:Var,Throw:Bool)
       78    => Let $map = GetInternalProperty(O,"ParameterMap");
       78       Let $isMapped = GetOwnProperty($map,P);
       78       Let $result = Delete@Default(O,P,Throw);
       78       If @AndBool($result, @NeqVal($isMapped, Undefined)) = true then {
       10         DoI Delete($map:>Oid, P, false);
                };
       39       Return $result;
           
           //////////////////////////////////////////////////////////////////////////////
           // 11 Expressions
           //////////////////////////////////////////////////////////////////////////////
           
           syntax KItem /* Reference */ ::= "@GetReference" "(" Exp ")"
           
   542704  rule <k> @GetReference(%var(N:Var)) => GetIdentifierReference(E,N,Strict) ... </k>
                <running>
                  <lexicalEnv> E:Eid </lexicalEnv>
                  _
                </running>
                <env>
                  <eid> E </eid>
                  <strict> Strict:Bool </strict>
                  _
                </env>
           
   180638  context @GetReference(%mem(HOLE,_))
   180623  context @GetReference(%mem(_:Val,HOLE))
    90311  rule <k> @GetReference(%mem(O:Val,N:Val)) // NOTE: O does not need to be an Oid
                 => CheckObjectCoercible(O) ~> @Ref(O, ToString(N), Strict) ... </k>
                <running>
                  <lexicalEnv> E:Eid </lexicalEnv>
                  _
                </running>
                <env>
                  <eid> E </eid>
                  <strict> Strict:Bool </strict>
                  _
                </env>
           
       41  rule @GetReference(E:Exp) => @Throw(@ReferenceError("GetReference",E)) when @IsReferenceExp(E) =/=K true
           
           syntax KItem /* Bool */ ::= "@IsReferenceExp" "(" Exp ")" [function]
           
           rule @IsReferenceExp(E:Exp) => getKLabel(E) ==KLabel '%var`(_`)
                                   orBool getKLabel(E) ==KLabel '%mem`(_`,_`)
           
      246  rule %emptyExp => Undefined
           
           // 11.1.1 The this Keyword
           
    29733  rule <k> %this => This ... </k>
                <running>
                  <thisBinding> This:Val </thisBinding>
                  _
                </running>
           
           // 11.1.2 Identifier Reference
           // 10.3.1 Identifier Resolution
           
   353355  rule %var(N:Var) => GetValue(@GetReference(%var(N)))
           
           // 11.1.3 Literal Reference
           // TODO: Numeric, Regular Expressions
           
    29733  rule %con(%this)    => %this
     1415  rule %con(%null)    => %null
    32244  rule %con(B:Bool)   => B
    45468  rule %con(I:Int)    => @ResolveOverflow(I)
     2167  rule %con(F:Float)  => @ResolveOverflow(F)
   152960  rule %con(S:String) => S
           
           // 11.1.4 Array Initialiser
           
     1675  rule %arr(Es:Exps) => @MakeArray(@RemoveLastEmptyExp(Es))
           
           // NOTE: the last ending comma should be ignored: [ 1, 2, ] => [ 1, 2 ]
           //       "If an element is elided at the end of an array, that element does not contribute to the length of the Array." (p.63)
           syntax Exps ::= "@RemoveLastEmptyExp" "(" Exps ")" [function]
           rule @RemoveLastEmptyExp(                   %nil ) => %nil
           rule @RemoveLastEmptyExp(%cons(%emptyExp,   %nil)) => %nil
           rule @RemoveLastEmptyExp(%cons(E:Exp,       %nil)) => %cons(E,%nil) when E =/=K %emptyExp
           rule @RemoveLastEmptyExp(%cons(E:Exp,    Es:Exps)) => %cons(E,@RemoveLastEmptyExp(Es)) when Es =/=K %nil
           
           // 11.1.5 Object Initialiser
           // NOTE: step 4 of p.66 (duplicated properties) is checked by 'CheckDuplicatedProp'
           
     6851  rule %obj(PAs:Exps) => @AssignProps(@CreateObject,PAs)
           
    13702  syntax KItem /* Oid */ ::= "@AssignProps" "(" K /* Oid */ "," Exps ")" [seqstrict(1)]
     6851  rule @AssignProps(O:Oid, %nil) => O
     8114  rule @AssignProps(O:Oid, %cons(PA:Exp, PAs:Exps)) => @AssignProp(O,PA) ~> @AssignProps(O,PAs)
           
           syntax KItem /* .K */ ::= "@AssignProp" "(" Oid "," Exp ")" 
           
    16164  context @AssignProp(_,%prop(_,HOLE))
     8082  rule @AssignProp(O:Oid, %prop(P:Var,V:Val))
             => DefineOwnProperty(O, P, @desc("Value" |-> V "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false) ~> @Ignore
           
       17  rule <k> @AssignProp(O:Oid, %get(P:Var,FunBody:Stmt))
       34        => Let $closure = @CreateFunctionObject(%nil, FunBody, E, @IsStrict(FunBody) orBool Strict); // 10.1.1 Strict Mode Code, Case 3
       17           DoI DefineOwnProperty(O, P, @GenDesc("Get", $closure, "Enumerable", true, "Configurable", true), false);
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
           
       15  rule <k> @AssignProp(O:Oid, %set(P:Var,X:Var,FunBody:Stmt))
       30        => Let $closure = @CreateFunctionObject(%cons(%var(X),%nil), FunBody, E, @IsStrict(FunBody) orBool Strict); // 10.1.1 Strict Mode Code, Case 3
       15           DoI DefineOwnProperty(O, P, @GenDesc("Set", $closure, "Enumerable", true, "Configurable", true), false);
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
           
    57238  rule %mem(E1:Exp,E2:Exp) => GetValue(@GetReference(%mem(E1,E2)))
           
           // 11.2.2 The new Operator
           
    10707  rule %new(F:Exp,Es:Exps) => @ConstructIfPossible(F,Es)
           
    42819  syntax KItem /* Oid */ ::= "@ConstructIfPossible" "(" K /* Val */ "," K /* Vals */ ")" [seqstrict(1,2)]
    10704  rule @ConstructIfPossible(F:Val, Args:Vals)
    21408    => If @IsConstructable(F) = true then {
    10622         Do Construct(F, Args);
                } else {
       82         Do @Throw(@TypeError("ConstructIfPossible",F));
                }
           
           syntax KItem /* Bool */ ::= "@IsConstructable" "(" Val ")"
    10688  rule <k> @IsConstructable(F:Oid) => "prototype" in keys(Prop) ... </k>
                <obj>
                  <oid> F </oid>
                  <properties> Prop:Map </properties>
                  _
                </obj>
       16  rule @IsConstructable(F:Val) => false when @IsOid(F) =/=K true
           
           // 11.2.3 Function Calls
           
   117645  rule %call(F:Exp,Es:Exps) => @CallIfPossible(F, @DetermineThis(F), Es)
                when @IsEval(F) ==K false // TODO: could it be made in uniform way?
           
           syntax KItem /* Val */ ::= "@DetermineThis" "(" Exp ")"
           
   110320  rule @DetermineThis(F) => @FindThis(@GetReference(F)) when @IsReferenceExp(F) ==K true
     7288  rule @DetermineThis(F) => Undefined                  when @IsReferenceExp(F) ==K false
           
   220630  syntax KItem /* Val */ ::= "@FindThis" "(" K /* Reference */ ")" [seqstrict(1)]
           
    19555  rule @FindThis(@Ref(O:Oid,_,_)) => O
    90474  rule @FindThis(@Ref(E:Eid,_,_)) => ImplicitThisValue(E)
      281  rule @FindThis(@Ref(I:Primitive,_,_)) => I // NOTE: This will be resolved by @ResolveThis
           rule @FindThis(@Ref(Undefined,_,_)) => Undefined
           
   705561  syntax KItem /* Val */ ::= "@CallIfPossible" "(" K /* Val */ "," K /* Val */ "," K /* Vals */ ")" [seqstrict(1,2,3)]
           
   117504  rule @CallIfPossible(F:Val, This:Val, Args:Vals)
   235008    => If IsCallable(F) = true then {
   117460         Do Call(F, This, Args);
                } else {
       44         Do @Throw(@TypeError("CallIfPossible",F));
                }
           
           // 11.2.4 Argument Lists
           
   320023  context %cons(HOLE,_)
   319801  context %cons(_:Val,HOLE)
   159836  rule %cons(V:Val,Vs:Vals) => @Cons(V,Vs)
   130856  rule %nil => @Nil
           
           // 11.2.5 Function Expressions
           
    10204  rule %fun(       Params:Exps, FunBody:Stmt) => @FunctionExpressionAnonymous(   Params, FunBody)
       68  rule %fun(F:Var, Params:Exps, FunBody:Stmt) => @FunctionExpressionRecursive(F, Params, FunBody)
           
           // 11.3.1 Postfix Increment Operator
           
           syntax Id ::= "$lhs" | "$oldValue" | "$newValue"
           
     2522  rule %post(E:Exp,%inc)
     5042    => Let $lhs = @GetReference(E);
     5037       Let $oldValue = ToNumber(GetValue($lhs));
     5034       Let $newValue = @Addition($oldValue,1);
     2517       Do PutValue($lhs,$newValue);
     2517       Return $oldValue;
           
           // 11.3.2 Postfix Decrement Operator
           
     1167  rule %post(E:Exp,%dec)
     2332    => Let $lhs = @GetReference(E);
     2327       Let $oldValue = ToNumber(GetValue($lhs));
     2324       Let $newValue = @Subtraction($oldValue,1);
     1162       Do PutValue($lhs,$newValue);
     1162       Return $oldValue;
           
           // 11.4.1 The delete Operator
           
           // TODO: consider the first sentence of note.
     1284  rule %pre(%delete,E:Exp)
     1284    => If @IsReferenceExp(E) = false then {
       20         DoI E;
       20         Return true;
                } else {
     2527         Let $ref = @GetReference(E);
     1263         If IsUnresolvableReference($ref) = true then {
        5           If IsStrictReference($ref) = true then {
        1             Do @Throw(@SyntaxError("delete unresolvable ref",$ref));
                    } else {
        4             Return true;
                    }
                  } else {
     1258           If IsPropertyReference($ref) = true then {
     2294             Return Delete(ToObject(GetBase($ref)), GetReferencedName($ref), IsStrictReference($ref));
                    } else {
      107             If IsStrictReference($ref) = true then {
       26               Do @Throw(@SyntaxError("delete not property ref",$ref));
                      } else {
      162               Return DeleteBinding(GetBase($ref), GetReferencedName($ref));
                      }
                    }
                  }
                }
           
           // 11.4.2 The void Operator
           
       93  rule %pre(%void,E:Exp) => E ~> @Ignore ~> Undefined
           
           // 11.4.3 The typeof Operator
           
     3667  rule %pre(%typeof,E:Exp) => @Try(@TypeOf(E),"undefined")
           
     7289  syntax KItem ::= "@TypeOf" "(" K /* Val */ ")" [seqstrict(1)]
      486  rule @TypeOf(Undefined) => "undefined"
        3  rule @TypeOf(@NullVal  ) => "object"
       36  rule @TypeOf(_:Bool    ) => "boolean"
       98  rule @TypeOf(_:Number  ) => "number"
      158  rule @TypeOf(_:String  ) => "string"
     2768  rule @TypeOf(O:Oid     )
     5536    => If IsCallable(O) = true then {
      377         Return "function";
                } else {
     2391         Return "object";
                }
           // for built-in objects' functions
       73  rule @TypeOf(@(_)      ) => "function" // TODO: is there any better way?
           
           // NOTE: We don't need to consider the 'Case 2.a' that the reference value of E is an unresolvable reference.
           //       If the case happens, evaluating E throws an ReferenceError and we can catch the case.
           
           syntax KItem ::= "@Try" "(" K "," K ")" | "@PopExc"
           syntax KItem ::= "@exc" "(" K "," K "," CtrlCellFragment ")"
           
     3667  rule <k> (@Try(E1:K,E2:K) => E1 ~> @PopExc) ~> K </k>
                <ctrl>
                  <excStack> (.List => ListItem(@exc(E2,K,Ctrl))) _:List </excStack>
                  Ctrl
                </ctrl>
           
     3622  rule <k> V:Val ~> @PopExc => V ... </k>
                <ctrl>
                  <excStack> (ListItem(@exc(_,_,_)) => .List) _:List </excStack>
                  _
                </ctrl>
           
       43  rule <k> @Throw(V) ~> _ => E2 ~> K </k>
                <ctrl>
                  <excStack> (ListItem(@exc(E2,K,Ctrl)) => .List) _:List </excStack>
                  (_ => Ctrl)
                </ctrl>
           
           // 11.4.4 Prefix Increment Operator
           
     3456  rule %pre(%inc,E:Exp)
     6910    => Let $lhs = @GetReference(E);
     6905       Let $oldValue = ToNumber(GetValue($lhs));
     6902       Let $newValue = @Addition($oldValue,1);
     3451       Do PutValue($lhs,$newValue);
     3451       Return $newValue;
           
           // 11.4.5 Prefix Decrement Operator
           
       48  rule %pre(%dec,E:Exp)
       94    => Let $lhs = @GetReference(E);
       89       Let $oldValue = ToNumber(GetValue($lhs));
       86       Let $newValue = @Subtraction($oldValue,1);
       43       Do PutValue($lhs,$newValue);
       43       Return $newValue;
           
           // 11.4.6 Unary + Operator
           
      826  rule %pre(%plus,E:Exp) => ToNumber(E)
           
           // 11.4.7 Unary - Operator
           
     6420  rule %pre(%minus,E:Exp) => @Minus(ToNumber(E))
           
    12941  syntax KItem ::= "@Minus" "(" K /* Number */ ")" [seqstrict(1)]
    12149  rule @Minus(I:Int     ) => I *Int   (-1)   when I =/=Int   0
      536  rule @Minus(F:Float   ) => F *Float (-1.0) when F =/=Float 0.0
      293  rule @Minus(0         ) => @nz
        1  rule @Minus(0.0       ) => @nz
       14  rule @Minus(@nz       ) => 0.0
       33  rule @Minus(@NaN      ) => @NaN
      640  rule @Minus(@+Infinity) => @-Infinity
       13  rule @Minus(@-Infinity) => @+Infinity
           
           // 11.4.8 Bitwise NOT Operator ( ~ )
           
      105  rule %pre(%tilde,E:Exp) => @NotBitwise(ToInt32(E))
           
      205  syntax KItem ::= "@NotBitwise" "(" K ")" [seqstrict(1)]
           
      100  rule @NotBitwise(I:Int) => ~Int I
           
           // 11.4.9 Logical NOT Operator ( ! )
           
    16096  rule %pre(%bang,E:Exp) => @Not(ToBoolean(E))
           
    77878  syntax KItem ::= "@Not" "(" K /* Bool */ ")" [seqstrict(1)]
    40638  rule @Not(true) => false
     5809  rule @Not(false) => true
           
           // 11.? Binary Operator
           
   200174  context %bop(OpNormal,HOLE,_)
   182730  context %bop(OpNormal,_:Val,HOLE)
           
           // TODO: IEEE 754 binary double-precision arithmetic: *, /, %, +, -
           
    36518  syntax KItem ::= "@ResolveOverflow" "(" K /* Number */ ")" [seqstrict(1)]
     4798  rule @ResolveOverflow(F:Float) => @ResolveOverflowAux(F,F)
    60450  rule @ResolveOverflow(I:Int)   => @ResolveOverflowAux(I,@Int2Float(I))
           //
      640  rule @ResolveOverflow(N:Number) => N when isFloat(N) =/=K true andBool isInt(N) =/=K true
           
           syntax KItem ::= "@ResolveOverflowAux" "(" Number "," Float ")"
           syntax Id ::= "$max"
    65247  rule @ResolveOverflowAux(N:Number, F:Float)
    65247    => Let $max = 1.7976931348623157e308; // MAX_VALUE
    65247       If F >=Float 0.0 = true then {
    64926         If F >Float $max:>Float = true then {
       19           Return @+Infinity;
                  } else {
    64907           Return N;
                  }
                } else {
      321         If (F *Float -1.0) >Float $max:>Float = true then {
        8           Return @-Infinity;
                  } else {
      313           Return N;
                  }
                }
           
           // TODO: instead of using this, generalize number type to include sign information so that negative zero can be represented naturally
    14262  syntax KItem ::= "@ResolveNumber" "(" K /* Number */ "," K /* Bool */ ")" [seqstrict(1,2)]
       18  rule @ResolveNumber(0,  false) => @nz
           rule @ResolveNumber(0.0,false) => @nz
        8  rule @ResolveNumber(-0.0,false) => @nz
     3682  rule @ResolveNumber(N:Number,Positive:Bool) => N when (N =/=K 0 andBool N =/=K 0.0) orBool Positive =/=K false
           
           syntax Bool ::= "@IsPositive" "(" Number ")" [function]
           rule @IsPositive(I:Int)   => I >=Int   0
           rule @IsPositive(F:Float) => F >=Float 0.0
           rule @IsPositive(@nz) => false
           rule @IsPositive(@NaN) => true // TODO:
           rule @IsPositive(@+Infinity) => true
           rule @IsPositive(@-Infinity) => false
           
           // 11.5.1 Applying the * Operator
           
     2883  rule %bop(%times,V1:Val,V2:Val) => @ResolveOverflow(@MultiplicationSign(ToNumber(V1),ToNumber(V2)))
           
    11527  syntax KItem ::= "@MultiplicationSign" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
     2880  rule @MultiplicationSign(N1:Number,N2:Number) => @ResolveNumber(@Multiplication(N1,N2), @XorBool(@IsPositive(N1),@IsPositive(N2)))
           
           syntax KItem ::= "@Multiplication" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
       35  rule @Multiplication(@NaN,_) => @NaN
       25  rule @Multiplication(_,@NaN) => @NaN
           //
      471  rule @Multiplication(I1:Int,I2:Int    ) => I1            *Int   I2
       30  rule @Multiplication(I1:Int,F2:Float  ) => @Int2Float(I1) *Float F2
        2  rule @Multiplication( I:Int,@nz       ) => @MultiplicationNegativeZero(I)
       13  rule @Multiplication( I:Int,@+Infinity) => @MultiplicationInfinity(I)
        2  rule @Multiplication( I:Int,@-Infinity) => @MultiplicationInfinity(@Minus(I))
           //
     1081  rule @Multiplication(F1:Float,I2:Int    ) => F1 *Float @Int2Float(I2)
     1196  rule @Multiplication(F1:Float,F2:Float  ) => F1 *Float F2
           rule @Multiplication( F:Float,@nz       ) => @MultiplicationNegativeZero(F)
        1  rule @Multiplication( F:Float,@+Infinity) => @MultiplicationInfinity(F)
        1  rule @Multiplication( F:Float,@-Infinity) => @MultiplicationInfinity(@Minus(F))
           //
        2  rule @Multiplication(@nz,I:Int     ) => @MultiplicationNegativeZero(I)
           rule @Multiplication(@nz,F:Float   ) => @MultiplicationNegativeZero(F)
        2  rule @Multiplication(@nz,@nz       ) => 0
        1  rule @Multiplication(@nz,@+Infinity) => @NaN
        1  rule @Multiplication(@nz,@-Infinity) => @NaN
           //
        2  rule @Multiplication(@+Infinity,I:Int     ) => @MultiplicationInfinity(I)
        5  rule @Multiplication(@+Infinity,F:Float   ) => @MultiplicationInfinity(F)
        1  rule @Multiplication(@+Infinity,@nz       ) => @MultiplicationInfinity(@nz)
        1  rule @Multiplication(@+Infinity,@+Infinity) => @+Infinity
        1  rule @Multiplication(@+Infinity,@-Infinity) => @-Infinity
           //
        2  rule @Multiplication(@-Infinity,I:Int     ) => @MultiplicationInfinity(@Minus(I))
        2  rule @Multiplication(@-Infinity,F:Float   ) => @MultiplicationInfinity(@Minus(F))
        1  rule @Multiplication(@-Infinity,@nz       ) => @MultiplicationInfinity(@Minus(@nz))
        1  rule @Multiplication(@-Infinity,@+Infinity) => @-Infinity
        1  rule @Multiplication(@-Infinity,@-Infinity) => @+Infinity
           
       16  syntax KItem ::= "@MultiplicationInfinity" "(" K /* Number */ ")" [seqstrict(1)]
        3  rule @MultiplicationInfinity(@nz    ) => @NaN
        2  rule @MultiplicationInfinity(0      ) => @NaN
        2  rule @MultiplicationInfinity(I:Int  ) => @+Infinity when I >Int 0
       13  rule @MultiplicationInfinity(I:Int  ) => @-Infinity when I <Int 0
        1  rule @MultiplicationInfinity(0.0    ) => @NaN
        6  rule @MultiplicationInfinity(F:Float) => @+Infinity when F >Float 0.0
        3  rule @MultiplicationInfinity(F:Float) => @-Infinity when F <Float 0.0
           
           syntax KItem ::= "@MultiplicationNegativeZero" "(" K /* Number */ ")"
        4  rule @MultiplicationNegativeZero(I:Int  ) => @nz when I >=Int 0
           rule @MultiplicationNegativeZero(I:Int  ) => 0   when I  <Int 0
           rule @MultiplicationNegativeZero(F:Float) => @nz when F >=Float 0.0
           rule @MultiplicationNegativeZero(F:Float) => 0   when F  <Float 0.0
           
           // 11.5.2 Applying the / Operator
           
      546  rule %bop(%div,V1:Val,V2:Val) => @ResolveOverflow(@DivisionSign(ToNumber(V1),ToNumber(V2)))
           
     2179  syntax KItem ::= "@DivisionSign" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
      543  rule @DivisionSign(N1:Number,N2:Number) => @ResolveNumber(@Division(N1,N2), @XorBool(@IsPositive(N1),@IsPositive(N2)))
           
           syntax KItem ::= "@Division" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
       34  rule @Division(@NaN,_) => @NaN
       27  rule @Division(_,@NaN) => @NaN
           //
       23  rule @Division(0,  N:Number) =>        @DivisionZero(N)  when N =/=K @NaN
           rule @Division(0.0,N:Number) =>        @DivisionZero(N)  when N =/=K @NaN
        8  rule @Division(@nz,N:Number) => @Minus(@DivisionZero(N)) when N =/=K @NaN
           //
      105  rule @Division(N:Number,0  ) =>        @DivisionByZero(N)  when N =/=K @NaN
       15  rule @Division(N:Number,0.0) =>        @DivisionByZero(N)  when N =/=K @NaN
       36  rule @Division(N:Number,@nz) => @Minus(@DivisionByZero(N)) when N =/=K @NaN
           //
        5  rule @Division(@+Infinity,N:Number) =>        @DivisionInfinity(N)  when N =/=K @NaN
        5  rule @Division(@-Infinity,N:Number) => @Minus(@DivisionInfinity(N)) when N =/=K @NaN
           //
        5  rule @Division(N:Number,@+Infinity) =>        @DivisionByInfinity(N)  when N =/=K @NaN
        4  rule @Division(N:Number,@-Infinity) => @Minus(@DivisionByInfinity(N)) when N =/=K @NaN
           //
      141  rule @Division(I1:Int,  I2:Int    ) =>           I1  /Int             I2  when I1 =/=Int   0   andBool I2 =/=Int   0    andBool I1 %Int I2 ==Int  0
       28  rule @Division(I1:Int,  I2:Int    ) => @Int2Float(I1) /Float @Int2Float(I2) when I1 =/=Int   0   andBool I2 =/=Int   0    andBool I1 %Int I2 =/=Int 0
       76  rule @Division(I1:Int,  F2:Float  ) => @Int2Float(I1) /Float F2            when I1 =/=Int   0   andBool F2 =/=Float 0.0
        8  rule @Division(F1:Float,I2:Int    ) =>           F1  /Float @Int2Float(I2) when F1 =/=Float 0.0 andBool I2 =/=Int   0
       23  rule @Division(F1:Float,F2:Float  ) =>           F1  /Float F2            when F1 =/=Float 0.0 andBool F2 =/=Float 0.0
           
           syntax KItem ::= "@DivisionZero" "(" K /* Number */ ")" [seqstrict(1)]
        2  rule @DivisionZero(@nz    ) => @NaN
        4  rule @DivisionZero(0      ) => @NaN
       16  rule @DivisionZero(I:Int  ) => 0   when I >Int 0
        5  rule @DivisionZero(I:Int  ) => @nz when I <Int 0
           rule @DivisionZero(0.0    ) => @NaN
        2  rule @DivisionZero(F:Float) => 0   when F >Float 0.0
        2  rule @DivisionZero(F:Float) => @nz when F <Float 0.0
           rule @DivisionZero(@+Infinity) => 0
           rule @DivisionZero(@-Infinity) => @nz
           
           syntax KItem ::= "@DivisionInfinity" "(" K /* Number */ ")" [seqstrict(1)]
           rule @DivisionInfinity(@nz    ) => @-Infinity
           rule @DivisionInfinity(0      ) => @+Infinity
        2  rule @DivisionInfinity(I:Int  ) => @+Infinity when I >Int 0
        2  rule @DivisionInfinity(I:Int  ) => @-Infinity when I <Int 0
           rule @DivisionInfinity(0.0    ) => @+Infinity
        1  rule @DivisionInfinity(F:Float) => @+Infinity when F >Float 0.0
        1  rule @DivisionInfinity(F:Float) => @-Infinity when F <Float 0.0
        2  rule @DivisionInfinity(@+Infinity) => @NaN
        2  rule @DivisionInfinity(@-Infinity) => @NaN
           
           syntax KItem ::= "@DivisionByZero" "(" K /* Number */ ")" [seqstrict(1)]
           rule @DivisionByZero(@nz    ) => @NaN
           rule @DivisionByZero(0      ) => @NaN
      147  rule @DivisionByZero(I:Int  ) => @+Infinity when I >Int 0
        3  rule @DivisionByZero(I:Int  ) => @-Infinity when I <Int 0
           rule @DivisionByZero(0.0    ) => @NaN
        2  rule @DivisionByZero(F:Float) => @+Infinity when F >Float 0.0
           rule @DivisionByZero(F:Float) => @-Infinity when F <Float 0.0
        2  rule @DivisionByZero(@+Infinity) => @+Infinity
        2  rule @DivisionByZero(@-Infinity) => @-Infinity
           
           syntax KItem ::= "@DivisionByInfinity" "(" K /* Number */ ")" [seqstrict(1)]
           rule @DivisionByInfinity(@nz    ) => @nz
           rule @DivisionByInfinity(0      ) => 0
        4  rule @DivisionByInfinity(I:Int  ) => 0   when I >Int 0
        4  rule @DivisionByInfinity(I:Int  ) => @nz when I <Int 0
           rule @DivisionByInfinity(0.0    ) => 0.0
        1  rule @DivisionByInfinity(F:Float) => 0.0 when F >Float 0.0
           rule @DivisionByInfinity(F:Float) => @nz when F <Float 0.0
           rule @DivisionByInfinity(@+Infinity) => @NaN
           rule @DivisionByInfinity(@-Infinity) => @NaN
           
           // 11.5.3 Applying the % Operator
           
      288  rule %bop(%mod,V1:Val,V2:Val) => @ResolveOverflow(@ModuloSign(ToNumber(V1),ToNumber(V2)))
           
     1147  syntax KItem ::= "@ModuloSign" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
      285  rule @ModuloSign(N1:Number,N2:Number) => @ResolveNumber(@Modulo(N1,N2), @IsPositive(N1))
           
           syntax KItem ::= "@Modulo" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
       34  rule @Modulo(@NaN,_) => @NaN
       25  rule @Modulo(_,@NaN) => @NaN
           //
      144  rule @Modulo(I1:Int,I2:Int) => I1 %Int I2 when I2 =/=Int 0
       17  rule @Modulo(I1:Int,0     ) => @NaN
       15  rule @Modulo(I1:Int,N2:Number) => @Modulo(@Int2Float(I1),N2) when notBool(isInt(N2))
       13  rule @Modulo(N1:Number,I2:Int) => @Modulo(N1,@Int2Float(I2)) when notBool(isInt(N1))
           //
        5  rule @Modulo( _:Float,@nz       ) => @NaN
        2  rule @Modulo( _:Float,0.0       ) => @NaN
        4  rule @Modulo(0.0     , F:Float  ) => 0.0 when F =/=Float 0.0
        8  rule @Modulo(F1:Float,F2:Float  ) => F1 %Float F2 when F1 =/=Float 0.0 andBool F2 =/=Float 0.0
        8  rule @Modulo( F:Float,@+Infinity) => F
        8  rule @Modulo( F:Float,@-Infinity) => F
           //
        1  rule @Modulo(@nz     ,0.0       ) => @NaN
        8  rule @Modulo(@nz     ,F:Float   ) => @nz when F =/=Float 0.0
        1  rule @Modulo(@nz     ,@nz       ) => @NaN
        2  rule @Modulo(@nz     ,@+Infinity) => @nz
        2  rule @Modulo(@nz     ,@-Infinity) => @nz
           //
        8  rule @Modulo(@+Infinity,_) => @NaN
           //
        8  rule @Modulo(@-Infinity,_) => @NaN
           
           // 11.6.1 The Addition operator ( + )
           
    19934  rule %bop(%plus,V1:Val,V2:Val) => @PolymorphicAddition(ToPrimitive(V1,""), ToPrimitive(V2,""))
           
    79730  syntax KItem ::= "@PolymorphicAddition" "(" K /* Val */ "," K /* Val */ ")" [seqstrict(1,2)]
     2109  rule @PolymorphicAddition(V1:Val,V2:Val) => @ResolveOverflow(@Addition(ToNumber(V1), ToNumber(V2))) when notBool(@IsString(V1) ==K true) andBool notBool(@IsString(V2) ==K true)
    17821  rule @PolymorphicAddition(V1:Val,V2:Val) =>              @Concatnation(ToString(V1), ToString(V2))  when          isString(V1) ==K true   orBool          isString(V2) ==K true
           
    71284  syntax KItem ::= "@Concatnation" "(" K /* String */ "," K /* String */ ")" [seqstrict(1,2)]
    17821  rule @Concatnation(S1:String,S2:String) => S1 +String S2
           
           // 11.6.2 The Subtraction Operator ( - )
           
     6045  rule %bop(%minus,V1:Val,V2:Val) => @ResolveOverflow(@Subtraction(ToNumber(V1), ToNumber(V2)))
           
           // 11.6.3 Applying the Additive Operators to Numbers
           
    22806  syntax KItem ::= "@Addition" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
       85  rule @Addition(@NaN,_) => @NaN
       34  rule @Addition(_,@NaN) => @NaN
           //
    15044  rule @Addition(I1:Int,I2:Int    ) => I1 +Int I2
        9  rule @Addition(I1:Int,F2:Float  ) => @Int2Float(I1) +Float F2
       34  rule @Addition( I:Int,@nz       ) => I
        3  rule @Addition( _:Int,@+Infinity) => @+Infinity
        3  rule @Addition( _:Int,@-Infinity) => @-Infinity
           //
       31  rule @Addition(F1:Float,I2:Int    ) => F1 +Float @Int2Float(I2)
       45  rule @Addition(F1:Float,F2:Float  ) => F1 +Float F2
        3  rule @Addition( F:Float,@nz       ) => F
        3  rule @Addition( _:Float,@+Infinity) => @+Infinity
        2  rule @Addition( _:Float,@-Infinity) => @-Infinity
           //
        4  rule @Addition(@nz,I:Int     ) => I
        4  rule @Addition(@nz,F:Float   ) => F
        4  rule @Addition(@nz,@nz       ) => @nz
           rule @Addition(@nz,@+Infinity) => @+Infinity
           rule @Addition(@nz,@-Infinity) => @-Infinity
           //
        2  rule @Addition(@+Infinity,_:Int     ) => @+Infinity
        2  rule @Addition(@+Infinity,_:Float   ) => @+Infinity
           rule @Addition(@+Infinity,@nz       ) => @+Infinity
        2  rule @Addition(@+Infinity,@+Infinity) => @+Infinity
        2  rule @Addition(@+Infinity,@-Infinity) => @NaN
           //
        2  rule @Addition(@-Infinity,_:Int     ) => @-Infinity
        2  rule @Addition(@-Infinity,_:Float   ) => @-Infinity
           rule @Addition(@-Infinity,@nz       ) => @-Infinity
        2  rule @Addition(@-Infinity,@+Infinity) => @NaN
        2  rule @Addition(@-Infinity,@-Infinity) => @-Infinity
           
    24175  syntax KItem ::= "@Subtraction" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
     7247  rule @Subtraction(N1:Number,N2:Number) => @Addition(N1,@Minus(N2))
           
           // 11.7.1 The Left Shift Operator ( << )
           
     2381  rule %bop(%lshift,V1:Val,V2:Val) => @LeftShift(ToInt32(V1),ToUint32(V2))
           
     9519  syntax KItem ::= "@LeftShift" "(" K "," K ")" [seqstrict(1,2)]
           
     2378  rule @LeftShift(I1:Int,I2:Int) => svalueMInt(shlMInt(mi(32,I1), I2 &Int 31 /* 0x1F */))
           
           // 11.7.2 The Signed Right Shift Operator ( >> )
           
     2325  rule %bop(%rshift,V1:Val,V2:Val) => @SignedRightShift(ToInt32(V1),ToUint32(V2))
           
     9295  syntax KItem ::= "@SignedRightShift" "(" K "," K ")" [seqstrict(1,2)]
           
           // Arithmetic shift, sign extension shift: ashrMInt
     2322  rule @SignedRightShift(I1:Int,I2:Int) => svalueMInt(ashrMInt(mi(32,I1), I2 &Int 31 /* 0x1F */))
           
           // 11.7.3 The Unsigned Right Shift Operator ( >>> )
           
     2389  rule %bop(%rshiftshift,V1:Val,V2:Val) => @UnsignedRightShift(ToUint32(V1),ToUint32(V2))
           
     9539  syntax KItem ::= "@UnsignedRightShift" "(" K "," K ")" [seqstrict(1,2)]
           
           // Logical shift, zero-filling shift: lshrMInt
     2382  rule @UnsignedRightShift(I1:Int,I2:Int) => uvalueMInt(lshrMInt(mi(32,I1), I2 &Int 31 /* 0x1F */))
           
           // 11.8.1 The Less-than Operator ( < )
           
           syntax Id ::= "$v1" | "$v2" | "$r"
           
    13215  rule %bop(%lt,V1:Val,V2:Val)
    26429    => Let $v1 = ToPrimitive(V1,"Number");
    26426       Let $v2 = ToPrimitive(V2,"Number");
    26423       Let $r = @LessThan($v1,$v2);
    13211       If $r = Undefined then {
       34         Return false;
                } else {
    13177         Return $r;
                }
           
           // 11.8.2 The Greater-than Operator ( > )
           
     2600  rule %bop(%gt,V1:Val,V2:Val)
     5199    => Let $v1 = ToPrimitive(V1,"Number");
     5196       Let $v2 = ToPrimitive(V2,"Number");
     5194       Let $r = @LessThan($v2,$v1);
     2597       If $r = Undefined then {
       33         Return false;
                } else {
     2564         Return $r;
                }
           
           // 11.8.3 The Less-than-or-equal Operator ( <= )
           
     1836  rule %bop(%le,V1:Val,V2:Val)
     3671    => Let $v1 = ToPrimitive(V1,"Number");
     3668       Let $v2 = ToPrimitive(V2,"Number");
     3666       Let $r = @LessThan($v2,$v1);
     1833       If $r = Undefined then {
       36         Return false;
                } else {
     3594         Return @Not($r);
                }
           
           // 11.8.4 The Greater-than-or-equal Operator ( >= )
           
     5766  rule %bop(%ge,V1:Val,V2:Val)
    11531    => Let $v1 = ToPrimitive(V1,"Number");
    11528       Let $v2 = ToPrimitive(V2,"Number");
    11526       Let $r = @LessThan($v1,$v2);
     5763       If $r = Undefined then {
       36         Return false;
                } else {
    11454         Return @Not($r);
                }
           
           // 11.8.5 The Abstract Relational Comparison Algorithm
           
           syntax KItem ::= "@LessThan" "(" K "," K ")"
    23216  rule @LessThan(V1:Val,V2:Val) => @LessThanNumber(ToNumber(V1),ToNumber(V2))
                when notBool(@IsString(V1) andBool @IsString(V2))
      189  rule @LessThan(V1:String,V2:String) => @LessThanString(V1,V2)
           
    92710  syntax KItem ::= "@LessThanNumber" "(" K "," K ")" [seqstrict(1,2)]
       76  rule @LessThanNumber(@NaN,_) => Undefined
       63  rule @LessThanNumber(_,@NaN) => Undefined
           //
    22393  rule @LessThanNumber(I:Int,N:Number) => @LessThanNumber(@Int2Float(I),N)
    22409  rule @LessThanNumber(N:Number,I:Int) => @LessThanNumber(N,@Int2Float(I))
           //
    21930  rule @LessThanNumber(F1:Float,F2:Float  ) => F1 <Float F2
        6  rule @LessThanNumber( 0.0    ,@nz       ) => false
           rule @LessThanNumber( F:Float,@nz       ) => F <Float 0.0 when F =/=Float 0.0
      511  rule @LessThanNumber( _:Float,@+Infinity) => true
       20  rule @LessThanNumber( _:Float,@-Infinity) => false
           //
        1  rule @LessThanNumber(@nz,F:Float   ) => 0.0 <Float F when F =/=Float 0.0
        8  rule @LessThanNumber(@nz,0.0       ) => false // NOTE: unlike intuition, step.3.g is not typo
        4  rule @LessThanNumber(@nz,@nz       ) => false
        1  rule @LessThanNumber(@nz,@+Infinity) => true
           rule @LessThanNumber(@nz,@-Infinity) => false
           //
       34  rule @LessThanNumber(@+Infinity,_:Float   ) => false
           rule @LessThanNumber(@+Infinity,@nz       ) => false
       11  rule @LessThanNumber(@+Infinity,@+Infinity) => false
        8  rule @LessThanNumber(@+Infinity,@-Infinity) => false
           //
      512  rule @LessThanNumber(@-Infinity,_:Float   ) => true
        3  rule @LessThanNumber(@-Infinity,@nz       ) => true
       16  rule @LessThanNumber(@-Infinity,@+Infinity) => true
       11  rule @LessThanNumber(@-Infinity,@-Infinity) => false
           
           syntax KItem ::= "@LessThanString" "(" K "," K ")"
           
      189  rule @LessThanString(S1:String,S2:String) => S1 <String S2
           
           // 11.8.6 The instanceof operator
           
     1253  rule %bop(%instanceof,V1:Val,V2:Val)
     1253    => If @IsOid(V2) = true then {
     2496         If @HasHasInstance(V2) = true then {
     2487           Return HasInstance(V2,V1);
                  } else {
        3           Do @Throw(@TypeError("instanceof not having hasinstance",V2));
                  }
                } else {
        5         Do @Throw(@TypeError("instanceof not object",V2));
                }
           
           syntax KItem /* Bool */ ::= "@HasHasInstance" "(" K ")"
     1248  rule @HasHasInstance(F:Oid)
             => @EqVal(GetInternalProperty(F,"Class"), "Function")
           
           // 11.8.7 The in operator
           
       62  rule %bop(%in,V1:Val,V2:Val)
       62    => If @IsOid(V2) = true then {
      114         Return HasProperty(V2,ToString(V1));
                } else {
        5         Do @Throw(@TypeError("in",V2));
                }
           
           // 11.9.1 The Equals Operator ( == )
           
      264  rule %bop(%eq, V1:Val,V2:Val) =>      @AbstractEquality(V1,V2)
           
           // 11.9.2 The Does-not-equals Operator ( != )
           
      253  rule %bop(%neq,V1:Val,V2:Val) => @Not(@AbstractEquality(V1,V2))
           
           // 11.9.3 The Abstract Equality Comparison Algorithm
           
      598  syntax KItem ::= "@AbstractEquality" "(" K /* Val */ "," K /* Val */ ")" [seqstrict(1,2)]
           
        6  rule @AbstractEquality(Undefined,Undefined) => true
        2  rule @AbstractEquality(Undefined,@NullVal  ) => true
        2  rule @AbstractEquality(Undefined,_:Bool    ) => false
        2  rule @AbstractEquality(Undefined,_:String  ) => false
        4  rule @AbstractEquality(Undefined,_:Number  ) => false
        2  rule @AbstractEquality(Undefined,_:Oid     ) => false
           //
        2  rule @AbstractEquality(@NullVal,  Undefined) => true
        2  rule @AbstractEquality(@NullVal,  @NullVal  ) => true
        2  rule @AbstractEquality(@NullVal,  _:Bool    ) => false
        2  rule @AbstractEquality(@NullVal,  _:String  ) => false
        2  rule @AbstractEquality(@NullVal,  _:Number  ) => false
        2  rule @AbstractEquality(@NullVal,  _:Oid     ) => false
           //
        2  rule @AbstractEquality(B:Bool,    Undefined) => false
        2  rule @AbstractEquality(B:Bool,    @NullVal  ) => false
       25  rule @AbstractEquality(B1:Bool,   B2:Bool   ) => B1 ==K B2
        4  rule @AbstractEquality(B:Bool,    S:String  ) => @AbstractEquality(ToNumber(B), ToNumber(S))
       35  rule @AbstractEquality(B:Bool,    N:Number  ) => @AbstractEquality(ToNumber(B), N)
       12  rule @AbstractEquality(B:Bool,    O:Oid     ) => @AbstractEquality(ToNumber(B), ToPrimitive(O,""))
           //
        3  rule @AbstractEquality(S:String,  Undefined) => false
        3  rule @AbstractEquality(S:String,  @NullVal  ) => false
        6  rule @AbstractEquality(S:String,  B:Bool    ) => @AbstractEquality(ToNumber(S), ToNumber(B))
       78  rule @AbstractEquality(S1:String, S2:String ) => S1 ==K S2
       26  rule @AbstractEquality(S:String,  N:Number  ) => @AbstractEquality(ToNumber(S), N)
       17  rule @AbstractEquality(S:String,  O:Oid     ) => @AbstractEquality(S, ToPrimitive(O,""))
           //
        2  rule @AbstractEquality(N:Number,  Undefined) => false
        2  rule @AbstractEquality(N:Number,  @NullVal  ) => false
        9  rule @AbstractEquality(N:Number,  B:Bool    ) => @AbstractEquality(N, ToNumber(B))
       26  rule @AbstractEquality(N:Number,  S:String  ) => @AbstractEquality(N, ToNumber(S))
      338  rule @AbstractEquality(N1:Number, N2:Number ) => @AbstractEqualityNumber(N1,N2)
       16  rule @AbstractEquality(N:Number,  O:Oid     ) => @AbstractEquality(N, ToPrimitive(O,""))
           //
        2  rule @AbstractEquality(O:Oid,     Undefined) => false
        2  rule @AbstractEquality(O:Oid,     @NullVal  ) => false
       18  rule @AbstractEquality(O:Oid,     B:Bool    ) => @AbstractEquality(ToPrimitive(O,""), ToNumber(B))
       43  rule @AbstractEquality(O:Oid,     S:String  ) => @AbstractEquality(ToPrimitive(O,""), S)
       52  rule @AbstractEquality(O:Oid,     N:Number  ) => @AbstractEquality(ToPrimitive(O,""), N)
       18  rule @AbstractEquality(O1:Oid,    O2:Oid    ) => O1 ==K O2
           
           syntax KItem ::= "@AbstractEqualityNumber" "(" K /* Val */ "," K /* Val */ ")" [seqstrict(1,2)]
           
       28  rule @AbstractEqualityNumber(@NaN,_:Number) => false
       14  rule @AbstractEqualityNumber(_:Number,@NaN) => false
           //
       36  rule @AbstractEqualityNumber(0,  0  ) => true
           rule @AbstractEqualityNumber(0,  0.0) => true
        4  rule @AbstractEqualityNumber(0,  @nz) => true
           rule @AbstractEqualityNumber(0.0,0  ) => true
           rule @AbstractEqualityNumber(0.0,0.0) => true
           rule @AbstractEqualityNumber(0.0,@nz) => true
        3  rule @AbstractEqualityNumber(@nz,0  ) => true
           rule @AbstractEqualityNumber(@nz,0.0) => true
           rule @AbstractEqualityNumber(@nz,@nz) => true
           //
      253  rule @AbstractEqualityNumber(N1:Number,N2:Number) => SameValue(N1,N2)
                when notBool(N1 ==K @NaN orBool N2 ==K @NaN)
             andBool notBool((N1 ==K 0 orBool N1 ==K 0.0 orBool N1 ==K @nz) andBool
                             (N2 ==K 0 orBool N2 ==K 0.0 orBool N2 ==K @nz))
           
           // 11.9.4 The Strict Equals Operator ( === )
           
    21491  rule %bop(%eqs, V1:Val,V2:Val) =>      @StrictEquality(V1,V2)
           
           // 11.9.5 The Strict Does-not-equal Operator ( !== )
           
    22606  rule %bop(%neqs,V1:Val,V2:Val) => @Not(@StrictEquality(V1,V2))
           
           // 11.9.6 The Strict Equality Comparison Algorithm
           
     1404  syntax KItem ::= "@StrictEquality" "(" K /* Val */ "," K /* Val */ ")" [seqstrict(1,2)]
           
    41343  rule @StrictEquality(V1:Val,V2:Val) => SameValue(V1,V2)
                when notBool(V1 ==K @NaN orBool V2 ==K @NaN)
             andBool notBool((V1 ==K 0 orBool V1 ==K 0.0 orBool V1 ==K @nz) andBool
                             (V2 ==K 0 orBool V2 ==K 0.0 orBool V2 ==K @nz))
           //
       69  rule @StrictEquality(@NaN,_) => false
       22  rule @StrictEquality(_,@NaN) => false
           //
     3281  rule @StrictEquality(0,  0  ) => true
           rule @StrictEquality(0,  0.0) => true
        5  rule @StrictEquality(0,  @nz) => true
       22  rule @StrictEquality(0.0,0  ) => true
        2  rule @StrictEquality(0.0,0.0) => true
           rule @StrictEquality(0.0,@nz) => true
       19  rule @StrictEquality(@nz,0  ) => true
           rule @StrictEquality(@nz,0.0) => true
       54  rule @StrictEquality(@nz,@nz) => true
           
           // 11.10 Binary Bitwise Operators
           
      241  rule %bop(%amp,  V1:Val,V2:Val) => @BitwiseAND(ToInt32(V1),ToInt32(V2))
      187  rule %bop(%caret,V1:Val,V2:Val) => @BitwiseXOR(ToInt32(V1),ToInt32(V2))
      191  rule %bop(%bar,  V1:Val,V2:Val) => @BitwiseOR (ToInt32(V1),ToInt32(V2))
           
      959  syntax KItem /* Int32 */ ::= "@BitwiseAND" "(" K /* Int32 */ "," K /* Int32 */ ")" [seqstrict(1,2)]
      743  syntax KItem /* Int32 */ ::= "@BitwiseXOR" "(" K /* Int32 */ "," K /* Int32 */ ")" [seqstrict(1,2)]
      759  syntax KItem /* Int32 */ ::= "@BitwiseOR"  "(" K /* Int32 */ "," K /* Int32 */ ")" [seqstrict(1,2)]
           
      238  rule @BitwiseAND(I1:Int,I2:Int) => I1   &Int I2
      184  rule @BitwiseXOR(I1:Int,I2:Int) => I1 xorInt I2
      188  rule @BitwiseOR (I1:Int,I2:Int) => I1   |Int I2
           
           // 11.11 Binary Logical Operators
           
           context %bop(_:OpShortcut,HOLE,_)
           
     7374  rule %bop(%and,V1:Val,E2:Exp)
    14748    => If ToBoolean(V1) = true then {
    13067         Return E2;
                } else {
      838         Return V1;
                }
           
     1185  rule %bop(%or,V1:Val,E2:Exp)
     2370    => If ToBoolean(V1) = true then {
      672         Return V1;
                } else {
      972         Return E2;
                }
           
           // 11.12 Conditional Operator( ? : )
           
     1588  context %cond(HOLE,_,_)
      792  rule %cond(V:Val,E1,E2)
     1584    => If ToBoolean(V) = true then {
      629         Return E1;
                } else {
      947         Return E2;
                }
           
           // 11.13.1 Simple Assignment ( = )
           // TODO: Consider Strict mode, Step 4
           
   100095  rule %bop(%assign,L:Exp,E:Exp) => @PutValueAndReturn(@GetReference(L),E)
           
   407148  syntax KItem /* Val */ ::= "@PutValueAndReturn" "(" K /* Reference */ "," K /* Val */ ")" [seqstrict(1,2)]
   103305  rule @PutValueAndReturn(L:Reference,V:Val) => PutValue(L,V) ~> V
           
           // 11.13.2 Compound Assignment ( op= )
           
           syntax Id ::= "$ref"
     3606  rule %bopassign(Op:Op,L:Exp,E:Exp)
     7190    => Let $ref = @GetReference(L);
     3584       Do @PutValueAndReturn($ref, %bop(Op, GetValue($ref), E));
           
           // 11.14 Comma Operator(,)
           
       62  rule %comma(E1:Exp,E2:Exp) => E1 ~> @Ignore ~> E2
           
           //////////////////////////////////////////////////////////////////////////////
           // 12 Statements
           //////////////////////////////////////////////////////////////////////////////
           
           // 12.1 Block
           // NOTE: Nothing to do
           
           // 12.2 Variable Statement
           
    79553  rule %vdecl(_) => %emptyStmt
           
           // 12.3 Empty Statement
           
   280932  rule %emptyStmt => @Normal
           
           // 12.4 Expression Statement
           
   141381  rule %exp(E:Exp) => @Exp(E)
           
   280056  syntax KItem ::= "@Exp" "(" K /* Val */ ")" [seqstrict(1)]
   138675  rule @Exp(V:Val) => @UpdateStmtValue(V) ~> @Normal
           
           syntax KItem /* .K */ ::= "@UpdateStmtValue" "(" Val ")"
   118271  rule <k> @UpdateStmtValue(V:Val) => . ... </k>
                <lastNonEmptyValue> _ => V </lastNonEmptyValue>
                when V =/=K Undefined
    20404  rule @UpdateStmtValue(Undefined) => .
           
           // 12.5 The if Statement
           
   143257  context %if(HOLE,_,_)
    71541  rule %if(V:Val,S1,S2)
   143082    => If ToBoolean(V) = true then {
    15243         Do S1;
                } else {
    56298         Do S2;
                }
           
           // 12.6 Iteration Statements
           
           // 12.6.1 The do-while Statement
           
       76  rule %do(S,E) => %seq(S, %while(E,S))
           
           // 12.6.2 The while Statement
           
    10374  rule %while(E,S) => %if(E, %seq(S, %while(E,S)), %emptyStmt)
           
           // 12.6.3 The for Statement
           
       28  rule %for(S0,%emptyExp,E2,S) => %seq(S0, %while(%con(true), %seq(S, %exp(E2))))
     3220  rule %for(S0,E1,       E2,S) => %seq(S0, %while(E1,         %seq(S, %exp(E2)))) when E1 =/=K %emptyExp
           
           // 12.6.4 The for-in Statement
           
           syntax Id ::= "$e" | "$props"
           
     2023  rule %forin(S0,E1,E2,S) => %seq(S0, @ForIn(E1,E2,S))
           
           syntax Stmt ::= "@ForIn" "(" Exp "," Exp "," Stmt ")"
     2023  rule @ForIn(L:Exp,E:Exp,S:Stmt)
     4046    => Let $e = E;
     4046       If @OrBool(@EqVal($e, @NullVal), @EqVal($e, Undefined)) = true then {
       14         Return @Normal;
                } else {
     4018         Let $o = ToObject($e);
     4018         Let $props = @EnumerateAllProperties($o:>Oid, .Map, .Set);
                //Let $props = @EnumerateAllProperties($o:>Oid, .Set, .Set);
     2009         Do @ForInAux(L, $o:>Oid, $props, S);
                }
           
           syntax Stmt ::= "@ForInAux" "(" Exp "," Oid "," K "," Stmt ")"
           syntax Id ::= "$owner"
     1786  rule @ForInAux(_:Exp, _:Oid, @m(                   .Map), _:Stmt) => @Normal
     4315  rule @ForInAux(L:Exp, O:Oid, @m(P:Var |-> OP:Oid Ps:Map), S:Stmt)
     8630    => Let $desc = GetProperty(O,P);
     4315       If $desc = Undefined then {
        4         Do @ForInAux(L,O,@m(Ps),S);
                } else {
     8622         Let $owner = GetPropertyOwner(O,P);
     4311         If $owner = OP then {
     4311           Do %seq(%exp(%bop(%assign,L,%con(P:>String))),
                             %seq(S, @ForInAux(L,O,@m(Ps),S)));
                  } else {
                    // NOTE: UNSPECIFIED/UNDEFINED BEHAVIOR:
                    // If the current property name refers to another property, then the behavior is not specified in the language standard.
                    // This situation can occur when (for example)
                    // - the existing property was deleted before visiting, which reveals a shadowed property.
                    // - a new property was added, which shadows the existing property.
                    // - the prototype chain was modified so that it inherits different objects.
        0           Do @unspecified;
                  }
                }
           
           syntax KItem ::= "@unspecified"
           
           syntax KItem /* Set */ ::= "@EnumerateAllProperties" "(" Oid "," Map "," Set ")"
     2009  rule     @EnumerateAllProperties(@NullOid, TM:Map, _:Set) => @m(TM)
     4484  rule <k> @EnumerateAllProperties(O:Oid, TM:Map, KS:Set)
                 => @EnumerateAllProperties(Proto, @AddProp(O,Prop,TM,KS), keys(Prop) KS) ... </k>
                <obj>
                  <oid> O </oid>
                  <properties> Prop:Map </properties>
                  <internalProperties> "Prototype" |-> Proto:Oid _:Map </internalProperties>
                </obj>
                when O =/=K @NullOid
           
           syntax Map ::= "@AddProp" "(" Oid "," Map "," Map "," Set ")" [function]
           rule @AddProp(O:Oid,                                      .Map, TM:Map,  _:Set) => TM
           rule @AddProp(O:Oid, (P:Var |-> Desc:PropertyDescriptor) M:Map, TM:Map, KS:Set) => @AddPropAux(O, P, Desc, M, TM, KS)
           //
           syntax Map ::= "@AddPropAux" "(" Oid "," Var "," PropertyDescriptor "," Map "," Map "," Set ")" [function]
           rule @AddPropAux(O:Oid, P:Var, Desc:PropertyDescriptor, M:Map, TM:Map, KS:Set) => @AddProp(O, M, P |-> O TM, KS) when notBool(P in KS) andBool Desc."Enumerable" ==K true
           rule @AddPropAux(O:Oid, P:Var, Desc:PropertyDescriptor, M:Map, TM:Map, KS:Set) => @AddProp(O, M,         TM, KS) when         P in KS   orBool Desc."Enumerable" ==K false
           /*
           syntax Map ::= "@AddProp" "(" Oid "," Map "," Map "," Set ")" [function]
           rule @AddProp(O:Oid,                                      .Map, TM:Map,  _:Set) => TM
           rule @AddProp(O:Oid, (P:Var |-> Desc:PropertyDescriptor) M:Map, TM:Map, KS:Set) => @AddProp(O, M, P |-> O TM, KS) when notBool(P in KS) andBool Desc."Enumerable" ==K true
           rule @AddProp(O:Oid, (P:Var |-> Desc:PropertyDescriptor) M:Map, TM:Map, KS:Set) => @AddProp(O, M,         TM, KS) when         P in KS   orBool Desc."Enumerable" ==K false
           */
           
           // XXX: Unsupported AC Matching
           //
           // syntax Stmt ::= "@ForInAux" "(" Exp "," Oid "," K "," Stmt ")"
           // syntax Id ::= "$owner"
           // rule @ForInAux(_:Exp, _:Oid, @s(                                .Set), _:Stmt) => @Normal
           // rule @ForInAux(L:Exp, O:Oid, @s(SetItem(@tuple(OP:Oid,P:Var)) Ps:Set), S:Stmt)
           //   => Let $desc = GetProperty(O,P);
           //      If $desc = Undefined then {
           //        Do @ForInAux(L,O,@s(Ps),S);
           //      } else {
           //        Let $owner = GetPropertyOwner(O,P);
           //        If $owner = OP then {
           //          Do %seq(%exp(%bop(%assign,L,%con(P:>String))),
           //                   %seq(S, @ForInAux(L,O,@s(Ps),S)));
           //        } else {
           //          // NOTE: UNSPECIFIED/UNDEFINED BEHAVIOR:
           //          // If the current property name refers to another property, then the behavior is not specified in the language standard.
           //          // This situation can occur when (for example)
           //          // - the existing property was deleted before visiting, which reveals a shadowed property.
           //          // - a new property was added, which shadows the existing property.
           //          // - the prototype chain was modified so that it inherits different objects.
           //          Do @unspecified;
           //        }
           //      }
           // 
           // syntax KItem ::= "@unspecified"
           // 
           // syntax KItem /* Set */ ::= "@EnumerateAllProperties" "(" Oid "," Set "," Set ")"
           // rule     @EnumerateAllProperties(@NullOid, TS:Set, _:Set) => @s(TS)
           // rule <k> @EnumerateAllProperties(O:Oid, TS:Set, KS:Set)
           //       => @EnumerateAllProperties(Proto, @AddTuples(O,Prop,TS,KS), keys(Prop) KS) ... </k>
           //      <obj>
           //        <oid> O </oid>
           //        <properties> Prop:Map </properties>
           //        <internalProperties> "Prototype" |-> Proto:Oid _:Map </internalProperties>
           //      </obj>
           //      when O =/=K @NullOid
           // 
           // syntax KItem ::= "@tuple" "(" K "," K ")"
           // 
           // syntax Set ::= "@AddTuples" "(" Oid "," Map "," Set "," Set ")" [function]
           // rule @AddTuples(O:Oid,                                      .Map, TS:Set,  _:Set) => TS
           // rule @AddTuples(O:Oid, (P:Var |-> Desc:PropertyDescriptor) M:Map, TS:Set, KS:Set) => @AddTuples(O, M, SetItem(@tuple(O,P)) TS, KS) when notBool(P in KS) andBool Desc."Enumerable" ==K true
           // rule @AddTuples(O:Oid, (P:Var |-> Desc:PropertyDescriptor) M:Map, TS:Set, KS:Set) => @AddTuples(O, M,                      TS, KS) when         P in KS   orBool Desc."Enumerable" ==K false
           
           // XXX: Before supporting unspecified behavior check
           //
           // syntax Stmt ::= "@ForInAux" "(" Exp "," Oid "," K "," Stmt ")"
           // rule @ForInAux(_:Exp, _:Oid, @s(                 .Set), _:Stmt) => @Normal
           // rule @ForInAux(L:Exp, O:Oid, @s(SetItem(P:Var) Ps:Set), S:Stmt)
           //   => Let $desc = GetProperty(O,P);
           //      If $desc = Undefined then {
           //        Do @ForInAux(L,O,@s(Ps),S);
           //      } else {
           //        If $desc."Enumerable" = true then {
           //          Do %seq(%exp(%bop(%assign,L,%con(P:>String))),
           //                   %seq(S, @ForInAux(L,O,@s(Ps),S)));
           //        } else {
           //          Do @ForInAux(L,O,@s(Ps),S);
           //        }
           //      }
           //
           // syntax K /* Set */ ::= "@EnumerateAllProperties" "(" Oid "," Set ")"
           // rule     @EnumerateAllProperties(@NullOid, S:Set) => @s(S)
           // rule <k> @EnumerateAllProperties(O:Oid, S:Set)
           //       => @EnumerateAllProperties(Proto, keys(Prop) S) ... </k>
           //      <obj>
           //        <oid> O </oid>
           //        <properties> Prop:Map </properties>
           //        <internalProperties> "Prototype" |-> Proto:Oid _:Map </internalProperties>
           //      </obj>
           //      when O =/=K @NullOid
           
           // 12.7 The continue Statement
           
      180  rule %continue(L) => @Continue(L)
           
           // 12.8 The break Statement
           
      207  rule %break(L) => @Break(L)
           
           // 12.9 The return Statement
           
    82641  context %return(HOLE)
    41112  rule %return(V:Val) => @Return(V)
           
           // 12.10 The with Statement
           
      196  rule <k> %with(E,S)
      196        => Do @SetRunningCtx(NewObjectEnvironment(ToObject(E),Env,true,false), This);
      338           Let $result = S;
      144           Do @RestoreRunningCtx;
      144           Return $result;
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
           
      283  rule %switch(E,C1,D,C2) => @Switch(E,C1,D,C2)
           
      566  syntax KItem ::= "@Switch" "(" K /* Val */ "," Stmt "," Stmt "," Stmt ")" [seqstrict(1)]
           
      623  rule @Switch(Input:Val, %seq(%case(E,S),C1), D, C2)
     1246    => If @StrictEquality(Input,E) = true then {
       20         Do %seq(S,%seq(C1,%seq(D,C2)));
                } else {
      603         Do @Switch(Input,C1,D,C2);
                }
           
       97  rule @Switch(Input:Val, %emptyStmt, D, %seq(%case(E,S),C2))
      194    => If @StrictEquality(Input,E) = true then {
       13         Do %seq(S,C2);
                } else {
       84         Do @Switch(Input,%emptyStmt,D,C2);
                }
           
      249  rule @Switch(_:Val, %emptyStmt, %default(S), %emptyStmt) => S
           
        1  rule @Switch(_:Val, %emptyStmt, %emptyStmt, %emptyStmt) => @Normal
           
       10  rule %case(_,S) => S
        6  rule %default(S) => S
           
           // 12.12 Labelled Statements
           // TODO: Move to the first-pass
           
     5874  rule %label(L,S) => %seq(@AddContinueLabel(L,S), %labelBreak(L))
           
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
           
    11061  rule %labelContinue(_) => %emptyStmt
     4985  rule %labelBreak(_)    => %emptyStmt
           
           // 12.13 The throw Statement
           
     1549  context %throw(HOLE)
      773  rule %throw(V:Val) => @Throw(V)
           
           // 12.14 The try Statement
           
           /*
           rule %try(S:Stmt,X:Var,Catch:Stmt             ) => @TryCatch(S,X,Catch)
           */
      305  rule %try(S:Stmt,                 Finally:Stmt) => @TryFinally(S,Finally)
     3015  rule %try(S:Stmt,X:Var,Catch:Stmt,Finally:Stmt) => @TryCatchFinally(S,X,Catch,Finally)
           
           syntax KItem ::= "@TryCatch" "(" Stmt "," Var "," Stmt ")"
                      | "@PopExcTC"
           
           rule <k> (@TryCatch(S:Stmt,X:Var,Catch:Stmt) => S ~> @PopExcTC) ~> K </k>
                <ctrl>
                  <excStack> (.List => ListItem(@excTC(X,Catch,K,Ctrl))) _:List </excStack>
                  Ctrl
                </ctrl>
           
           rule <k> CT:CompletionType ~> @PopExcTC => CT ... </k>
                <ctrl>
                  <excStack> (ListItem(@excTC(_,_,_,_)) => .List) _:List </excStack>
                  _
                </ctrl>
           
           rule <k> @Throw(V) ~> _ => @Catch(X,V,Catch) ~> K </k>
                <ctrl>
                  <excStack> (ListItem(@excTC(X,Catch,K,Ctrl)) => .List) _:List </excStack>
                  (_ => Ctrl)
                </ctrl>
           
           syntax KItem ::= "@TryFinally" "(" K "," Stmt ")" // NOTE: the first argument should be of sort K not Stmt because @Catch(...) can be given there
                      | "@PopExcTF"
           
     2031  rule <k> (@TryFinally(S:K,Finally:Stmt) => S ~> @PopExcTF) ~> K </k>
                <ctrl>
                  <excStack> (.List => ListItem(@excTF(Finally,K,Ctrl))) _:List </excStack>
                  Ctrl
                </ctrl>
           
     1952  rule <k> CT:CompletionType ~> @PopExcTF => @ResolveFinally(Finally, CT) ... </k>
                <ctrl>
                  <excStack> (ListItem(@excTF(Finally,_,_)) => .List) _:List </excStack>
                  _
                </ctrl>
           
       71  rule <k> @Throw(V) ~> _ => @ResolveFinally(Finally, @Throw(V)) ~> K </k>
                <ctrl>
                  <excStack> (ListItem(@excTF(Finally,K,Ctrl)) => .List) _:List </excStack>
                  (_ => Ctrl)
                </ctrl>
           
           syntax KItem ::= "@TryCatchFinally" "(" Stmt "," Var "," Stmt "," Stmt ")"
                      | "@PopExcTCF"
           
     3015  rule <k> (@TryCatchFinally(S:Stmt,X:Var,Catch:Stmt,Finally:Stmt) => S ~> @PopExcTCF) ~> K </k>
                <ctrl>
                  <excStack> (.List => ListItem(@excTCF(X,Catch,Finally,K,Ctrl))) _:List </excStack>
                  Ctrl
                </ctrl>
           
     1279  rule <k> CT:CompletionType ~> @PopExcTCF => @ResolveFinally(Finally, CT) ... </k>
                <ctrl>
                  <excStack> (ListItem(@excTCF(_,_,Finally,_,_)) => .List) _:List </excStack>
                  _
                </ctrl>
           
     1726  rule <k> @Throw(V) ~> _ => @TryFinally(@Catch(X,V,Catch), Finally) ~> K </k>
                <ctrl>
                  <excStack> (ListItem(@excTCF(X,Catch,Finally,K,Ctrl)) => .List) _:List </excStack>
                  (_ => Ctrl)
                </ctrl>
           
           // NOTE: If the first argument evaluates to 'Throw', then it is handled differently with Throw's rules.
           //       The second argument should be non-strict, because it could be 'Throw'.
     6587  syntax KItem ::= "@ResolveFinally" "(" K /* CompletionType */ "," K /* CompletionType or Throw */ ")" [seqstrict(1)]
     3216  rule @ResolveFinally( _:CompletionTypeNormal,CT:K) => CT
       69  rule @ResolveFinally(CT:CompletionTypeAbrupt, _:K) => CT
           
           syntax KItem /* CompletionType */ ::= "@Catch" "(" Var "," Val "," Stmt ")"
           syntax Id ::= "$catchEnv" | "$result"
     1726  rule <k> @Catch(X:Var,V:Val,Catch:Stmt)
     3452        => Let $catchEnv = NewDeclarativeEnvironment(E, Strict);
     1726           Do CreateMutableBinding($catchEnv:>Eid, X, false);
     1726           Do SetMutableBinding($catchEnv:>Eid, X, V, false);
     1726           Do @SetRunningCtx($catchEnv:>Eid, This);
     3423           Let $result = Catch;
     1697           Do @RestoreRunningCtx;
     1697           Return $result;
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
           
           // 12.15 The debugger statement
           // TODO:
           
           //////////////////////////////////////////////////////////////////////////////
           // 13 Function Definition
           //////////////////////////////////////////////////////////////////////////////
           
           syntax KItem /* Oid */ ::= "@FunctionDeclaration" "(" Var "," Exps "," Stmt ")"
   134022  rule @FunctionDeclaration(_,Params:Exps,FunBody:Stmt)
             => @FunctionExpressionAnonymous(Params,FunBody)
           
           syntax KItem /* Oid */ ::= "@FunctionExpressionAnonymous" "(" Exps "," Stmt ")"
   144226  rule <k> @FunctionExpressionAnonymous(Params:Exps, FunBody:Stmt)
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
           
           syntax KItem /* Oid */ ::= "@FunctionExpressionRecursive" "(" Var "," Exps "," Stmt ")"
           syntax Id ::= "$funcEnv" | "$closure"
       68  rule <k> @FunctionExpressionRecursive(F:Var, Params:Exps, FunBody:Stmt)
       68        => Let $strict = @IsStrict(FunBody) orBool Strict; // 10.1.1 Strict Mode Code, Case 3
      136           Let $funcEnv = NewDeclarativeEnvironment(E, $strict:>Bool);
       68           Do CreateImmutableBinding($funcEnv:>Eid, F);
      136           Let $closure = @CreateFunctionObject(Params, FunBody, $funcEnv:>Eid, $strict:>Bool);
       68           Do InitializeImmutableBinding($funcEnv:>Eid, F, $closure:>Val);
       68           Return $closure;
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
           
           syntax KItem /* Oid */ ::= "@CreateFunctionObject" "(" Exps "," Stmt "," Eid "," Bool ")"
   243818  rule <k> @CreateFunctionObject(Params:Exps, FunBody:Stmt, Scope:Eid, Strict:Bool) => @CreateFunctionObjectAux(@o(!F), Strict) ... </k>
                <objs>
                  (. => <obj>
                          <oid> @o(!F:Int) </oid>
                          <properties>
                            "length"           |-> @desc("Value" |-> @Length(Params) "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "prototype"        |-> @desc("Value" |-> @o(!P)           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> false)
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
                          <oid> @o(!P:Int) </oid>
                          <properties>
                            "constructor"      |-> @desc("Value" |-> @o(!F)           "Writable" |-> true  "Enumerable" |-> false "Configurable" |-> true)
                          </properties>
                          <internalProperties>
                            "Prototype"        |-> @ObjectProtoOid
                            "Class"            |-> "Object"
                            "Extensible"       |-> true
                          </internalProperties>
                        </obj>)
                  _
                </objs>
           
           syntax KItem /* Oid */ ::= "@CreateFunctionObjectAux" "(" Oid "," Bool ")"
   142445  rule <k> @CreateFunctionObjectAux(O:Oid,false) => O ... </k>
   101373  rule <k> @CreateFunctionObjectAux(O:Oid,true ) => O ... </k>
                <obj>
                  <oid> O </oid>
                  <properties>
                    (.Map => "caller"    |-> @desc("Get" |-> @("ThrowTypeError") "Set" |-> @("ThrowTypeError") "Enumerable" |-> false "Configurable" |-> false))
                    (.Map => "arguments" |-> @desc("Get" |-> @("ThrowTypeError") "Set" |-> @("ThrowTypeError") "Enumerable" |-> false "Configurable" |-> false))
                    _:Map
                  </properties>
                  _
                </obj>
           
           // 13.2.1 [[Call]]
           
     3888  syntax KItem /* Val */ ::= "Call" "(" K /* Oid */ "," K /* Val */ "," K /* Vals */ ")" [seqstrict(1,2,3)]
    47614  rule Call(F:Oid, This:Val, Args:Vals)
    95227    => If @IsBoundFunction(F) = true then {
       55         Do Call@BoundFunction(F,This,Args);
                } else {
    47558         Do Call@Default(F,This,Args);
                }
                when @IsStandardBuiltinObject(F) ==K false // TODO: could it be made in uniform way?
           
           syntax KItem /* Val */ ::= "Call@Default" "(" K /* Oid */ "," K /* Val */ "," K /* Vals */ ")" [seqstrict(1,2,3)]
    47607  rule <k> Call@Default(F:Oid, This:Val, Args:Vals)
                 => @EnterFunctionCode(F,This,Args) ~> Code ~> @ExitFunctionCode ... </k>
                <obj>
                  <oid> F </oid>
                  <internalProperties> "Code" |-> Code:Stmt _:Map </internalProperties>
                  _
                </obj>
        6  rule <k> Call@Default(F:Oid,_,_) => Undefined ... </k>
                <obj>
                  <oid> F </oid>
                  <internalProperties> Prop:Map </internalProperties>
                  _
                </obj>
                when notBool("Code" in keys(Prop))
           
           syntax KItem ::= "@ExitFunctionCode"
    41097  rule @Return(V:Val) ~> @ExitFunctionCode => @RestoreRunningCtx ~> V
     4663  rule @Normal        ~> @ExitFunctionCode => @RestoreRunningCtx ~> Undefined
           
           // 13.2.2 [[Construct]]
           
           syntax KItem /* Oid */ ::= "Construct" "(" K /* Oid */ "," K /* Vals */ ")" [seqstrict(1,2)]
      493  rule Construct(F:Oid, Args:Vals)
      986    => If @IsBoundFunction(F) = true then {
                  Do Construct@BoundFunction(F,Args);
                } else {
      493         Do Construct@Default(F,Args);
                }
                when @IsStandardBuiltinObject(F) ==K false // TODO: could it be made in uniform way?
           
           syntax KItem /* Oid */ ::= "Construct@Default" "(" K /* Oid */ "," K /* Vals */ ")" [seqstrict(1,2)]
      493  rule <k> Construct@Default(F:Oid, Args:Vals) => Call(F,@o(!N),Args) ~> @ReturnConstructedObject(@o(!N)) ... </k>
                <objs>
                  (. => <obj>
                          <oid> @o(!N:Int) </oid>
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
                      _:Map
                    </properties>
                    _
                  </obj>
                  _
                </objs>
           // TODO: Check correctness of steps 5-7
           
           syntax Oid ::= "@ResolvePrototype" "(" Val ")" [function]
           rule @ResolvePrototype(Prototype:Oid) => Prototype
           rule @ResolvePrototype(Prototype:Val) => @ObjectProtoOid when notBool(@IsOid(Prototype) ==K true)
           
           // Return the newly created object, but if the previous construct call returns another object, then use it.
           // NOTE: (From p.31 of the book, Good Parts): If the function was invoked with the new prefix and the return value is not an object, then this (the new object) is returned instaed.
           syntax KItem /* Oid */ ::= "@ReturnConstructedObject" "(" Oid ")"
       36  rule O:Oid ~> @ReturnConstructedObject(_    ) => O
      441  rule V:Val ~> @ReturnConstructedObject(O:Oid) => O when notBool(@IsOid(V) ==K true)
           
           // 13.2.3 The [[ThrowTypeError]] Function Object
           
           // TODO: check if this simple version works correctly
       50  rule Call(@("ThrowTypeError"), _:Val, _:Vals) => @Throw(@TypeError("ThrowTypeError",""))
           
           //////////////////////////////////////////////////////////////////////////////
           // 14 Program
           //////////////////////////////////////////////////////////////////////////////
           
   822640  context %seq(HOLE, _)
   796641  context %seq(_:CompletionTypeNormal, HOLE)
   389869  rule %seq(   _:CompletionTypeNormal, Tail:CompletionType) => Tail
     1854  rule %seq(Head:CompletionTypeReturn,    _:Stmt          ) => Head
     1050  rule %seq(Head:CompletionTypeGoto,   Tail:Stmt          ) => @ResolveGoto(Head, Tail)
           
           syntax KItem ::= "@ResolveGoto" "(" CompletionTypeGoto "," Stmt ")"
      363  rule @ResolveGoto(CT:CompletionTypeGoto, S:Stmt         ) => @Normal             when @IsMatch(CT,S)  ==K true
      687  rule @ResolveGoto(CT:CompletionTypeGoto, S:Stmt         ) => CT                  when @IsMatch(CT,S)  ==K false
           //
           rule @ResolveGoto(CT:CompletionTypeGoto, %seq(S1,S2)) => S2                  when @IsMatch(CT,S1) ==K true
      233  rule @ResolveGoto(CT:CompletionTypeGoto, %seq(S1,S2)) => @ResolveGoto(CT,S2) when @IsMatch(CT,S1) ==K false
           //
       11  rule @ResolveGoto(CT:CompletionTypeGoto, %seq(%seq(S1,S2),S3)) => @ResolveGoto(CT, %seq(S1,%seq(S2,S3)))
           
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
   133908  rule %fdecl(_,_,_) => %emptyStmt
           
           //////////////////////////////////////////////////////////////////////////////
           // 14.1 Directive Prologues and the Use Strict Directive
           
           syntax Bool ::= "@IsStrict" "(" Stmt ")" [function]
           rule @IsStrict(S:Stmt) => @IsStrictPartial(@SkipPrelude(S)) ==K true
           
           syntax Bool ::= "@IsStrictPartial" "(" Stmt ")" [function]
           rule @IsStrictPartial(     %exp(%con("USE_STRICT"))   ) => true
           rule @IsStrictPartial(%seq(%exp(%con("USE_STRICT")),_)) => true
           rule @IsStrictPartial(%seq(%exp(%con(C:String    )),S)) => @IsStrictPartial(S) when C =/=String "USE_STRICT"
           
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
           
           //////////////////////////////////////////////////////////////////////////////
           // 15 Standard Built-in ECMAScript Objects
           //////////////////////////////////////////////////////////////////////////////
           
           syntax KItem /* Bool */ ::= "@IsStandardBuiltinObject" "(" Oid ")" [function]
           rule @IsStandardBuiltinObject(O:Oid) => (O ==K @ObjectOid        )
                                            orBool (O ==K @FunctionOid      ) orBool (O ==K @FunctionProtoOid )
                                            orBool (O ==K @ArrayOid         )
                                            orBool (O ==K @StringOid        )
                                            orBool (O ==K @BooleanOid       )
                                            orBool (O ==K @NumberOid        )
                                            orBool (O ==K @DateOid          )
                                            orBool (O ==K @RegExpOid        )
                                            orBool (O ==K @ErrorOid         )
                                            //
                                            orBool (O ==K @EvalErrorOid     )
                                            orBool (O ==K @RangeErrorOid    )
                                            orBool (O ==K @ReferenceErrorOid)
                                            orBool (O ==K @SyntaxErrorOid   )
                                            orBool (O ==K @TypeErrorOid     )
                                            orBool (O ==K @URIErrorOid      )
                                            //
                                            orBool (O ==K @MathOid          )
                                            orBool (O ==K @JSONOid          )
           
           syntax Val ::= "@" "(" String ")"
           
           // NOTE: It should ignore additional arguements given for builtin functions
           
           //////////////////////////////////////////////////////////////////////////////
           // Parse
           
           syntax KItem /* Stmt or Throw */ ::= "@Parse" "(" String ")" [function]
           rule @Parse(P:String) => @ParseAux(#external(@PWD +String "/jsmassage.sh\x01" +String P),P)
           //
           syntax KItem /* Stmt or Throw */ ::= "@ParseAux" "(" K /* Program */ "," K /* String */ ")" [function]
           rule @ParseAux(P:String, _) => @ParsePgm(P)
           rule @ParseAux(#tcpError(E:String), P:String) => @Throw(@SyntaxError("#external: " +String E, P))
           
           syntax KItem /* Stmt or Throw */ ::= "@ParsePgm" "(" String ")" [function]
           rule @ParsePgm(P:String) => @ParsePgmAux(#parse(P,"Program"),P)
           //
           syntax KItem /* Stmt or Throw */ ::= "@ParsePgmAux" "(" K /* Program */ "," K /* String */ ")" [function]
           rule @ParsePgmAux(P:SourceElements, _) => ^SourceElements(P)
           rule @ParsePgmAux(#noparse, P:String) => @Throw(@SyntaxError("#parse Program",P))
           //rule @ParsePgmAux(K /* #noparse */, P:String) => @Throw(@SyntaxError("#parse",P)) when isSourceElements(K) =/=K true
           
           syntax KItem /* Exps or Throw */ ::= "@ParseParams" "(" String ")" [function]
           rule @ParseParams(P:String) => @ParseParamsAux(#parse(P,"Parameters"),P)
           //
           syntax KItem /* Exps or Throw */ ::= "@ParseParamsAux" "(" K /* Parameters */ "," K /* String */ ")" [function]
           rule @ParseParamsAux(P:Parameters, _) => ^Parameters(P)
           rule @ParseParamsAux(#noparse, P:String) => @Throw(@SyntaxError("#parse Parameters",P))
           //rule @ParseParamsAux(K /* #noparse */, P:String) => @Throw(@SyntaxError("#parse",P)) when isSourceElements(K) =/=K true
           
           //////////////////////////////////////////////////////////////////////////////
           // 15.1 The Global Object
           
           // 15.1.2.1 eval (x)
           
      973  rule %call(%var("eval"), Es:Exps) => Call(@("eval_d"), Undefined, Es)
           
        9  rule Call(@("eval_d"), _, @Cons(V:Val,     _:Vals)) => V when @IsString(V) ==K false
           rule Call(@("eval_i"), _, @Cons(V:Val,     _:Vals)) => V when @IsString(V) ==K false
           //
      963  rule Call(@("eval_d"), _, @Cons(Pgm:String,_:Vals)) => @Eval(@Parse(Pgm), true)
       16  rule Call(@("eval_i"), _, @Cons(Pgm:String,_:Vals)) => @Eval(@Parse(Pgm), false)
           
           syntax KItem ::= "@Eval" "(" K /* Stmt or Throw */ "," Bool ")"
      955  rule @Eval(Code:Stmt, Direct:Bool) => @EnterEvalCode(Code,Direct) ~> Code ~> @ExitEvalCode
       24  rule @Eval(@Throw(@SyntaxError(E:String,P:String)), _) => @Throw(@SyntaxError(E,P))
           //rule @Eval(@Throw(@SyntaxError("#parse",P:String)), _) => @Throw(@SyntaxError("#parse",P))
           
           syntax KItem ::= "@ExitEvalCode"
      735  rule <k> @Normal ~> @ExitEvalCode => @RestoreRunningCtx ~> V ... </k>
                <lastNonEmptyValue> V:Val </lastNonEmptyValue>
           
           syntax KItem /* Bool */ ::= "@IsEval" "(" Exp ")" [function]
           rule @IsEval(E:Exp) => E ==K %var("eval") // TODO: this is quick fix. any better way?
           
           //////////////////////////////////////////////////////////////////////////////
           // 15.2 Object Objects
           
           // 15.2.1.1 Object ( [ value ] )
           
       95  rule Call(@ObjectOid, _, Vs:Vals) => @CallObject(Vs)
           
           syntax KItem /* Oid */ ::= "@CallObject" "(" K /* Vals */ ")" [seqstrict(1)]
       89  rule @CallObject(@Cons(V:Val,     _:Vals)) => ToObject(V) when V =/=K @NullVal andBool V =/=K Undefined
        2  rule @CallObject(@Cons(@NullVal,  _:Vals)) => @CreateObject
        3  rule @CallObject(@Cons(Undefined,_:Vals)) => @CreateObject
        1  rule @CallObject(                 @Nil   ) => @CreateObject
           
           // 15.2.2.1 new Object ( [ value ] )
           
      542  rule Construct(@ObjectOid, Vs:Vals) => @NewObject(Vs)
           
           syntax KItem /* Oid */ ::= "@NewObject" "(" K /* Vals */ ")" [seqstrict(1)]
        8  rule @NewObject(@Cons(Undefined,_:Vals)) => @CreateObject
        4  rule @NewObject(@Cons(@NullVal,  _:Vals)) => @CreateObject
       14  rule @NewObject(@Cons(B:Bool,    _:Vals)) => ToObject(B)
        5  rule @NewObject(@Cons(S:String,  _:Vals)) => ToObject(S)
       17  rule @NewObject(@Cons(N:Number,  _:Vals)) => ToObject(N)
        6  rule @NewObject(@Cons(O:Oid,     _:Vals)) => O
      488  rule @NewObject(                 @Nil   ) => @CreateObject
           
           syntax KItem /* Oid */ ::= "@CreateObject"
   107327  rule <k> @CreateObject => @o(!N) ... </k>
                <objs>
                  (. => <obj>
                          <oid> @o(!N:Int) </oid>
                          <properties> .Map </properties>
                          <internalProperties>
                            "Prototype"  |-> @ObjectProtoOid // Object prototype object 15.2.4
                            "Class"      |-> "Object"
                            "Extensible" |-> true
                          </internalProperties>
                        </obj>)
                  _
                </objs>
           
           // 15.2.3.4 Object.getOwnPropertyNames ( O )
           // TODO:STD: consider note: when O is string object
           
           syntax KItem ::= "@ObjectGetOwnPropertyNames" "(" Oid ")"
      216  rule <k> @ObjectGetOwnPropertyNames(O:Oid) => @MakeArray(@Set2Vals(keys(Prop))) ... </k>
                <obj>
                  <oid> O </oid>
                  <properties> Prop:Map </properties>
                  _
                </obj>
           
           //////////////////////////////////////////////////////////////////////////////
           // 15.3 Function Objects
           
           // 15.3.1.1 Function (p1, p2, ... , pn, body)
           
     6963  rule Call(@FunctionOid, _, Vs:Vals) => @NewFunction(Vs)
           
           // 15.3.2.1 new Function (p1, p2, ... , pn, body)
           
      103  rule Construct(@FunctionOid, Vs:Vals) => @NewFunction(Vs)
           
           syntax KItem /* Oid */ ::= "@NewFunction" "(" K /* Vals */ ")" [seqstrict(1)]
       22  rule @NewFunction(             @Nil      ) => @CreateFunction(%nil, %emptyStmt)
           // NOTE: We have two rules because of preventing a leading comma.
     6939  rule @NewFunction(             Args:Vals ) => @NewFunctionAux("",            Args) when @LengthVals(Args) ==Int 1
      105  rule @NewFunction(@Cons(P1:Val,Args:Vals)) => @NewFunctionAux(ToString(P1), Args) when Args =/=K @Nil
           
      209  syntax KItem /* Oid */ ::= "@NewFunctionAux" "(" K /* String */ "," K /* Vals */ ")" [seqstrict(1,2)]
           syntax Id ::= "$p" | "$body"
       41  rule @NewFunctionAux(Params:String, @Cons(P:Val,Args:Vals))
       82    => Let $p = ToString(P);
       41       Do @NewFunctionAux(Params +String "," +String $p:>String, Args);
                when Args =/=K @Nil
     7043  rule @NewFunctionAux(Params:String, @Cons(Body:Val,@Nil))
    14084    => Let $body = ToString(Body);
     7041       Do @CreateFunction(@ParseParams(Params), @Parse($body:>String));
           
           syntax KItem /* Oid */ ::= "@CreateFunction" "(" Exps "," Stmt ")"
     7056  rule <k> @CreateFunction(Params:Exps,FunBody:Stmt)
     7056        => Let $strict = @IsStrict(FunBody); // 10.1.1 Strict Mode Code, Case 4
     7056           Do @CheckEarlyErrors($strict:>Bool, FunBody);
     7052           Do @CreateFunctionObject(Params, FunBody, E, $strict:>Bool);
                ... </k>
                <ctx>
                  <running>
                    <lexicalEnv> E:Eid </lexicalEnv>
                    _
                  </running>
                  _
                </ctx>
           
           // 15.3.4 Properties of the Function Prototype Object
           // p.118 The Function prototype object is itself a Function object (its [[Class]] is "Function") that, when invoked, accepts any arguments and returns undefined.
           
        4  rule Call(@FunctionProtoOid, _, _:Vals) => Undefined
           
           // 15.3.4.2 Function.prototype.toString ( )
           
           // TODO:STD: ad-hoc, temorary implementation
           syntax KItem ::= "@FunctionPrototypeToString" "(" Oid ")"
       99  rule @FunctionPrototypeToString(F:Oid) => "[function ...]"
           
           // 15.3.4.3 Function.prototype.apply (thisArg, argArray)
           
           syntax KItem ::= "@FunctionPrototypeApply" "(" Val "," Val "," Val ")"
           syntax Id ::= "$n" | "$argList"
     1022  rule @FunctionPrototypeApply(Func:Val, ThisArg:Val, ArgArray:Val)
     2044    => If IsCallable(Func) = false then {
                  Do @Throw(@TypeError("Function.prototype.apply: func is not callable",Func));
                } else {
     2044         If @OrBool(@EqVal(ArgArray,@NullVal), @EqVal(ArgArray,Undefined)) = true then {
       49           Do Call(Func,ThisArg,@Nil);
                  } else {
      973           If @IsOid(ArgArray) = true then {
      971             Do Call(Func, ThisArg, @Array2List(ArgArray:>Oid));
                    } else {
        2             Do @Throw(@TypeError("Function.prototype.apply: argArray is not an object",Func));
                    }
                  }
                }
           
      110  syntax KItem /* Vals */ ::= "@Array2List" "(" K /* Oid */ ")" [seqstrict(1)]
           //syntax Id ::= "$n"
     1026  rule @Array2List(ArgArray:Oid)
     2052    => Let $len = Get(ArgArray,"length");
     2052       Let $n = ToUint32($len:>Val);
     1026       Do @Array2ListAux(ArgArray, $n:>Int -Int 1, @Nil);
           //
           syntax KItem /* Vals */ ::= "@Array2ListAux" "(" Oid "," Int "," Vals ")"
           syntax Id ::= "$v"
     1179  rule @Array2ListAux(ArgArray:Oid, N:Int, Args:Vals)
     1179    => If N <Int 0 = true then {
     1026         Return Args;
                } else {
      306         Let $v = Get(ArgArray, ToString(N));
      153         Do @Array2ListAux(ArgArray, N -Int 1, @Cons($v:>Val, Args));
                }
           
           // 15.3.4.5 Function.prototype.bind (thisArg [, arg1 [, arg2, ...]])
           
           syntax KItem ::= "@FunctionPrototypeBind" "(" Val "," Val "," Val ")"
           syntax Id ::= "$f"
      125  rule @FunctionPrototypeBind(Func:Val, ThisArg:Val, ArgArray:Val)
      250    => If IsCallable(Func) = false then {
                  Do @Throw(@TypeError("Function.prototype.bind",Func));
                } else {
      250         Let $f = @CreateObject;
      125         Do SetInternalProperty($f:>Oid, "TargetFunction", Func);
      125         Do SetInternalProperty($f:>Oid, "BoundThis", ThisArg);
      125         Do SetInternalProperty($f:>Oid, "BoundArgs", ArgArray);
      125         Do SetInternalProperty($f:>Oid, "Class", "Function");
      125         Do SetInternalProperty($f:>Oid, "Prototype", @FunctionProtoOid);
                  // TODO:STD: step 15-17
      125         DoI DefineOwnProperty($f:>Oid, "caller",    @desc("Get" |-> @("ThrowTypeError") "Set" |-> @("ThrowTypeError") "Enumerable" |-> false "Configurable" |-> false), false);
      125         DoI DefineOwnProperty($f:>Oid, "arguments", @desc("Get" |-> @("ThrowTypeError") "Set" |-> @("ThrowTypeError") "Enumerable" |-> false "Configurable" |-> false), false);
      125         Return $f;
                }
           
           syntax KItem /* Bool */ ::= "@IsBoundFunction" "(" Oid ")"
    49351  rule <k> @IsBoundFunction(O:Oid) => "BoundArgs" in keys(Prop) ... </k>
                <obj>
                  <oid> O </oid>
                  <internalProperties> Prop:Map </internalProperties>
                  _
                </obj>
           
           // 15.3.4.5.1 [[Call]]
           
           syntax KItem /* Val */ ::= "Call@BoundFunction" "(" K /* Oid */ "," K /* Val */ "," K /* Vals */ ")" [seqstrict(1,2,3)]
           syntax Id ::= "$boundArgs" | "$boundThis" | "$target" | "$args"
       55  rule Call@BoundFunction(F:Oid, This:Val, Args:Vals)
      110    => Let $target    =             GetInternalProperty(F, "TargetFunction");
      110       Let $boundThis =             GetInternalProperty(F, "BoundThis");
      110       Let $boundArgs = @Array2List(GetInternalProperty(F, "BoundArgs"));
       55       Let $args = @AppendVals($boundArgs:>Vals, Args);
      102       Return Call@Default($target:>Oid, $boundThis:>Val, $args:>Vals);
           
           // 15.3.4.5.2 [[Construct]]
           
           // TODO:STD: step 2
           syntax KItem /* Oid */ ::= "Construct@BoundFunction" "(" K /* Oid */ "," K /* Vals */ ")" [seqstrict(1,2)]
           rule Construct@BoundFunction(F:Oid, Args:Vals)
             => Let $target    =             GetInternalProperty(F, "TargetFunction");
                Let $boundArgs = @Array2List(GetInternalProperty(F, "BoundArgs"));
                Let $args = @AppendVals($boundArgs:>Vals, Args);
                Return Construct@Default($target:>Oid, $args:>Vals);
           
           // 15.3.4.5.3 [[HasInstance]] (V)
           
           // TODO:STD: step 2
           syntax KItem /* Bool */ ::= "HasInstance@BoundFunction" "(" K /* Oid */ "," K /* Val */ ")" [seqstrict(1,2)]
           rule HasInstance@BoundFunction(F:Oid, V:Val)
             => Let $target = GetInternalProperty(F, "TargetFunction");
                Return HasInstance@Default($target:>Oid, V);
           
           // 15.3.5 Properties of Function Instances
           
           // 15.3.5.3 [[HasInstance]] (V)
           
           syntax KItem /* Bool */ ::= "HasInstance" "(" K "," K ")" [seqstrict(1,2)]
     1245  rule HasInstance(F:Oid, V:Val)
     2490    => If @IsBoundFunction(F) = true then {
                  Do HasInstance@BoundFunction(F,V);
                } else {
     1245         Do HasInstance@Default(F,V);
                }
           
           syntax KItem /* Bool */ ::= "HasInstance@Default" "(" K "," K ")" [seqstrict(1,2)]
           syntax Id ::= "$o"
     1245  rule HasInstance@Default(F:Oid,V:Val)
     1245    => If @IsOid(V) = true then {
     2450         Let $o = Get(F,"prototype");
     1225         If @IsOid($o:>Val) = true then {
     2444           Return @IsPrototypeOf($o:>Oid, V:>Oid);
                  } else {
        3           Do @Throw(@TypeError("HasInstance@Default",F));
                  }
                } else {
       20         Return false;
                }
           
           // TODO: Duplicated: Object.isPrototypeOf
           syntax KItem /* Bool */ ::= "@IsPrototypeOf" "(" Oid "," Oid ")"
     1222  rule @IsPrototypeOf(O:Oid,V:Oid)
             => @IsPrototypeOfAux(O,GetInternalProperty(V,"Prototype"))
           
     2582  syntax KItem /* Bool */ ::= "@IsPrototypeOfAux" "(" K "," K ")" [seqstrict(1,2)]
     1291  rule @IsPrototypeOfAux(O:Oid,V:Oid)
     1291    => If V = @NullOid then {
       27         Return false;
                } else {
     1264         If O = V then {
     1195           Return true;
                  } else {
       69           Do @IsPrototypeOfAux(O,GetInternalProperty(V,"Prototype"));
                  }
                }
           
           // 15.3.5.4 [[Get]] (P)
           // TODO:STD:
           
           //////////////////////////////////////////////////////////////////////////////
           // 15.4 Array Objects
           
           // 15.4.1.1 Array ( [ item1 [ , item2 [ , ... ] ] ] )
           
       18  rule Call(@ArrayOid, _, Vs:Vals) => @NewArray(Vs)
           
           // 15.4.2.1 new Array ( [ item0 [ , item1 [ , ... ] ] ] )
           
      227  rule Construct(@ArrayOid, Vs:Vals) => @NewArray(Vs)
           
           syntax KItem /* Oid */ ::= "@NewArray" "(" K /* Vals */ ")" [seqstrict(1)]
      193  rule @NewArray(Vs:Vals) => @CreateArray(@LengthVals(Vs), Vs) when @LengthVals(Vs) =/=Int 1
       30  rule @NewArray(@Cons(V:Val,@Nil)) => @CreateArray(1, @Cons(V:Val,@Nil)) when notBool(isInt(V) ==K true)
           
           syntax KItem /* Oid */ ::= "@CreateArray" "(" Int "," Vals ")"
     2136  rule <k> @CreateArray(Len:Int, Vs:Vals) => @CreateArray@InsertElements(@o(!N),Vs,0) ... </k>
                <objs>
                  (. => <obj>
                          <oid> @o(!N:Int) </oid>
                          <properties>
                            "length" |-> @desc("Value" |-> Len "Writable" |-> true "Enumerable" |-> false "Configurable" |-> false) // 15.4.5.2 length
                          </properties>
                          <internalProperties>
                            "Prototype"      |-> @ArrayProtoOid
                            "Class"          |-> "Array"
                            "Extensible"     |-> true
                          </internalProperties>
                        </obj>)
                  _
                </objs>
           
           syntax KItem /* Oid */ ::= "@CreateArray@InsertElements" "(" Oid "," Vals "," Int ")"
     2136  rule     @CreateArray@InsertElements(O:Oid, @Nil, _) => O
     1884  rule <k> @CreateArray@InsertElements(O:Oid, @Cons(V:Val,Vs:Vals), I:Int) => @CreateArray@InsertElements(O, Vs, I +Int 1) ... </k>
                <obj>
                  <oid> O </oid>
                  <properties>
                    (.Map => Int2String(I) |-> @desc("Value" |-> V "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true))
                    _:Map
                  </properties>
                  _
                </obj>
           
           // 15.4.2.2 new Array (len)
           // TODO:STD: more correctly: ToUint32(len) = len, o.w. throw RangeError
           
       22  rule @NewArray(@Cons(Len:Int,@Nil)) => @CreateArray(Len, @Nil)
           
           // 15.4.X make Array
           // NOTE: @MakeArray differs from @NewArray in that it simply creates array object given arguments instead of distinguishing the single argument case
           
     3350  syntax KItem /* Oid */ ::= "@MakeArray" "(" K /* Vals */ ")" [seqstrict(1)]
     1891  rule @MakeArray(Vs:Vals) => @CreateArray(@LengthVals(Vs), Vs)
           
           // 15.4.5 Properties of Array Instances
           
           // TODO: Duplicated: Array.isArray
           syntax KItem /* Bool */ ::= "@IsArrayObject" "(" Oid ")"
   636526  rule <k> @IsArrayObject(O:Oid) => Class ==String "Array" ... </k>
                <obj>
                  <oid> O </oid>
                  <internalProperties>
                    "Class" |-> Class:String
                    _:Map
                  </internalProperties>
                  _
                </obj>
           
           // 15.4.5.1 [[DefineOwnProperty]] ( P, Desc, Throw )
           
           // Intuitive algorithm
           //
           // If P is not array index, then same with the normal DefineOwnProperty.
           //
           // If P is an array index and P < length, then the same with the normal one.
           // If P is an array index and P >= length, then add the element and increase length to P + 1.
           //
           // If P is 'length' and new length value >= length, then the same with the normal one.
           // If P is 'length' and new length value < length, then delete all elements whose index >= new length.
           //   If some elements cannot be deleted, then set the new length value to the largest element's index + 1.
           
           syntax KItem /* Bool */ ::= "DefineOwnProperty@Array" "(" K /* Oid */ "," K /* Var */ "," K /* PropertyDescriptor */ "," K /* Bool */ ")" [seqstrict(1,2,3,4)]
           syntax Id ::= "$oldLenDesc" | "$oldLen" | "$newLenDesc" | "$newLen" | "$succeeded" | "$succeeded2"
     3031  rule DefineOwnProperty@Array(O:Oid,P:Var,Desc:PropertyDescriptor,Throw:Bool)
             => // Step 1,2
     6062       Let $oldLenDesc = GetOwnProperty(O,"length");
     3031       Let $oldLen = $oldLenDesc."Value";
                // Step 3
     3031       If P = "length" then {
                  // Step 3.a
      210         If Desc."Value" = Undefined then { // TODO:STD: check if 'absent field' = 'undefined'.
       31           Do DefineOwnProperty@Default(O,P,Desc,Throw);
                  } else {
                    // Step 3.b
                  //Let $newLenDesc = Desc;
                    // Step 3.c
      354           Let $newLen = ToUint32(Desc."Value");
      350           If $newLen = ToNumber(Desc."Value") then {
                      // Step 3.e
      268             Let $newLenDesc = @AddDesc("Value", $newLen, Desc);
                      // Step 3.f
      268             If %bop(%ge, $newLen:>Val, $oldLen:>Val) = true then {
       74               Do DefineOwnProperty@Default(O, "length", $newLenDesc, Throw);
                      } else {
                        // Step 3.g
      120               If @EqVal($oldLenDesc."Writable",false) = true then {
        2                 Return Reject(Throw, "DefineOwnProperty@Array cannot increase length", DefineOwnProperty@Array(O,P,Desc,Throw));
                        } else {
                          // TODO:STD: check if step 3.h, 3.i, and 3.m are useless?
                          // Step 3.j
      116                 Let $succeeded = DefineOwnProperty@Default(O, "length", $newLenDesc, Throw);
                          // Step 3.k
       58                 If $succeeded = false then {
                            Return false;
                          } else {
                            // Step 3.l, 3.n
       58                   Do DefineOwnProperty@Array@DeleteOthers(O,P,Desc,Throw,$newLenDesc,$newLen,$oldLen);
                          }
                        }
                      }
                    } else {
                      // Step 3.d
       41             Do @Throw(@RangeError("DefineOwnProperty@Array index over int32", DefineOwnProperty@Array(O,P,Desc,Throw)));
                    }
                  }
                } else {
                  // Step 4
     5642         If @IsArrayIndex(P) = true then {
                    // Step 4.a
     5137           Let $index = ToUint32(P);
                    // Step 4.b
     5136           If @AndBool(%bop(%ge, $index:>Val, $oldLen:>Val), @EqVal($oldLenDesc."Writable",false)) = true then {
        4             Return Reject(Throw, "DefineOwnProperty@Array cannot increase length", DefineOwnProperty@Array(O,P,Desc,Throw));
                    } else {
                      // Step 4.c
     5128             Let $succeeded2 = DefineOwnProperty@Default(O,P,Desc,false);
                      // Step 4.d
     2564             If $succeeded2 = false then {
       56               Return Reject(Throw, "DefineOwnProperty@Array cannot assign", DefineOwnProperty@Array(O,P,Desc,Throw));
                      } else {
                        // Step 4.e
     5016               If %bop(%ge, $index:>Val, $oldLen:>Val) = true then {
      965                 Do DefineOwnProperty@Default(O, "length", @AddDesc("Value", %bop(%plus, $index:>Val, 1), $oldLenDesc), false); // NOTE: should return true
                        } else {
                          // Step 4.f
     1543                 Return true;
                        }
                      }
                    }
                  } else {
                    // Step 5
      252           Do DefineOwnProperty@Default(O,P,Desc,Throw);
                  }
                }
           
           syntax KItem /* Bool */ ::= "@IsArrayIndex" "(" Var ")"
     2821  rule @IsArrayIndex(P:Var) => @EqVal(ToString(ToUint32(P)), P) /* TODO:STD: and ToUint32(P) =/=K 2^32 - 1 */
           
           syntax KItem /* Bool */ ::= "DefineOwnProperty@Array@DeleteOthers" "(" K /* Oid */ "," K /* Var */ "," K /* PropertyDescriptor */ "," K /* Bool */ "," K /* PropertyDescriptor */ "," K /* Val */ "," K /* Val */ ")" [seqstrict(1,2,3,4,5,6,7)]
           syntax Id ::= "$deleteSucceeded"
     4518  rule DefineOwnProperty@Array@DeleteOthers(O:Oid,P:Var,Desc:PropertyDescriptor,Throw:Bool,NewLenDesc:PropertyDescriptor,NewLen:Val,OldLen:Val)
     9036    => If %bop(%lt, NewLen, OldLen) = true then {
                  // Step 3.l.i
     8966         Let $oldLen = %bop(%minus, OldLen, 1);
                  // Step 3.l.ii
     8965         Let $deleteSucceeded = Delete(O, ToString($oldLen), false);
                  // Step 3.l.iii
     4482         If $deleteSucceeded = false then {
       44           Let $newLenDesc = @AddDesc("Value", %bop(%plus, $oldLen:>Val, 1), NewLenDesc);
       22           DoI DefineOwnProperty@Default(O, "length", $newLenDesc, false);
       22           Return Reject(Throw, "DefineOwnProperty@Array cannot delete others", DefineOwnProperty@Array(O,P,Desc,Throw));
                  } else {
     4460           Do DefineOwnProperty@Array@DeleteOthers(O, P, Desc, Throw, NewLenDesc, NewLen, $oldLen);
                  }
                } else {
                  // Step 3.n
       35         Return true;
                }
           
           //////////////////////////////////////////////////////////////////////////////
           // 15.5 String Objects
           
           // 15.5.1.1 String ( [ value ] )
           
      253  rule Call(@StringOid, _, Vs:Vals) => @CallString(Vs)
           
           syntax KItem /* String */ ::= "@CallString" "(" K /* Vals */ ")" [seqstrict(1)]
      252  rule @CallString(@Cons(V:Val,_:Vals)) => ToString(V)
        1  rule @CallString(            @Nil   ) => ""
           
           // 15.5.2.1 new String ( [ value ] )
           
      718  rule Construct(@StringOid, Vs:Vals) => @NewString(Vs)
           
           syntax KItem /* Oid */ ::= "@NewString" "(" K /* Vals */ ")" [seqstrict(1)]
     1293  rule @NewString(@Cons(V:Val,_:Vals)) => @CreateString(ToString(V))
       45  rule @NewString(            @Nil   ) => @CreateString("")
           
     2582  syntax KItem /* Oid */ ::= "@CreateString" "(" K /* String */ ")" [seqstrict(1)]
     1334  rule <k> @CreateString(S:String) => @o(!N) ... </k>
                <objs>
                  (. => <obj>
                          <oid> @o(!N:Int) </oid>
                          <properties>
                            "length" |-> @desc("Value" |-> lengthString(S) "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false) // 15.5.5.1 length
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
           
           // 15.5.5 Properties of String Instances
           
           syntax KItem /* Bool */ ::= "@IsStringObject" "(" Oid ")"
  3125640  rule <k> @IsStringObject(O:Oid) => Class ==String "String" ... </k>
                <obj>
                  <oid> O </oid>
                  <internalProperties>
                    "Class" |-> Class:String
                    _:Map
                  </internalProperties>
                  _
                </obj>
           
           // 15.5.5.2 [[GetOwnProperty]] ( P )
           
           syntax KItem /* Val */ ::= "GetOwnProperty@String" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict(1,2)]
           syntax Id ::= "$index" | "$resultStr"
     5075  rule GetOwnProperty@String(O:Oid,P:Var)
    10150    => Let $desc = GetOwnProperty@Default(O,P);
     5075       If $desc = Undefined then {
     4294         If ToString(ToInteger(P:>Val)) = P then { // TODO:STD: it should have been 'ToString(abs(ToInteger(P)))'
      112           Let $str = GetInternalProperty(O,"PrimitiveValue");
      112           Let $index = ToInteger(P:>Val);
       56           Let $len = lengthString($str:>String);
                  //If $len:>Int <=Int $index:>Int = true then {
      112           If @OrBool(%bop(%lt,$index:>Number,0), %bop(%ge,$index:>Number,$len:>Int)) = true then {
       53             Return Undefined;
                    } else {
        3             Let $resultStr = @CharAt($str:>String, $index:>Number);
        3             Return @GenDesc("Value", $resultStr, "Enumerable", true, "Writable", false, "Configurable", false);
                    }
                  } else {
     2091           Return Undefined;
                  }
                } else {
     2928         Return $desc;
                }
           
           //////////////////////////////////////////////////////////////////////////////
           // 15.6 Boolean Objects
           
           // 15.6.1.1 Boolean (value)
           
       87  rule Call(@BooleanOid, _, Vs:Vals) => @CallBoolean(Vs)
           
           syntax KItem /* Boolean */ ::= "@CallBoolean" "(" K /* Vals */ ")" [seqstrict(1)]
       83  rule @CallBoolean(@Cons(V:Val,_:Vals)) => ToBoolean(V)
        4  rule @CallBoolean(            @Nil   ) => false
           
           // 15.6.2.1 new Boolean (value)
           
      680  rule Construct(@BooleanOid, Vs:Vals) => @NewBoolean(Vs)
           
           syntax KItem /* Oid */ ::= "@NewBoolean" "(" K /* Vals */ ")" [seqstrict(1)]
      690  rule @NewBoolean(@Cons(V:Val,_:Vals)) => @CreateBoolean(ToBoolean(V))
       32  rule @NewBoolean(            @Nil   ) => @CreateBoolean(false) // TODO: Report: This is not specified in standard.
           
     1380  syntax KItem /* Oid */ ::= "@CreateBoolean" "(" K /* Bool */ ")" [seqstrict(1)]
      722  rule <k> @CreateBoolean(B:Bool) => @o(!N) ... </k>
                <objs>
                  (. => <obj>
                          <oid> @o(!N:Int) </oid>
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
           
           //////////////////////////////////////////////////////////////////////////////
           // 15.7 Number Objects
           
           // 15.7.1.1 Number ( [ value ] )
           
      327  rule Call(@NumberOid, _, Vs:Vals) => @CallNumber(Vs)
           
           syntax KItem /* Number */ ::= "@CallNumber" "(" K /* Vals */ ")" [seqstrict(1)]
      314  rule @CallNumber(@Cons(V:Val,_:Vals)) => ToNumber(V)
       13  rule @CallNumber(            @Nil   ) => 0
           
           // 15.7.2.1 new Number ( [ value ] )
           
      842  rule Construct(@NumberOid, Vs:Vals) => @NewNumber(Vs)
           
           syntax KItem /* Oid */ ::= "@NewNumber" "(" K /* Val */ ")" [seqstrict(1)]
      905  rule @NewNumber(@Cons(V:Val,_:Vals)) => @CreateNumber(ToNumber(V))
       86  rule @NewNumber(            @Nil   ) => @CreateNumber(0)
           
     1810  syntax KItem /* Oid */ ::= "@CreateNumber" "(" K /* Bool */ ")" [seqstrict(1)]
      991  rule <k> @CreateNumber(V:Number) => @o(!N) ... </k>
                <objs>
                  (. => <obj>
                          <oid> @o(!N:Int) </oid>
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
           
           // 15.7.4.5 Number.prototype.toFixed (fractionDigits)
           
        6  syntax KItem /* String */ ::= "@NumberPrototypeToFixed" "(" Oid "," K /* Int */ ")" [seqstrict(2)]
        1  rule <k> @NumberPrototypeToFixed(O:Oid,D:Int) => #external("node\x01-p\x01-e\x01new Number(" +String Int2String(I) +String ").toFixed(" +String Int2String(D) +String ")") ... </k>
                <obj>
                  <oid> O </oid>
                  <internalProperties>
                    "PrimitiveValue" |-> I:Int
                    _
                  </internalProperties>
                  _
                </obj>
        2  rule <k> @NumberPrototypeToFixed(O:Oid,D:Int) => #external("node\x01-p\x01-e\x01new Number(" +String Float2String(F) +String ").toFixed(" +String Int2String(D) +String ")") ... </k>
                <obj>
                  <oid> O </oid>
                  <internalProperties>
                    "PrimitiveValue" |-> F:Float
                    _
                  </internalProperties>
                  _
                </obj>
           
           //////////////////////////////////////////////////////////////////////////////
           // 15.8 The Math Object
           
           // NOTE: We do not need to have a Call or Construct for the Math object:
           // 15.8 The Math object does not have a [[Construct]] internal property; it is not possible to use the Math object as a constructor with the new operator.
           // 15.8 The Math object does not have a [[Call]] internal property; it is not possible to invoke the Math object as a function.
           
           // 15.8.2.9 floor (x)
           
           syntax KItem ::= "@MathFloor" "(" Number ")"
        3  rule @MathFloor(I:Int)      => I
      141  rule @MathFloor(F:Float)    => Float2Int(F)
        2  rule @MathFloor(@nz)        => @nz
        3  rule @MathFloor(@NaN)       => @NaN
        3  rule @MathFloor(@+Infinity) => @+Infinity
        2  rule @MathFloor(@-Infinity) => @-Infinity
           
           // 15.8.2.13 pow (x, y)
           
           // TODO:STD: other cases
           syntax KItem ::= "@MathPow" "(" Number "," Number ")"
       12  rule @MathPow(I1:Int,  I2:Int)   => I1 ^Int   I2
        1  rule @MathPow(F1:Float,F2:Float) => F1 ^Float F2
           
           //////////////////////////////////////////////////////////////////////////////
           // 15.9 Date Objects
           // TODO:STD:
           
           // 15.9.2.1 Date ( [ year [, month [, date [, hours [, minutes [, seconds [, ms ] ] ] ] ] ] ] )
           
        1  rule Call(@DateOid, _, _:Vals) => %call(%mem(%new(%var("Date"), %nil), %con("toString")), %nil) // (new Date()).toString()
           
           // 15.9.3.1 new Date (year, month [, date [, hours [, minutes [, seconds [, ms ] ] ] ] ] )
           // 15.9.3.2 new Date (value)
           // 15.9.3.3 new Date ( )
           // TODO:STD: Implement correctly
           
           // XXX: HACK for test262 ch9 and ch11
       24  rule Construct(@DateOid, @Cons(V:Val,@Nil)) => @CreateDate(TimeClip(ToNumber(V)))
       69  rule Construct(@DateOid,             @Nil ) => @CreateDate(0) // HACK: 0 is used instead of the current time in milli-seconds
           
       48  syntax KItem /* Oid */ ::= "@CreateDate" "(" K /* Number */ ")" [seqstrict(1)]
       93  rule <k> @CreateDate(V:Number) => @o(!N) ... </k>
                <objs>
                  (. => <obj>
                          <oid> @o(!N:Int) </oid>
                          <properties> .Map </properties>
                          <internalProperties>
                            "Prototype"      |-> @DateProtoOid
                            "Class"          |-> "Date"
                            "Extensible"     |-> true
                            "PrimitiveValue" |-> V
                          </internalProperties>
                        </obj>)
                  _
                </objs>
           
           // 15.9.1.14 TimeClip (time)
           
           // TODO:STD: Consider Step 2. If abs(N) > 8.64 * 10^15, return NaN.
       48  syntax KItem /* Number */ ::= "TimeClip" "(" K /* Number */ ")" [seqstrict(1)]
       24  rule TimeClip(N:Number)
       48    => If @IsFinite(N) = true then {
       34         Return ToInteger(N);
                } else {
        7         Return @NaN;
                }
           
           syntax KItem /* Bool */ ::= "@IsFinite" "(" Number ")"
       24  rule @IsFinite(N:Number) => N =/=K @NaN andBool N =/=K @+Infinity andBool N =/=K @-Infinity
           
           // 15.9.5.2 Date.prototype.toString ( )
           
           // TODO:STD: HACK
           syntax KItem /* String */ ::= "@DatePrototypeToString" "(" Oid ")"
       11  rule @DatePrototypeToString(O:Oid) => "[date ...]"
           
           //////////////////////////////////////////////////////////////////////////////
           // 15.10 RegExp (RegularExpression) Objects
           // TODO:STD:
           
           // 15.10.3.1 RegExp(pattern, flags)
           // TODO: consider the first case: pattern is "RegExp" object and flags is undefined.
           
        3  rule Call(@RegExpOid, _, Vs:Vals) => Construct(@RegExpOid, Vs)
           
           // 15.10.4.1 new RegExp(pattern, flags)
           // TODO:STD: Implement correctly
           
           // XXX: HACK for test262 ch9 and ch11
       55  rule Construct(@RegExpOid, _:Vals) => @CreateRegExp
           
           syntax KItem /* Oid */ ::= "@CreateRegExp"
       55  rule <k> @CreateRegExp => @o(!N) ... </k>
                <objs>
                  (. => <obj>
                          <oid> @o(!N:Int) </oid>
                          <properties> .Map </properties>
                          <internalProperties>
                            "Prototype"      |-> @RegExpProtoOid
                            "Class"          |-> "RegExp"
                            "Extensible"     |-> true
                          </internalProperties>
                        </obj>)
                  _
                </objs>
           
           //////////////////////////////////////////////////////////////////////////////
           // 15.11 ErrorObjects
           
           // 15.11.1.1 Error (message)
           
       11  rule Call(@ErrorOid, _, Vs:Vals) => @NewError(Vs)
           
           // 15.11.2.1 new Error (message)
           
     6864  rule Construct(@ErrorOid, Vs:Vals) => @NewError(Vs)
           
           syntax KItem /* Oid */ ::= "@NewError" "(" K /* Vals */ ")" [seqstrict(1)]
     6826  rule @NewError(@Cons(V:Val,_:Vals)) => @CreateError(ToString(V))
       49  rule @NewError(            @Nil   ) => @CreateError("")
           
    13652  syntax KItem /* Oid */ ::= "@CreateError" "(" K /* String */ ")" [seqstrict(1)]
     6875  rule <k> @CreateError(Msg:String) => @o(!N) ... </k>
                <objs>
                  (. => <obj>
                          <oid> @o(!N:Int) </oid>
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
           
           //////////////////////////////////////////////////////////////////////////////
           // 15.11.6 Native Error Types Used in This Standard
           // 15.11.7 NativeError Object Structure
           
           // 15.11.7.2 NativeError (message)
           
      173  rule Call(NativeError:Oid, _, Vs:Vals) => @NewNativeError(NativeError, Vs)
                when (NativeError ==K @EvalErrorOid     )
              orBool (NativeError ==K @RangeErrorOid    )
              orBool (NativeError ==K @ReferenceErrorOid)
              orBool (NativeError ==K @SyntaxErrorOid   )
              orBool (NativeError ==K @TypeErrorOid     )
              orBool (NativeError ==K @URIErrorOid      )
           
           // 15.11.7.4 new NativeError (message)
           
        7  rule Construct(NativeError:Oid, Vs:Vals) => @NewNativeError(NativeError, Vs)
                when (NativeError ==K @EvalErrorOid     )
              orBool (NativeError ==K @RangeErrorOid    )
              orBool (NativeError ==K @ReferenceErrorOid)
              orBool (NativeError ==K @SyntaxErrorOid   )
              orBool (NativeError ==K @TypeErrorOid     )
              orBool (NativeError ==K @URIErrorOid      )
           
           syntax KItem /* Oid */ ::= "@NewNativeError" "(" K /* Oid */ "," K /* Vals */ ")" [seqstrict(1,2)]
      173  rule @NewNativeError(NativeError:Oid, @Cons(V:Val,_)) => @CreateNativeError(NativeError, ToString(V), "@NewNativeError") // NOTE: multiple arguments are allowed: e.g. ch12/12.14/S12.14_A19_T2.js; ch12/12.14/S12.14_A19_T1.js
        7  rule @NewNativeError(NativeError:Oid, @Nil)           => @CreateNativeError(NativeError, "",           "@NewNativeError")
           
           // NOTE: The third argument is only for debugging purpose, not a language standard. It should be non-strict.
      346  syntax KItem /* Oid */ ::= "@CreateNativeError" "(" K /* Oid */ "," K /* String */ "," K ")" [seqstrict(1,2)]
     1517  rule <k> @CreateNativeError(NativeError:Oid, Msg:String, KDebug:K) => @o(!N) ... </k>
                <objs>
                  (. => <obj>
                          <oid> @o(!N:Int) </oid>
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
           
           syntax Oid ::= "@ResolveNativeError" "(" Oid ")" [function]
           rule @ResolveNativeError(@EvalErrorOid     ) => @EvalErrorProtoOid
           rule @ResolveNativeError(@RangeErrorOid    ) => @RangeErrorProtoOid
           rule @ResolveNativeError(@ReferenceErrorOid) => @ReferenceErrorProtoOid
           rule @ResolveNativeError(@SyntaxErrorOid   ) => @SyntaxErrorProtoOid
           rule @ResolveNativeError(@TypeErrorOid     ) => @TypeErrorProtoOid
           rule @ResolveNativeError(@URIErrorOid      ) => @URIErrorProtoOid
           
           // TODO: more elegantly
           syntax KItem /* Oid */ ::= "@EvalError"      "(" String "," K ")"
           syntax KItem /* Oid */ ::= "@RangeError"     "(" String "," K ")"
           syntax KItem /* Oid */ ::= "@ReferenceError" "(" String "," K ")"
           syntax KItem /* Oid */ ::= "@SyntaxError"    "(" String "," K ")"
           syntax KItem /* Oid */ ::= "@TypeError"      "(" String "," K ")"
           syntax KItem /* Oid */ ::= "@URIError"       "(" String "," K ")"
           rule @EvalError     (Msg:String, KDebug:K) => @CreateNativeError(@EvalErrorOid     , Msg, KDebug)
       41  rule @RangeError    (Msg:String, KDebug:K) => @CreateNativeError(@RangeErrorOid    , Msg, KDebug)
      304  rule @ReferenceError(Msg:String, KDebug:K) => @CreateNativeError(@ReferenceErrorOid, Msg, KDebug)
      258  rule @SyntaxError   (Msg:String, KDebug:K) => @CreateNativeError(@SyntaxErrorOid   , Msg, KDebug)
      734  rule @TypeError     (Msg:String, KDebug:K) => @CreateNativeError(@TypeErrorOid     , Msg, KDebug)
           rule @URIError      (Msg:String, KDebug:K) => @CreateNativeError(@URIErrorOid      , Msg, KDebug)
           
           //////////////////////////////////////////////////////////////////////////////
           // 15.12 The JSON Object
           
           // NOTE: We do not need to have a Call or Construct for the JSON object:
           // 15.12 The JSON object does not have a [[Construct]] internal property; it is not possible to use the JSON object as a constructor with the new operator.
           // 15.12 The JSON object does not have a [[Call]] internal property; it is not possible to invoke the JSON object as a function.
           
           //////////////////////////////////////////////////////////////////////////////
           // APIs
           //////////////////////////////////////////////////////////////////////////////
           
           syntax KItem /* .K */ ::= "@RegisterAPIs"
     6835  rule <k> @RegisterAPIs => . ... </k>
                <objs>
                  <obj>
                    <oid> @GlobalOid </oid>
                    <properties>
                      (.Map => "IsObject"                 |-> @desc("Value" |-> @("IsObject")                 "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "ToObject"                 |-> @desc("Value" |-> @("ToObject")                 "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "ToString"                 |-> @desc("Value" |-> @("ToString")                 "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "ToNumber"                 |-> @desc("Value" |-> @("ToNumber")                 "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "ToInteger"                |-> @desc("Value" |-> @("ToInteger")                "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "ToUint32"                 |-> @desc("Value" |-> @("ToUint32")                 "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "ToUint16"                 |-> @desc("Value" |-> @("ToUint16")                 "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "IsNaN"                    |-> @desc("Value" |-> @("IsNaN")                    "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "IsPositiveZero"           |-> @desc("Value" |-> @("IsPositiveZero")           "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "IsNegativeZero"           |-> @desc("Value" |-> @("IsNegativeZero")           "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "IsFunction"               |-> @desc("Value" |-> @("IsFunction")               "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "IsCallable"               |-> @desc("Value" |-> @("IsCallable")               "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            //
                            "NoConstructor"            |-> @desc("Value" |-> @("NoConstructor")            "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            //
                            "GetInternalProperty"      |-> @desc("Value" |-> @("GetInternalProperty")      "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "SetInternalProperty"      |-> @desc("Value" |-> @("SetInternalProperty")      "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            //
                            "GetOwnProperty"           |-> @desc("Value" |-> @("GetOwnProperty")           "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "DefineOwnProperty"        |-> @desc("Value" |-> @("DefineOwnProperty")        "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            //
                            "FromPropertyDescriptor"   |-> @desc("Value" |-> @("FromPropertyDescriptor")   "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                              "ToPropertyDescriptor"   |-> @desc("Value" |-> @(  "ToPropertyDescriptor")   "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            //
                            "CheckObjectCoercible"     |-> @desc("Value" |-> @("CheckObjectCoercible")     "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            //
                            "ObjectGetOwnPropertyNames"|-> @desc("Value" |-> @("ObjectGetOwnPropertyNames")"Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            //
                            "FunctionPrototypeToString"|-> @desc("Value" |-> @("FunctionPrototypeToString")"Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "FunctionPrototypeApply"   |-> @desc("Value" |-> @("FunctionPrototypeApply"   )"Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "FunctionPrototypeBind"    |-> @desc("Value" |-> @("FunctionPrototypeBind"    )"Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            //
                            "NumberPrototypeToFixed"   |-> @desc("Value" |-> @("NumberPrototypeToFixed")   "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            //
                            "MathPow"                  |-> @desc("Value" |-> @("MathPow"  )                "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "MathFloor"                |-> @desc("Value" |-> @("MathFloor")                "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "MathSin"                  |-> @desc("Value" |-> @("MathSin")                  "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            //
                            "DatePrototypeToString"    |-> @desc("Value" |-> @("DatePrototypeToString")    "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            //
                            "LengthString"             |-> @desc("Value" |-> @("LengthString")             "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "Trim"                     |-> @desc("Value" |-> @("Trim"        )             "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "Int2Char"                 |-> @desc("Value" |-> @("Int2Char"    )             "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "Char2Int"                 |-> @desc("Value" |-> @("Char2Int"    )             "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "CharAt"                   |-> @desc("Value" |-> @("CharAt"      )             "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "FindString"               |-> @desc("Value" |-> @("FindString"  )             "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            "SubstrString"             |-> @desc("Value" |-> @("SubstrString")             "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            //
                            "NumberToString"           |-> @desc("Value" |-> @("NumberToString")           "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            //
                            "Print"                    |-> @desc("Value" |-> @("Print")                    "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                            //
                            "CurrentTimeMillis"        |-> @desc("Value" |-> @("CurrentTimeMillis")        "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
                      )
                      _:Map
                    </properties>
                    _
                  </obj>
                  _
                </objs>
           
           // NOTE: All these APIs should return a value of type Val
           
    13075  rule Call(@("IsObject"),           Undefined, @Cons(V:Val,@Nil)) => @IsOid(V)
     5205  rule Call(@("ToObject"),           Undefined, @Cons(V:Val,@Nil)) => ToObject(V)
    13918  rule Call(@("ToString"),           Undefined, @Cons(V:Val,@Nil)) => ToString(V)
     4779  rule Call(@("ToNumber"),           Undefined, @Cons(V:Val,@Nil)) => ToNumber(V)
      353  rule Call(@("ToInteger"),          Undefined, @Cons(V:Val,@Nil)) => ToInteger(V)
      496  rule Call(@("ToUint32"),           Undefined, @Cons(V:Val,@Nil)) => ToUint32(V)
      122  rule Call(@("ToUint16"),           Undefined, @Cons(V:Val,@Nil)) => ToUint16(V)
     2529  rule Call(@("IsNaN"),              Undefined, @Cons(V:Val,@Nil)) => V ==K @NaN
      413  rule Call(@("IsPositiveZero"),     Undefined, @Cons(V:Val,@Nil)) => V ==K 0 orBool V ==K 0.0
      861  rule Call(@("IsNegativeZero"),     Undefined, @Cons(V:Val,@Nil)) => V ==K @nz
     2230  rule Call(@("IsFunction"),         Undefined, @Cons(V:Val,@Nil)) => IsCallable(V)
       56  rule Call(@("IsCallable"),         Undefined, @Cons(V:Val,@Nil)) => IsCallable(V)
           
           rule <k> Call(@("NoConstructor"), Undefined, @Cons(O:Val,@Nil)) => Undefined ... </k>
                <objs>
                  <obj>
                    <oid> O </oid>
                    <properties>
                      ("prototype" |-> @desc("Value" |-> P:Oid _) => .Map)
                      _:Map
                    </properties>
                    <internalProperties>
                      "Strict" |-> (_ => false)
                      _:Map
                    </internalProperties>
                    _
                  </obj>
                  (<obj> <oid> P </oid> _ </obj> => .)
                  _
                </objs>
           
     4948  rule Call(@("GetInternalProperty"), Undefined, @Cons(O:Val,@Cons(P:Val,@Nil)))
     9896    => Let $v = GetInternalProperty(O:>Oid,P:>Var);
     9896       If @AndBool(@EqVal(P,"Prototype"), @EqVal($v,@NullOid)) = true then {
        6          Return @NullVal;
                } else {
     4942          Return $v;
                }
      507  rule Call(@("SetInternalProperty"), Undefined, @Cons(O:Val,@Cons(P:Val,@Cons(V:Val,@Nil))))
     1014    => If @AndBool(@EqVal(P,"Prototype"), @EqVal(V,@NullVal)) = true then {
        1         Do SetInternalProperty(O:>Oid,P:>Var,@NullOid);
                } else {
      506         Do SetInternalProperty(O:>Oid,P:>Var,V);
                }
      507       Return Undefined;
           
     5327  rule Call(@("GetOwnProperty"),         Undefined, @Cons(O:Val,@Cons(P:Val,                             @Nil  ))) => GetOwnProperty(O,P)
     3272  rule Call(@("DefineOwnProperty"),      Undefined, @Cons(O:Val,@Cons(P:Val,@Cons(V:Val,@Cons(Strict:Val,@Nil))))) => DefineOwnProperty(O,P,V,Strict)
           
     5327  rule Call(@("FromPropertyDescriptor"), Undefined, @Cons(V:Val,@Nil)) => FromPropertyDescriptor(V)
     3333  rule Call(@(  "ToPropertyDescriptor"), Undefined, @Cons(V:Val,@Nil)) =>   ToPropertyDescriptor(V)
           
      496  rule Call(@("CheckObjectCoercible"),   Undefined, @Cons(V:Val,@Nil)) => CheckObjectCoercible(V) ~> Undefined
           
      216  rule Call(@("ObjectGetOwnPropertyNames"),  Undefined, @Cons(O:Val,@Nil)) => @ObjectGetOwnPropertyNames(O:>Oid)
           
       99  rule Call(@("FunctionPrototypeToString"),  Undefined, @Cons(Func:Val,@Nil)) => @FunctionPrototypeToString(Func:>Oid)
     1022  rule Call(@("FunctionPrototypeApply"   ),  Undefined, @Cons(Func:Val,@Cons(ThisArg:Val,@Cons(ArgArray:Val,@Nil)))) => @FunctionPrototypeApply(Func,ThisArg,ArgArray)
      125  rule Call(@("FunctionPrototypeBind"    ),  Undefined, @Cons(Func:Val,@Cons(ThisArg:Val,@Cons(ArgArray:Val,@Nil)))) => @FunctionPrototypeBind(Func,ThisArg,ArgArray)
           
        3  rule Call(@("NumberPrototypeToFixed"), Undefined, @Cons(O:Val,@Cons(V:Val,@Nil))) => @NumberPrototypeToFixed(O:>Oid, ToInteger(V))
           
      154  rule Call(@("MathFloor"),          Undefined, @Cons(N:Val,@Nil)) => @MathFloor(N:>Number)
       36  rule Call(@("MathPow"),            Undefined, @Cons(N1:Val,@Cons(N2:Val,@Nil))) => @MathPow(N1:>Number, N2:>Number)
       10  rule Call(@("MathSin"),            Undefined, @Cons(N:Val,@Nil))
       20    => Let $n = ToString(N);
       20       Return ToNumber(#external("node\x01-p\x01-e\x01Math.sin(" +String $n:>String +String ")"));
           
       11  rule Call(@("DatePrototypeToString"), Undefined, @Cons(O:Val,@Nil)) => @DatePrototypeToString(O:>Oid)
           
      353  rule Call(@("LengthString"),       Undefined, @Cons(S:Val,@Nil)) => lengthString(S:>String)
      122  rule Call(@("Trim"),               Undefined, @Cons(S:Val,@Nil)) => trim(S:>String) // TODO:STD: check the builtin's trim has correct whitespaces and lineterminators.
       79  rule Call(@("Int2Char"),           Undefined, @Cons(I:Val,@Nil)) => @Int2Char(I:>Int)
       17  rule Call(@("Char2Int"),           Undefined, @Cons(S:Val,@Nil)) => @Char2Int(S:>String)
       40  rule Call(@("CharAt"),             Undefined, @Cons(S:Val,@Cons(N:Val,@Nil))) => @CharAt(S:>String, N:>Number)
      183  rule Call(@("FindString"),         Undefined, @Cons(S1:Val,@Cons(S2:Val,@Cons(I:Val,@Nil)))) => @FindString(S1:>String, S2:>String, I:>Int)
       97  rule Call(@("SubstrString"),       Undefined, @Cons(S:Val,@Cons(I1:Val,@Cons(I2:Val,@Nil)))) => @SubstrString(S:>String, I1:>Int, I2:>Int)
           
      117  rule Call(@("NumberToString"),     Undefined, @Cons(N:Val,@Cons(R:Val,@Nil))) => @NumberToString(N:>Number, R:>Int)
           
           rule Call(@("Print"),              Undefined, @Cons(V:Val,@Nil)) => @PrintNewline(V)
           
           rule Call(@("CurrentTimeMillis"),  Undefined, @Nil) => 0 // TODO:STD: do correctly
           
           //////////////////////////////////////////////////////////////////////////////
           // 16 Errors
           //////////////////////////////////////////////////////////////////////////////
           
           syntax KItem ::= "@CheckEarlyErrors" "(" Bool "," Stmt ")"
    14846  rule @CheckEarlyErrors(Strict:Bool, Code:Stmt) => @CEE(Strict, .Set, Code)
           
           syntax KItem ::= "@CEE" /* Check Early Errors */ "(" Bool "," Set "," K /* Stmt or Exp or Exps */ ")"
           //
   134663  rule @CEE(Strict:Bool, Ls:Set, %fdecl(F:Var,Es:Exps,S:Stmt))            => @CheckReserved(Strict,F) ~> @SMRFun(Strict,F,Es,S) ~> @CEE(Strict,Ls,Es) ~> @CEE(Strict orBool @IsStrict(S), .Set, S)
   196173  rule @CEE(Strict:Bool, Ls:Set, %vdecl(N:Var))                           => @CheckReserved(Strict,N) ~> @SMRVar(Strict,N)
   750568  rule @CEE(Strict:Bool, Ls:Set, %seq(S1:Stmt,S2:Stmt))                   => @CEE(Strict,Ls,S1) ~> @CEE(Strict,Ls,S2)
   470901  rule @CEE(Strict:Bool, Ls:Set, %exp(E))                                 => @CEE(Strict,Ls,E)
   243958  rule @CEE(Strict:Bool, Ls:Set, %if(E:Exp,S1:Stmt,S2:Stmt))              => @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,S1) ~> @CEE(Strict,Ls,S2)
       76  rule @CEE(Strict:Bool, Ls:Set, %do(S:Stmt,E:Exp))                       => @CEE(Strict,Ls,S) ~> @CEE(Strict,Ls,E)
       47  rule @CEE(Strict:Bool, Ls:Set, %while(E:Exp,S:Stmt))                    => @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,S)
    27552  rule @CEE(Strict:Bool, Ls:Set, %for  (S1:Stmt,E1:Exp,E2:Exp,S2:Stmt))   => @CEE(Strict,Ls,S1) ~> @CEE(Strict,Ls,E1) ~> @CEE(Strict,Ls,E2) ~> @CEE(Strict,Ls,S2)
    14234  rule @CEE(Strict:Bool, Ls:Set, %forin(S1:Stmt,E1:Exp,E2:Exp,S2:Stmt))   => @CEE(Strict,Ls,S1) ~> @CEE(Strict,Ls,E1) ~> @CEE(Strict,Ls,E2) ~> @CEE(Strict,Ls,S2)
       65  rule @CEE(Strict:Bool, Ls:Set, %continue(L:Var))                        => @CheckReserved(Strict,L) ~> @CheckGoto(Ls,L)
     6989  rule @CEE(Strict:Bool, Ls:Set, %break(L:Var))                           => @CheckReserved(Strict,L) ~> @CheckGoto(Ls,L)
    41999  rule @CEE(Strict:Bool, Ls:Set, %label(L:Var,S:Stmt))                    => @CheckReserved(Strict,L) ~> @CEE(Strict, SetItem(L) Ls, S)
   144804  rule @CEE(Strict:Bool, Ls:Set, %return(E:Exp))                          => @CEE(Strict,Ls,E)
    28033  rule @CEE(Strict:Bool, Ls:Set, %throw(E:Exp))                           => @CEE(Strict,Ls,E)
    36146  rule @CEE(Strict:Bool, Ls:Set, %try(S1:Stmt,X:Var,S2:Stmt,S3:Stmt))     => @CheckReserved(Strict,X) ~> @SMRVar(Strict,X) ~> @CEE(Strict,Ls,S1) ~> @CEE(Strict,Ls,S2) ~> @CEE(Strict,Ls,S3)
      286  rule @CEE(Strict:Bool, Ls:Set, %try(S1:Stmt,              S3:Stmt))     =>                                                  @CEE(Strict,Ls,S1) ~>                       @CEE(Strict,Ls,S3)
      197  rule @CEE(Strict:Bool, Ls:Set, %with(E:Exp,S:Stmt))                     => @CheckWith(Strict) ~> @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,S)
   300964  rule @CEE(Strict:Bool, Ls:Set, %emptyStmt)                              => .
       11  rule @CEE(Strict:Bool, Ls:Set, %switch(E:Exp,S1:Stmt,S2:Stmt,S3:Stmt))  => @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,S1) ~> @CEE(Strict,Ls,S2) ~> @CEE(Strict,Ls,S3)
       40  rule @CEE(Strict:Bool, Ls:Set, %case(E:Exp,S:Stmt))                     => @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,S)
        9  rule @CEE(Strict:Bool, Ls:Set, %default(S:Stmt))                        => @CEE(Strict,Ls,S)
           //
   828067  rule @CEE(Strict:Bool, Ls:Set, %con(_:Const))                           => .
  1655149  rule @CEE(Strict:Bool, Ls:Set, %var(N:Var))                             => @CheckReserved(Strict,N)
     7427  rule @CEE(Strict:Bool, Ls:Set, %arr(Es:Exps))                           => @CEE(Strict,Ls,Es)
    27681  rule @CEE(Strict:Bool, Ls:Set, %obj(Es:Exps))                           => @CheckDuplicatedProp(Strict,Es) ~> @CEE(Strict,Ls,Es)
    22008  rule @CEE(Strict:Bool, Ls:Set, %prop(P:Var,E:Exp))                      => /* @CheckReserved(Strict,P) ~> */ @CEE(Strict,Ls,E)
       19  rule @CEE(Strict:Bool, Ls:Set, %get(P:Var,      S:Stmt))                => /* @CheckReserved(Strict,P) ~> */                                                                       @CEE(Strict orBool @IsStrict(S), .Set, S)
       22  rule @CEE(Strict:Bool, Ls:Set, %set(P:Var,X:Var,S:Stmt))                => /* @CheckReserved(Strict,P) ~> */ @CheckReserved(Strict,X) ~> @SMRVar(Strict orBool @IsStrict(S), X) ~> @CEE(Strict orBool @IsStrict(S), .Set, S)
   337311  rule @CEE(Strict:Bool, Ls:Set, %mem(E1:Exp,E2:Exp))                     => @CEE(Strict,Ls,E1) ~> @CEE(Strict,Ls,E2)
    24694  rule @CEE(Strict:Bool, Ls:Set, %new(E:Exp,Es:Exps))                     => @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,Es)
   219849  rule @CEE(Strict:Bool, Ls:Set, %call(E:Exp,Es:Exps))                    => @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,Es)
       54  rule @CEE(Strict:Bool, Ls:Set, %comma(E1:Exp,E2:Exp))                   => @CEE(Strict,Ls,E1) ~> @CEE(Strict,Ls,E2)
   123173  rule @CEE(Strict:Bool, Ls:Set, %pre(O:Op,E:Exp))                        => @CheckInvalidLValue(Strict,%pre(O,E))           ~> @CEE(Strict,Ls,E)
    27709  rule @CEE(Strict:Bool, Ls:Set, %post(E:Exp,O:Op))                       => @CheckInvalidLValue(Strict,%post(E,O))          ~> @CEE(Strict,Ls,E)
   758851  rule @CEE(Strict:Bool, Ls:Set, %bop(O:Op,E1:Exp,E2:Exp))                => @CheckInvalidLValue(Strict,%bop(O,E1,E2))       ~> @CEE(Strict,Ls,E1) ~> @CEE(Strict,Ls,E2)
     1319  rule @CEE(Strict:Bool, Ls:Set, %bopassign(O:Op,E1:Exp,E2:Exp))          => @CheckInvalidLValue(Strict,%bopassign(O,E1,E2)) ~> @CEE(Strict,Ls,E1) ~> @CEE(Strict,Ls,E2)
       50  rule @CEE(Strict:Bool, Ls:Set, %cond(E1:Exp,E2:Exp,E3:Exp))             => @CEE(Strict,Ls,E1) ~> @CEE(Strict,Ls,E2) ~> @CEE(Strict,Ls,E3)
       83  rule @CEE(Strict:Bool, Ls:Set, %emptyExp)                               => .
       78  rule @CEE(Strict:Bool, Ls:Set, %fun(X:Var,Es:Exps,S:Stmt))              => @CheckReserved(Strict,X) ~> @SMRFun(Strict,X, Es,S) ~> @CEE(Strict,Ls,Es) ~> @CEE(Strict orBool @IsStrict(S), .Set, S)
    24225  rule @CEE(Strict:Bool, Ls:Set, %fun(      Es:Exps,S:Stmt))              =>                             @SMRFun(Strict,"",Es,S) ~> @CEE(Strict,Ls,Es) ~> @CEE(Strict orBool @IsStrict(S), .Set, S)
           //
   473611  rule @CEE(Strict:Bool, Ls:Set, %cons(E:Exp,Es:Exps))                    => @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,Es)
   438545  rule @CEE(Strict:Bool, Ls:Set, %nil)                                    => .
           
           syntax KItem ::= "@CheckDuplicatedProp" "(" Bool "," Exps ")"
    27681  rule @CheckDuplicatedProp(Strict:Bool, Es:Exps)
    55362    => If @DuplicatedProp(Strict,Es) = true then {
       10         Do @Throw(@SyntaxError("Duplicated properties",Es));
                };
           //
           syntax KItem ::= "@DuplicatedProp" "(" Bool "," Exps ")"
    27681  rule @DuplicatedProp(Strict:Bool,Es:Exps) => @DuplicatedPropAux(Strict,Es,.Set,.Set,.Set)
           //
           syntax KItem ::= "@DuplicatedPropAux" "(" Bool "," Exps "," Set "," Set "," Set ")"
        2  rule @DuplicatedPropAux(Strict:Bool, %cons(%prop(D:Var,_), Es:Exps), DS:Set, GS:Set, SS:Set) => true when D in GS orBool D in SS
        2  rule @DuplicatedPropAux(Strict:Bool, %cons(%prop(D:Var,_), Es:Exps), DS:Set, GS:Set, SS:Set) => true when D in DS andBool Strict ==K true
    22012  rule @DuplicatedPropAux(Strict:Bool, %cons(%prop(D:Var,_), Es:Exps), DS:Set, GS:Set, SS:Set) => @DuplicatedPropAux(Strict, Es, SetItem(D) DS, GS, SS) when notBool(D in GS orBool D in SS)
                                                                                                                                                              andBool notBool(D in DS andBool Strict ==K true)
           //
        3  rule @DuplicatedPropAux(Strict:Bool, %cons(%get(G:Var,_),  Es:Exps), DS:Set, GS:Set, SS:Set) => true when G in GS orBool G in DS
       23  rule @DuplicatedPropAux(Strict:Bool, %cons(%get(G:Var,_),  Es:Exps), DS:Set, GS:Set, SS:Set) => @DuplicatedPropAux(Strict, Es, DS, SetItem(G) GS, SS) when notBool(G in GS orBool G in DS)
           //
        3  rule @DuplicatedPropAux(Strict:Bool, %cons(%set(S:Var,_,_),Es:Exps), DS:Set, GS:Set, SS:Set) => true when S in SS orBool S in DS
       26  rule @DuplicatedPropAux(Strict:Bool, %cons(%set(S:Var,_,_),Es:Exps), DS:Set, GS:Set, SS:Set) => @DuplicatedPropAux(Strict, Es, DS, GS, SetItem(S) SS) when notBool(S in SS orBool S in DS)
           //
    27671  rule @DuplicatedPropAux(Strict:Bool, %nil, _, _, _) => false
           
           syntax KItem ::= "@CheckInvalidLValue" "(" Bool "," Exp ")"
   911052  rule @CheckInvalidLValue(Strict:Bool, E:Exp)
   911052    => If @InvalidLValue(Strict,E) = true then {
       56         Do @Throw(@SyntaxError("In strict mode, 'eval' or 'arguments' cannot be updated",E));
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
           
           syntax KItem ::= "@CheckWith" "(" Bool ")"
      197  rule @CheckWith(Strict:Bool)
      197    => If Strict = true then {
       14         Do @Throw(@SyntaxError("In strict mode, with cannot be used",""));
                };
           
           syntax KItem ::= "@CheckGoto" "(" Set "," Var ")"
     7054  rule @CheckGoto(Ls:Set, L:Var)
     7054    => If notBool(L in Ls) = true then {
       24         Do @Throw(@SyntaxError("continue or break without nested iteration or switch stmt",L));
                };
           
           //////////////////////////////////////////////////////////////////////////////
           // Strict Mode Restrictions
           //////////////////////////////////////////////////////////////////////////////
           
           // 11.1.5, PropertyAssignment : set PropertyName ( PropertySetParameterList ) { FunctionBody } 
           // 12.2.1 Strict Mode Restrictions
           // 12.10.1 Strict Mode Restrictions
           // 12.14.1 Strict Mode Restrictions
           // 13.1 Strict Mode Restrictions
           
           syntax KItem ::= "@SMRVar" "(" Bool "," Var ")"
   604058  rule @SMRVar(Strict:Bool, P:Var)
  1208116    => If @AndBool(Strict ==K true, @OrBool(P ==K "eval", P ==K "arguments")) = true then {
       62         Do @Throw(@SyntaxError("Strict Mode Restrictions, eval or arguments as a variable",P));
                };
           
           syntax KItem ::= "@SMRFun" "(" Bool "," Var "," Exps "," Stmt ")"
   158966  rule @SMRFun(Strict:Bool, F:Var, Ps:Exps, FB:Stmt)
   158966    => Let $strict = @IsStrict(FB) orBool Strict;
   158966       Do @SMRVar($strict:>Bool,F);
   158953       Do @SMRVars($strict:>Bool,Ps);
   158939       Do @SMRParams($strict:>Bool,Ps);
           //
           syntax KItem ::= "@SMRVars" "(" Bool "," Exps ")"
   212766  rule @SMRVars(Strict:Bool, %cons(%var(X:Var),Ps:Exps)) => @SMRVar(Strict,X) ~> @SMRVars(Strict,Ps)
   158939  rule @SMRVars(Strict:Bool, %nil) => .
           //
           syntax KItem ::= "@SMRParams" "(" Bool "," Exps ")"
   158939  rule @SMRParams(Strict:Bool, Ps:Exps)
   317878    => If @AndBool(Strict, @DuplicatedParams(Ps)) = true then {
       20         Do @Throw(@SyntaxError("Strict Mode Restrictions, duplicated parameters",Ps));
                };
           //
           syntax KItem ::= "@DuplicatedParams" "(" Exps ")"
   158939  rule @DuplicatedParams(Ps:Exps) => @DuplicatedParamsAux(Ps,.Set)
           //
           syntax KItem ::= "@DuplicatedParamsAux" "(" Exps "," Set ")"
       26  rule @DuplicatedParamsAux(%cons(%var(X:Var),Ps:Exps),S:Set) => true when X in S
   212719  rule @DuplicatedParamsAux(%cons(%var(X:Var),Ps:Exps),S:Set) => @DuplicatedParamsAux(Ps, SetItem(X) S) when notBool(X in S)
   158913  rule @DuplicatedParamsAux(%nil,_) => false
           
           //////////////////////////////////////////////////////////////////////////////
           // Pseudo-code evaluation
           //////////////////////////////////////////////////////////////////////////////
           
           //////////////////////////////////////////////////////////////////////////////
           // Pseudo-code evaluation
           //////////////////////////////////////////////////////////////////////////////
           
           syntax PseudoCodes ::= PseudoCode PseudoCodes
                                | PseudoCode
  9352757  syntax PseudoCode  ::= "Let" Id "=" K ";" [seqstrict(2)]
                                | "Do"  K ";"
                                | "DoI" K ";"
 23553973                       | "If" K "=" K "then" "{" PseudoCodes "}" "else" "{" PseudoCodes "}" [seqstrict(1,2)]
  3142390                       | "If" K "=" K "then" "{" PseudoCodes "}" ";"                        [seqstrict(1,2)]
  2615948                       | "Return" K ";" [seqstrict(1)]
                                | "Return"   ";"
                                | "Nop" ";"
           syntax Exp ::= Id
           
  8203719  rule PC:PseudoCode PCs:PseudoCodes => PC ~> PCs
           //rule Let X:Id = V:KResult; ~> PCs:PseudoCodes => PCs[V / X]
           
  5276970  rule Let X:Id = V:KResult; ~> PCs:PseudoCodes => #visit(PCs, '@Replace`(_`,_`), V, '_==K_, X)
           //
           syntax KItem ::= "@Replace" "(" K "," K ")" [function]
           rule @Replace(_, K) => K
           
  6885937  rule Do  K; => K
   422222  rule DoI K; => K ~> @Ignore
  4312202  rule If V1:KResult = V2:KResult then { PCs } else { _   } => PCs when V1 ==K  V2
 12539726  rule If V1:KResult = V2:KResult then { _   } else { PCs } => PCs when V1 =/=K V2
   824765  rule If V1:KResult = V2:KResult then { PCs } ;            => PCs when V1 ==K  V2
  5000182  rule If V1:KResult = V2:KResult then { _   } ;            => .K  when V1 =/=K V2
  5132695  rule Return V:KResult; => V
     1059  rule Return; => .K
    29538  rule Nop; => .K
           
           syntax KItem ::= "BEGIN" PseudoCodes "END"
           syntax PseudoCode ::= "Exit" ";"
           
   667965  rule <k> BEGIN PCs:PseudoCodes END ~> K => PCs ~> Exit; </k>
                <pseudoStack> (.List => ListItem(@pseudo(K))) _:List </pseudoStack>
           
   667633  rule <k> V:KResult ~> Exit; ~> _ => V ~> K </k> <pseudoStack> (ListItem(@pseudo(K)) => .List) _:List </pseudoStack>
           rule <k>              Exit; ~> _ =>      K </k> <pseudoStack> (ListItem(@pseudo(K)) => .List) _:List </pseudoStack>
           
           //////////////////////////////////////////////////////////////////////////////
           // Utils
           //////////////////////////////////////////////////////////////////////////////
           
           syntax KItem /* .K */ ::= "@True?" | "@False?"
           rule true  ~> @True?  => .
   184097  rule false ~> @False? => .
           
           syntax KItem /* .K */ ::= "@Ignore"
   661610  rule _:Val ~> @Ignore => .
           
           syntax Int ::= "@Length" "(" Exps ")" [function]
           rule @Length(%cons(_,Es)) => 1 +Int @Length(Es)
           rule @Length(%nil) => 0
           
           syntax Int ::= "@LengthVals" "(" Vals ")" [function]
           rule @LengthVals(@Cons(_,Vs)) => 1 +Int @LengthVals(Vs)
           rule @LengthVals(@Nil) => 0
           
           syntax Exp ::= Exp /* PropertyDescriptor */ "." Var [function]
           rule @desc(X |-> V:Val _) . X => V
           rule @desc(M:Map        ) . X => Undefined when notBool(X in keys(M))
           
           syntax Bool ::= "@SubDesc" "(" PropertyDescriptor "," PropertyDescriptor ")" [function]
           rule @SubDesc(@desc(M1:Map), @desc(M2:Map)) => @SubDescAux(keys(M1), @desc(M1), @desc(M2))
           //
           syntax Bool ::= "@SubDescAux" "(" Set "," PropertyDescriptor "," PropertyDescriptor ")" [function]
           rule @SubDescAux(                    .Set , @desc( _:Map), @desc( _:Map)) => true
           rule @SubDescAux((SetItem(X:String) S:Set), @desc(M1:Map), @desc(M2:Map)) => @SubDescAuxSingle(X,M1,M2) andBool @SubDescAux(S,@desc(M1),@desc(M2))
           //
           syntax Bool ::= "@SubDescAuxSingle" "(" String "," Map "," Map ")" [function]
           rule @SubDescAuxSingle(X:String,M1:Map,M2:Map) => X in keys(M2) andBool SameValue(M1[X], M2[X])
           
           /*
           syntax Bool ::= "@SubDesc" "(" PropertyDescriptor "," PropertyDescriptor ")" [function]
           rule @SubDesc(@desc(                 .Map), @desc(               _     )) => true
           rule @SubDesc(@desc(               M1:Map), @desc(                 .Map)) => false                         when M1 =/=Map .Map
           rule @SubDesc(@desc((X |-> V1:Val) M1:Map), @desc((X |-> V2:Val) M2:Map)) => @SubDesc(@desc(M1),@desc(M2)) when         SameValue(V1,V2)
           rule @SubDesc(@desc((X |-> V1:Val) _     ), @desc((X |-> V2:Val) _     )) => false                         when notBool(SameValue(V1,V2))
           rule @SubDesc(@desc((X |-> _     ) _     ), @desc(               M2:Map)) => false                         when notBool(X in keys(M2))
           rule @SubDesc(@desc(               M1:Map), @desc((X |-> V2:Val) M2:Map)) => @SubDesc(@desc(M1),@desc(M2)) when notBool(X in keys(M2))
           */
           
           syntax Map ::= "@AddMap" "(" K "," K "," Map ")" [function]
           rule @AddMap(X, V,           M:Map) => (X |-> V) M when notBool(X in keys(M))
           rule @AddMap(X, V, (X |-> _) M:Map) => (X |-> V) M when notBool(X in keys(M))
           
     2558  syntax KItem /* .K */ ::= "@AddDesc" "(" K /* Var */ "," K /* Val */ "," K /* PropertyDescriptor */ ")" [seqstrict(1,2,3)]
     7464  rule @AddDesc(X:Var,V:Val,@desc(Desc)) => @desc(@AddMap(X,V,Desc))
           
           syntax Bool ::= "@MemDesc" "(" PropertyDescriptor "," Var ")" [function]
           rule @MemDesc(@desc(Desc),X:Var) => X in keys(Desc)
           
           syntax KItem ::= "@GenDesc" "(" K "," K                                     ")" [function]
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
           
           syntax Vals ::= "@AppendVals" "(" Vals "," Vals ")" [function]
           rule @AppendVals(@Cons(V1:Val,Vs1:Vals), Vs2:Vals) => @Cons(V1, @AppendVals(Vs1,Vs2))
           rule @AppendVals(@Nil, Vs:Vals) => Vs
           
           syntax KItem ::= "@Print" "(" K ")" [seqstrict(1)]
           rule <k> @Print(S:String) => Undefined ... </k>
                <out> _:List (.List => ListItem(S)) </out>
           
           syntax KItem ::= "@PrintNewline" "(" K ")" [seqstrict(1)]
           rule @PrintNewline(S:String) => @Print(S +String "\n")
           
           syntax KItem ::= "@LOG" "(" K ")"
           rule <k> @LOG(K) => . ... </k>
                <log> _:List (.List => ListItem(K)) </log>
           
           syntax Bool ::= "@IsPrimitive" "(" Val ")" [function]
           rule @IsPrimitive(V:Val) => @IsBool(V) orBool @IsString(V) orBool @IsNumber(V)
           
           syntax Bool ::= "@IsBool" "(" Val ")" [function]
           rule @IsBool(Undefined) => false
           rule @IsBool(@NullVal  ) => false
           rule @IsBool(_:Bool    ) => true
           rule @IsBool(_:String  ) => false
           rule @IsBool(_:Number  ) => false
           rule @IsBool(_:Oid     ) => false
           
           syntax Bool ::= "@IsString" "(" Val ")" [function]
           rule @IsString(Undefined) => false
           rule @IsString(@NullVal  ) => false
           rule @IsString(_:Bool    ) => false
           rule @IsString(_:String  ) => true
           rule @IsString(_:Number  ) => false
           rule @IsString(_:Oid     ) => false
           
           syntax Bool ::= "@IsNumber" "(" Val ")" [function]
           rule @IsNumber(Undefined) => false
           rule @IsNumber(@NullVal  ) => false
           rule @IsNumber(_:Bool    ) => false
           rule @IsNumber(_:String  ) => false
           rule @IsNumber(_:Number  ) => true
           rule @IsNumber(_:Oid     ) => false
           
           syntax Bool ::= "@IsOid" "(" Val ")" [function]
           rule @IsOid(Undefined) => false
           rule @IsOid(@NullVal  ) => false
           rule @IsOid(_:Bool    ) => false
           rule @IsOid(_:String  ) => false
           rule @IsOid(_:Number  ) => false
           rule @IsOid(_:Oid     ) => true
           
  6423844  syntax KItem /* Bool */ ::= "@AndBool" "(" K /* Bool */ "," K /* Bool */ ")" [seqstrict(1,2)]
  2733316  rule @AndBool(B1:Bool,B2:Bool) => B1 andBool B2
           
  1980400  syntax KItem /* Bool */ ::= "@OrBool" "(" K /* Bool */ "," K /* Bool */ ")" [seqstrict(1,2)]
  1767337  rule @OrBool(B1:Bool,B2:Bool) => B1 orBool B2
           
           syntax KItem /* Bool */ ::= "@XorBool" "(" K /* Bool */ "," K /* Bool */ ")" [seqstrict(1,2)]
     3423  rule @XorBool(B1:Bool,B2:Bool) => B1 ==K B2
           
           syntax KItem /* Bool */ ::= "@NotBool" "(" K /* Bool */ ")" [seqstrict(1)]
   243320  rule @NotBool(B:Bool) => notBool(B)
           
     8138  syntax KItem /* Bool */ ::= "@EqVal" "(" K /* Val */ "," K /* Val */ ")" [seqstrict(1,2)]
  1726715  rule @EqVal(V1:Val,V2:Val) => V1 ==K V2
           
           syntax KItem /* Bool */ ::= "@NeqVal" "(" K /* Val */ "," K /* Val */ ")" [seqstrict(1,2)]
   243359  rule @NeqVal(V1:Val,V2:Val) => V1 =/=K V2
           
           syntax String ::= "@CharAt" "(" String "," Number ")" [function]
           rule @CharAt(S:String,I:Int) => substrString(S, I, I +Int 1)
           rule @CharAt(S:String,@nz  ) => @CharAt(S,0)
           
           syntax KItem /* String */ ::= "@Int2Char" "(" Int ")"
       79  rule @Int2Char(I:Int) => chrChar(I)
           
           syntax KItem /* Int */ ::= "@Char2Int" "(" String ")"
       17  rule @Char2Int(S:String) => ordChar(S)
           
           syntax KItem /* String */ ::= "@SubstrString" "(" String "," Int "," Int ")"
     6736  rule @SubstrString(S:String,I1:Int,I2:Int) => substrString(S,I1,I2)
           
           syntax KItem /* Int */ ::= "@String2Int" "(" String ")"
     6212  rule @String2Int(S:String) => String2Int(S)
           
           syntax KItem /* Float */ ::= "@String2Float" "(" String ")"
       88  rule @String2Float(S:String) => String2Float(S)
           
           syntax KItem ::= "@String2Base" "(" String "," Int ")"
       50  rule @String2Base(S:String,B:Int) => String2Base(S,B)
           
           syntax KItem /* Int */ ::= "@FindString" "(" String "," String "," Int ")"
      183  rule @FindString(S1:String,S2:String,I:Int) => findString(S1,S2,I)
           
           syntax KItem /* String */ ::= "@NumberToString" "(" Number "," Int ")"
           // TODO:STD: consider radix other then 10
       83  rule @NumberToString(N:Number, 10) => ToString(N)
           
           syntax KItem ::= "@Cond" "(" K /* Bool */ "," K "," K ")" [seqstrict(1)]
           rule @Cond(true,  K:K, _) => K
           rule @Cond(false, _, K:K) => K
           
           syntax KItem ::= "@Min" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
           rule @Min(N1:Number,N2:Number)
             => If %bop(%lt,N1,N2) = true then {
                  Return N1;
                } else {
                  Return N2;
                }
           
           syntax KItem ::= "@Max" "(" K /* Number */ "," K /* Number */ ")" [seqstrict(1,2)]
           rule @Max(N1:Number,N2:Number)
             => If %bop(%gt,N1,N2) = true then {
                  Return N1;
                } else {
                  Return N2;
                }
           
           syntax Float ::= "@Int2Float" "(" Int ")" [function]
           rule @Int2Float(I:Int) => Int2Float(I, 53, 11)
           
           syntax String ::= "@PWD" [function]
           rule @PWD => "/home/daejunpark/dev/jstest/js/work"
           
           // XXX: Copied from "include/builtins/string.k"
           rule ltrim(S:String) => ltrim(replaceFirst(S, " ", "")) when findString(S, " ", 0) ==Int 0
           rule ltrim(S:String) => S when findString(S, " ", 0) =/=Int 0
           rule ltrim("") => ""
           //
           rule rtrim(S:String) => rtrim(substrString(S,0, lengthString(S) -Int 1)) when substrString(S, lengthString(S) -Int 1, lengthString(S)) ==String " "
           rule rtrim(S:String) => S when substrString(S, lengthString(S) -Int 1, lengthString(S)) =/=String " "
           rule rtrim("") => ""
           //
           rule trim(S:K) => ltrim(rtrim(S))
           
           syntax KItem ::= "#external" "(" String ")" [function]
           rule #external(Cmd:String) => #externalAux(#system(Cmd))
           syntax KItem ::= "#externalAux" "(" K ")" [function]
           rule #externalAux(#systemResult(ExitCode:Int,Stdout:String,Stderr:String)) => Stdout            when ExitCode ==Int 0
           rule #externalAux(#systemResult(ExitCode:Int,Stdout:String,Stderr:String)) => #tcpError(Stderr) when ExitCode =/=Int 0
           
           endmodule
