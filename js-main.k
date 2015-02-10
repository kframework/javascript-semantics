require "js-trans.k"
require "js-str-numeric-literal.k"
require "js-prelude.k"

require "modules/verification_lemmas.k"

//require "verification/patterns/float_set.k"
//require "verification/patterns/float_tree_pattern.k"
require "verification/patterns/string_set.k"
require "verification/patterns/string_tree_pattern.k"
//require "verification/patterns/list_pattern.k"

module JS-SYNTAX
imports JS-ORIG-SYNTAX
imports JS-STR-NUMERIC-LITERAL
endmodule

module JS-MAIN

imports JS-SYNTAX
imports JS-TRANS
imports JS-PRELUDE

imports VERIFICATION_LEMMAS

//////////////////////////////////////////////////////////////////////////////
// Configuration
//////////////////////////////////////////////////////////////////////////////

syntax KItem ::= "@Run" "(" Stmt ")"
rule @Run(Pgm:Stmt) => @EnterGlobalCode(Pgm) ~> Pgm

configuration
<T>
  <k> @InitConfig ~> @LoadConfig ~> @Run(^SourceElements($PGM:SourceElements)) </k>
  <objs map="">
    // 8.6 The Object Type
    <obj multiplicity="*">
      <oid key=""> .K </oid> // Oid
      <properties> .Map </properties> // Var -> PropertyDescriptor
      <internalProperties> .Map </internalProperties> // Var -> PropertyDescriptor
    </obj>
  </objs>
  <envs map="">
    // 10.2 Lexical Environments
    <env multiplicity="*">
      <eid key=""> .K </eid> // Eid
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
    <pseudoCtx>
      <pseudoStack> .List </pseudoStack>
      <pseudoEnv> .Map </pseudoEnv>
    </pseudoCtx>
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
syntax KItem ::= "@pseudo" "(" K "," Map ")"

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
syntax Oid  ::= "@o" "(" Int ")" [smtlib(smt_pointer_object)]
              | "@NullOid"
// 8.11 The Lexical Environment and Environment Record Specification Types
syntax Eid  ::= "@e" "(" Int ")"
              | "@NullEid"

syntax UndefinedType ::= "Undefined" // 8.1 The Undefined Type
syntax NullType ::= "@NullVal" [smtlib(smt_pointer_null)] // 8.2 The Null Type

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

syntax Float ::= "@MAX_VALUE"
rule @MAX_VALUE => 1.7976931348623157e308 [macro]
//
syntax Float ::= "@MIN_VALUE"
rule @MIN_VALUE => 4.9e-324 [macro]

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
syntax KItem                    ::= "@Throw"    "(" K /* Val */ ")" [seqstrict] // NOTE: @Throw is no longer a completion type. Rather, we use another exception handling mechanism.

syntax KResult ::= CompletionType
syntax Stmt    ::= CompletionType

// TODO: check if we can describe without following
syntax KResult ::= "@m" "(" Map ")"
syntax KResult ::= "@s" "(" Set ")"

//////////////////////////////////////////////////////////////////////////////
// Initializing Configuration
//////////////////////////////////////////////////////////////////////////////

#include "js-init-configuration.k"

syntax KItem /* .K */ ::= "@LoadConfig"
rule <k> @LoadConfig => . ... </k>
#include "js-config.k"

//////////////////////////////////////////////////////////////////////////////
// 7.6.1 Reserved Words
//////////////////////////////////////////////////////////////////////////////
// TODO: This should have been used by a front-end such as 'js-trans.k' so that we can distinguish between 'Name' and 'String', both are 'PropertyName'.

syntax KItem ::= "@CheckReserved" "(" K /* Bool */ "," K /* Var */ ")" [seqstrict]
rule @CheckReserved(Strict:Bool, X:Var)
  => BEGIN
     If #@IsReservedWord(Strict,X) = true then {
       Do @Throw(@SyntaxError("A reserved word cannot be used as an identifier",X));
     };
     END

syntax Bool ::= "#@IsReservedWord" "(" Bool "," Var ")" [function]
rule #@IsReservedWord(Strict:Bool, X:Var)
  =>      #@IsKeyword(X)
   orBool #@IsFutureReservedWord(X)
   orBool (Strict andBool #@IsFutureReservedWordInStrictMode(X))
   orBool (X ==K "null")
   orBool (X ==K "true")
   orBool (X ==K "false")

syntax Bool ::= "#@IsKeyword" "(" Var ")" [function]
rule #@IsKeyword(X:Var)
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

syntax Bool ::= "#@IsFutureReservedWord" "(" Var ")" [function]
rule #@IsFutureReservedWord(X:Var)
  =>      (X ==K "class")
   orBool (X ==K "const")
   orBool (X ==K "enum")
   orBool (X ==K "export")
   orBool (X ==K "extends")
   orBool (X ==K "import")
   orBool (X ==K "super")

syntax Bool ::= "#@IsFutureReservedWordInStrictMode" "(" Var ")" [function]
rule #@IsFutureReservedWordInStrictMode(X:Var)
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

syntax Reference    ::= "@Ref" "(" K /* Base */ "," K /* Var */ "," K /* Bool */ ")" [seqstrict]
syntax ReferenceVal ::= "@Ref" "("      Base    ","      Var    ","      Bool    ")"
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

syntax KItem /* Base */ ::= "GetBase" "(" K /* Reference */ ")" [seqstrict]
rule GetBase(@Ref(Base:Base,_,_)) => Base

syntax KItem /* Var */ ::= "GetReferencedName" "(" K /* Reference */ ")" [seqstrict]
rule GetReferencedName(@Ref(_,Name:Var,_)) => Name

syntax KItem /* Bool */ ::= "IsStrictReference" "(" K /* Reference */ ")" [seqstrict]
rule IsStrictReference(@Ref(_,_,Strict:Bool)) => Strict

syntax KItem /* Bool */ ::= "HasPrimitiveBase" "(" K /* Reference */ ")" [seqstrict]
rule HasPrimitiveBase(@Ref(Undefined, _,_)) => false
rule HasPrimitiveBase(@Ref(_:Primitive,_,_)) => true
rule HasPrimitiveBase(@Ref(_:Oid,      _,_)) => false
rule HasPrimitiveBase(@Ref(_:Eid,      _,_)) => false

syntax KItem /* Bool */ ::= "IsPropertyReference" "(" K /* Reference */ ")" [seqstrict]
rule IsPropertyReference(@Ref(Undefined, _,_)) => false
rule IsPropertyReference(@Ref(_:Primitive,_,_)) => true
rule IsPropertyReference(@Ref(_:Oid,      _,_)) => true
rule IsPropertyReference(@Ref(_:Eid,      _,_)) => false

syntax KItem /* Bool */ ::= "IsUnresolvableReference" "(" K /* Reference */ ")" [seqstrict]
rule IsUnresolvableReference(@Ref(Base:Base,_,_)) => Base ==K Undefined

// 8.7.1 GetValue (V)
// TODO: Do we need to consider step 1?

syntax KItem /* Val */ ::= "GetValue" "(" K /* Reference */ ")" [seqstrict]

rule GetValue(@Ref(E:Eid,      N:Var, Strict:Bool)) => GetBindingValue(E,N,Strict)
rule GetValue(@Ref(O:Oid,      P:Var, _          )) => Get(O,P)

rule GetValue(@Ref(Undefined, P:Var, _          )) => @Throw(@ReferenceError("GetValue",P))

/* NOTE: This does not work!!! [[Get]] with 'ToObject' differs from [[Get]] for Primitive base.
rule GetValue(@Ref(B:Bool,     P:Var, Strict:Bool)) => GetValue(@Ref(ToObject(B),P,Strict))
rule GetValue(@Ref(S:String,   P:Var, Strict:Bool)) => GetValue(@Ref(ToObject(S),P,Strict))
rule GetValue(@Ref(N:Number,   P:Var, Strict:Bool)) => GetValue(@Ref(ToObject(N),P,Strict))
*/

rule GetValue(@Ref(B:Primitive,P:Var, _          )) => GetPrimitive(B,P)

syntax KItem /* Val */ ::= "GetPrimitive" "(" K /* Primitive */ "," K /* Var */ ")" [seqstrict]
rule GetPrimitive(Base:Primitive,P:Var)
  => BEGIN
     Let $o = ToObject(Base);
     Let $desc = GetProperty($o,P);
     If $desc = Undefined then {
       Return Undefined;
     } else {
       If IsDataDescriptor($desc) = true then {
         Return $desc."Value";
       } else {
         Let $getter = $desc."Get";
         If $getter = Undefined then {
           Return Undefined;
         } else {
           Return Call($getter,Base,@Nil); // NOTE: Only difference from Get@Default: 'Base' is used, instead of '$o'.
         }
       }
     }
     END

// 8.7.2 PutValue (V, W)

// NOTE: Step 1 is covered by @GetReference that raise ReferenceError for non-reference expressions
syntax KItem /* .K */ ::= "PutValue" "(" K /* Reference */ "," K /* Val */ ")" [seqstrict]

rule PutValue(@Ref(E:Eid,      N:Var, Strict:Bool), V:Val) => SetMutableBinding(E,N,V,Strict) when (N =/=K "eval" andBool N =/=K "arguments") orBool Strict =/=K true
rule PutValue(@Ref(O:Oid,      P:Var, Strict:Bool), V:Val) => Put(O,         P,V,Strict)
rule PutValue(@Ref(Undefined, P:Var, false      ), V:Val) => Put(@GlobalOid,P,V,false)
rule PutValue(@Ref(Undefined, P:Var, true       ), _    ) => @Throw(@ReferenceError("PutValue",P))

// NOTE: Handled by this: 11.13.1 step 4, 11.13.2 step 6, 11.3.1, 11.3.2, 11.4.4, 11.4.5
rule PutValue(@Ref(_:Eid,      N:Var, true       ), _    ) => @Throw(@SyntaxError("PutValue",N)) when N ==K "eval" orBool N ==K "arguments"

/*
/* NOTE: This does not work!!! [[Put]] with 'ToObject' differs from [[Put]] for Primitive base.
rule PutValue(@Ref(B:Bool,     P:Var, Strict:Bool), V:Val) => PutValue(@Ref(ToObject(B),P,Strict),V)
rule PutValue(@Ref(S:String,   P:Var, Strict:Bool), V:Val) => PutValue(@Ref(ToObject(S),P,Strict),V)
rule PutValue(@Ref(N:Number,   P:Var, Strict:Bool), V:Val) => PutValue(@Ref(ToObject(N),P,Strict),V)
*/

rule PutValue(@Ref(B:Primitive,P:Var, Strict:Bool), V:Val) => PutPrimitive(B,P,V,Strict)

syntax KItem /* Val */ ::= "PutPrimitive" "(" K /* Primitive */ "," K /* Var */ "," K /* Val */ "," K /* Bool */ ")" [seqstrict]
rule PutPrimitive(Base:Primitive,P:Var,V:Val,Throw:Bool)
  => BEGIN
     Let $o = ToObject(Base);
     If CanPut($o,P) = false then {
       If Throw = true then {
         Do @Throw(@TypeError("PutPrimitive, cannot put",PutPrimitive(Base,P,V,Throw)));
       } else {
         Return;
       }
     } else {
       Let $ownDesc = GetOwnProperty($o,P);
       If IsDataDescriptor($ownDesc) = true then {
         // NOTE: different from [[Put]]: do not put value
         If Throw = true then {
           Do @Throw(@TypeError("PutPrimitive, own Desc is a data descriptor",PutPrimitive(Base,P,V,Throw)));
         } else {
           Return;
         }
       } else {
         Let $desc = GetProperty($o,P);
         If IsAccessorDescriptor($desc) = true then {
           Let $setter = $desc."Set";
           DoI Call($setter,Base,@Cons(V,@Nil)); // NOTE: different from [[Put]]: use 'Base' instead of '$o'
         } else {
           // NOTE: different from [[Put]]: do not put value
           If Throw = true then {
             Do @Throw(@TypeError("PutPrimitive, inherited Desc is a data descriptor",PutPrimitive(Base,P,V,Throw)));
           } else {
             Return;
           }
         }
       }
     }
     END

//////////////////////////////////////////////////////////////////////////////
// 8.10 The Property Descriptor and Property Identifier Specification Types
//////////////////////////////////////////////////////////////////////////////

// 8.10.1 IsAccessorDescriptor ( Desc )

syntax KItem /* Bool */ ::= "IsAccessorDescriptor" "(" K /* Val */ ")" [seqstrict]

rule IsAccessorDescriptor(Undefined) => false
rule IsAccessorDescriptor(@desc(Desc)) => ("Get" in keys(Desc)) orBool
                                           ("Set" in keys(Desc))

// 8.10.2 IsDataDescriptor ( Desc )

syntax KItem /* Bool */ ::= "IsDataDescriptor" "(" K /* Val */ ")" [seqstrict]

rule IsDataDescriptor(Undefined) => false
rule IsDataDescriptor(@desc(Desc)) => ("Value"    in keys(Desc)) orBool
                                       ("Writable" in keys(Desc))

// 8.10.3 IsGenericDescriptor ( Desc )

syntax KItem /* Bool */ ::= "IsGenericDescriptor" "(" K /* Val */ ")" [seqstrict]

rule IsGenericDescriptor(Undefined) => false
rule IsGenericDescriptor(@desc(Desc)) => notBool("Get"      in keys(Desc)) andBool
                                          notBool("Set"      in keys(Desc)) andBool
                                          notBool("Value"    in keys(Desc)) andBool
                                          notBool("Writable" in keys(Desc))

// 8.10.? IsValidDescriptor ( Desc )

syntax KItem /* Bool */ ::= "IsValidDescriptor" "(" K /* PropertyDescriptor */ ")" [seqstrict]

rule IsValidDescriptor(Desc:PropertyDescriptor) => @NotBool(@AndBool(IsAccessorDescriptor(Desc),IsDataDescriptor(Desc)))

// 8.10.? #IsFullyPopulatedDescriptor ( Desc )

syntax Bool ::= "#IsFullyPopulatedDescriptor" "(" PropertyDescriptor ")" [function]

rule #IsFullyPopulatedDescriptor(@desc(Desc)) => (keys(Desc) ==K SetItem("Get")   SetItem("Set")      SetItem("Enumerable") SetItem("Configurable"))
                                         orBool (keys(Desc) ==K SetItem("Value") SetItem("Writable") SetItem("Enumerable") SetItem("Configurable"))

// 8.10.? MakeFullyPopulatedDescriptor ( Desc )

syntax KItem /* PropertyDescriptor */ ::= "MakeFullyPopulatedDataDescriptor1" "(" K /* PropertyDescriptor */ ")" [seqstrict]
rule MakeFullyPopulatedDataDescriptor1(Desc:PropertyDescriptor) => MakeFullyPopulatedDataDescriptor2(Desc,@desc("Value" |-> Undefined "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false))

syntax KItem /* PropertyDescriptor */ ::= "MakeFullyPopulatedAccessorDescriptor1" "(" K /* PropertyDescriptor */ ")" [seqstrict]
rule MakeFullyPopulatedAccessorDescriptor1(Desc:PropertyDescriptor) => MakeFullyPopulatedAccessorDescriptor2(Desc,@desc("Get" |-> Undefined "Set" |-> Undefined "Enumerable" |-> false "Configurable" |-> false))

syntax KItem /* PropertyDescriptor */ ::= "MakeFullyPopulatedDataDescriptor2" "(" K /* PropertyDescriptor */ "," K /* PropertyDescriptor */ ")" [seqstrict]
rule MakeFullyPopulatedDataDescriptor2(@desc(Desc),Default:PropertyDescriptor) => MakeFullyPopulatedDataDescriptor2(@desc(#@AddMap("Value",       Default.."Value",       Desc)),Default) when notBool("Value"        in keys(Desc))
rule MakeFullyPopulatedDataDescriptor2(@desc(Desc),Default:PropertyDescriptor) => MakeFullyPopulatedDataDescriptor2(@desc(#@AddMap("Writable",    Default.."Writable",    Desc)),Default) when notBool("Writable"     in keys(Desc))
rule MakeFullyPopulatedDataDescriptor2(@desc(Desc),Default:PropertyDescriptor) => MakeFullyPopulatedDataDescriptor2(@desc(#@AddMap("Enumerable",  Default.."Enumerable",  Desc)),Default) when notBool("Enumerable"   in keys(Desc))
rule MakeFullyPopulatedDataDescriptor2(@desc(Desc),Default:PropertyDescriptor) => MakeFullyPopulatedDataDescriptor2(@desc(#@AddMap("Configurable",Default.."Configurable",Desc)),Default) when notBool("Configurable" in keys(Desc))
rule MakeFullyPopulatedDataDescriptor2(@desc(Desc),Default:PropertyDescriptor) => @desc(Desc) when #IsFullyPopulatedDescriptor(@desc(Desc))

syntax KItem /* PropertyDescriptor */ ::= "MakeFullyPopulatedAccessorDescriptor2" "(" K /* PropertyDescriptor */ "," K /* PropertyDescriptor */ ")" [seqstrict]
rule MakeFullyPopulatedAccessorDescriptor2(@desc(Desc),Default:PropertyDescriptor) => MakeFullyPopulatedAccessorDescriptor2(@desc(#@AddMap("Get",         Default.."Get",         Desc)),Default) when notBool("Get"          in keys(Desc))
rule MakeFullyPopulatedAccessorDescriptor2(@desc(Desc),Default:PropertyDescriptor) => MakeFullyPopulatedAccessorDescriptor2(@desc(#@AddMap("Set",         Default.."Set",         Desc)),Default) when notBool("Set"          in keys(Desc))
rule MakeFullyPopulatedAccessorDescriptor2(@desc(Desc),Default:PropertyDescriptor) => MakeFullyPopulatedAccessorDescriptor2(@desc(#@AddMap("Enumerable",  Default.."Enumerable",  Desc)),Default) when notBool("Enumerable"   in keys(Desc))
rule MakeFullyPopulatedAccessorDescriptor2(@desc(Desc),Default:PropertyDescriptor) => MakeFullyPopulatedAccessorDescriptor2(@desc(#@AddMap("Configurable",Default.."Configurable",Desc)),Default) when notBool("Configurable" in keys(Desc))
rule MakeFullyPopulatedAccessorDescriptor2(@desc(Desc),Default:PropertyDescriptor) => @desc(Desc) when #IsFullyPopulatedDescriptor(@desc(Desc))

// 8.10.4 FromPropertyDescriptor ( Desc )

syntax KItem /* Val */ ::= "FromPropertyDescriptor" "(" K /* PropertyDescriptor */ ")" [seqstrict]

rule FromPropertyDescriptor(Undefined) => Undefined

syntax Id ::= "$obj"

rule FromPropertyDescriptor(Desc:PropertyDescriptor)
  => BEGIN
     Let $obj = @CreateObject;
     If IsDataDescriptor(Desc) = true then {
       DoI DefineOwnProperty($obj, "value",      @desc("Value" |-> Desc.."Value"        "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
       DoI DefineOwnProperty($obj, "writable",   @desc("Value" |-> Desc.."Writable"     "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     } else /* IsAccessorDescriptor(Desc) = true */ {
       DoI DefineOwnProperty($obj, "get",        @desc("Value" |-> Desc.."Get"          "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
       DoI DefineOwnProperty($obj, "set",        @desc("Value" |-> Desc.."Set"          "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     }
     DoI DefineOwnProperty($obj, "enumerable",   @desc("Value" |-> Desc.."Enumerable"   "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     DoI DefineOwnProperty($obj, "configurable", @desc("Value" |-> Desc.."Configurable" "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false);
     Return $obj;
     END
     when #IsFullyPopulatedDescriptor(Desc)

// 8.10.5 ToPropertyDescriptor ( Obj )
// TODO: make it more elegant

syntax KItem /* PropertyDescriptor */ ::= "ToPropertyDescriptor" "(" K /* Val */ ")" [seqstrict]

rule ToPropertyDescriptor(V:Val) => @Throw(@TypeError("ToPropertyDescriptor",V)) when notBool(#@IsOid(V))

syntax Id ::= "$desc0" | "$desc1" | "$desc2" | "$desc3" | "$desc4" | "$desc5" | "$desc6"

rule ToPropertyDescriptor(O:Oid)
  => BEGIN
     Let $desc0 = @desc(.Map);
     Let $desc1 = ToPropertyDescriptorAux(O,"enumerable",  $desc0,"Enumerable");
     Let $desc2 = ToPropertyDescriptorAux(O,"configurable",$desc1,"Configurable");
     Let $desc3 = ToPropertyDescriptorAux(O,"value",       $desc2,"Value");
     Let $desc4 = ToPropertyDescriptorAux(O,"writable",    $desc3,"Writable");
     Let $desc5 = ToPropertyDescriptorAux(O,"get",         $desc4,"Get");
     Let $desc6 = ToPropertyDescriptorAux(O,"set",         $desc5,"Set");
     If IsValidDescriptor($desc6) = true then {
       Return $desc6;
     } else {
       Do @Throw(@TypeError("ToPropertyDescriptor InvalidDescriptor",$desc6));
     }
     END

syntax KItem /* PropertyDescriptor */ ::= "ToPropertyDescriptorAux" "(" K /* Oid */ "," K /* Var */ "," K /* PropertyDescriptor */ "," K /* String */ ")" [seqstrict]

syntax Id ::= "$value"

rule ToPropertyDescriptorAux(O:Oid,P:Var,Desc:PropertyDescriptor,Attr:String)
  => BEGIN
     If HasProperty(O,P) = true then {
       Let $value = ToBoolean(Get(O,P));
       Return @AddDesc(Attr, $value, Desc);
     } else {
       Return Desc;
     }
     END
     when (P ==K "enumerable"   andBool Attr ==K "Enumerable")
   orBool (P ==K "configurable" andBool Attr ==K "Configurable")
   orBool (P ==K "writable"     andBool Attr ==K "Writable")

rule ToPropertyDescriptorAux(O:Oid,P:Var,Desc:PropertyDescriptor,Attr:String)
  => BEGIN
     If HasProperty(O,P) = true then {
       Let $value = Get(O,P);
       Return @AddDesc(Attr, $value, Desc);
     } else {
       Return Desc;
     }
     END
     when P ==K "value" andBool Attr ==K "Value"

rule ToPropertyDescriptorAux(O:Oid,P:Var,Desc:PropertyDescriptor,Attr:String)
  => BEGIN
     If HasProperty(O,P) = true then {
       Let $value = Get(O,P);
       If IsCallable($value) = true then {
         Nop;
       } else {
         If $value = Undefined then {
           Nop;
         } else {
           Do @Throw(@TypeError("ToPropertyDescriptorAux",$value));
         }
       }
       Return @AddDesc(Attr, $value, Desc);
     } else {
       Return Desc;
     }
     END
     when (P ==K "get" andBool Attr ==K "Get")
   orBool (P ==K "set" andBool Attr ==K "Set")

//////////////////////////////////////////////////////////////////////////////
// 8.12 Algorithms for Object Internal Methods
//////////////////////////////////////////////////////////////////////////////

// 8.12.1 [[GetOwnProperty]] (P)

syntax KItem /* Val */ ::= "GetOwnProperty" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict]

rule GetOwnProperty(O:Oid,P:Var)
  => BEGIN
     If @IsArgumentsObjectNonStrictWithFormalParams(O) = true then {
       Do GetOwnProperty@Arguments(O,P);
     } else {
       If @IsStringObject(O) = true then {
         Do GetOwnProperty@String(O,P);
       } else {
         Do GetOwnProperty@Default(O,P);
       }
     }
     END

syntax KItem /* Val */ ::= "GetOwnProperty@Default" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict]

rule <k> GetOwnProperty@Default(O:Oid,P:Var) => V ... </k>
     <obj>
       <oid> O </oid>
       <properties> P |-> V:Val _:Map </properties>
       _
     </obj>
rule <k> GetOwnProperty@Default(O:Oid,P:Var) => Undefined ... </k>
     <obj>
       <oid> O </oid>
       <properties> Prop:Map </properties>
       _
     </obj>
     when notBool(P in keys(Prop))

// 8.12.? [[GetInternalProperty]] (P)

syntax KItem /* Val */ ::= "GetInternalProperty" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict]

rule <k> GetInternalProperty(O:Oid,P:Var) => V ... </k>
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

syntax KItem /* .K */ ::= "SetInternalProperty" "(" K /* Oid */ "," K /* Var */ "," K /* Val */ ")" [seqstrict]

rule <k> SetInternalProperty(O:Oid,P:Var,V:Val) => . ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties> Prop:Map => #@AddMap(P,V,Prop) </internalProperties>
       _
     </obj>

// 8.12.? [[GetInheritedProperty]] (P)

syntax KItem /* Val */ ::= "GetInheritedProperty" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict]

rule <k> GetInheritedProperty(O:Oid,P:Var) => GetProperty(O',P) ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties> "Prototype" |-> O':Oid _:Map </internalProperties>
       _
     </obj>
     when O' =/=K @NullOid
rule <k> GetInheritedProperty(O:Oid,_) => Undefined ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties> "Prototype" |-> @NullOid _:Map </internalProperties>
       _
     </obj>

// 8.12.? [[GetInheritedPropertyOwner]] (P)

syntax KItem /* Val */ ::= "GetInheritedPropertyOwner" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict]

rule <k> GetInheritedPropertyOwner(O:Oid,P:Var) => GetPropertyOwner(O',P) ... </k>
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

syntax KItem /* Val */ ::= "GetProperty" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict]

syntax Id ::= "$prop"
rule GetProperty(O:Oid,P:Var)
  => BEGIN
     Let $prop = GetOwnProperty(O,P);
     If $prop = Undefined then {
       Return GetInheritedProperty(O,P);
     } else {
       Return $prop;
     }
     END

// 8.12.? [[GetPropertyOwner]] (P)

syntax KItem /* Val */ ::= "GetPropertyOwner" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict]

rule GetPropertyOwner(O:Oid,P:Var)
  => BEGIN
     Let $prop = GetOwnProperty(O,P);
     If $prop = Undefined then {
       Return GetInheritedPropertyOwner(O,P);
     } else {
       Return O;
     }
     END

// 8.12.3 [[Get]] (P)

syntax KItem /* Val */ ::= "Get" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict]

rule Get(O:Oid,P:Var)
  => BEGIN
     If @IsArgumentsObjectNonStrictWithFormalParams(O) = true then {
       Do Get@Arguments(O,P);
     } else {
       Do Get@Default(O,P);
     }
     END

syntax KItem /* Val */ ::= "Get@Default" "(" K /* Oid */ "," K /* Var */ ")"  [seqstrict]

syntax Id ::= "$desc" | "$getter"
rule Get@Default(O:Oid,P:Var)
  => BEGIN
     Let $desc = GetProperty(O,P);
     If $desc = Undefined then {
       Return Undefined;
     } else {
       If IsDataDescriptor($desc) = true then {
         Return $desc."Value";
       } else {
         Let $getter = $desc."Get";
         If $getter = Undefined then {
           Return Undefined;
         } else {
           Return Call($getter,O,@Nil);
         }
       }
     }
     END

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

syntax KItem /* Bool */ ::= "CanPut" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict]

syntax Id ::= "$proto" | "$inherited"
rule CanPut(O:Oid,P:Var)
  => BEGIN
     Let $desc = GetOwnProperty(O,P);
     If $desc = Undefined then {
       Let $proto = GetInternalProperty(O,"Prototype");
       If $proto = @NullOid then {
         Return GetInternalProperty(O,"Extensible");
       } else {
         Let $inherited = GetProperty($proto,P);
         If $inherited = Undefined then {
           Return GetInternalProperty(O,"Extensible");
         } else {
           If IsAccessorDescriptor($inherited) = true then {
             If $inherited."Set" = Undefined then {
               Return false;
             } else {
               Return true;
             }
           } else {
             If GetInternalProperty(O,"Extensible") = false then {
               Return false;
             } else {
               Return $inherited."Writable";
             }
           }
         }
       }
     } else {
       If IsAccessorDescriptor($desc) = true then {
         If $desc."Set" = Undefined then {
           Return false;
         } else {
           Return true;
         }
       } else {
         Return $desc."Writable";
       }
     }
     END

// 8.12.5 [[Put]] ( P, V, Throw )

syntax KItem /* .K */ ::= "Put" "(" K /* Oid */ "," K /* Var */ "," K /* Val */ "," K /* Bool */ ")" [seqstrict]

syntax Id ::= "$ownDesc" | "$valueDesc" | "$setter" | "$newDesc"
rule Put(O:Oid,P:Var,V:Val,Throw:Bool)
  => BEGIN
     If CanPut(O,P) = false then {
       If Throw = true then {
         Do @Throw(@TypeError("Put",Put(O,P,V,Throw)));
       } else {
         Return;
       }
     } else {
       Let $ownDesc = GetOwnProperty(O,P);
       If IsDataDescriptor($ownDesc) = true then {
         Let $valueDesc = @desc("Value" |-> V);
         DoI DefineOwnProperty(O,P,$valueDesc,Throw);
       } else {
         Let $desc = GetProperty(O,P);
         If IsAccessorDescriptor($desc) = true then {
           Let $setter = $desc."Set";
           DoI Call($setter,O,@Cons(V,@Nil));
         } else {
           Let $newDesc = @desc("Value" |-> V "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true);
           DoI DefineOwnProperty(O,P,$newDesc,Throw);
         }
       }
     }
     END

// 8.12.? [[HasOwnProperty]] (P)

syntax KItem /* Bool */ ::= "HasOwnProperty" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict]

rule HasOwnProperty(O:Oid,P:Var)
  => BEGIN
     If GetOwnProperty(O,P) = Undefined then {
       Return false;
     } else {
       Return true;
     }
     END

// 8.12.6 [[HasProperty]] (P)

syntax KItem /* Bool */ ::= "HasProperty" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict]

rule HasProperty(O:Oid,P:Var)
  => BEGIN
     If GetProperty(O,P) = Undefined then {
       Return false;
     } else {
       Return true;
     }
     END

// 8.12.7 [[Delete]] (P, Throw)

syntax KItem /* Bool */ ::= "Delete" "(" K /* Oid */ "," K /* Var */ "," K /* Bool */ ")" [seqstrict]

rule Delete(O:Oid,P:Var,Throw:Bool)
  => BEGIN
     If @IsArgumentsObjectNonStrictWithFormalParams(O) = true then {
       Do Delete@Arguments(O,P,Throw);
     } else {
       Do Delete@Default(O,P,Throw);
     }
     END

syntax KItem /* Bool */ ::= "Delete@Default" "(" K /* Oid */ "," K /* Var */ "," K /* Bool */ ")"  [seqstrict]

rule <k> Delete@Default(O:Oid,P:Var,Throw:Bool) => true ... </k>
     <obj>
       <oid> O </oid>
       <properties> Prop:Map </properties>
       _
     </obj>
     when notBool(P in keys(Prop))
rule <k> Delete@Default(O:Oid,P:Var,Throw:Bool) => true ... </k>
     <obj>
       <oid> O </oid>
       <properties>
         (P |-> @desc("Configurable" |-> true _) => .Map)
         _:Map
       </properties>
       _
     </obj>
rule <k> Delete@Default(O:Oid,P:Var,Throw:Bool) => Reject(Throw,"Delete@Default",Delete@Default(O,P,Throw)) ... </k>
     <obj>
       <oid> O </oid>
       <properties>
         P |-> @desc("Configurable" |-> false _)
         _:Map
       </properties>
       _
     </obj>

// 8.12.8 [[DefaultValue]] (hint)

syntax KItem /* Val */ ::= "DefaultValue" "(" K /* Oid */ "," K /* String */ ")"  [seqstrict]
// TODO: Can we make it more elegant?

syntax Id ::= "$toString" | "$valueOf" | "$str" | "$val"

rule DefaultValue(O:Oid,"String")
  => BEGIN
     Let $toString = Get(O,"toString");
     If IsCallable($toString) = true then {
       Let $str = Call($toString,O,@Nil);
       If @IsPrimitive($str) = true then {
         Return $str; Exit;
       };
     };
     Let $valueOf = Get(O,"valueOf");
     If IsCallable($valueOf) = true then {
       Let $val = Call($valueOf,O,@Nil);
       If @IsPrimitive($val) = true then {
         Return $val; Exit;
       };
     };
     Do @Throw(@TypeError("DefaultValue String",O));
     END

rule DefaultValue(O:Oid,"Number")
  => BEGIN
     Let $valueOf = Get(O,"valueOf");
     If IsCallable($valueOf) = true then {
       Let $val = Call($valueOf,O,@Nil);
       If @IsPrimitive($val) = true then {
         Return $val; Exit;
       };
     };
     Let $toString = Get(O,"toString");
     If IsCallable($toString) = true then {
       Let $str = Call($toString,O,@Nil);
       If @IsPrimitive($str) = true then {
         Return $str; Exit;
       };
     };
     Do @Throw(@TypeError("DefaultValue Number",O));
     END

rule <k> DefaultValue(O:Oid,"") => DefaultValue(O,"String") ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties> "Class" |-> "Date" _:Map </internalProperties>
       _
     </obj>

rule <k> DefaultValue(O:Oid,"") => DefaultValue(O,"Number") ... </k>
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

syntax KItem /* Bool */ ::= "DefineOwnProperty" "(" K /* Oid */ "," K /* Var */ "," K /* PropertyDescriptor */ "," K /* Bool */ ")" [seqstrict]

rule DefineOwnProperty(O:Oid,P:Var,Desc:PropertyDescriptor,Throw:Bool)
  => BEGIN
     If @IsArgumentsObjectNonStrictWithFormalParams(O) = true then {
       Do DefineOwnProperty@Arguments(O,P,Desc,Throw);
     } else {
       If @IsArrayObject(O) = true then {
         Do DefineOwnProperty@Array(O,P,Desc,Throw);
       } else {
         Do DefineOwnProperty@Default(O,P,Desc,Throw);
       }
     }
     END

syntax KItem /* Bool */ ::= "DefineOwnProperty@Default" "(" K /* Oid */ "," K /* Var */ "," K /* PropertyDescriptor */ "," K /* Bool */ ")" [seqstrict]

syntax Id ::= "$current" | "$current2" | "$extensible"
rule DefineOwnProperty@Default(O:Oid,P:Var,Desc:PropertyDescriptor,Throw:Bool)
  => BEGIN
   //Do @LOG(DefineOwnProperty@Default(O,P,Desc,Throw));
     Let $current = GetOwnProperty(O,P);
   //Do @LOG($current);
   //Do @LOG(IsDataDescriptor($current));
   //Do @LOG(IsDataDescriptor(Desc));
     Let $extensible = GetInternalProperty(O,"Extensible");
     If $current = Undefined then {
       If $extensible = false then {
         Return Reject(Throw,"DefineOwnProperty@Default not extensible",DefineOwnProperty@Default(O,P,Desc,Throw)); Exit;
       } else {
         If @OrBool(IsGenericDescriptor(Desc), IsDataDescriptor(Desc)) = true then {
         //Do @LOG("Data");
         //Do @LOG(Desc);
           Do SetOwnProperty(O,P,MakeFullyPopulatedDataDescriptor1(Desc));
         } else {
         //Do @LOG("Accessor");
         //Do @LOG(Desc);
           Do SetOwnProperty(O,P,MakeFullyPopulatedAccessorDescriptor1(Desc));
         }
         Return true;
       }
     } else {
//     If @SubDesc(Desc,$current) = true then { // NOTE: Redundant: It is safe even if it proceeds along the way.
//       Return true;
//     } else {
         If $current."Configurable" = false then {
           If Desc."Configurable" = true then {
             Return Reject(Throw,"DefineOwnProperty@Default conflict configurable",DefineOwnProperty@Default(O,P,Desc,Throw)); Exit;
           };
           If @OrBool(@AndBool(@EqVal($current."Enumerable", true ), @EqVal(Desc."Enumerable", false)),
                       @AndBool(@EqVal($current."Enumerable", false), @EqVal(Desc."Enumerable", true ))) = true then {
             Return Reject(Throw,"DefineOwnProperty@Default conflict enumerable",DefineOwnProperty@Default(O,P,Desc,Throw)); Exit;
           };
         };
         If IsGenericDescriptor(Desc) = true then {
           Nop;
         } else {
           If @OrBool(@AndBool(IsDataDescriptor($current), IsAccessorDescriptor(Desc)),
                       @AndBool(IsAccessorDescriptor($current), IsDataDescriptor(Desc))) = true then {
             If $current."Configurable" = false then {
               Return Reject(Throw,"DefineOwnProperty@Default conflict descriptor type",DefineOwnProperty@Default(O,P,Desc,Throw)); Exit;
             };
           //Do @LOG("convert");
             Do ConvertDescriptorType(O,P);
           } else {
             If @AndBool(IsDataDescriptor($current), IsDataDescriptor(Desc)) = true then {
               If $current."Configurable" = false then {
                 If @AndBool(@EqVal($current."Writable", false), @EqVal(Desc."Writable", true)) = true then {
                   Return Reject(Throw,"DefineOwnProperty@Default conflict writable",DefineOwnProperty@Default(O,P,Desc,Throw)); Exit;
                 };
                 If @AndBool(@AndBool(@EqVal($current."Writable", false), @NeqVal(Desc."Value", Undefined)), @NotBool(SameValue(Desc."Value",$current."Value"))) = true then {
                   Return Reject(Throw,"DefineOwnProperty@Default not writable",DefineOwnProperty@Default(O,P,Desc,Throw)); Exit;
                 };
               };
             } else {
               If $current."Configurable" = false then {
                 If @AndBool(@NeqVal(Desc."Set", Undefined), @NotBool(SameValue(Desc."Set",$current."Set"))) = true then {
                   Return Reject(Throw,"DefineOwnProperty@Default conflict set",DefineOwnProperty@Default(O,P,Desc,Throw)); Exit;
                 };
                 If @AndBool(@NeqVal(Desc."Get", Undefined), @NotBool(SameValue(Desc."Get",$current."Get"))) = true then {
                   Return Reject(Throw,"DefineOwnProperty@Default conflict get",DefineOwnProperty@Default(O,P,Desc,Throw)); Exit;
                 };
               };
             }
           }
         }
         Let $current2 = GetOwnProperty@Default(O,P);
         If @OrBool(IsGenericDescriptor($current2), IsDataDescriptor($current2)) = true then {
         //Do @LOG("Data");
         //Do @LOG(Desc);
         //Do @LOG($current2);
           Do SetOwnProperty(O,P,MakeFullyPopulatedDataDescriptor2(Desc,$current2));
         } else {
         //Do @LOG("Accessor");
         //Do @LOG(Desc);
         //Do @LOG($current2);
           Do SetOwnProperty(O,P,MakeFullyPopulatedAccessorDescriptor2(Desc,$current2));
         }
         Return true;
//     }
     }
     END

syntax KItem /* .K */ ::= "ConvertDescriptorType" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict]
rule <k> ConvertDescriptorType(O:Oid,P:Var) => . ... </k>
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
rule <k> ConvertDescriptorType(O:Oid,P:Var) => . ... </k>
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

syntax KItem /* .K */ ::= "SetOwnProperty" "(" K /* Oid */ "," K /* Var */ "," K /* Val */ ")" [seqstrict]
rule <k> SetOwnProperty(O:Oid,P:Var,V:Val) => . ... </k>
     <obj>
       <oid> O </oid>
       <properties> Prop:Map => #@AddMap(P,V,Prop) </properties>
       _
     </obj>

syntax KItem /* Bool */ ::= "Reject" "(" K /* Bool */ "," K /* String */ "," K ")" [seqstrict(1,2)]
rule Reject(true, S:String,K:K) => @Throw(@TypeError("Reject" +String S, K))
rule Reject(false,_,       _  ) => false

//////////////////////////////////////////////////////////////////////////////
// 9 Type Conversion and Testing
//////////////////////////////////////////////////////////////////////////////

// 9.1 ToPrimitive

syntax KItem /* Val */ ::= "ToPrimitive" "(" K /* Val */ "," K /* String */ ")" [seqstrict]

rule ToPrimitive(Undefined,               _) => Undefined
rule ToPrimitive(@NullVal,                 _) => @NullVal
rule ToPrimitive(B:Bool,                   _) => B
rule ToPrimitive(S:String,                 _) => S
rule ToPrimitive(N:Number,                 _) => N
rule ToPrimitive(O:Oid, PreferredType:String) => DefaultValue(O,PreferredType)

// 9.2 ToBoolean

syntax KItem /* Bool */ ::= "ToBoolean" "(" K /* Val */ ")" [seqstrict]

rule ToBoolean(Undefined) => false
rule ToBoolean(@NullVal  ) => false
rule ToBoolean(B:Bool    ) => B
rule ToBoolean(S:String  ) => true when S =/=String ""
rule ToBoolean(""        ) => false
rule ToBoolean(N:Number  ) => true when N =/=K 0 andBool N =/=K @NaN andBool N =/=K @nz
rule ToBoolean(0         ) => false
rule ToBoolean(@nz       ) => false
rule ToBoolean(@NaN      ) => false
rule ToBoolean(O:Oid     ) => true

// 9.3 ToNumber

syntax KItem /* Number */ ::= "ToNumber" "(" K /* Val */ ")" [seqstrict]

rule ToNumber(Undefined) => @NaN
rule ToNumber(@NullVal  ) => 0
rule ToNumber(true      ) => 1
rule ToNumber(false     ) => 0
rule ToNumber(S:String  ) => @StringToNumber(trim(replaceAll(S,"\n","")))
rule ToNumber(N:Number  ) => N
rule ToNumber(O:Oid     ) => ToNumber(ToPrimitive(O,"Number"))

// 9.3.1 ToNumber Applied to the String Type

syntax KItem /* Bool */ ::= "@IsStrNumericLiteral" "(" K /* String */ ")" [seqstrict]
rule @IsStrNumericLiteral(N:String) => @IsStrNumericLiteralAux(#parse(N,"StrNumericLiteral"))

syntax KItem /* Bool */ ::= "@IsStrNumericLiteralAux" "(" K /* StrNumericLiteral or IOError */ ")" // nostrict
rule @IsStrNumericLiteralAux(K) => isStrNumericLiteral(K) ==K true
/*
rule @IsStrNumericLiteralAux(_:StrNumericLiteral) => true
rule @IsStrNumericLiteralAux(#noparse) => false
*/

syntax KItem /* Number */ ::= "@StringToNumber" "(" K /* String */ ")" [seqstrict]
syntax Id ::= "$isMinus" | "$num" | "$num2"
rule @StringToNumber(S:String)
  => BEGIN
     If lengthString(S) ==Int 0 = true then {
       Return 0;
     } else {
       If @IsStrNumericLiteral(S) = true then {
         Let $isMinus = @IsMinus(S);
         Let $str = @RemoveLeadingZeros(@RemoveLeadingSign(S));
         Let $num = @ResolveOverflow(@StringToNumber@Core($str));
         If $isMinus = true then {
           Return @Bop(%times, -1, $num);
         } else {
           Return $num;
         }
       } else {
         Return @NaN;
       }
     }
     END

syntax KItem /* Number */ ::= "@StringToNumber@Core" "(" K /* String */ ")" [seqstrict]
syntax Id ::= "$s"
rule @StringToNumber@Core(S:String)
  => BEGIN
     If S = "Infinity" then {
       Return @+Infinity;
     } else {
       If @IsHexIntegerLiteral(S) = true then {
         Let $s = @SubstrString(S,1,lengthString(S));
         Return @String2Base($s, 16);
       } else {
         If @IsFloatLiteral(S) = true then {
           Return @String2Float(S);
         } else {
           Return @String2Int(S);
         }
       }
     }
     END

syntax KItem /* Bool */ ::= "@IsMinus" "(" K /* String */ ")" [seqstrict]
rule @IsMinus(S:String) => substrString(S,0,1) ==String "-"

syntax KItem /* String */ ::= "@RemoveLeadingSign" "(" K /* String */ ")" [seqstrict]
syntax Id ::= "$prefix"
rule @RemoveLeadingSign(S:String)
  => BEGIN
     If lengthString(S) >=Int 2 = true then {
       Let $prefix = @SubstrString(S,0,1);
       If @OrBool(@EqVal($prefix,"+"), @EqVal($prefix,"-")) = true then {
         Return @SubstrString(S,1,lengthString(S));
       } else {
         Return S;
       }
     } else {
       Return S;
     }
     END

syntax KItem /* String */ ::= "@RemoveLeadingZeros" "(" K /* String */ ")" [seqstrict]
rule @RemoveLeadingZeros(S:String)
  => BEGIN
     If lengthString(S) >=Int 2 = true then {
       If @SubstrString(S,0,1) = "0" then {
         If @SubstrString(S,1,2) = "." then {
           Return S;
         } else {
           Return @RemoveLeadingZeros(@SubstrString(S,1,lengthString(S)));
         }
       } else {
         Return S;
       }
     } else {
       Return S;
     }
     END

syntax KItem /* Bool */ ::= "@IsHexIntegerLiteral" "(" K /* String */ ")" [seqstrict]
rule @IsHexIntegerLiteral(S:String) => substrString(S,0,1) ==String "x"
                                orBool substrString(S,0,1) ==String "X"

syntax KItem /* Bool */ ::= "@IsFloatLiteral" "(" K /* String */ ")" [seqstrict]
rule @IsFloatLiteral(S:String) => @OrBool(@HasPoint(S), @HasExponentPart(S))

syntax KItem /* Bool */ ::= "@HasExponentPart" "(" K /* String */ ")" [seqstrict]
rule @HasExponentPart(S:String) => findString(S, "e", 0) =/=Int -1
                            orBool findString(S, "E", 0) =/=Int -1

syntax KItem /* Bool */ ::= "@HasPoint" "(" K /* String */ ")" [seqstrict]
rule @HasPoint(S:String) => findString(S, ".", 0) =/=Int -1

// 9.4 ToInteger

syntax KItem /* Val */ ::= "ToInteger" "(" K /* Val */ ")" [seqstrict]

rule ToInteger(V:Val) => @NumberToInteger(ToNumber(V))

// TODO: Do more correctly
syntax KItem /* Int */ ::= "@NumberToInteger" "(" K /* Number */ ")" [seqstrict]
rule @NumberToInteger(I:Int  ) => I
rule @NumberToInteger(F:Float) => Float2Int(F)
rule @NumberToInteger(@nz    ) => @nz
rule @NumberToInteger(@NaN   ) => 0
rule @NumberToInteger(@+Infinity) => @+Infinity
rule @NumberToInteger(@-Infinity) => @-Infinity

// 9.5 ToInt32: (Signed 32 Bit Integer)

syntax KItem /* Int32 */ ::= "ToInt32" "(" K /* Val */ ")" [seqstrict]

rule ToInt32(V:Val) => @NumberToInt32(ToNumber(V))

syntax KItem /* Int32 */ ::= "@NumberToInt32" "(" K /* Number */ ")" [seqstrict]
rule @NumberToInt32(I:Int  )    => @IntToInt32(I)
rule @NumberToInt32(F:Float)    => @IntToInt32(Float2Int(F))
rule @NumberToInt32(@nz    )    => 0
rule @NumberToInt32(@NaN   )    => 0
rule @NumberToInt32(@+Infinity) => 0
rule @NumberToInt32(@-Infinity) => 0

syntax KItem /* Int32 */ ::= "@IntToInt32" "(" K /* Int */ ")" [seqstrict]
rule @IntToInt32(I:Int) => svalueMInt(mi(32,I))

// 9.6 ToUint32: (Unsigned 32 Bit Integer)

syntax KItem /* Val */ ::= "ToUint32" "(" K /* Val */ ")" [seqstrict]

rule ToUint32(V:Val) => @NumberToUint32(ToNumber(V))

syntax KItem /* Int32 */ ::= "@NumberToUint32" "(" K /* Number */ ")" [seqstrict]
rule @NumberToUint32(I:Int  )    => @IntToUint32(I)
rule @NumberToUint32(F:Float)    => @IntToUint32(Float2Int(F))
rule @NumberToUint32(@nz    )    => 0
rule @NumberToUint32(@NaN   )    => 0
rule @NumberToUint32(@+Infinity) => 0
rule @NumberToUint32(@-Infinity) => 0

syntax KItem /* Uint32 */ ::= "@IntToUint32" "(" K /* Int */ ")" [seqstrict]
rule @IntToUint32(I:Int) => uvalueMInt(mi(32,I))

// 9.7 ToUint16: (Unsigned 16 Bit Integer)

syntax KItem /* Val */ ::= "ToUint16" "(" K /* Val */ ")" [seqstrict]

rule ToUint16(V:Val) => @NumberToUint16(ToNumber(V))

syntax KItem /* Int32 */ ::= "@NumberToUint16" "(" K /* Number */ ")" [seqstrict]
rule @NumberToUint16(I:Int  )    => @IntToUint16(I)
rule @NumberToUint16(F:Float)    => @IntToUint16(Float2Int(F))
rule @NumberToUint16(@nz    )    => 0
rule @NumberToUint16(@NaN   )    => 0
rule @NumberToUint16(@+Infinity) => 0
rule @NumberToUint16(@-Infinity) => 0

syntax KItem /* Uint16 */ ::= "@IntToUint16" "(" K /* Int */ ")" [seqstrict]
rule @IntToUint16(I:Int) => uvalueMInt(mi(16,I))

// 9.8 ToString

syntax KItem /* Val */ ::= "ToString" "(" K /* Val */ ")" [seqstrict]

rule ToString(Undefined) => "undefined"
rule ToString(@NullVal  ) => "null"
rule ToString(true      ) => "true"
rule ToString(false     ) => "false"
rule ToString(S:String  ) => S
rule ToString(I:Int     ) => #external("node\x01-p\x01-e\x01String(" +String Int2String(I)   +String ")")
rule ToString(F:Float   ) => #external("node\x01-p\x01-e\x01String(" +String Float2String(F) +String ")")
rule ToString(@nz       ) => "0"
rule ToString(@NaN      ) => "NaN"
rule ToString(@+Infinity) =>  "Infinity"
rule ToString(@-Infinity) => "-Infinity"
rule ToString(O:Oid     ) => ToString(ToPrimitive(O,"String"))

// 9.9 ToObject

syntax KItem /* Val */ ::= "ToObject" "(" K /* Val */ ")" [seqstrict]

rule ToObject(Undefined) => @Throw(@TypeError("ToObject","Undefined"))
rule ToObject(@NullVal  ) => @Throw(@TypeError("ToObject","Null"))
rule ToObject(B:Bool    ) => @NewBoolean(@Cons(B,@Nil))
rule ToObject(S:String  ) => @NewString(@Cons(S,@Nil))
rule ToObject(N:Number  ) => @NewNumber(@Cons(N,@Nil))
rule ToObject(O:Oid) => O

// 9.10 CheckObjectCoercible

syntax KItem /* .K */ ::= "CheckObjectCoercible" "(" K /* Val */ ")" [seqstrict]
rule <k> CheckObjectCoercible(V:Val) => . ... </k>
     when (V =/=K Undefined) andBool
          (V =/=K @NullVal)
rule CheckObjectCoercible(Undefined) => @Throw(@TypeError("CheckObjectCoercible","Undefined"))
rule CheckObjectCoercible(@NullVal  ) => @Throw(@TypeError("CheckObjectCoercible","Null"))

// 9.11 IsCallable

syntax KItem /* Bool */ ::= "IsCallable" "(" K /* Val */ ")" [seqstrict]

rule IsCallable(Undefined) => false
rule IsCallable(@NullVal  ) => false
rule IsCallable(B:Bool    ) => false
rule IsCallable(S:String  ) => false
rule IsCallable(N:Number  ) => false
rule <k> IsCallable(O:Oid ) => Class ==K "Function" ... </k> // TODO: Do more correctly
     <obj>
       <oid> O </oid>
       <internalProperties> "Class" |-> Class:String _:Map </internalProperties>
       _
     </obj>
rule IsCallable(@(_)) => true

// 9.12 The SameValue Algorithm

syntax KItem /* Bool */ ::= "SameValue" "(" K /* Val */ "," K /* Val */ ")" [seqstrict]

// TODO: Do more correctly Step 4 of Number
rule SameValue(V1:Val,V2:Val) => V1 ==K V2 when notBool(isInt(V1)   ==K true andBool isFloat(V2) ==K true)
                                         andBool notBool(isFloat(V1) ==K true andBool isInt(V2)   ==K true)
rule SameValue(I1:Int,  F2:Float) => #@Int2Float(I1) ==Float F2
rule SameValue(F1:Float,I2:Int  ) =>            F1 ==Float #@Int2Float(I2)

//////////////////////////////////////////////////////////////////////////////
// 10.2.1 Environment Records
//////////////////////////////////////////////////////////////////////////////

syntax KItem /* Bool */ ::= "HasBinding" "(" K /* Eid */ "," K /* Var */ ")" [seqstrict]
// 10.2.1.1.1 HasBinding(N)
rule <k> HasBinding(E:Eid,N:Var) => N in keys(Record) ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> Record:Map </declEnvRec>
       _
     </env>
// 10.2.1.2.1 HasBinding(N)
rule <k> HasBinding(E:Eid,N:Var) => HasProperty(O,N) ... </k>
     <env>
       <eid> E </eid>
       <objEnvRec>
         <bindingObj> O:Oid </bindingObj>
         _
       </objEnvRec>
       _
     </env>

syntax KItem /* .K */ ::= "CreateMutableBinding" "(" K /* Eid */ "," K /* Var */ "," K /* Bool */ ")"  [seqstrict]
// 10.2.1.1.2 CreateMutableBinding (N, D)
rule <k> CreateMutableBinding(E:Eid,N:Var,D:Bool) => . ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> (.Map => N |-> @ve(Undefined,false,true,D)) Record:Map </declEnvRec>
       _
     </env>
     when notBool(N in keys(Record))
// 10.2.1.2.2 CreateMutableBinding (N, D)
rule <k> CreateMutableBinding(E:Eid,N:Var,D:Bool)
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

syntax KItem /* .K */ ::= "SetMutableBinding" "(" K /* Eid */ "," K /* Var */ "," K /* Val */ "," K /* Bool */ ")" [seqstrict]
// 10.2.1.1.3 SetMutableBinding (N,V,S)
rule <k> SetMutableBinding(E:Eid,N:Var,V:Val,S:Bool) => . ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> N |-> @ve((_ => V),(_ => true),true,_) _:Map </declEnvRec>
       _
     </env>
rule <k> SetMutableBinding(E:Eid,N:Var,_:Val,true) => @Throw(@TypeError("SetMutableBinding",N)) ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> N |-> @ve(_,_,false,_) _:Map </declEnvRec>
       _
     </env>
rule <k> SetMutableBinding(E:Eid,N:Var,_:Val,false) => . ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> N |-> @ve(_,_,false,_) _:Map </declEnvRec>
       _
     </env>
// 10.2.1.2.3 SetMutableBinding (N,V,S)
rule <k> SetMutableBinding(E:Eid,N:Var,V:Val,S:Bool) => Put(O,N,V,S) ... </k>
     <env>
       <eid> E </eid>
       <objEnvRec>
         <bindingObj> O:Oid </bindingObj>
         _
       </objEnvRec>
       _
     </env>

syntax KItem /* Val */ ::= "GetBindingValue" "(" K /* Eid */ "," K /* Var */ "," K /* Bool */ ")"  [seqstrict]
// 10.2.1.1.4 GetBindingValue(N,S)
rule <k> GetBindingValue(E:Eid,N:Var,S:Bool) => V ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> N |-> @ve(V:Val,Initialized:Bool,Mutable:Bool,_) _:Map </declEnvRec>
       _
     </env>
     when notBool(Initialized ==K false andBool Mutable ==K false)
rule <k> GetBindingValue(E:Eid,N:Var,S:Bool)
      => BEGIN
         If S = true then {
           Do @Throw(@ReferenceError("GetBindingValue, DeclEnv", N));
         } else {
           Return Undefined;
         }
         END
      ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> N |-> @ve(_,false,false,_) _:Map </declEnvRec>
       _
     </env>
// 10.2.1.2.4 GetBindingValue(N,S)
rule <k> GetBindingValue(E:Eid,N:Var,S:Bool)
      => BEGIN
         If HasProperty(O,N) = true then {
           Return Get(O,N);
         } else {
           If S = true then {
             Do @Throw(@ReferenceError("GetBindingValue, ObjEnv", N));
           } else {
             Return Undefined;
           }
         } 
         END
     ... </k>
     <env>
       <eid> E </eid>
       <objEnvRec>
         <bindingObj> O:Oid </bindingObj>
         _
       </objEnvRec>
       _
     </env>

syntax KItem /* Bool */ ::= "DeleteBinding" "(" K /* Eid */ "," K /* Var */ ")"  [seqstrict]
// 10.2.1.1.5 DeleteBinding (N)
rule <k> DeleteBinding(E:Eid,N:Var) => true ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> (N |-> @ve(_,_,_,true) => .Map) _:Map </declEnvRec>
       _
     </env>
rule <k> DeleteBinding(E:Eid,N:Var) => false ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> N |-> @ve(_,_,_,false) _:Map </declEnvRec>
       _
     </env>
rule <k> DeleteBinding(E:Eid,N:Var) => true ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> Record:Map </declEnvRec>
       _
     </env>
     when notBool(N in keys(Record))
// 10.2.1.2.5 DeleteBinding (N)
rule <k> DeleteBinding(E:Eid,N:Var) => Delete(O,N,false) ... </k>
     <env>
       <eid> E </eid>
       <objEnvRec>
         <bindingObj> O:Oid </bindingObj>
         _
       </objEnvRec>
       _
     </env>

syntax KItem /* Val */ ::= "ImplicitThisValue" "(" K /* Eid */ ")"  [seqstrict]
// 10.2.1.1.6 ImplicitThisValue()
rule <k> ImplicitThisValue(E:Eid) => Undefined ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> _:Map </declEnvRec>
       _
     </env>
// 10.2.1.2.6 ImplicitThisValue()
rule <k> ImplicitThisValue(E:Eid) => O ... </k>
     <env>
       <eid> E </eid>
       <objEnvRec>
         <bindingObj> O:Oid </bindingObj>
         <provideThis> true </provideThis>
       </objEnvRec>
       _
     </env>
rule <k> ImplicitThisValue(E:Eid) => Undefined ... </k>
     <env>
       <eid> E </eid>
       <objEnvRec>
         <provideThis> false </provideThis>
         _
       </objEnvRec>
       _
     </env>

syntax KItem /* .K */ ::= "CreateImmutableBinding" "(" K /* Eid */ "," K /* Var */ ")"  [seqstrict]
// 10.2.1.1.7 CreateImmutableBinding (N)
rule <k> CreateImmutableBinding(E:Eid,N:Var) => . ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> (.Map => N |-> @ve(Undefined,false,false,false)) Record:Map </declEnvRec>
       _
     </env>
     when notBool(N in keys(Record))

syntax KItem /* .K */ ::= "InitializeImmutableBinding" "(" K /* Eid */ "," K /* Var */ "," K /* Val */ ")"  [seqstrict]
// 10.2.1.1.8 InitializeImmutableBinding (N,V)
rule <k> InitializeImmutableBinding(E:Eid,N:Var,V:Val) => . ... </k>
     <env>
       <eid> E </eid>
       <declEnvRec> N |-> @ve((_ => V),(false => true),false,_) _:Map </declEnvRec>
       _
     </env>

//////////////////////////////////////////////////////////////////////////////
// 10.2.2 Lexical Environment Operations
//////////////////////////////////////////////////////////////////////////////

// 10.2.2.1 GetIdentifierReference (lex, name, strict)

syntax KItem /* Reference */ ::= "GetIdentifierReference" "(" K /* Eid */ "," K /* Var */ "," K /* Bool */ ")" [seqstrict]

rule GetIdentifierReference(@NullEid,N:Var,Strict:Bool) => @Ref(Undefined,N,Strict)
rule <k> GetIdentifierReference(E:Eid,N:Var,Strict:Bool)
      => BEGIN
         If HasBinding(E,N) = true then {
           Return @Ref(E,N,Strict);
         } else {
           Return GetIdentifierReference(E',N,Strict);
         }
         END
     ... </k>
     <env>
       <eid> E </eid>
       <outer> E' </outer>
       _
     </env>

// 10.2.2.2 NewDeclarativeEnvironment (E)

syntax KItem /* Eid */ ::= "NewDeclarativeEnvironment" "(" K /* Eid */ "," K /* Bool */ ")"  [seqstrict]

rule <k> NewDeclarativeEnvironment(E:Eid, Strict:Bool) => @e(!N) ... </k>
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

syntax KItem /* Eid */ ::= "NewObjectEnvironment" "(" K /* Oid */ "," K /* Eid */ "," K /* Bool */ "," K /* Bool */ ")" [seqstrict]

rule <k> NewObjectEnvironment(O:Oid,E:Eid,ProvideThis:Bool,Strict:Bool) => @e(!N) ... </k>
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
rule <k> @EnterGlobalCode(Code:Stmt)
      => @CheckEarlyErrors(#@IsStrict(Code), Code)
      ~> @BindDeclarations("function",false,#@IsStrict(Code),Code)
      ~> @BindDeclarations("variable",false,#@IsStrict(Code),Code)
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
               <strict> #@IsStrict(Code) </strict> // 10.1.1 Strict Mode Code, Case 1
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

syntax KItem /* .K */ ::= "@EnterEvalCode" "(" Stmt "," K /* Bool */ /* Direct? */ ")" [seqstrict(2)]
syntax Id ::= "$strict"
rule <k> @EnterEvalCode(Code:Stmt, true)
      => BEGIN
         Let $strict = #@IsStrict(Code) orBool Strict; // 10.1.1 Strict Mode Code, Case 2 (direct call to eval)
         Do @CheckEarlyErrors($strict, Code);
         Do @SetRunningCtx(@NewDeclarativeEnvironmentForEval(E,$strict), This);
         Do @BindDeclarations("function",true,$strict,Code);
         Do @BindDeclarations("variable",true,$strict,Code);
         END
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
  => BEGIN
     Let $strict = #@IsStrict(Code); // 10.1.1 Strict Mode Code, Case 2 (NOT direct call to eval)
     Do @CheckEarlyErrors($strict, Code);
     Do @SetRunningCtx(@NewDeclarativeEnvironmentForEval(@GlobalEid,$strict), @GlobalOid);
     Do @BindDeclarations("function",true,$strict,Code);
     Do @BindDeclarations("variable",true,$strict,Code);
     END

syntax KItem /* Eid */ ::= "@NewDeclarativeEnvironmentForEval" "(" K /* Eid */ "," K /* Bool */ /* Strict? */ ")" [seqstrict]
rule @NewDeclarativeEnvironmentForEval(E,true ) => NewDeclarativeEnvironment(E, true)
rule @NewDeclarativeEnvironmentForEval(E,false) => E

// 10.4.3 Entering Function Code

syntax KItem /* .K */ ::= "@EnterFunctionCode" "(" K /* Oid */ "," K /* Val */ "," K /* Vals */ ")" [seqstrict]
rule <k> @EnterFunctionCode(F:Oid,This:Val,Args:Vals)
      => BEGIN
         Do @SetRunningCtx(NewDeclarativeEnvironment(E,Strict), @ResolveThis(Strict,This));
         Do @BindFunctionParameters(F,Args,Strict);
         Do @BindDeclarations("function",false,Strict,Code);
         Do @BindArgumentsObject(F,Args,Strict);
         Do @BindDeclarations("variable",false,Strict,Code);
         END
     ... </k>
     <obj>
       <oid> F </oid>
       <internalProperties>
         "Scope"  |-> E:Eid
         "Code"   |-> Code:Stmt
         "Strict" |-> Strict:Bool
         _:Map
       </internalProperties>
       _
     </obj>

syntax KItem /* Oid */ ::= "@ResolveThis" "(" K /* Bool */ "," K /* Val */ ")" [seqstrict]
rule @ResolveThis(true, V:Val) => V
rule @ResolveThis(false,O:Oid) => O                   // NOTE: Method call or function call under the 'with'
rule @ResolveThis(false,Undefined) => @GlobalOid     // NOTE: Function call without the 'with' (from p.28 of Good Parts)
rule @ResolveThis(false,@NullVal  ) => @GlobalOid     // NOTE: Apply call with 'null' as a 'this' value (from p.30 of Good Parts)
rule @ResolveThis(false,V:Val) => ToObject(V) when isPrimitive(V) ==K true

syntax KItem /* .K */ ::= "@SetRunningCtx" "(" K /* Eid */ "," K /* Oid */ ")" [seqstrict]
rule <k> @SetRunningCtx(E:Eid,This:Val) => . ... </k>
     <ctx>
       <activeStack> (.List => ListItem(@active(R))) _:List </activeStack>
       <running>
         (R => <lexicalEnv> E </lexicalEnv>
               <thisBinding> This </thisBinding>
               <lastNonEmptyValue> Undefined </lastNonEmptyValue>)
       </running>
     </ctx>

syntax KItem /* Val */ ::= "@RestoreRunningCtx"
rule <k> @RestoreRunningCtx => . ... </k>
     <ctx>
       <activeStack> (ListItem(@active(R)) => .List) _:List </activeStack>
       <running> _ => R </running>
     </ctx>

// 10.5 Declaration Binding Instantiation

// 10.5: Step 4: Function Parameter Binding Instantiation
syntax KItem /* .K */ ::= "@BindFunctionParameters" "(" K /* Oid */ "," K /* Vals */ "," K /* Bool */ ")"  [seqstrict]
rule <k> @BindFunctionParameters(F:Oid,Args:Vals,Strict:Bool) => @SetParams(Ns,Args,Strict) ... </k>
     <obj>
       <oid> F </oid>
       <internalProperties> "FormalParameters" |-> Ns:Exps _:Map </internalProperties>
       _
     </obj>
//
syntax KItem /* .K */ ::= "@SetParams" "(" Exps "," K /* Vals */ "," K /* Bool */ ")" [seqstrict(2,3)]
rule @SetParams(%nil, _:Vals, _) => .
rule @SetParams(%cons(%var(N:Var), Ns:Exps), @Nil                 , Strict:Bool) => @SetParam(N, Undefined, Strict) ~> @SetParams(Ns, @Nil, Strict)
rule @SetParams(%cons(%var(N:Var), Ns:Exps), @Cons(V:Val, Vs:Vals), Strict:Bool) => @SetParam(N, V         , Strict) ~> @SetParams(Ns, Vs,   Strict)
//
syntax KItem /* .K */ ::= "@SetParam" "(" K /* Var */ "," K /* Val */ "," K /* Bool */ ")" [seqstrict]
rule <k> @SetParam(N,V,Strict:Bool)
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
syntax KItem /* .K */ ::= "@BindDeclarations" "(" K /* String */ "," K /* Bool */ "," K /* Bool */ "," Stmt ")" [seqstrict(1,2,3)]
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %fdecl(F:Var,Ps:Exps,FB:Stmt))      => BEGIN If Mode = "function" then { Do @BindFunctionDeclaration(F,Ps,FB,CB,Strict); }; END
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %vdecl(N:Var))                      => BEGIN If Mode = "variable" then { Do @BindVariableDeclaration(N,CB,Strict); }; END
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %seq(S1:Stmt,S2:Stmt))              => @BindDeclarations(Mode,CB,Strict,S1) ~> @BindDeclarations(Mode,CB,Strict,S2)
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %exp(_))                            => .
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %if(_,S1:Stmt,S2:Stmt))             => @BindDeclarations(Mode,CB,Strict,S1) ~> @BindDeclarations(Mode,CB,Strict,S2)
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %do(S:Stmt,_))                      => @BindDeclarations(Mode,CB,Strict,S)
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %while(_,S:Stmt))                   => @BindDeclarations(Mode,CB,Strict,S)
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %for  (S1:Stmt,_,_,S2:Stmt))        => @BindDeclarations(Mode,CB,Strict,S1) ~> @BindDeclarations(Mode,CB,Strict,S2)
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %forin(S1:Stmt,_,_,S2:Stmt))        => @BindDeclarations(Mode,CB,Strict,S1) ~> @BindDeclarations(Mode,CB,Strict,S2)
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %continue(_))                       => .
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %break(_))                          => .
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %label(_,S:Stmt))                   => @BindDeclarations(Mode,CB,Strict,S)
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %return(_))                         => .
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %throw(_))                          => .
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %try(S1:Stmt,_,S2:Stmt,S3:Stmt))    => @BindDeclarations(Mode,CB,Strict,S1) ~> @BindDeclarations(Mode,CB,Strict,S2) ~> @BindDeclarations(Mode,CB,Strict,S3)
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %try(S1:Stmt,          S3:Stmt))    => @BindDeclarations(Mode,CB,Strict,S1) ~>                                         @BindDeclarations(Mode,CB,Strict,S3)
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %with(_,S:Stmt))                    => @BindDeclarations(Mode,CB,Strict,S)
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %emptyStmt)                         => .
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %switch(_,S1:Stmt,S2:Stmt,S3:Stmt)) => @BindDeclarations(Mode,CB,Strict,S1) ~> @BindDeclarations(Mode,CB,Strict,S2) ~> @BindDeclarations(Mode,CB,Strict,S3)
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %case(_,S:Stmt))                    => @BindDeclarations(Mode,CB,Strict,S)
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %default(S:Stmt))                   => @BindDeclarations(Mode,CB,Strict,S)
rule @BindDeclarations(Mode:String, CB:Bool, Strict:Bool, %debugger)                          => .

// 10.5: Step 5: Function Declaration Binding Instantiation
syntax KItem /* .K */ ::= "@BindFunctionDeclaration" "(" K /* Var */ "," Exps "," Stmt "," K /* Bool */ "," K /* Bool */ ")" [seqstrict(1,4,5)]
syntax Id ::= "$existingProp"
rule <k> @BindFunctionDeclaration(N:Var, Params:Exps, FunBody:Stmt, ConfigurableBindings:Bool, Strict:Bool)
      => BEGIN
         If HasBinding(E,N) = false then {
           Do CreateMutableBinding(E,N,ConfigurableBindings);
         } else {
           If E = @GlobalEid then {
             Let $existingProp = GetProperty(@GlobalOid,N);
             If $existingProp."Configurable" = true then {
               DoI DefineOwnProperty(@GlobalOid, N, @desc("Value" |-> Undefined "Writable" |-> true "Enumerable" |-> true "Configurable" |-> ConfigurableBindings), true);
             } else {
               If IsAccessorDescriptor($existingProp) = true then {
                 Do @Throw(@TypeError("BindFunctionDeclaration accessor",$existingProp));
               };
               If @AndBool($existingProp."Writable", $existingProp."Enumerable") = false then {
                 Do @Throw(@TypeError("BindFunctionDeclaration writable/enumerable",$existingProp));
               };
             }
           };
         }
         Do SetMutableBinding(E, N, @FunctionDeclaration(N,Params,FunBody), Strict);
         END
     ... </k>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         _
       </running>
       _
     </ctx>

// 10.5: Step 8: Variable Declaration Binding Instantiation
syntax KItem /* .K */ ::= "@BindVariableDeclaration" "(" K /* Var */ "," K /* Bool */ "," K /* Bool */ ")" [seqstrict]
rule <k> @BindVariableDeclaration(N:Var, ConfigurableBindings:Bool, Strict:Bool)
      => BEGIN
         If HasBinding(E,N) = true then {
           Return;
         } else {
           Do CreateMutableBinding(E,N,ConfigurableBindings);
           Do SetMutableBinding(E,N,Undefined,Strict);
         }
         END
     ... </k>
     <ctx>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         _
       </running>
       _
     </ctx>

syntax KItem /* .K */ ::= "@BindArgumentsObject" "(" K /* Oid */ "," K /* Vals */ "," K /* Bool */ ")" [seqstrict]
syntax Id ::= "$argsObj"
rule <k> @BindArgumentsObject(F:Oid,Args:Vals,Strict:Bool)
      => BEGIN
         If HasBinding(E,"arguments") = false then {
           Let $argsObj = @CreateArgumentsObject(F,Names,Args,E,Strict);
           If Strict = true then {
             Do CreateImmutableBinding(E,"arguments");
             Do InitializeImmutableBinding(E,"arguments",$argsObj);
           } else {
             Do CreateMutableBinding(E,"arguments",false); // TODO: check if the third argument is false or not (not mentioned in the specification)
             Do SetMutableBinding(E,"arguments",$argsObj,false);
           }
         };
         END
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

syntax KItem /* Oid */ ::= "@CreateArgumentsObject" "(" K /* Oid */ "," Exps "," K /* Vals */ "," K /* Eid */ "," K /* Bool */ ")" [seqstrict(1,3,4,5)]
syntax Id ::= "$len" | "$map"
rule @CreateArgumentsObject(Func:Oid, Names:Exps, Args:Vals, Env:Eid, Strict:Bool)
  => BEGIN
     Let $len = #@LengthVals(Args);
     Let $obj = @CreateObject;
     Do SetInternalProperty($obj, "Class", "Arguments");
     Do SetInternalProperty($obj, "Strict", Strict); // NOTE: This is not specified in language standard, but added for our own @IsArgumentsObjectNonStrictWithFormalParams
     DoI DefineOwnProperty($obj, "length", @GenDesc("Value", $len, "Writable", true, "Enumerable", false, "Configurable", true), false);
     Let $map = @CreateObject;
     Do @BindActualParams($obj, Args, 0);
     If Strict = false then {
       Do @BindFormalParams($map, Names, Args, Env, 0);
     };
     If #@Length(Names) >Int 0 = true then {
       Do SetInternalProperty($obj, "ParameterMap", $map);
     };
     If Strict = true then {
       DoI DefineOwnProperty($obj, "caller", @desc("Get" |-> @("ThrowTypeError") "Set" |-> @("ThrowTypeError") "Enumerable" |-> false "Configurable" |-> false), false);
       DoI DefineOwnProperty($obj, "callee", @desc("Get" |-> @("ThrowTypeError") "Set" |-> @("ThrowTypeError") "Enumerable" |-> false "Configurable" |-> false), false);
     } else {
       DoI DefineOwnProperty($obj, "callee", @desc("Value" |-> Func "Writable" |-> true "Enumerable" |-> false "Configurable" |-> true), false);
     }
     Return $obj;
     END

syntax KItem /* .K */ ::= "@BindActualParams" "(" K /* Oid */ "," K /* Vals */ "," K /* Int */ ")" [seqstrict]
rule @BindActualParams(O:Oid, @Nil, _) => .
rule @BindActualParams(O:Oid, @Cons(V:Val,Vs:Vals), I:Int)
  => DefineOwnProperty(O, ToString(I), @desc("Value" |-> V "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false) ~> @Ignore ~>
     @BindActualParams(O, Vs, I +Int 1)

syntax KItem /* .K */ ::= "@BindFormalParams" "(" K /* Oid */ "," Exps "," K /* Vals */ "," K /* Eid */ "," K /* Int */ ")" [seqstrict(1,3,4,5)]
// TODO: consider step 11.c.ii 2nd condition: "name is not an element of mappedNames". what if duplicated names?
rule @BindFormalParams(M:Oid, %nil, _, _, _) => .
rule @BindFormalParams(M:Oid, _, @Nil, _, _) => .
rule @BindFormalParams(M:Oid, %cons(%var(Name:Var),Names:Exps), @Cons(Arg:Val,Args:Vals), Env:Eid, I:Int)
  => BEGIN
     Let $getter = @MakeArgGetter(Name,Env);
     Let $setter = @MakeArgSetter(Name,Env);
     DoI DefineOwnProperty(M, ToString(I), @GenDesc("Get", $getter, "Set", $setter, "Configurable", true), false);
     Do @BindFormalParams(M, Names, Args, Env, I +Int 1);
     END

syntax KItem /* Oid */ ::= "@MakeArgGetter" "(" K /* Var */ "," K /* Eid */ ")" [seqstrict]
rule @MakeArgGetter(N:Var,E:Eid) => @CreateFunctionObject(%nil, %return(%var(N)), E, true) // TODO: in what case? // 10.1.1 Strict Mode Code, Case ?

syntax KItem /* Oid */ ::= "@MakeArgSetter" "(" K /* Var */ "," K /* Eid */ ")" [seqstrict]
syntax Id ::= "$param"
rule @MakeArgSetter(N:Var,E:Eid)
  => BEGIN
     Return @CreateFunctionObject(%cons(%var((N:>String +String "_arg"):>Var),%nil), %exp(%bop(%assign,%var(N),%var((N:>String +String "_arg"):>Var))), E, true); // TODO: in what case? // 10.1.1 Strict Mode Code, Case ?
     END

syntax KItem /* Bool */ ::= "@IsArgumentsObjectNonStrictWithFormalParams" "(" K /* Oid */ ")" [seqstrict]
rule <k> @IsArgumentsObjectNonStrictWithFormalParams(O:Oid)
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
rule <k> @IsArgumentsObjectNonStrictWithFormalParams(O:Oid) => false ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         InternalProperties:Map
       </internalProperties>
       _
     </obj>
     when notBool("Strict" in keys(InternalProperties))

syntax Id ::= "$isMapped" | "$allowed"

syntax KItem /* Val */ ::= "Get@Arguments" "(" K /* Oid */ "," K /* Var */ ")"  [seqstrict]

rule Get@Arguments(O:Oid,P:Var)
  => BEGIN
     Let $map = GetInternalProperty(O,"ParameterMap");
     Let $isMapped = GetOwnProperty($map,P);
     If $isMapped = Undefined then {
       Return Get@Default(O,P); // TODO: consider step 3.b
     } else {
       Return Get($map,P);
     }
     END

syntax KItem /* Val */ ::= "GetOwnProperty@Arguments" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict]

rule GetOwnProperty@Arguments(O:Oid,P:Var)
  => BEGIN
     Let $desc = GetOwnProperty@Default(O,P);
     If $desc = Undefined then {
       Return $desc;
     } else {
       Let $map = GetInternalProperty(O,"ParameterMap");
       Let $isMapped = GetOwnProperty($map,P);
       If $isMapped = Undefined then {
         Return $desc;
       } else {
         Return @AddDesc("Value", Get($map,P), $desc);
       }
     }
     END

syntax KItem /* Bool */ ::= "DefineOwnProperty@Arguments" "(" K /* Oid */ "," K /* Var */ "," K /* PropertyDescriptor */ "," K /* Bool */ ")" [seqstrict]

rule DefineOwnProperty@Arguments(O:Oid,P:Var,Desc:PropertyDescriptor,Throw:Bool)
  => BEGIN
     Let $map = GetInternalProperty(O,"ParameterMap");
     Let $isMapped = GetOwnProperty($map,P);
     Let $allowed = DefineOwnProperty@Default(O,P,Desc,false);
     If $allowed = false then {
       If Throw = true then {
         Do @Throw(@TypeError("DefineOwnProperty for Arguments",DefineOwnProperty(O,P,Desc,Throw)));
       } else {
         Return false;
       }
     } else {
       If $isMapped = Undefined then {
         Nop;
       } else {
         If IsAccessorDescriptor(Desc) = true then {
           DoI Delete($map, P, false);
         } else {
           If @MemDesc(Desc,"Value") = true then {
             Do Put($map, P, Desc."Value", Throw);
           };
           If Desc."Writable" = false then {
             DoI Delete($map, P, false);
           };
         }
       }
       Return true;
     }
     END

syntax KItem /* Bool */ ::= "Delete@Arguments" "(" K /* Oid */ "," K /* Var */ "," K /* Bool */ ")"  [seqstrict]

rule Delete@Arguments(O:Oid,P:Var,Throw:Bool)
  => BEGIN
     Let $map = GetInternalProperty(O,"ParameterMap");
     Let $isMapped = GetOwnProperty($map,P);
     Let $result = Delete@Default(O,P,Throw);
     If @AndBool($result, @NeqVal($isMapped, Undefined)) = true then {
       DoI Delete($map, P, false);
     };
     Return $result;
     END

//////////////////////////////////////////////////////////////////////////////
// 11 Expressions
//////////////////////////////////////////////////////////////////////////////

syntax KItem /* Reference */ ::= "@GetReference" "(" Exp ")"

rule <k> @GetReference(%var(N:Var)) => GetIdentifierReference(E,N,Strict) ... </k>
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

rule @GetReference(E:Exp) => @Throw(@ReferenceError("GetReference",E)) when notBool(#@IsReferenceExp(E))

syntax Bool ::= "#@IsReferenceExp" "(" Exp ")" [function]

rule #@IsReferenceExp(E:Exp) => getKLabel(E) ==KLabel '%var`(_`)
                        orBool getKLabel(E) ==KLabel '%mem`(_`,_`)

rule %emptyExp => Undefined

// 11.1.1 The this Keyword

rule <k> %this => This ... </k>
     <running>
       <thisBinding> This:Val </thisBinding>
       _
     </running>

// 11.1.2 Identifier Reference
// 10.3.1 Identifier Resolution

rule %var(N:Var) => GetValue(@GetReference(%var(N)))

// 11.1.3 Literal Reference
// TODO: Numeric, Regular Expressions

rule %con(%this)    => %this
rule %con(%null)    => %null
rule %con(B:Bool)   => B
rule %con(I:Int)    => @ResolveOverflow(I)
rule %con(F:Float)  => @ResolveOverflow(F)
rule %con(S:String) => S

// 11.1.4 Array Initialiser

rule %arr(Es:Exps) => @MakeArray(#@RemoveLastEmptyExp(Es))

// NOTE: the last ending comma should be ignored: [ 1, 2, ] => [ 1, 2 ]
//       "If an element is elided at the end of an array, that element does not contribute to the length of the Array." (p.63)
syntax Exps ::= "#@RemoveLastEmptyExp" "(" Exps ")" [function]
rule #@RemoveLastEmptyExp(                   %nil ) => %nil
rule #@RemoveLastEmptyExp(%cons(%emptyExp,   %nil)) => %nil
rule #@RemoveLastEmptyExp(%cons(E:Exp,       %nil)) => %cons(E,%nil) when E =/=K %emptyExp
rule #@RemoveLastEmptyExp(%cons(E:Exp,    Es:Exps)) => %cons(E,#@RemoveLastEmptyExp(Es)) when Es =/=K %nil

// 11.1.5 Object Initialiser
// NOTE: step 4 of p.66 (duplicated properties) is checked by 'CheckDuplicatedProp'

rule %obj(PAs:Exps) => @AssignProps(@CreateObject,PAs)

syntax KItem /* Oid */ ::= "@AssignProps" "(" K /* Oid */ "," Exps ")" [seqstrict(1)]
rule @AssignProps(O:Oid, %nil) => O
rule @AssignProps(O:Oid, %cons(PA:Exp, PAs:Exps)) => @AssignProp(O,PA) ~> @AssignProps(O,PAs)

syntax KItem /* .K */ ::= "@AssignProp" "(" K /* Oid */ "," Exp ")"  [seqstrict(1)]

context @AssignProp(_,%prop(_,HOLE))
rule @AssignProp(O:Oid, %prop(P:Var,V:Val))
  => DefineOwnProperty(O, P, @desc("Value" |-> V "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true), false) ~> @Ignore

rule <k> @AssignProp(O:Oid, %get(P:Var,FunBody:Stmt))
      => BEGIN
         Let $closure = @CreateFunctionObject(%nil, FunBody, E, #@IsStrict(FunBody) orBool Strict); // 10.1.1 Strict Mode Code, Case 3
         DoI DefineOwnProperty(O, P, @GenDesc("Get", $closure, "Enumerable", true, "Configurable", true), false);
         END
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
      => BEGIN
         Let $closure = @CreateFunctionObject(%cons(%var(X),%nil), FunBody, E, #@IsStrict(FunBody) orBool Strict); // 10.1.1 Strict Mode Code, Case 3
         DoI DefineOwnProperty(O, P, @GenDesc("Set", $closure, "Enumerable", true, "Configurable", true), false);
         END
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

rule %mem(E1:Exp,E2:Exp) => GetValue(@GetReference(%mem(E1,E2)))

// 11.2.2 The new Operator

rule %new(F:Exp,Es:Exps) => @ConstructIfPossible(F,Es)

syntax KItem /* Oid */ ::= "@ConstructIfPossible" "(" K /* Val */ "," K /* Vals */ ")" [seqstrict]
rule @ConstructIfPossible(F:Val, Args:Vals)
  => BEGIN
     If @IsConstructable(F) = true then {
       Do Construct(F, Args);
     } else {
       Do @Throw(@TypeError("ConstructIfPossible",F));
     }
     END

syntax KItem /* Bool */ ::= "@IsConstructable" "(" K /* Val */ ")" [seqstrict]
rule <k> @IsConstructable(F:Oid) => "prototype" in keys(Prop) ... </k>
     <obj>
       <oid> F </oid>
       <properties> Prop:Map </properties>
       _
     </obj>
rule @IsConstructable(F:Val) => false when notBool(#@IsOid(F))

// 11.2.3 Function Calls

rule %call(F:Exp,Es:Exps) => @CallIfPossible(F, @DetermineThis(F), Es)
     when #@IsEval(F) ==K false // TODO: could it be made in uniform way?
  andBool #@IsAPI(F) ==K false

syntax KItem /* Val */ ::= "@DetermineThis" "(" Exp ")"

rule @DetermineThis(F) => @FindThis(@GetReference(F)) when #@IsReferenceExp(F)
rule @DetermineThis(F) => Undefined                  when notBool(#@IsReferenceExp(F))

syntax KItem /* Val */ ::= "@FindThis" "(" K /* ReferenceVal */ ")" [seqstrict]

rule @FindThis(@Ref(O:Oid,_,_)) => O
rule @FindThis(@Ref(E:Eid,_,_)) => ImplicitThisValue(E)
rule @FindThis(@Ref(I:Primitive,_,_)) => I // NOTE: This will be resolved by @ResolveThis
/* NOTE: Not possible.
   If @GetReference(F) is Ref(Undefined,_,_), then it could not get to here, because evaluating F, which is GetValue(@GetReference(F)), will raise RefereneError.
   Indeed, this rule is not specified in the standard, which already knows this.
   Indeed, the condition of Step 7 is "#@IsReferenceExp(F) is false", not "@GetReference(F) is Ref(Undefined,_,_)".
rule @FindThis(@Ref(Undefined,_,_)) => Undefined
*/

syntax KItem /* Val */ ::= "@CallIfPossible" "(" K /* Val */ "," K /* Val */ "," K /* Vals */ ")" [seqstrict]

rule @CallIfPossible(F:Val, This:Val, Args:Vals)
  => BEGIN
     If IsCallable(F) = true then {
       Do Call(F, This, Args);
     } else {
       Do @Throw(@TypeError("CallIfPossible",F));
     }
     END

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
  => BEGIN
     Let $lhs = @GetReference(E);
     Let $oldValue = ToNumber(GetValue($lhs));
     Let $newValue = @Addition($oldValue,1);
     Do PutValue($lhs,$newValue);
     Return $oldValue;
     END

// 11.3.2 Postfix Decrement Operator

rule %post(E:Exp,%dec)
  => BEGIN
     Let $lhs = @GetReference(E);
     Let $oldValue = ToNumber(GetValue($lhs));
     Let $newValue = @Subtraction($oldValue,1);
     Do PutValue($lhs,$newValue);
     Return $oldValue;
     END

// 11.4.1 The delete Operator

// TODO: consider the first sentence of note.
rule %pre(%delete,E:Exp)
  => BEGIN
     If #@IsReferenceExp(E) = false then {
       DoI E;
       Return true;
     } else {
       Let $ref = @GetReference(E);
       If IsUnresolvableReference($ref) = true then {
         If IsStrictReference($ref) = true then {
           Do @Throw(@SyntaxError("delete unresolvable ref",$ref));
         } else {
           Return true;
         }
       } else {
         If IsPropertyReference($ref) = true then {
           Return Delete(ToObject(GetBase($ref)), GetReferencedName($ref), IsStrictReference($ref));
         } else {
           If IsStrictReference($ref) = true then {
             Do @Throw(@SyntaxError("delete not property ref",$ref));
           } else {
             Return DeleteBinding(GetBase($ref), GetReferencedName($ref));
           }
         }
       }
     }
     END

// 11.4.2 The void Operator

rule %pre(%void,E:Exp) => E ~> @Ignore ~> Undefined

// 11.4.3 The typeof Operator

rule %pre(%typeof,E:Exp) => @Try(@TypeOf(E),"undefined")

syntax KItem ::= "@TypeOf" "(" K /* Val */ ")" [seqstrict]
rule @TypeOf(Undefined) => "undefined"
rule @TypeOf(@NullVal  ) => "object"
rule @TypeOf(_:Bool    ) => "boolean"
rule @TypeOf(_:Number  ) => "number"
rule @TypeOf(_:String  ) => "string"
rule @TypeOf(O:Oid     )
  => BEGIN
     If IsCallable(O) = true then {
       Return "function";
     } else {
       Return "object";
     }
     END
// for built-in objects' functions
rule @TypeOf(@(_)      ) => "function" // TODO: is there any better way?

// NOTE: We don't need to consider the 'Case 2.a' that the reference value of E is an unresolvable reference.
//       If the case happens, evaluating E throws an ReferenceError and we can catch the case.

syntax KItem ::= "@Try" "(" K "," K ")" | "@PopExc"
syntax KItem ::= "@exc" "(" K "," K "," CtrlCellFragment ")"

rule <k> (@Try(E1:K,E2:K) => E1 ~> @PopExc) ~> K </k>
     <ctrl>
       <excStack> (.List => ListItem(@exc(E2,K,Ctrl))) _:List </excStack>
       Ctrl
     </ctrl>

rule <k> V:Val ~> @PopExc => V ... </k>
     <ctrl>
       <excStack> (ListItem(@exc(_,_,_)) => .List) _:List </excStack>
       _
     </ctrl>

rule <k> @Throw(V) ~> _ => E2 ~> K </k>
     <ctrl>
       <excStack> (ListItem(@exc(E2,K,Ctrl)) => .List) _:List </excStack>
       (_ => Ctrl)
     </ctrl>

// 11.4.4 Prefix Increment Operator

rule %pre(%inc,E:Exp)
  => BEGIN
     Let $lhs = @GetReference(E);
     Let $oldValue = ToNumber(GetValue($lhs));
     Let $newValue = @Addition($oldValue,1);
     Do PutValue($lhs,$newValue);
     Return $newValue;
     END

// 11.4.5 Prefix Decrement Operator

rule %pre(%dec,E:Exp)
  => BEGIN
     Let $lhs = @GetReference(E);
     Let $oldValue = ToNumber(GetValue($lhs));
     Let $newValue = @Subtraction($oldValue,1);
     Do PutValue($lhs,$newValue);
     Return $newValue;
     END

// 11.4.6 Unary + Operator

rule %pre(%plus,E:Exp) => ToNumber(E)

// 11.4.7 Unary - Operator

rule %pre(%minus,E:Exp) => @Minus(ToNumber(E))

syntax KItem ::= "@Minus" "(" K /* Number */ ")" [seqstrict]
rule @Minus(I:Int     ) => I *Int   (-1)   when I =/=Int   0
rule @Minus(F:Float   ) => F *Float (-1.0) when F =/=Float 0.0
rule @Minus(0         ) => @nz
rule @Minus(0.0       ) => @nz
rule @Minus(@nz       ) => 0.0
rule @Minus(@NaN      ) => @NaN
rule @Minus(@+Infinity) => @-Infinity
rule @Minus(@-Infinity) => @+Infinity

// 11.4.8 Bitwise NOT Operator ( ~ )

rule %pre(%tilde,E:Exp) => @NotBitwise(ToInt32(E))

syntax KItem ::= "@NotBitwise" "(" K /* Int */ ")" [seqstrict]

rule @NotBitwise(I:Int) => ~Int I

// 11.4.9 Logical NOT Operator ( ! )

rule %pre(%bang,E:Exp) => @Not(ToBoolean(E))

syntax KItem ::= "@Not" "(" K /* Bool */ ")" [seqstrict]
rule @Not(true) => false
rule @Not(false) => true

// 11.? Binary Operator

context %bop(_:OpNormal,HOLE,_)
context %bop(_:OpNormal,_:Val,HOLE)

// TODO: IEEE 754 binary double-precision arithmetic: *, /, %, +, -

syntax KItem ::= "@ResolveOverflow" "(" K /* Number */ ")" [seqstrict]
rule @ResolveOverflow(F:Float) => @ResolveOverflowAux(F,F)
rule @ResolveOverflow(I:Int)   => @ResolveOverflowAux(I,#@Int2Float(I)) when notBool(I <Int @MAX_INT andBool I >Int @MIN_INT)
rule @ResolveOverflow(I:Int)   => I                                     when         I <Int @MAX_INT andBool I >Int @MIN_INT
//
rule @ResolveOverflow(N:Number) => N when isFloat(N) =/=K true andBool isInt(N) =/=K true

syntax KItem ::= "@ResolveOverflowAux" "(" K /* Number */ "," K /* Float */ ")" [seqstrict]
rule @ResolveOverflowAux(N:Number, F:Float)
  => BEGIN
     If F >=Float 0.0 = true then {
       If F >Float @MAX_VALUE = true then {
         Return @+Infinity;
       } else {
         Return N;
       }
     } else {
       If (F *Float -1.0) >Float @MAX_VALUE = true then {
         Return @-Infinity;
       } else {
         Return N;
       }
     }
     END

// TODO: instead of using this, generalize number type to include sign information so that negative zero can be represented naturally
syntax KItem ::= "@ResolveNumber" "(" K /* Number */ "," K /* Bool */ ")" [seqstrict]
rule @ResolveNumber(0,  false) => @nz
rule @ResolveNumber(0.0,false) => @nz
rule @ResolveNumber(-0.0,false) => @nz
rule @ResolveNumber(N:Number,Positive:Bool) => N when (N =/=K 0 andBool N =/=K 0.0) orBool Positive =/=K false

syntax KItem /* Bool */ ::= "@IsPositive" "(" K /* Number */ ")" [seqstrict]
rule @IsPositive(I:Int)   => I >=Int   0
rule @IsPositive(F:Float) => F >=Float 0.0
rule @IsPositive(@nz) => false
rule @IsPositive(@NaN) => true // TODO:
rule @IsPositive(@+Infinity) => true
rule @IsPositive(@-Infinity) => false

// 11.5.1 Applying the * Operator

rule %bop(%times,V1:Val,V2:Val) => @ResolveOverflow(@MultiplicationSign(ToNumber(V1),ToNumber(V2)))

syntax KItem ::= "@MultiplicationSign" "(" K /* Number */ "," K /* Number */ ")" [seqstrict]
rule @MultiplicationSign(N1:Number,N2:Number) => @ResolveNumber(@Multiplication(N1,N2), @XorBool(@IsPositive(N1),@IsPositive(N2)))

syntax KItem ::= "@Multiplication" "(" K /* Number */ "," K /* Number */ ")" [seqstrict]
rule @Multiplication(@NaN,_) => @NaN
rule @Multiplication(_,@NaN) => @NaN
//
rule @Multiplication(I1:Int,I2:Int    ) => I1            *Int   I2
rule @Multiplication(I1:Int,F2:Float  ) => #@Int2Float(I1) *Float F2
rule @Multiplication( I:Int,@nz       ) => @MultiplicationNegativeZero(I)
rule @Multiplication( I:Int,@+Infinity) => @MultiplicationInfinity(I)
rule @Multiplication( I:Int,@-Infinity) => @MultiplicationInfinity(@Minus(I))
//
rule @Multiplication(F1:Float,I2:Int    ) => F1 *Float #@Int2Float(I2)
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

syntax KItem ::= "@MultiplicationInfinity" "(" K /* Number */ ")" [seqstrict]
rule @MultiplicationInfinity(@nz    ) => @NaN
rule @MultiplicationInfinity(0      ) => @NaN
rule @MultiplicationInfinity(I:Int  ) => @+Infinity when I >Int 0
rule @MultiplicationInfinity(I:Int  ) => @-Infinity when I <Int 0
rule @MultiplicationInfinity(0.0    ) => @NaN
rule @MultiplicationInfinity(F:Float) => @+Infinity when F >Float 0.0
rule @MultiplicationInfinity(F:Float) => @-Infinity when F <Float 0.0

syntax KItem ::= "@MultiplicationNegativeZero" "(" K /* Number */ ")" [seqstrict]
rule @MultiplicationNegativeZero(I:Int  ) => @nz when I >=Int 0
rule @MultiplicationNegativeZero(I:Int  ) => 0   when I  <Int 0
rule @MultiplicationNegativeZero(F:Float) => @nz when F >=Float 0.0
rule @MultiplicationNegativeZero(F:Float) => 0   when F  <Float 0.0

// 11.5.2 Applying the / Operator

rule %bop(%div,V1:Val,V2:Val) => @ResolveOverflow(@DivisionSign(ToNumber(V1),ToNumber(V2)))

syntax KItem ::= "@DivisionSign" "(" K /* Number */ "," K /* Number */ ")" [seqstrict]
rule @DivisionSign(N1:Number,N2:Number) => @ResolveNumber(@Division(N1,N2), @XorBool(@IsPositive(N1),@IsPositive(N2)))

syntax KItem ::= "@Division" "(" K /* Number */ "," K /* Number */ ")" [seqstrict]
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
rule @Division(I1:Int,  I2:Int    ) =>           I1  /Int             I2  when I1 =/=Int   0   andBool I2 =/=Int   0    andBool I1 %Int I2 ==Int  0
rule @Division(I1:Int,  I2:Int    ) => #@Int2Float(I1) /Float #@Int2Float(I2) when I1 =/=Int   0   andBool I2 =/=Int   0    andBool I1 %Int I2 =/=Int 0
rule @Division(I1:Int,  F2:Float  ) => #@Int2Float(I1) /Float F2            when I1 =/=Int   0   andBool F2 =/=Float 0.0
rule @Division(F1:Float,I2:Int    ) =>           F1  /Float #@Int2Float(I2) when F1 =/=Float 0.0 andBool I2 =/=Int   0
rule @Division(F1:Float,F2:Float  ) =>           F1  /Float F2            when F1 =/=Float 0.0 andBool F2 =/=Float 0.0

syntax KItem ::= "@DivisionZero" "(" K /* Number */ ")" [seqstrict]
rule @DivisionZero(@nz    ) => @NaN
rule @DivisionZero(0      ) => @NaN
rule @DivisionZero(I:Int  ) => 0   when I >Int 0
rule @DivisionZero(I:Int  ) => @nz when I <Int 0
rule @DivisionZero(0.0    ) => @NaN
rule @DivisionZero(F:Float) => 0   when F >Float 0.0
rule @DivisionZero(F:Float) => @nz when F <Float 0.0
rule @DivisionZero(@+Infinity) => 0
rule @DivisionZero(@-Infinity) => @nz

syntax KItem ::= "@DivisionInfinity" "(" K /* Number */ ")" [seqstrict]
rule @DivisionInfinity(@nz    ) => @-Infinity
rule @DivisionInfinity(0      ) => @+Infinity
rule @DivisionInfinity(I:Int  ) => @+Infinity when I >Int 0
rule @DivisionInfinity(I:Int  ) => @-Infinity when I <Int 0
rule @DivisionInfinity(0.0    ) => @+Infinity
rule @DivisionInfinity(F:Float) => @+Infinity when F >Float 0.0
rule @DivisionInfinity(F:Float) => @-Infinity when F <Float 0.0
rule @DivisionInfinity(@+Infinity) => @NaN
rule @DivisionInfinity(@-Infinity) => @NaN

syntax KItem ::= "@DivisionByZero" "(" K /* Number */ ")" [seqstrict]
rule @DivisionByZero(@nz    ) => @NaN
rule @DivisionByZero(0      ) => @NaN
rule @DivisionByZero(I:Int  ) => @+Infinity when I >Int 0
rule @DivisionByZero(I:Int  ) => @-Infinity when I <Int 0
rule @DivisionByZero(0.0    ) => @NaN
rule @DivisionByZero(F:Float) => @+Infinity when F >Float 0.0
rule @DivisionByZero(F:Float) => @-Infinity when F <Float 0.0
rule @DivisionByZero(@+Infinity) => @+Infinity
rule @DivisionByZero(@-Infinity) => @-Infinity

syntax KItem ::= "@DivisionByInfinity" "(" K /* Number */ ")" [seqstrict]
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

rule %bop(%mod,V1:Val,V2:Val) => @ResolveOverflow(@ModuloSign(ToNumber(V1),ToNumber(V2)))

syntax KItem ::= "@ModuloSign" "(" K /* Number */ "," K /* Number */ ")" [seqstrict]
rule @ModuloSign(N1:Number,N2:Number) => @ResolveNumber(@Modulo(N1,N2), @IsPositive(N1))

syntax KItem ::= "@Modulo" "(" K /* Number */ "," K /* Number */ ")" [seqstrict]
rule @Modulo(@NaN,_) => @NaN
rule @Modulo(_,@NaN) => @NaN
//
rule @Modulo(I1:Int,I2:Int) => I1 %Int I2 when I2 =/=Int 0
rule @Modulo(I1:Int,0     ) => @NaN
rule @Modulo(I1:Int,N2:Number) => @Modulo(#@Int2Float(I1),N2) when notBool(isInt(N2))
rule @Modulo(N1:Number,I2:Int) => @Modulo(N1,#@Int2Float(I2)) when notBool(isInt(N1))
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

rule %bop(%plus,V1:Val,V2:Val) => @PolymorphicAddition(ToPrimitive(V1,""), ToPrimitive(V2,""))

syntax KItem ::= "@PolymorphicAddition" "(" K /* Val */ "," K /* Val */ ")" [seqstrict]
rule @PolymorphicAddition(V1:Val,V2:Val) => @ResolveOverflow(@Addition(ToNumber(V1), ToNumber(V2))) when notBool(#@IsString(V1)) andBool notBool(#@IsString(V2))
rule @PolymorphicAddition(V1:Val,V2:Val) =>              @Concatnation(ToString(V1), ToString(V2))  when          isString(V1)   orBool          isString(V2)

syntax KItem ::= "@Concatnation" "(" K /* String */ "," K /* String */ ")" [seqstrict]
rule @Concatnation(S1:String,S2:String) => S1 +String S2

// 11.6.2 The Subtraction Operator ( - )

rule %bop(%minus,V1:Val,V2:Val) => @ResolveOverflow(@Subtraction(ToNumber(V1), ToNumber(V2)))

// 11.6.3 Applying the Additive Operators to Numbers

syntax KItem ::= "@Addition" "(" K /* Number */ "," K /* Number */ ")" [seqstrict]
rule @Addition(@NaN,_) => @NaN
rule @Addition(_,@NaN) => @NaN
//
rule @Addition(I1:Int,I2:Int    ) => I1 +Int I2
rule @Addition(I1:Int,F2:Float  ) => #@Int2Float(I1) +Float F2
rule @Addition( I:Int,@nz       ) => I
rule @Addition( _:Int,@+Infinity) => @+Infinity
rule @Addition( _:Int,@-Infinity) => @-Infinity
//
rule @Addition(F1:Float,I2:Int    ) => F1 +Float #@Int2Float(I2)
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

syntax KItem ::= "@Subtraction" "(" K /* Number */ "," K /* Number */ ")" [seqstrict]
rule @Subtraction(I1:Int,I2:Int) => I1 -Int I2
rule @Subtraction(N1:Number,N2:Number) => @Addition(N1,@Minus(N2)) when notBool(isInt(N1)) orBool notBool(isInt(N2))

// 11.7.1 The Left Shift Operator ( << )

rule %bop(%lshift,V1:Val,V2:Val) => @LeftShift(ToInt32(V1),ToUint32(V2))

syntax KItem ::= "@LeftShift" "(" K "," K ")" [seqstrict]

rule @LeftShift(I1:Int,I2:Int) => svalueMInt(shlMInt(mi(32,I1), I2 &Int 31 /* 0x1F */))

// 11.7.2 The Signed Right Shift Operator ( >> )

rule %bop(%rshift,V1:Val,V2:Val) => @SignedRightShift(ToInt32(V1),ToUint32(V2))

syntax KItem ::= "@SignedRightShift" "(" K "," K ")" [seqstrict]

// Arithmetic shift, sign extension shift: ashrMInt
rule @SignedRightShift(I1:Int,I2:Int) => svalueMInt(ashrMInt(mi(32,I1), I2 &Int 31 /* 0x1F */))

// 11.7.3 The Unsigned Right Shift Operator ( >>> )

rule %bop(%rshiftshift,V1:Val,V2:Val) => @UnsignedRightShift(ToUint32(V1),ToUint32(V2))

syntax KItem ::= "@UnsignedRightShift" "(" K "," K ")" [seqstrict]

// Logical shift, zero-filling shift: lshrMInt
rule @UnsignedRightShift(I1:Int,I2:Int) => uvalueMInt(lshrMInt(mi(32,I1), I2 &Int 31 /* 0x1F */))

// 11.8.1 The Less-than Operator ( < )

syntax Id ::= "$v1" | "$v2" | "$r"

rule %bop(%lt,V1:Val,V2:Val)
  => BEGIN
     Let $v1 = ToPrimitive(V1,"Number");
     Let $v2 = ToPrimitive(V2,"Number");
     Let $r = @LessThan($v1,$v2);
     If $r = Undefined then {
       Return false;
     } else {
       Return $r;
     }
     END

// 11.8.2 The Greater-than Operator ( > )

rule %bop(%gt,V1:Val,V2:Val)
  => BEGIN
     Let $v1 = ToPrimitive(V1,"Number");
     Let $v2 = ToPrimitive(V2,"Number");
     Let $r = @LessThan($v2,$v1);
     If $r = Undefined then {
       Return false;
     } else {
       Return $r;
     }
     END

// 11.8.3 The Less-than-or-equal Operator ( <= )

rule %bop(%le,V1:Val,V2:Val)
  => BEGIN
     Let $v1 = ToPrimitive(V1,"Number");
     Let $v2 = ToPrimitive(V2,"Number");
     Let $r = @LessThan($v2,$v1);
     If $r = Undefined then {
       Return false;
     } else {
       Return @Not($r);
     }
     END

// 11.8.4 The Greater-than-or-equal Operator ( >= )

rule %bop(%ge,V1:Val,V2:Val)
  => BEGIN
     Let $v1 = ToPrimitive(V1,"Number");
     Let $v2 = ToPrimitive(V2,"Number");
     Let $r = @LessThan($v1,$v2);
     If $r = Undefined then {
       Return false;
     } else {
       Return @Not($r);
     }
     END

// 11.8.5 The Abstract Relational Comparison Algorithm

syntax KItem ::= "@LessThan" "(" K "," K ")" [seqstrict]
rule @LessThan(V1:Val,V2:Val) => @LessThanNumber(ToNumber(V1),ToNumber(V2))
     when notBool(#@IsString(V1) andBool #@IsString(V2))
rule @LessThan(V1:String,V2:String) => @LessThanString(V1,V2)

syntax KItem ::= "@LessThanNumber" "(" K "," K ")" [seqstrict]
rule @LessThanNumber(@NaN,_) => Undefined
rule @LessThanNumber(_,@NaN) => Undefined
//
rule @LessThanNumber(I1:Int,I2:Int) => I1 <Int I2
//
rule @LessThanNumber(I:Int,N:Number) => @LessThanNumber(#@Int2Float(I),N) when notBool(isInt(N))
rule @LessThanNumber(N:Number,I:Int) => @LessThanNumber(N,#@Int2Float(I)) when notBool(isInt(N))
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

syntax KItem ::= "@LessThanString" "(" K "," K ")" [seqstrict]

rule @LessThanString(S1:String,S2:String) => S1 <String S2

// 11.8.6 The instanceof operator

rule %bop(%instanceof,V1:Val,V2:Val)
  => BEGIN
     If @IsOid(V2) = true then {
       If @HasHasInstance(V2) = true then {
         Return HasInstance(V2,V1);
       } else {
         Do @Throw(@TypeError("instanceof not having hasinstance",V2));
       }
     } else {
       Do @Throw(@TypeError("instanceof not object",V2));
     }
     END

syntax KItem /* Bool */ ::= "@HasHasInstance" "(" K /* Oid */ ")" [seqstrict]
rule @HasHasInstance(F:Oid)
  => @EqVal(GetInternalProperty(F,"Class"), "Function")

// 11.8.7 The in operator

rule %bop(%in,V1:Val,V2:Val)
  => BEGIN
     If @IsOid(V2) = true then {
       Return HasProperty(V2,ToString(V1));
     } else {
       Do @Throw(@TypeError("in",V2));
     }
     END

// 11.9.1 The Equals Operator ( == )

rule %bop(%eq, V1:Val,V2:Val) =>      @AbstractEquality(V1,V2)

// 11.9.2 The Does-not-equals Operator ( != )

rule %bop(%neq,V1:Val,V2:Val) => @Not(@AbstractEquality(V1,V2))

// 11.9.3 The Abstract Equality Comparison Algorithm

syntax KItem ::= "@AbstractEquality" "(" K /* Val */ "," K /* Val */ ")" [seqstrict]

rule @AbstractEquality(Undefined,Undefined) => true
rule @AbstractEquality(Undefined,@NullVal  ) => true
rule @AbstractEquality(Undefined,_:Bool    ) => false
rule @AbstractEquality(Undefined,_:String  ) => false
rule @AbstractEquality(Undefined,_:Number  ) => false
rule @AbstractEquality(Undefined,_:Oid     ) => false
//
rule @AbstractEquality(@NullVal,  Undefined) => true
rule @AbstractEquality(@NullVal,  @NullVal  ) => true
rule @AbstractEquality(@NullVal,  _:Bool    ) => false
rule @AbstractEquality(@NullVal,  _:String  ) => false
rule @AbstractEquality(@NullVal,  _:Number  ) => false
rule @AbstractEquality(@NullVal,  _:Oid     ) => false
//
rule @AbstractEquality(B:Bool,    Undefined) => false
rule @AbstractEquality(B:Bool,    @NullVal  ) => false
rule @AbstractEquality(B1:Bool,   B2:Bool   ) => B1 ==K B2
rule @AbstractEquality(B:Bool,    S:String  ) => @AbstractEquality(ToNumber(B), ToNumber(S))
rule @AbstractEquality(B:Bool,    N:Number  ) => @AbstractEquality(ToNumber(B), N)
rule @AbstractEquality(B:Bool,    O:Oid     ) => @AbstractEquality(ToNumber(B), ToPrimitive(O,""))
//
rule @AbstractEquality(S:String,  Undefined) => false
rule @AbstractEquality(S:String,  @NullVal  ) => false
rule @AbstractEquality(S:String,  B:Bool    ) => @AbstractEquality(ToNumber(S), ToNumber(B))
rule @AbstractEquality(S1:String, S2:String ) => S1 ==K S2
rule @AbstractEquality(S:String,  N:Number  ) => @AbstractEquality(ToNumber(S), N)
rule @AbstractEquality(S:String,  O:Oid     ) => @AbstractEquality(S, ToPrimitive(O,""))
//
rule @AbstractEquality(N:Number,  Undefined) => false
rule @AbstractEquality(N:Number,  @NullVal  ) => false
rule @AbstractEquality(N:Number,  B:Bool    ) => @AbstractEquality(N, ToNumber(B))
rule @AbstractEquality(N:Number,  S:String  ) => @AbstractEquality(N, ToNumber(S))
rule @AbstractEquality(N1:Number, N2:Number ) => @AbstractEqualityNumber(N1,N2)
rule @AbstractEquality(N:Number,  O:Oid     ) => @AbstractEquality(N, ToPrimitive(O,""))
//
rule @AbstractEquality(O:Oid,     Undefined) => false
rule @AbstractEquality(O:Oid,     @NullVal  ) => false
rule @AbstractEquality(O:Oid,     B:Bool    ) => @AbstractEquality(ToPrimitive(O,""), ToNumber(B))
rule @AbstractEquality(O:Oid,     S:String  ) => @AbstractEquality(ToPrimitive(O,""), S)
rule @AbstractEquality(O:Oid,     N:Number  ) => @AbstractEquality(ToPrimitive(O,""), N)
rule @AbstractEquality(O1:Oid,    O2:Oid    ) => O1 ==K O2

syntax KItem ::= "@AbstractEqualityNumber" "(" K /* Val */ "," K /* Val */ ")" [seqstrict]

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
rule @AbstractEqualityNumber(N1:Number,N2:Number) => SameValue(N1,N2)
     when notBool(N1 ==K @NaN orBool N2 ==K @NaN)
  andBool notBool((N1 ==K 0 orBool N1 ==K 0.0 orBool N1 ==K @nz) andBool
                  (N2 ==K 0 orBool N2 ==K 0.0 orBool N2 ==K @nz))

// 11.9.4 The Strict Equals Operator ( === )

rule %bop(%eqs, V1:Val,V2:Val) =>      @StrictEquality(V1,V2)

// 11.9.5 The Strict Does-not-equal Operator ( !== )

rule %bop(%neqs,V1:Val,V2:Val) => @Not(@StrictEquality(V1,V2))

// 11.9.6 The Strict Equality Comparison Algorithm

syntax KItem ::= "@StrictEquality" "(" K /* Val */ "," K /* Val */ ")" [seqstrict]

rule @StrictEquality(V1:Val,V2:Val) => SameValue(V1,V2)
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

rule %bop(%amp,  V1:Val,V2:Val) => @BitwiseAND(ToInt32(V1),ToInt32(V2))
rule %bop(%caret,V1:Val,V2:Val) => @BitwiseXOR(ToInt32(V1),ToInt32(V2))
rule %bop(%bar,  V1:Val,V2:Val) => @BitwiseOR (ToInt32(V1),ToInt32(V2))

syntax KItem /* Int32 */ ::= "@BitwiseAND" "(" K /* Int32 */ "," K /* Int32 */ ")" [seqstrict]
syntax KItem /* Int32 */ ::= "@BitwiseXOR" "(" K /* Int32 */ "," K /* Int32 */ ")" [seqstrict]
syntax KItem /* Int32 */ ::= "@BitwiseOR"  "(" K /* Int32 */ "," K /* Int32 */ ")" [seqstrict]

rule @BitwiseAND(I1:Int,I2:Int) => I1   &Int I2
rule @BitwiseXOR(I1:Int,I2:Int) => I1 xorInt I2
rule @BitwiseOR (I1:Int,I2:Int) => I1   |Int I2

// 11.11 Binary Logical Operators

context %bop(_:OpShortcut,HOLE,_)

rule %bop(%and,V1:Val,E2:Exp)
  => BEGIN
     If ToBoolean(V1) = true then {
       Return E2;
     } else {
       Return V1;
     }
     END

rule %bop(%or,V1:Val,E2:Exp)
  => BEGIN
     If ToBoolean(V1) = true then {
       Return V1;
     } else {
       Return E2;
     }
     END

// 11.12 Conditional Operator( ? : )

context %cond(HOLE,_,_)
rule %cond(V:Val,E1,E2)
  => BEGIN
     If ToBoolean(V) = true then {
       Return E1;
     } else {
       Return E2;
     }
     END

// 11.13.1 Simple Assignment ( = )
// TODO: Consider Strict mode, Step 4

rule %bop(%assign,L:Exp,E:Exp) => @PutValueAndReturn(@GetReference(L),E)

syntax KItem /* Val */ ::= "@PutValueAndReturn" "(" K /* Reference */ "," K /* Val */ ")" [seqstrict]
rule @PutValueAndReturn(L:Reference,V:Val) => PutValue(L,V) ~> V

// 11.13.2 Compound Assignment ( op= )

syntax Id ::= "$ref"
rule %bopassign(Op:Op,L:Exp,E:Exp)
  => BEGIN
     Let $ref = @GetReference(L);
     Do @PutValueAndReturn($ref, %bop(Op, GetValue($ref), E));
     END

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

syntax KItem ::= "@Exp" "(" K /* Val */ ")" [seqstrict]
rule @Exp(V:Val) => @UpdateStmtValue(V) ~> @Normal

syntax KItem /* .K */ ::= "@UpdateStmtValue" "(" K /* Val */ ")" [seqstrict]
rule <k> @UpdateStmtValue(V:Val) => . ... </k>
     <lastNonEmptyValue> _ => V </lastNonEmptyValue>
     when V =/=K Undefined
rule @UpdateStmtValue(Undefined) => .

// 12.5 The if Statement

context %if(HOLE,_,_)
rule %if(V:Val,S1,S2)
  => BEGIN
     If ToBoolean(V) = true then {
       Do S1;
     } else {
       Do S2;
     }
     END

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
  => BEGIN
     Let $e = E;
     If @OrBool(@EqVal($e, @NullVal), @EqVal($e, Undefined)) = true then {
       Return @Normal;
     } else {
       Let $o = ToObject($e);
       Let $props = @EnumerateAllProperties($o, .Map, .Set);
     //Let $props = @EnumerateAllProperties($o, .Set, .Set);
       Do @ForInAux(L, $o, $props, S);
     }
     END

syntax Stmt ::= "@ForInAux" "(" Exp "," K /* Oid */ "," K "," Stmt ")" [seqstrict(2,3)]
syntax Id ::= "$owner"
rule @ForInAux(_:Exp, _:Oid, @m(                   .Map), _:Stmt) => @Normal
rule @ForInAux(L:Exp, O:Oid, @m(P:Var |-> OP:Oid Ps:Map), S:Stmt)
  => BEGIN
     Let $desc = GetProperty(O,P);
     If $desc = Undefined then {
       Do @ForInAux(L,O,@m(Ps),S);
     } else {
       Let $owner = GetPropertyOwner(O,P);
       If $owner = OP then {
         Do %seq(%exp(%bop(%assign,L,%con(P:>String))),
                  %seq(S, @ForInAux(L,O,@m(Ps),S)));
       } else {
         // NOTE: UNSPECIFIED/UNDEFINED BEHAVIOR:
         // If the current property name refers to another property, then the behavior is not specified in the language standard.
         // This situation can occur when (for example)
         // - the existing property was deleted before visiting, which reveals a shadowed property.
         // - a new property was added, which shadows the existing property.
         // - the prototype chain was modified so that it inherits different objects.
         Do @unspecified;
       }
     }
     END

syntax KItem ::= "@unspecified"

syntax KItem /* Set */ ::= "@EnumerateAllProperties" "(" K /* Oid */ "," Map "," Set ")" [seqstrict(1)]
rule     @EnumerateAllProperties(@NullOid, TM:Map, _:Set) => @m(TM)
rule <k> @EnumerateAllProperties(O:Oid, TM:Map, KS:Set)
      => @EnumerateAllProperties(Proto, #@AddProp(O,Prop,TM,KS), keys(Prop) KS) ... </k>
     <obj>
       <oid> O </oid>
       <properties> Prop:Map </properties>
       <internalProperties> "Prototype" |-> Proto:Oid _:Map </internalProperties>
     </obj>
     when O =/=K @NullOid

syntax Map ::= "#@AddProp" "(" Oid "," Map "," Map "," Set ")" [function]
rule #@AddProp(O:Oid,                                      .Map, TM:Map,  _:Set) => TM
rule #@AddProp(O:Oid, (P:Var |-> Desc:PropertyDescriptor) M:Map, TM:Map, KS:Set) => #@AddPropAux(O, P, Desc, M, TM, KS)
//
syntax Map ::= "#@AddPropAux" "(" Oid "," Var "," PropertyDescriptor "," Map "," Map "," Set ")" [function]
rule #@AddPropAux(O:Oid, P:Var, Desc:PropertyDescriptor, M:Map, TM:Map, KS:Set) => #@AddProp(O, M, P |-> O TM, KS) when notBool(P in KS) andBool Desc.."Enumerable" ==K true
rule #@AddPropAux(O:Oid, P:Var, Desc:PropertyDescriptor, M:Map, TM:Map, KS:Set) => #@AddProp(O, M,         TM, KS) when         P in KS   orBool Desc.."Enumerable" ==K false
/*
syntax Map ::= "#@AddProp" "(" Oid "," Map "," Map "," Set ")" [function]
rule #@AddProp(O:Oid,                                      .Map, TM:Map,  _:Set) => TM
rule #@AddProp(O:Oid, (P:Var |-> Desc:PropertyDescriptor) M:Map, TM:Map, KS:Set) => #@AddProp(O, M, P |-> O TM, KS) when notBool(P in KS) andBool Desc."Enumerable" ==K true
rule #@AddProp(O:Oid, (P:Var |-> Desc:PropertyDescriptor) M:Map, TM:Map, KS:Set) => #@AddProp(O, M,         TM, KS) when         P in KS   orBool Desc."Enumerable" ==K false
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

rule %continue(L) => @Continue(L)

// 12.8 The break Statement

rule %break(L) => @Break(L)

// 12.9 The return Statement

context %return(HOLE)
rule %return(V:Val) => @Return(V)

// 12.10 The with Statement

rule <k> %with(E,S)
      => BEGIN
         Do @SetRunningCtx(NewObjectEnvironment(ToObject(E),Env,true,false), This);
         Let $result = S;
         Do @RestoreRunningCtx;
         Return $result;
         END
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

syntax KItem ::= "@Switch" "(" K /* Val */ "," Stmt "," Stmt "," Stmt ")" [seqstrict(1)]

rule @Switch(Input:Val, %seq(%case(E,S),C1), D, C2)
  => BEGIN
     If @StrictEquality(Input,E) = true then {
       Do %seq(S,%seq(C1,%seq(D,C2)));
     } else {
       Do @Switch(Input,C1,D,C2);
     }
     END

rule @Switch(Input:Val, %emptyStmt, D, %seq(%case(E,S),C2))
  => BEGIN
     If @StrictEquality(Input,E) = true then {
       Do %seq(S,C2);
     } else {
       Do @Switch(Input,%emptyStmt,D,C2);
     }
     END

rule @Switch(_:Val, %emptyStmt, %default(S), %emptyStmt) => S

rule @Switch(_:Val, %emptyStmt, %emptyStmt, %emptyStmt) => @Normal

rule %case(_,S) => S
rule %default(S) => S

// 12.12 Labelled Statements
// TODO: Move to the first-pass

rule %label(L,S) => %seq(#@AddContinueLabel(L,S), %labelBreak(L))

syntax Stmt ::= "#@AddContinueLabel" "(" Var "," Stmt ")" [function]
rule #@AddContinueLabel(L, %while(E,S)) => %while(E, %seq(S, %labelContinue(L)))
rule #@AddContinueLabel(L, %do(S,E))    =>    %do(   %seq(S, %labelContinue(L)), E)
rule #@AddContinueLabel(L, %for  (S0,E1,E2,S)) => %for  (S0, E1, E2, %seq(S, %labelContinue(L)))
rule #@AddContinueLabel(L, %forin(S0,E1,E2,S)) => %forin(S0, E1, E2, %seq(S, %labelContinue(L)))
rule #@AddContinueLabel(L, %label(L',S)) => %label(L', #@AddContinueLabel(L,S))
rule #@AddContinueLabel(_, S) => S   when getKLabel(S) =/=KLabel '%while`(_`,_`)
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

syntax KItem ::= "@TryCatch" "(" Stmt "," K /* Var */ "," Stmt ")" [seqstrict(2)]
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

rule <k> (@TryFinally(S:K,Finally:Stmt) => S ~> @PopExcTF) ~> K </k>
     <ctrl>
       <excStack> (.List => ListItem(@excTF(Finally,K,Ctrl))) _:List </excStack>
       Ctrl
     </ctrl>

rule <k> CT:CompletionType ~> @PopExcTF => @ResolveFinally(Finally, CT) ... </k>
     <ctrl>
       <excStack> (ListItem(@excTF(Finally,_,_)) => .List) _:List </excStack>
       _
     </ctrl>

rule <k> @Throw(V) ~> _ => @ResolveFinally(Finally, @Throw(V)) ~> K </k>
     <ctrl>
       <excStack> (ListItem(@excTF(Finally,K,Ctrl)) => .List) _:List </excStack>
       (_ => Ctrl)
     </ctrl>

syntax KItem ::= "@TryCatchFinally" "(" Stmt "," K /* Var */ "," Stmt "," Stmt ")" [seqstrict(2)]
           | "@PopExcTCF"

rule <k> (@TryCatchFinally(S:Stmt,X:Var,Catch:Stmt,Finally:Stmt) => S ~> @PopExcTCF) ~> K </k>
     <ctrl>
       <excStack> (.List => ListItem(@excTCF(X,Catch,Finally,K,Ctrl))) _:List </excStack>
       Ctrl
     </ctrl>

rule <k> CT:CompletionType ~> @PopExcTCF => @ResolveFinally(Finally, CT) ... </k>
     <ctrl>
       <excStack> (ListItem(@excTCF(_,_,Finally,_,_)) => .List) _:List </excStack>
       _
     </ctrl>

rule <k> @Throw(V) ~> _ => @TryFinally(@Catch(X,V,Catch), Finally) ~> K </k>
     <ctrl>
       <excStack> (ListItem(@excTCF(X,Catch,Finally,K,Ctrl)) => .List) _:List </excStack>
       (_ => Ctrl)
     </ctrl>

// NOTE: If the first argument evaluates to 'Throw', then it is handled differently with Throw's rules.
//       The second argument should be non-strict, because it could be 'Throw'.
syntax KItem ::= "@ResolveFinally" "(" K /* CompletionType */ "," K /* CompletionType or Throw */ ")" [seqstrict(1)]
rule @ResolveFinally( _:CompletionTypeNormal,CT:K) => CT
rule @ResolveFinally(CT:CompletionTypeAbrupt, _:K) => CT

syntax KItem /* CompletionType */ ::= "@Catch" "(" K /* Var */ "," K /* Val */ "," Stmt ")" [seqstrict(1,2)]
syntax Id ::= "$catchEnv" | "$result"
rule <k> @Catch(X:Var,V:Val,Catch:Stmt)
      => BEGIN
         Let $catchEnv = NewDeclarativeEnvironment(E, Strict);
         Do CreateMutableBinding($catchEnv, X, false);
         Do SetMutableBinding($catchEnv, X, V, false);
         Do @SetRunningCtx($catchEnv, This);
         Let $result = Catch;
         Do @RestoreRunningCtx;
         Return $result;
         END
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
/* NOTE: Implementing breakpoint as not giving the semantics
rule %debugger => %emptyStmt
*/

//////////////////////////////////////////////////////////////////////////////
// 13 Function Definition
//////////////////////////////////////////////////////////////////////////////

syntax KItem /* Oid */ ::= "@FunctionDeclaration" "(" K /* Var */ "," Exps "," Stmt ")" [seqstrict(1)]
rule @FunctionDeclaration(_,Params:Exps,FunBody:Stmt)
  => @FunctionExpressionAnonymous(Params,FunBody)

syntax KItem /* Oid */ ::= "@FunctionExpressionAnonymous" "(" Exps "," Stmt ")"
rule <k> @FunctionExpressionAnonymous(Params:Exps, FunBody:Stmt)
      => @CreateFunctionObject(Params, FunBody, E, #@IsStrict(FunBody) orBool Strict) ... </k> // 10.1.1 Strict Mode Code, Case 3
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

syntax KItem /* Oid */ ::= "@FunctionExpressionRecursive" "(" K /* Var */ "," Exps "," Stmt ")" [seqstrict(1)]
syntax Id ::= "$funcEnv" | "$closure"
rule <k> @FunctionExpressionRecursive(F:Var, Params:Exps, FunBody:Stmt)
      => BEGIN
         Let $strict = #@IsStrict(FunBody) orBool Strict; // 10.1.1 Strict Mode Code, Case 3
         Let $funcEnv = NewDeclarativeEnvironment(E, $strict);
         Do CreateImmutableBinding($funcEnv, F);
         Let $closure = @CreateFunctionObject(Params, FunBody, $funcEnv, $strict);
         Do InitializeImmutableBinding($funcEnv, F, $closure);
         Return $closure;
         END
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

syntax KItem /* Oid */ ::= "@CreateFunctionObject" "(" Exps "," Stmt "," K /* Eid */ "," K /* Bool */ ")" [seqstrict(3,4)]
rule <k> @CreateFunctionObject(Params:Exps, FunBody:Stmt, Scope:Eid, Strict:Bool) => @CreateFunctionObjectAux(@o(!F), Strict) ... </k>
     <objs>
       (. => <obj>
               <oid> @o(!F:Int) </oid>
               <properties>
                 "length"           |-> @desc("Value" |-> #@Length(Params) "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
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

syntax KItem /* Oid */ ::= "@CreateFunctionObjectAux" "(" K /* Oid */ "," K /* Bool */ ")" [seqstrict]
rule <k> @CreateFunctionObjectAux(O:Oid,false) => O ... </k>
rule <k> @CreateFunctionObjectAux(O:Oid,true ) => O ... </k>
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

syntax KItem /* Val */ ::= "Call" "(" K /* Oid */ "," K /* Val */ "," K /* Vals */ ")" [seqstrict]
rule Call(F:Oid, This:Val, Args:Vals)
  => BEGIN
     If @IsBoundFunction(F) = true then {
       Do Call@BoundFunction(F,This,Args);
     } else {
       Do Call@Default(F,This,Args);
     }
     END
     when #@IsStandardBuiltinObject(F) ==K false // TODO: could it be made in uniform way?

syntax KItem /* Val */ ::= "Call@Default" "(" K /* Oid */ "," K /* Val */ "," K /* Vals */ ")" [seqstrict]
rule <k> Call@Default(F:Oid, This:Val, Args:Vals)
      => @EnterFunctionCode(F,This,Args) ~> Code ~> @ExitFunctionCode ... </k>
     <obj>
       <oid> F </oid>
       <internalProperties> "Code" |-> Code:Stmt _:Map </internalProperties>
       _
     </obj>
rule <k> Call@Default(F:Oid,_,_) => Undefined ... </k>
     <obj>
       <oid> F </oid>
       <internalProperties> Prop:Map </internalProperties>
       _
     </obj>
     when notBool("Code" in keys(Prop))

syntax KItem ::= "@ExitFunctionCode"
rule @Return(V:Val) ~> @ExitFunctionCode => @RestoreRunningCtx ~> V
rule @Normal        ~> @ExitFunctionCode => @RestoreRunningCtx ~> Undefined

// 13.2.2 [[Construct]]

syntax KItem /* Oid */ ::= "Construct" "(" K /* Oid */ "," K /* Vals */ ")" [seqstrict]
rule Construct(F:Oid, Args:Vals)
  => BEGIN
     If @IsBoundFunction(F) = true then {
       Do Construct@BoundFunction(F,Args);
     } else {
       Do Construct@Default(F,Args);
     }
     END
     when #@IsStandardBuiltinObject(F) ==K false // TODO: could it be made in uniform way?

syntax KItem /* Oid */ ::= "Construct@Default" "(" K /* Oid */ "," K /* Vals */ ")" [seqstrict]
rule <k> Construct@Default(F:Oid, Args:Vals) => Call(F,@o(!N),Args) ~> @ReturnConstructedObject(@o(!N)) ... </k>
     <objs>
       (. => <obj>
               <oid> @o(!N:Int) </oid>
               <properties> .Map </properties>
               <internalProperties>
                 "Prototype"  |-> #@ResolvePrototype(Prototype)
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

syntax Oid ::= "#@ResolvePrototype" "(" Val ")" [function]
rule #@ResolvePrototype(Prototype:Oid) => Prototype
rule #@ResolvePrototype(Prototype:Val) => @ObjectProtoOid when notBool(#@IsOid(Prototype))

// Return the newly created object, but if the previous construct call returns another object, then use it.
// NOTE: (From p.31 of the book, Good Parts): If the function was invoked with the new prefix and the return value is not an object, then this (the new object) is returned instaed.
syntax KItem /* Oid */ ::= "@ReturnConstructedObject" "(" Oid ")" // nostrict
rule O:Oid ~> @ReturnConstructedObject(_    ) => O
rule V:Val ~> @ReturnConstructedObject(O:Oid) => O when notBool(#@IsOid(V))

// 13.2.3 The [[ThrowTypeError]] Function Object

// TODO: check if this simple version works correctly
rule Call(@("ThrowTypeError"), _:Val, _:Vals) => @Throw(@TypeError("ThrowTypeError",""))

//////////////////////////////////////////////////////////////////////////////
// 14 Program
//////////////////////////////////////////////////////////////////////////////

context %seq(HOLE, _)
context %seq(_:CompletionTypeNormal, HOLE)
rule %seq(   _:CompletionTypeNormal, Tail:CompletionType) => Tail
rule %seq(Head:CompletionTypeReturn,    _:Stmt          ) => Head
rule %seq(Head:CompletionTypeGoto,   Tail:Stmt          ) => @ResolveGoto(Head, Tail)

syntax KItem ::= "@ResolveGoto" "(" K /* CompletionTypeGoto */ "," Stmt ")" [seqstrict(1)]
rule @ResolveGoto(CT:CompletionTypeGoto, S:Stmt         ) => @Normal             when #@IsMatch(CT,S)  ==K true
rule @ResolveGoto(CT:CompletionTypeGoto, S:Stmt         ) => CT                  when #@IsMatch(CT,S)  ==K false
//
rule @ResolveGoto(CT:CompletionTypeGoto, %seq(S1,S2)) => S2                  when #@IsMatch(CT,S1) ==K true
rule @ResolveGoto(CT:CompletionTypeGoto, %seq(S1,S2)) => @ResolveGoto(CT,S2) when #@IsMatch(CT,S1) ==K false
//
rule @ResolveGoto(CT:CompletionTypeGoto, %seq(%seq(S1,S2),S3)) => @ResolveGoto(CT, %seq(S1,%seq(S2,S3)))

syntax Bool ::= "#@IsMatch" "(" CompletionTypeGoto "," Stmt ")" [function]
rule #@IsMatch(@Break(L:Var),    %labelBreak(L:Var ))    => true
rule #@IsMatch(@Break(""   ),    %labelBreak(_     ))    => true
rule #@IsMatch(@Break(L:Var),    %labelBreak(L':Var))    => false when L =/=K "" andBool L =/=K L'
rule #@IsMatch(@Break(_    ),    S                  )    => false when getKLabel(S) =/=KLabel '%labelBreak`(_`)
                                                              andBool getKLabel(S) =/=KLabel '%seq`(_`,_`)
rule #@IsMatch(@Continue(L:Var), %labelContinue(L:Var )) => true
rule #@IsMatch(@Continue(""   ), %labelContinue(_     )) => true
rule #@IsMatch(@Continue(L:Var), %labelContinue(L':Var)) => false when L =/=K "" andBool L =/=K L' 
rule #@IsMatch(@Continue(_    ), S                     ) => false when getKLabel(S) =/=KLabel '%labelContinue`(_`)
                                                              andBool getKLabel(S) =/=KLabel '%seq`(_`,_`)

// NOTE: @FunctionDeclaration is not executed here, but at 10.5 Declaration Binding Instantiation
rule %fdecl(_,_,_) => %emptyStmt

//////////////////////////////////////////////////////////////////////////////
// 14.1 Directive Prologues and the Use Strict Directive

syntax Bool ::= "#@IsStrict" "(" Stmt ")" [function]
rule #@IsStrict(S:Stmt) => #@IsStrictAux(#@SkipPrelude(S))

syntax Bool ::= "#@IsStrictAux" "(" Stmt ")" [function]
rule #@IsStrictAux(     %exp(%con("USE_STRICT"))   ) => true
rule #@IsStrictAux(%seq(%exp(%con("USE_STRICT")),_)) => true
rule #@IsStrictAux(%seq(%exp(%con(C:String    )),S)) => #@IsStrictAux(S) when C =/=String "USE_STRICT"
rule #@IsStrictAux(_) => false [owise]

syntax Stmt ::= "#@SkipPrelude" "(" Stmt ")" [function]
rule #@SkipPrelude(%seq(%exp(%con("BEGIN PRELUDE")),S)) => #@SkipPreludeAux(S)
rule #@SkipPrelude(%seq(S1,S2)) => %seq(S1,S2) when S1 =/=K %exp(%con("BEGIN PRELUDE"))
rule #@SkipPrelude(S) => S when getKLabel(S) =/=KLabel '%seq`(_`,_`)
//
syntax Stmt ::= "#@SkipPreludeAux" "(" Stmt ")" [function]
rule #@SkipPreludeAux(%seq(%exp(%con("END PRELUDE")),S)) => S
rule #@SkipPreludeAux(%seq(S1,S2)) => #@SkipPreludeAux(S2) when S1 =/=K %exp(%con("END PRELUDE"))

//////////////////////////////////////////////////////////////////////////////
// 15 Standard Built-in ECMAScript Objects
//////////////////////////////////////////////////////////////////////////////

#include "js-standard-builtin-objects.k"

//////////////////////////////////////////////////////////////////////////////
// 16 Errors
//////////////////////////////////////////////////////////////////////////////

syntax KItem ::= "@CheckEarlyErrors" "(" K /* Bool */ "," Stmt ")" [seqstrict(1)]
rule @CheckEarlyErrors(Strict:Bool, Code:Stmt) => @CEE(Strict, .Set, Code)

syntax KItem ::= "@CEE" /* Check Early Errors */ "(" K /* Bool */ "," Set "," K /* Stmt or Exp or Exps */ ")" [seqstrict(1)]
//
rule @CEE(Strict:Bool, Ls:Set, %fdecl(F:Var,Es:Exps,S:Stmt))            => @CheckReserved(Strict,F) ~> @SMRFun(Strict,F,Es,S) ~> @CEE(Strict,Ls,Es) ~> @CEE(Strict orBool #@IsStrict(S), .Set, S)
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
rule @CEE(Strict:Bool, Ls:Set, %switch(E:Exp,S1:Stmt,S2:Stmt,S3:Stmt))  => @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,S1) ~> @CEE(Strict,Ls,S2) ~> @CEE(Strict,Ls,S3)
rule @CEE(Strict:Bool, Ls:Set, %case(E:Exp,S:Stmt))                     => @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,S)
rule @CEE(Strict:Bool, Ls:Set, %default(S:Stmt))                        => @CEE(Strict,Ls,S)
rule @CEE(Strict:Bool, Ls:Set, %debugger)                               => .
//
rule @CEE(Strict:Bool, Ls:Set, %con(_:Const))                           => .
rule @CEE(Strict:Bool, Ls:Set, %var(N:Var))                             => @CheckReserved(Strict,N)
rule @CEE(Strict:Bool, Ls:Set, %arr(Es:Exps))                           => @CEE(Strict,Ls,Es)
rule @CEE(Strict:Bool, Ls:Set, %obj(Es:Exps))                           => @CheckDuplicatedProp(Strict,Es) ~> @CEE(Strict,Ls,Es)
rule @CEE(Strict:Bool, Ls:Set, %prop(P:Var,E:Exp))                      => /* @CheckReserved(Strict,P) ~> */ @CEE(Strict,Ls,E)
rule @CEE(Strict:Bool, Ls:Set, %get(P:Var,      S:Stmt))                => /* @CheckReserved(Strict,P) ~> */                                                                       @CEE(Strict orBool #@IsStrict(S), .Set, S)
rule @CEE(Strict:Bool, Ls:Set, %set(P:Var,X:Var,S:Stmt))                => /* @CheckReserved(Strict,P) ~> */ @CheckReserved(Strict,X) ~> @SMRVar(Strict orBool #@IsStrict(S), X) ~> @CEE(Strict orBool #@IsStrict(S), .Set, S)
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
rule @CEE(Strict:Bool, Ls:Set, %fun(X:Var,Es:Exps,S:Stmt))              => @CheckReserved(Strict,X) ~> @SMRFun(Strict,X, Es,S) ~> @CEE(Strict,Ls,Es) ~> @CEE(Strict orBool #@IsStrict(S), .Set, S)
rule @CEE(Strict:Bool, Ls:Set, %fun(      Es:Exps,S:Stmt))              =>                             @SMRFun(Strict,"",Es,S) ~> @CEE(Strict,Ls,Es) ~> @CEE(Strict orBool #@IsStrict(S), .Set, S)
//
rule @CEE(Strict:Bool, Ls:Set, %cons(E:Exp,Es:Exps))                    => @CEE(Strict,Ls,E) ~> @CEE(Strict,Ls,Es)
rule @CEE(Strict:Bool, Ls:Set, %nil)                                    => .

syntax KItem ::= "@CheckDuplicatedProp" "(" K /* Bool */ "," Exps ")" [seqstrict(1)]
rule @CheckDuplicatedProp(Strict:Bool, Es:Exps)
  => BEGIN
     If @DuplicatedProp(Strict,Es) = true then {
       Do @Throw(@SyntaxError("Duplicated properties",Es));
     };
     END
//
syntax KItem ::= "@DuplicatedProp" "(" K /* Bool */ "," Exps ")" [seqstrict(1)]
rule @DuplicatedProp(Strict:Bool,Es:Exps) => @DuplicatedPropAux(Strict,Es,.Set,.Set,.Set)
//
syntax KItem ::= "@DuplicatedPropAux" "(" K /* Bool */ "," Exps "," Set "," Set "," Set ")" [seqstrict(1)]
rule @DuplicatedPropAux(Strict:Bool, %cons(%prop(D:Var,_), Es:Exps), DS:Set, GS:Set, SS:Set) => true when D in GS orBool D in SS
rule @DuplicatedPropAux(Strict:Bool, %cons(%prop(D:Var,_), Es:Exps), DS:Set, GS:Set, SS:Set) => true when D in DS andBool Strict
rule @DuplicatedPropAux(Strict:Bool, %cons(%prop(D:Var,_), Es:Exps), DS:Set, GS:Set, SS:Set) => @DuplicatedPropAux(Strict, Es, SetItem(D) DS, GS, SS) when notBool(D in GS orBool D in SS)
                                                                                                                                                   andBool notBool(D in DS andBool Strict)
//
rule @DuplicatedPropAux(Strict:Bool, %cons(%get(G:Var,_),  Es:Exps), DS:Set, GS:Set, SS:Set) => true when G in GS orBool G in DS
rule @DuplicatedPropAux(Strict:Bool, %cons(%get(G:Var,_),  Es:Exps), DS:Set, GS:Set, SS:Set) => @DuplicatedPropAux(Strict, Es, DS, SetItem(G) GS, SS) when notBool(G in GS orBool G in DS)
//
rule @DuplicatedPropAux(Strict:Bool, %cons(%set(S:Var,_,_),Es:Exps), DS:Set, GS:Set, SS:Set) => true when S in SS orBool S in DS
rule @DuplicatedPropAux(Strict:Bool, %cons(%set(S:Var,_,_),Es:Exps), DS:Set, GS:Set, SS:Set) => @DuplicatedPropAux(Strict, Es, DS, GS, SetItem(S) SS) when notBool(S in SS orBool S in DS)
//
rule @DuplicatedPropAux(Strict:Bool, %nil, _, _, _) => false

syntax KItem ::= "@CheckInvalidLValue" "(" K /* Bool */ "," Exp ")" [seqstrict(1)]
rule @CheckInvalidLValue(Strict:Bool, E:Exp)
  => BEGIN
     If @InvalidLValue(Strict,E) = true then {
       Do @Throw(@SyntaxError("In strict mode, 'eval' or 'arguments' cannot be updated",E));
     };
     END
//
syntax KItem /* Bool */ ::= "@InvalidLValue" "(" K /* Bool */ "," Exp ")" [seqstrict(1)]
rule @InvalidLValue(true, %bop(%assign,%var("eval"     ),_)) => true
rule @InvalidLValue(true, %bop(%assign,%var("arguments"),_)) => true
//
rule @InvalidLValue(true, %bopassign(_,%var("eval"     ),_)) => true
rule @InvalidLValue(true, %bopassign(_,%var("arguments"),_)) => true
//
rule @InvalidLValue(true, %pre(%inc,%var("eval"     ))) => true
rule @InvalidLValue(true, %pre(%inc,%var("arguments"))) => true
//
rule @InvalidLValue(true, %pre(%dec,%var("eval"     ))) => true
rule @InvalidLValue(true, %pre(%dec,%var("arguments"))) => true
//
rule @InvalidLValue(true, %post(%var("eval"     ),%inc)) => true
rule @InvalidLValue(true, %post(%var("arguments"),%inc)) => true
//
rule @InvalidLValue(true, %post(%var("eval"     ),%dec)) => true
rule @InvalidLValue(true, %post(%var("arguments"),%dec)) => true
//
rule @InvalidLValue(_,_) => false [owise]


syntax KItem ::= "@CheckWith" "(" K /* Bool */ ")" [seqstrict]
rule @CheckWith(Strict:Bool)
  => BEGIN
     If Strict = true then {
       Do @Throw(@SyntaxError("In strict mode, with cannot be used",""));
     };
     END

syntax KItem ::= "@CheckGoto" "(" Set "," K /* Var */ ")" [seqstrict(2)]
rule @CheckGoto(Ls:Set, L:Var)
  => BEGIN
     If notBool(L in Ls) = true then {
       Do @Throw(@SyntaxError("continue or break without nested iteration or switch stmt",L));
     };
     END

//////////////////////////////////////////////////////////////////////////////
// Strict Mode Restrictions
//////////////////////////////////////////////////////////////////////////////

// 11.1.5, PropertyAssignment : set PropertyName ( PropertySetParameterList ) { FunctionBody } 
// 12.2.1 Strict Mode Restrictions
// 12.10.1 Strict Mode Restrictions
// 12.14.1 Strict Mode Restrictions
// 13.1 Strict Mode Restrictions

syntax KItem ::= "@SMRVar" "(" K /* Bool */ "," K /* Var */ ")" [seqstrict]
rule @SMRVar(Strict:Bool, P:Var)
  => BEGIN
     If @AndBool(Strict, @OrBool(P ==K "eval", P ==K "arguments")) = true then {
       Do @Throw(@SyntaxError("Strict Mode Restrictions, eval or arguments as a variable",P));
     };
     END

syntax KItem ::= "@SMRFun" "(" K /* Bool */ "," K /* Var */ "," Exps "," Stmt ")" [seqstrict(1,2)]
rule @SMRFun(Strict:Bool, F:Var, Ps:Exps, FB:Stmt)
  => BEGIN
     Let $strict = #@IsStrict(FB) orBool Strict;
     Do @SMRVar($strict,F);
     Do @SMRVars($strict,Ps);
     Do @SMRParams($strict,Ps);
     END
//
syntax KItem ::= "@SMRVars" "(" K /* Bool */ "," Exps ")" [seqstrict(1)]
rule @SMRVars(Strict:Bool, %cons(%var(X:Var),Ps:Exps)) => @SMRVar(Strict,X) ~> @SMRVars(Strict,Ps)
rule @SMRVars(Strict:Bool, %nil) => .
//
syntax KItem ::= "@SMRParams" "(" K /* Bool */ "," Exps ")" [seqstrict(1)]
rule @SMRParams(Strict:Bool, Ps:Exps)
  => BEGIN
     If @AndBool(Strict, @DuplicatedParams(Ps)) = true then {
       Do @Throw(@SyntaxError("Strict Mode Restrictions, duplicated parameters",Ps));
     };
     END
//
syntax KItem ::= "@DuplicatedParams" "(" Exps ")"
rule @DuplicatedParams(Ps:Exps) => @DuplicatedParamsAux(Ps,.Set)
//
syntax KItem ::= "@DuplicatedParamsAux" "(" Exps "," Set ")"
rule @DuplicatedParamsAux(%cons(%var(X:Var),Ps:Exps),S:Set) => true when X in S
rule @DuplicatedParamsAux(%cons(%var(X:Var),Ps:Exps),S:Set) => @DuplicatedParamsAux(Ps, SetItem(X) S) when notBool(X in S)
rule @DuplicatedParamsAux(%nil,_) => false

//////////////////////////////////////////////////////////////////////////////
// Pseudo-code evaluation
//////////////////////////////////////////////////////////////////////////////

#include "js-pseudo-code.k"

//////////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////////

syntax KItem /* .K */ ::= "@True?" | "@False?"
rule true  ~> @True?  => .
rule false ~> @False? => .

syntax KItem /* .K */ ::= "@Ignore"
rule _:Val ~> @Ignore => .

syntax KItem /* Int */ ::= "@Length" "(" Exps ")"
rule @Length(Es:Exps) => #@Length(Es)
//
syntax Int ::= "#@Length" "(" Exps ")" [function]
rule #@Length(%cons(_,Es)) => 1 +Int #@Length(Es)
rule #@Length(%nil) => 0

syntax KItem /* Int */ ::= "@LengthVals" "(" K /* Vals */ ")" [seqstrict]
rule @LengthVals(Vs:Vals) => #@LengthVals(Vs)
//
syntax Int ::= "#@LengthVals" "(" Vals ")" [function]
rule #@LengthVals(@Cons(_,Vs)) => 1 +Int #@LengthVals(Vs)
rule #@LengthVals(@Nil) => 0

// TODO: remove
syntax Val ::= PropertyDescriptor ".." Var [function]
rule @desc(X |-> V:Val _) .. X:Var => V
rule @desc(M:Map        ) .. X:Var => Undefined when notBool(X in keys(M))

syntax KItem /* Val */ ::= K /* PropertyDescriptor */ "." Var [seqstrict(1)]
rule @desc(X |-> V:Val _) . X:Var => V
rule @desc(M:Map        ) . X:Var => Undefined when notBool(X in keys(M))

syntax KItem /* Bool */ ::= "@SubDesc" "(" K /* PropertyDescriptor */ "," K /* PropertyDescriptor */ ")" [seqstrict]
rule @SubDesc(@desc(M1:Map), @desc(M2:Map)) => @SubDescAux(keys(M1), @desc(M1), @desc(M2))
//
syntax KItem /* Bool */ ::= "@SubDescAux" "(" Set "," K /* PropertyDescriptor */ "," K /* PropertyDescriptor */ ")" [seqstrict(2,3)]
rule @SubDescAux(                    .Set , @desc( _:Map), @desc( _:Map)) => true
rule @SubDescAux((SetItem(X:String) S:Set), @desc(M1:Map), @desc(M2:Map)) => @AndBool(@SubDescAuxSingle(X,M1,M2), @SubDescAux(S,@desc(M1),@desc(M2)))
//
syntax KItem /* Bool */ ::= "@SubDescAuxSingle" "(" K /* String */ "," Map "," Map ")" [seqstrict(1)]
rule @SubDescAuxSingle(X:String,M1:Map,M2:Map) => SameValue(M1[X], M2[X]) when X in keys(M2)
rule @SubDescAuxSingle(X:String,M1:Map,M2:Map) => false [owise]

/*
syntax Bool ::= "@SubDesc" "(" PropertyDescriptor "," PropertyDescriptor ")" [function]
rule @SubDesc(@desc(                 .Map), @desc(               _     )) => true
rule @SubDesc(@desc(               M1:Map), @desc(                 .Map)) => false                         when M1 =/=Map .Map
rule @SubDesc(@desc((X |-> V1:Val) M1:Map), @desc((X |-> V2:Val) M2:Map)) => @SubDesc(@desc(M1),@desc(M2)) when         SameValue(V1,V2)
rule @SubDesc(@desc((X |-> V1:Val) _     ), @desc((X |-> V2:Val) _     )) => false                         when notBool(SameValue(V1,V2))
rule @SubDesc(@desc((X |-> _     ) _     ), @desc(               M2:Map)) => false                         when notBool(X in keys(M2))
rule @SubDesc(@desc(               M1:Map), @desc((X |-> V2:Val) M2:Map)) => @SubDesc(@desc(M1),@desc(M2)) when notBool(X in keys(M2))
*/

syntax Map ::= "#@AddMap" "(" K "," K "," Map ")" [function]
rule #@AddMap(X, V,           M:Map) => (X |-> V) M when notBool(X in keys(M))
rule #@AddMap(X, V, (X |-> _) M:Map) => (X |-> V) M when notBool(X in keys(M))

syntax KItem /* .K */ ::= "@AddDesc" "(" K /* Var */ "," K /* Val */ "," K /* PropertyDescriptor */ ")" [seqstrict]
rule @AddDesc(X:Var,V:Val,@desc(Desc)) => @desc(#@AddMap(X,V,Desc))

syntax KItem /* Bool */ ::= "@MemDesc" "(" K /* PropertyDescriptor */ "," K /* Var */ ")" [seqstrict]
rule @MemDesc(@desc(Desc),X:Var) => X in keys(Desc)

syntax KItem ::= "@GenDesc" "(" K "," K                                     ")" [seqstrict]
           | "@GenDesc" "(" K "," K "," K "," K                         ")" [seqstrict]
           | "@GenDesc" "(" K "," K "," K "," K "," K "," K             ")" [seqstrict]
           | "@GenDesc" "(" K "," K "," K "," K "," K "," K "," K "," K ")" [seqstrict]
rule @GenDesc(X1:Var,V1:Val                                          ) => @desc(X1 |-> V1                              )
rule @GenDesc(X1:Var,V1:Val,X2:Var,V2:Val                            ) => @desc(X1 |-> V1 X2 |-> V2                    )
rule @GenDesc(X1:Var,V1:Val,X2:Var,V2:Val,X3:Var,V3:Val              ) => @desc(X1 |-> V1 X2 |-> V2 X3 |-> V3          )
rule @GenDesc(X1:Var,V1:Val,X2:Var,V2:Val,X3:Var,V3:Val,X4:Var,V4:Val) => @desc(X1 |-> V1 X2 |-> V2 X3 |-> V3 X4 |-> V4)

// NOTE: Set of Values => Vals
syntax KItem /* Vals */ ::= "@Set2Vals" "(" Set ")"
rule @Set2Vals(S:Set) => #@Set2Vals(S)
//
syntax Vals ::= "#@Set2Vals" "(" Set ")" [function]
rule #@Set2Vals(SetItem(V:Val) Vs:Set) => @Cons(V, #@Set2Vals(Vs))
rule #@Set2Vals(                 .Set) => @Nil

syntax KItem /* Vals */ ::= "@AppendVals" "(" K /* Vals */ "," K /* Vals */ ")" [seqstrict]
rule @AppendVals(Vs1:Vals,Vs2:Vals) => #@AppendVals(Vs1,Vs2)
//
syntax Vals ::= "#@AppendVals" "(" Vals "," Vals ")" [function]
rule #@AppendVals(@Cons(V1:Val,Vs1:Vals), Vs2:Vals) => @Cons(V1, #@AppendVals(Vs1,Vs2))
rule #@AppendVals(@Nil, Vs:Vals) => Vs

syntax KItem ::= "@Print" "(" K ")" [seqstrict]
rule <k> @Print(S:String) => Undefined ... </k>
     <out> _:List (.List => ListItem(S)) </out>

syntax KItem ::= "@PrintNewline" "(" K ")" [seqstrict]
rule @PrintNewline(S:String) => @Print(S +String "\n")

syntax KItem ::= "@LOG" "(" K ")"
rule <k> @LOG(K) => . ... </k>
     <log> _:List (.List => ListItem(K)) </log>

syntax KItem /* Bool */ ::= "@IsPrimitive" "(" K /* Val */ ")" [seqstrict]
rule @IsPrimitive(V:Val) => #@IsBool(V) orBool #@IsString(V) orBool #@IsNumber(V)

syntax Bool ::= "#@IsBool" "(" Val ")" [function]
rule #@IsBool(Undefined) => false
rule #@IsBool(@NullVal  ) => false
rule #@IsBool(_:Bool    ) => true
rule #@IsBool(_:String  ) => false
rule #@IsBool(_:Number  ) => false
rule #@IsBool(_:Oid     ) => false

syntax Bool ::= "#@IsString" "(" Val ")" [function]
rule #@IsString(Undefined) => false
rule #@IsString(@NullVal  ) => false
rule #@IsString(_:Bool    ) => false
rule #@IsString(_:String  ) => true
rule #@IsString(_:Number  ) => false
rule #@IsString(_:Oid     ) => false

syntax Bool ::= "#@IsNumber" "(" Val ")" [function]
rule #@IsNumber(Undefined) => false
rule #@IsNumber(@NullVal  ) => false
rule #@IsNumber(_:Bool    ) => false
rule #@IsNumber(_:String  ) => false
rule #@IsNumber(_:Number  ) => true
rule #@IsNumber(_:Oid     ) => false

syntax KItem /* Bool */ ::= "@IsOid" "(" K /* Val */ ")" [seqstrict]
rule @IsOid(V:Val) => #@IsOid(V)
//
syntax Bool ::= "#@IsOid" "(" Val ")" [function]
rule #@IsOid(Undefined) => false
rule #@IsOid(@NullVal  ) => false
rule #@IsOid(_:Bool    ) => false
rule #@IsOid(_:String  ) => false
rule #@IsOid(_:Number  ) => false
rule #@IsOid(_:Oid     ) => true

syntax KItem /* Bool */ ::= "@AndBool" "(" K /* Bool */ "," K /* Bool */ ")" [seqstrict]
rule @AndBool(B1:Bool,B2:Bool) => B1 andBool B2

syntax KItem /* Bool */ ::= "@OrBool" "(" K /* Bool */ "," K /* Bool */ ")" [seqstrict]
rule @OrBool(B1:Bool,B2:Bool) => B1 orBool B2

syntax KItem /* Bool */ ::= "@XorBool" "(" K /* Bool */ "," K /* Bool */ ")" [seqstrict]
rule @XorBool(B1:Bool,B2:Bool) => B1 ==K B2

syntax KItem /* Bool */ ::= "@NotBool" "(" K /* Bool */ ")" [seqstrict]
rule @NotBool(B:Bool) => notBool(B)

syntax KItem /* Bool */ ::= "@EqVal" "(" K /* Val */ "," K /* Val */ ")" [seqstrict]
rule @EqVal(V1:Val,V2:Val) => V1 ==K V2

syntax KItem /* Bool */ ::= "@NeqVal" "(" K /* Val */ "," K /* Val */ ")" [seqstrict]
rule @NeqVal(V1:Val,V2:Val) => V1 =/=K V2

syntax KItem /* String */ ::= "@CharAt" "(" K /* String */ "," K /* Number */ ")" [seqstrict]
rule @CharAt(S:String,I:Int) => substrString(S, I, I +Int 1)
rule @CharAt(S:String,@nz  ) => @CharAt(S,0)

syntax KItem /* String */ ::= "@Int2Char" "(" K /* Int */ ")" [seqstrict]
rule @Int2Char(I:Int) => chrChar(I)

syntax KItem /* Int */ ::= "@Char2Int" "(" K /* String */ ")" [seqstrict]
rule @Char2Int(S:String) => ordChar(S)

syntax KItem /* String */ ::= "@LengthString" "(" K /* String */ ")" [seqstrict]
rule @LengthString(S:String) => lengthString(S)

syntax KItem /* String */ ::= "@SubstrString" "(" K /* String */ "," K /* Int */ "," K /* Int */ ")" [seqstrict]
rule @SubstrString(S:String,I1:Int,I2:Int) => substrString(S,I1,I2)

syntax KItem /* Int */ ::= "@String2Int" "(" K /* String */ ")" [seqstrict]
rule @String2Int(S:String) => String2Int(S)

syntax KItem /* Float */ ::= "@String2Float" "(" K /* String */ ")" [seqstrict]
rule @String2Float(S:String) => String2Float(S)

syntax KItem ::= "@String2Base" "(" K /* String */ "," K /* Int */ ")" [seqstrict]
rule @String2Base(S:String,B:Int) => String2Base(S,B)

syntax KItem /* Int */ ::= "@FindString" "(" K /* String */ "," K /* String */ "," K /* Int */ ")" [seqstrict]
rule @FindString(S1:String,S2:String,I:Int) => findString(S1,S2,I)

syntax KItem /* String */ ::= "@NumberToString" "(" K /* Number */ "," K /* Int */ ")" [seqstrict]
// TODO:STD: consider radix other then 10
rule @NumberToString(N:Number, 10) => ToString(N)

syntax KItem ::= "@Cond" "(" K /* Bool */ "," K "," K ")" [seqstrict(1)]
rule @Cond(true,  K:K, _) => K
rule @Cond(false, _, K:K) => K

syntax KItem ::= "@Min" "(" K /* Number */ "," K /* Number */ ")" [seqstrict]
rule @Min(N1:Number,N2:Number)
  => BEGIN
     If %bop(%lt,N1,N2) = true then {
       Return N1;
     } else {
       Return N2;
     }
     END

syntax KItem ::= "@Max" "(" K /* Number */ "," K /* Number */ ")" [seqstrict]
rule @Max(N1:Number,N2:Number)
  => BEGIN
     If %bop(%gt,N1,N2) = true then {
       Return N1;
     } else {
       Return N2;
     }
     END

syntax Float ::= "#@Int2Float" "(" Int ")" [function]
rule #@Int2Float(I:Int) => Int2Float(I, 53, 11)

syntax String ::= "#@PWD" [function]
#include "js-pwd.k"

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
rule #externalAux(#systemResult(ExitCode:Int,Stdout:String,Stderr:String)) => #externalError(Stderr) when ExitCode =/=Int 0
syntax KItem ::= "#externalError" "(" String ")"

syntax KItem /* Exp */ ::= "@Bop" "(" OpNormal "," K /* Val */ "," K /* Val */ ")" [seqstrict(2,3)]
rule @Bop(OP:OpNormal,V1:Val,V2:Val) => %bop(OP,V1,V2)

syntax KItem /* Vals */ ::= "@MakeCons" "(" K /* Val */ "," K /* Vals */ ")" [seqstrict]
rule @MakeCons(V:Val,Vs:Vals) => @Cons(V,Vs)

syntax Int ::= "@MAX_INT"
             | "@MIN_INT"
rule @MAX_INT =>  4294967296 /* 2^32 */ [macro]
rule @MIN_INT => -4294967296 /* 2^32 */ [macro]

endmodule


module JS
imports JS-MAIN
//imports FLOAT-TREE-PATTERN
imports STRING-TREE-PATTERN
//imports LIST-PATTERN
syntax NullableObject ::= Oid | NullType
syntax Val ::= NullableObject
endmodule
