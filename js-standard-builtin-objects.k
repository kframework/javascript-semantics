//////////////////////////////////////////////////////////////////////////////
// 15 Standard Built-in ECMAScript Objects
//////////////////////////////////////////////////////////////////////////////

syntax K /* Bool */ ::= "@IsStandardBuiltinObject" "(" Oid ")" [function]
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

syntax K /* Stmt or Throw */ ::= "@Parse" "(" String ")" [function]
rule @Parse(P:String) => @ParseAux(#parseExternal(P,"Program"),P)
//
syntax K /* Stmt or Throw */ ::= "@ParseAux" "(" K /* Program */ "," K /* String */ ")" [function]
rule @ParseAux(P:SourceElements, _) => ^SourceElements(P)
rule @ParseAux(K /* String2K(#noparse) */, P:String) => @Throw(@SyntaxError("#parse",P)) when isSourceElements(K) =/=K true

syntax K /* Exps or Throw */ ::= "@ParseParams" "(" String ")" [function]
rule @ParseParams(P:String) => @ParseParamsAux(#parse(P,"Parameters"),P)
//
syntax K /* Exps or Throw */ ::= "@ParseParamsAux" "(" K /* Parameters */ "," K /* String */ ")" [function]
rule @ParseParamsAux(P:Parameters, _) => ^Parameters(P)
rule @ParseParamsAux(K /* String2K(#noparse) */, P:String) => @Throw(@SyntaxError("#parse",P)) when isSourceElements(K) =/=K true

//////////////////////////////////////////////////////////////////////////////
// 15.1 The Global Object

// 15.1.2.1 eval (x)

rule %call(%var("eval"), Es:Exps) => Call(@("eval_d"), Undefined, Es)

rule Call(@("eval_d"), _, @Cons(V:Val,     _:Vals)) => V when @IsString(V) ==K false
rule Call(@("eval_i"), _, @Cons(V:Val,     _:Vals)) => V when @IsString(V) ==K false
//
rule Call(@("eval_d"), _, @Cons(Pgm:String,_:Vals)) => @Eval(@Parse(Pgm), true)
rule Call(@("eval_i"), _, @Cons(Pgm:String,_:Vals)) => @Eval(@Parse(Pgm), false)

syntax K ::= "@Eval" "(" K /* Stmt or Throw */ "," Bool ")"
rule @Eval(Code:Stmt, Direct:Bool) => @EnterEvalCode(Code,Direct) ~> Code ~> @ExitEvalCode
rule @Eval(@Throw(@SyntaxError("#parse",P:String)), _) => @Throw(@SyntaxError("#parse",P))

syntax K ::= "@ExitEvalCode"
rule <k> @Normal ~> @ExitEvalCode => @RestoreRunningCtx ~> V ... </k>
     <lastNonEmptyValue> V:Val </lastNonEmptyValue>

syntax K /* Bool */ ::= "@IsEval" "(" Exp ")" [function]
rule @IsEval(E:Exp) => E ==K %var("eval") // TODO: this is quick fix. any better way?

//////////////////////////////////////////////////////////////////////////////
// 15.2 Object Objects

// 15.2.1.1 Object ( [ value ] )

rule Call(@ObjectOid, _, Vs:Vals) => @CallObject(Vs)

syntax K /* Oid */ ::= "@CallObject" "(" K /* Vals */ ")" [seqstrict(1)]
rule @CallObject(@Cons(V:Val,     _:Vals)) => ToObject(V) when V =/=K @NullVal andBool V =/=K Undefined
rule @CallObject(@Cons(@NullVal,  _:Vals)) => @CreateObject
rule @CallObject(@Cons(Undefined,_:Vals)) => @CreateObject
rule @CallObject(                 @Nil   ) => @CreateObject

// 15.2.2.1 new Object ( [ value ] )

rule Construct(@ObjectOid, Vs:Vals) => @NewObject(Vs)

syntax K /* Oid */ ::= "@NewObject" "(" K /* Vals */ ")" [seqstrict(1)]
rule @NewObject(@Cons(Undefined,_:Vals)) => @CreateObject
rule @NewObject(@Cons(@NullVal,  _:Vals)) => @CreateObject
rule @NewObject(@Cons(B:Bool,    _:Vals)) => ToObject(B)
rule @NewObject(@Cons(S:String,  _:Vals)) => ToObject(S)
rule @NewObject(@Cons(N:Number,  _:Vals)) => ToObject(N)
rule @NewObject(@Cons(O:Oid,     _:Vals)) => O
rule @NewObject(                 @Nil   ) => @CreateObject

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

// 15.2.3.4 Object.getOwnPropertyNames ( O )
// TODO:STD: consider note: when O is string object

syntax K ::= "@ObjectGetOwnPropertyNames" "(" Oid ")"
rule <k> @ObjectGetOwnPropertyNames(O:Oid) => @MakeArray(@Set2Vals(keys(Prop))) ... </k>
     <obj>
       <oid> O </oid>
       <properties> Prop:Map </properties>
       _
     </obj>

//////////////////////////////////////////////////////////////////////////////
// 15.3 Function Objects

// 15.3.1.1 Function (p1, p2, ... , pn, body)

rule Call(@FunctionOid, _, Vs:Vals) => @NewFunction(Vs)

// 15.3.2.1 new Function (p1, p2, ... , pn, body)

rule Construct(@FunctionOid, Vs:Vals) => @NewFunction(Vs)

syntax K /* Oid */ ::= "@NewFunction" "(" K /* Vals */ ")" [seqstrict(1)]
rule @NewFunction(             @Nil      ) => @CreateFunction(%nil, %emptyStmt)
// NOTE: We have two rules because of preventing a leading comma.
rule @NewFunction(             Args:Vals ) => @NewFunctionAux("",            Args) when @LengthVals(Args) ==Int 1
rule @NewFunction(@Cons(P1:Val,Args:Vals)) => @NewFunctionAux(ToString(P1), Args) when Args =/=K @Nil

syntax K /* Oid */ ::= "@NewFunctionAux" "(" K /* String */ "," K /* Vals */ ")" [seqstrict(1,2)]
syntax Id ::= "$p" | "$body"
rule @NewFunctionAux(Params:String, @Cons(P:Val,Args:Vals))
  => Let $p = ToString(P);
     Do @NewFunctionAux(Params +String "," +String $p::K::String, Args);
     when Args =/=K @Nil
rule @NewFunctionAux(Params:String, @Cons(Body:Val,@Nil))
  => Let $body = ToString(Body);
     Do @CreateFunction(@ParseParams(Params), @Parse($body::K::String));

syntax K /* Oid */ ::= "@CreateFunction" "(" Exps "," Stmt ")"
rule <k> @CreateFunction(Params:Exps,FunBody:Stmt)
      => Let $strict = @IsStrict(FunBody); // 10.1.1 Strict Mode Code, Case 4
         Do @CheckEarlyErrors($strict::K::Bool, FunBody);
         Do @CreateFunctionObject(Params, FunBody, E, $strict::K::Bool);
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

rule Call(@FunctionProtoOid, _, _:Vals) => Undefined

// 15.3.4.2 Function.prototype.toString ( )

// TODO:STD: ad-hoc, temorary implementation
syntax K ::= "@FunctionPrototypeToString" "(" Oid ")"
rule @FunctionPrototypeToString(F:Oid) => "[function ...]"

// 15.3.4.3 Function.prototype.apply (thisArg, argArray)

syntax K ::= "@FunctionPrototypeApply" "(" Val "," Val "," Val ")"
syntax Id ::= "$n" | "$argList"
rule @FunctionPrototypeApply(Func:Val, ThisArg:Val, ArgArray:Val)
  => If IsCallable(Func) = false then {
       Do @Throw(@TypeError("Function.prototype.apply: func is not callable",Func));
     } else {
       If @OrBool(@EqVal(ArgArray,@NullVal), @EqVal(ArgArray,Undefined)) = true then {
         Do Call(Func,ThisArg,@Nil);
       } else {
         If @IsOid(ArgArray) = true then {
           Do Call(Func, ThisArg, @Array2List(ArgArray::Oid));
         } else {
           Do @Throw(@TypeError("Function.prototype.apply: argArray is not an object",Func));
         }
       }
     }

syntax K /* Vals */ ::= "@Array2List" "(" K /* Oid */ ")" [seqstrict(1)]
syntax Id ::= "$n"
rule @Array2List(ArgArray:Oid)
  => Let $len = Get(ArgArray,"length");
     Let $n = ToUint32($len::K::Val);
     Do @Array2ListAux(ArgArray, $n::K::Int -Int 1, @Nil);
//
syntax K /* Vals */ ::= "@Array2ListAux" "(" Oid "," Int "," Vals ")"
syntax Id ::= "$v"
rule @Array2ListAux(ArgArray:Oid, N:Int, Args:Vals)
  => If N <Int 0 = true then {
       Return Args;
     } else {
       Let $v = Get(ArgArray, ToString(N));
       Do @Array2ListAux(ArgArray, N -Int 1, @Cons($v::K::Val, Args));
     }

// 15.3.4.5 Function.prototype.bind (thisArg [, arg1 [, arg2, ...]])

syntax K ::= "@FunctionPrototypeBind" "(" Val "," Val "," Val ")"
syntax Id ::= "$f"
rule @FunctionPrototypeBind(Func:Val, ThisArg:Val, ArgArray:Val)
  => If IsCallable(Func) = false then {
       Do @Throw(@TypeError("Function.prototype.bind",Func));
     } else {
       Let $f = @CreateObject;
       Do SetInternalProperty($f::K::Oid, "TargetFunction", Func);
       Do SetInternalProperty($f::K::Oid, "BoundThis", ThisArg);
       Do SetInternalProperty($f::K::Oid, "BoundArgs", ArgArray);
       Do SetInternalProperty($f::K::Oid, "Class", "Function");
       Do SetInternalProperty($f::K::Oid, "Prototype", @FunctionProtoOid);
       // TODO:STD: step 15-17
       DoI DefineOwnProperty($f::K::Oid, "caller",    @desc("Get" |-> @("ThrowTypeError") "Set" |-> @("ThrowTypeError") "Enumerable" |-> false "Configurable" |-> false), false);
       DoI DefineOwnProperty($f::K::Oid, "arguments", @desc("Get" |-> @("ThrowTypeError") "Set" |-> @("ThrowTypeError") "Enumerable" |-> false "Configurable" |-> false), false);
       Return $f;
     }

syntax K /* Bool */ ::= "@IsBoundFunction" "(" Oid ")"
rule <k> @IsBoundFunction(O:Oid) => "BoundArgs" in keys(Prop) ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties> Prop </internalProperties>
       _
     </obj>

// 15.3.4.5.1 [[Call]]

syntax K /* Val */ ::= "Call@BoundFunction" "(" K /* Oid */ "," K /* Val */ "," K /* Vals */ ")" [seqstrict(1,2,3)]
syntax Id ::= "$boundArgs" | "$boundThis" | "$target" | "$args"
rule Call@BoundFunction(F:Oid, This:Val, Args:Vals)
  => Let $target    =             GetInternalProperty(F, "TargetFunction");
     Let $boundThis =             GetInternalProperty(F, "BoundThis");
     Let $boundArgs = @Array2List(GetInternalProperty(F, "BoundArgs"));
     Let $args = @AppendVals($boundArgs::K::Vals, Args);
     Return Call@Default($target::K::Oid, $boundThis::K::Val, $args::K::Vals);

// 15.3.4.5.2 [[Construct]]

// TODO:STD: step 2
syntax K /* Oid */ ::= "Construct@BoundFunction" "(" K /* Oid */ "," K /* Vals */ ")" [seqstrict(1,2)]
rule Construct@BoundFunction(F:Oid, Args:Vals)
  => Let $target    =             GetInternalProperty(F, "TargetFunction");
     Let $boundArgs = @Array2List(GetInternalProperty(F, "BoundArgs"));
     Let $args = @AppendVals($boundArgs::K::Vals, Args);
     Return Construct@Default($target::K::Oid, $args::K::Vals);

// 15.3.4.5.3 [[HasInstance]] (V)

// TODO:STD: step 2
syntax K /* Bool */ ::= "HasInstance@BoundFunction" "(" K /* Oid */ "," K /* Val */ ")" [seqstrict(1,2)]
rule HasInstance@BoundFunction(F:Oid, V:Val)
  => Let $target = GetInternalProperty(F, "TargetFunction");
     Return HasInstance@Default($target::K::Oid, V);

// 15.3.5 Properties of Function Instances

// 15.3.5.3 [[HasInstance]] (V)

syntax K /* Bool */ ::= "HasInstance" "(" K "," K ")" [seqstrict(1,2)]
rule HasInstance(F:Oid, V:Val)
  => If @IsBoundFunction(F) = true then {
       Do HasInstance@BoundFunction(F,V);
     } else {
       Do HasInstance@Default(F,V);
     }

syntax K /* Bool */ ::= "HasInstance@Default" "(" K "," K ")" [seqstrict(1,2)]
syntax Id ::= "$o"
rule HasInstance@Default(F:Oid,V:Val)
  => If @IsOid(V) = true then {
       Let $o = Get(F,"prototype");
       If @IsOid($o::K::Val) = true then {
         Return @IsPrototypeOf($o::K::Oid, V::Oid);
       } else {
         Do @Throw(@TypeError("HasInstance@Default",F));
       }
     } else {
       Return false;
     }

// TODO: Duplicated: Object.isPrototypeOf
syntax K /* Bool */ ::= "@IsPrototypeOf" "(" Oid "," Oid ")"
rule @IsPrototypeOf(O:Oid,V:Oid)
  => @IsPrototypeOfAux(O,GetInternalProperty(V,"Prototype"))

syntax K /* Bool */ ::= "@IsPrototypeOfAux" "(" K "," K ")" [seqstrict(1,2)]
rule @IsPrototypeOfAux(O:Oid,V:Oid)
  => If V = @NullOid then {
       Return false;
     } else {
       If O = V then {
         Return true;
       } else {
         Do @IsPrototypeOfAux(O,GetInternalProperty(V,"Prototype"));
       }
     }

// 15.3.5.4 [[Get]] (P)
// TODO:STD:

//////////////////////////////////////////////////////////////////////////////
// 15.4 Array Objects

// 15.4.1.1 Array ( [ item1 [ , item2 [ , ... ] ] ] )

rule Call(@ArrayOid, _, Vs:Vals) => @NewArray(Vs)

// 15.4.2.1 new Array ( [ item0 [ , item1 [ , ... ] ] ] )

rule Construct(@ArrayOid, Vs:Vals) => @NewArray(Vs)

syntax K /* Oid */ ::= "@NewArray" "(" K /* Vals */ ")" [seqstrict(1)]
rule @NewArray(Vs:Vals) => @CreateArray(@LengthVals(Vs), Vs) when @LengthVals(Vs) =/=Int 1
rule @NewArray(@Cons(V:Val,@Nil)) => @CreateArray(1, @Cons(V:Val,@Nil)) when notBool(isInt(V) ==K true)

syntax K /* Oid */ ::= "@CreateArray" "(" Int "," Vals ")"
rule <k> @CreateArray(Len:Int, Vs:Vals) => @CreateArray@InsertElements(@o(N),Vs,0) ... </k>
     <objs>
       (. => <obj>
               <oid> @o(N) </oid>
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
// TODO:STD: more correctly: ToUint32(len) = len, o.w. throw RangeError

rule @NewArray(@Cons(Len:Int,@Nil)) => @CreateArray(Len, @Nil)

// 15.4.X make Array
// NOTE: @MakeArray differs from @NewArray in that it simply creates array object given arguments instead of distinguishing the single argument case

syntax K /* Oid */ ::= "@MakeArray" "(" K /* Vals */ ")" [seqstrict(1)]
rule @MakeArray(Vs:Vals) => @CreateArray(@LengthVals(Vs), Vs)

// 15.4.5 Properties of Array Instances

// TODO: Duplicated: Array.isArray
syntax K /* Bool */ ::= "@IsArrayObject" "(" Oid ")"
rule <k> @IsArrayObject(O:Oid) => Class ==String "Array" ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "Class" |-> Class:String
         _
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

syntax K /* Bool */ ::= "DefineOwnProperty@Array" "(" K /* Oid */ "," K /* Var */ "," K /* PropertyDescriptor */ "," K /* Bool */ ")" [seqstrict(1,2,3,4)]
syntax Id ::= "$oldLenDesc" | "$oldLen" | "$newLenDesc" | "$newLen" | "$succeeded" | "$succeeded2"
rule DefineOwnProperty@Array(O:Oid,P:Var,Desc:PropertyDescriptor,Throw:Bool)
  => // Step 1,2
     Let $oldLenDesc = GetOwnProperty(O,"length");
     Let $oldLen = $oldLenDesc."Value";
     // Step 3
     If P = "length" then {
       // Step 3.a
       If Desc."Value" = Undefined then { // TODO:STD: check if 'absent field' = 'undefined'.
         Do DefineOwnProperty@Default(O,P,Desc,Throw);
       } else {
         // Step 3.b
       //Let $newLenDesc = Desc;
         // Step 3.c
         Let $newLen = ToUint32(Desc."Value");
         If $newLen = ToNumber(Desc."Value") then {
           // Step 3.e
           Let $newLenDesc = @AddDesc("Value", $newLen, Desc);
           // Step 3.f
           If %bop(%ge, $newLen::K::Val, $oldLen::K::Val) = true then {
             Do DefineOwnProperty@Default(O, "length", $newLenDesc, Throw);
           } else {
             // Step 3.g
             If @EqVal($oldLenDesc."Writable",false) = true then {
               Return Reject(Throw, "DefineOwnProperty@Array cannot increase length", DefineOwnProperty@Array(O,P,Desc,Throw));
             } else {
               // TODO:STD: check if step 3.h, 3.i, and 3.m are useless?
               // Step 3.j
               Let $succeeded = DefineOwnProperty@Default(O, "length", $newLenDesc, Throw);
               // Step 3.k
               If $succeeded = false then {
                 Return false;
               } else {
                 // Step 3.l, 3.n
                 Do DefineOwnProperty@Array@DeleteOthers(O,P,Desc,Throw,$newLenDesc,$newLen,$oldLen);
               }
             }
           }
         } else {
           // Step 3.d
           Do @Throw(@RangeError("DefineOwnProperty@Array index over int32", DefineOwnProperty@Array(O,P,Desc,Throw)));
         }
       }
     } else {
       // Step 4
       If @IsArrayIndex(P) = true then {
         // Step 4.a
         Let $index = ToUint32(P);
         // Step 4.b
         If @AndBool(%bop(%ge, $index::K::Val, $oldLen::K::Val), @EqVal($oldLenDesc."Writable",false)) = true then {
           Return Reject(Throw, "DefineOwnProperty@Array cannot increase length", DefineOwnProperty@Array(O,P,Desc,Throw));
         } else {
           // Step 4.c
           Let $succeeded2 = DefineOwnProperty@Default(O,P,Desc,false);
           // Step 4.d
           If $succeeded2 = false then {
             Return Reject(Throw, "DefineOwnProperty@Array cannot assign", DefineOwnProperty@Array(O,P,Desc,Throw));
           } else {
             // Step 4.e
             If %bop(%ge, $index::K::Val, $oldLen::K::Val) = true then {
               Do DefineOwnProperty@Default(O, "length", @AddDesc("Value", %bop(%plus, $index::K::Val, 1), $oldLenDesc), false); // NOTE: should return true
             } else {
               // Step 4.f
               Return true;
             }
           }
         }
       } else {
         // Step 5
         Do DefineOwnProperty@Default(O,P,Desc,Throw);
       }
     }

syntax K /* Bool */ ::= "@IsArrayIndex" "(" Var ")"
rule @IsArrayIndex(P:Var) => @EqVal(ToString(ToUint32(P)), P) /* TODO:STD: and ToUint32(P) =/=K 2^32 - 1 */

syntax K /* Bool */ ::= "DefineOwnProperty@Array@DeleteOthers" "(" K /* Oid */ "," K /* Var */ "," K /* PropertyDescriptor */ "," K /* Bool */ "," K /* PropertyDescriptor */ "," K /* Val */ "," K /* Val */ ")" [seqstrict(1,2,3,4,5,6,7)]
syntax Id ::= "$deleteSucceeded"
rule DefineOwnProperty@Array@DeleteOthers(O:Oid,P:Var,Desc:PropertyDescriptor,Throw:Bool,NewLenDesc:PropertyDescriptor,NewLen:Val,OldLen:Val)
  => If %bop(%lt, NewLen, OldLen) = true then {
       // Step 3.l.i
       Let $oldLen = %bop(%minus, OldLen, 1);
       // Step 3.l.ii
       Let $deleteSucceeded = Delete(O, ToString($oldLen), false);
       // Step 3.l.iii
       If $deleteSucceeded = false then {
         Let $newLenDesc = @AddDesc("Value", %bop(%plus, $oldLen::K::Val, 1), NewLenDesc);
         DoI DefineOwnProperty@Default(O, "length", $newLenDesc, false);
         Return Reject(Throw, "DefineOwnProperty@Array cannot delete others", DefineOwnProperty@Array(O,P,Desc,Throw));
       } else {
         Do DefineOwnProperty@Array@DeleteOthers(O, P, Desc, Throw, NewLenDesc, NewLen, $oldLen);
       }
     } else {
       // Step 3.n
       Return true;
     }

//////////////////////////////////////////////////////////////////////////////
// 15.5 String Objects

// 15.5.1.1 String ( [ value ] )

rule Call(@StringOid, _, Vs:Vals) => @CallString(Vs)

syntax K /* String */ ::= "@CallString" "(" K /* Vals */ ")" [seqstrict(1)]
rule @CallString(@Cons(V:Val,_:Vals)) => ToString(V)
rule @CallString(            @Nil   ) => ""

// 15.5.2.1 new String ( [ value ] )

rule Construct(@StringOid, Vs:Vals) => @NewString(Vs)

syntax K /* Oid */ ::= "@NewString" "(" K /* Vals */ ")" [seqstrict(1)]
rule @NewString(@Cons(V:Val,_:Vals)) => @CreateString(ToString(V))
rule @NewString(            @Nil   ) => @CreateString("")

syntax K /* Oid */ ::= "@CreateString" "(" K /* String */ ")" [seqstrict(1)]
rule <k> @CreateString(S:String) => @o(N) ... </k>
     <objs>
       (. => <obj>
               <oid> @o(N) </oid>
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
     when fresh(N:Int)

// 15.5.5 Properties of String Instances

syntax K /* Bool */ ::= "@IsStringObject" "(" Oid ")"
rule <k> @IsStringObject(O:Oid) => Class ==String "String" ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "Class" |-> Class:String
         _
       </internalProperties>
       _
     </obj>

// 15.5.5.2 [[GetOwnProperty]] ( P )

syntax K /* Val */ ::= "GetOwnProperty@String" "(" K /* Oid */ "," K /* Var */ ")" [seqstrict(1,2)]
syntax Id ::= "$index" | "$resultStr"
rule GetOwnProperty@String(O:Oid,P:Var)
  => Let $desc = GetOwnProperty@Default(O,P);
     If $desc = Undefined then {
       If ToString(ToInteger(P::K::Val)) = P then { // TODO:STD: it should have been 'ToString(abs(ToInteger(P)))'
         Let $str = GetInternalProperty(O,"PrimitiveValue");
         Let $index = ToInteger(P::K::Val);
         Let $len = lengthString($str::K::String);
       //If $len::K::Int <=Int $index::K::Int = true then {
         If @OrBool(%bop(%lt,$index::K::Number,0), %bop(%ge,$index::K::Number,$len::K::Int)) = true then {
           Return Undefined;
         } else {
           Let $resultStr = @CharAt($str::K::String, $index::K::Number);
           Return @GenDesc("Value", $resultStr, "Enumerable", true, "Writable", false, "Configurable", false);
         }
       } else {
         Return Undefined;
       }
     } else {
       Return $desc;
     }

//////////////////////////////////////////////////////////////////////////////
// 15.6 Boolean Objects

// 15.6.1.1 Boolean (value)

rule Call(@BooleanOid, _, Vs:Vals) => @CallBoolean(Vs)

syntax K /* Boolean */ ::= "@CallBoolean" "(" K /* Vals */ ")" [seqstrict(1)]
rule @CallBoolean(@Cons(V:Val,_:Vals)) => ToBoolean(V)
rule @CallBoolean(            @Nil   ) => false

// 15.6.2.1 new Boolean (value)

rule Construct(@BooleanOid, Vs:Vals) => @NewBoolean(Vs)

syntax K /* Oid */ ::= "@NewBoolean" "(" K /* Vals */ ")" [seqstrict(1)]
rule @NewBoolean(@Cons(V:Val,_:Vals)) => @CreateBoolean(ToBoolean(V))
rule @NewBoolean(            @Nil   ) => @CreateBoolean(false) // TODO: Report: This is not specified in standard.

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

//////////////////////////////////////////////////////////////////////////////
// 15.7 Number Objects

// 15.7.1.1 Number ( [ value ] )

rule Call(@NumberOid, _, Vs:Vals) => @CallNumber(Vs)

syntax K /* Number */ ::= "@CallNumber" "(" K /* Vals */ ")" [seqstrict(1)]
rule @CallNumber(@Cons(V:Val,_:Vals)) => ToNumber(V)
rule @CallNumber(            @Nil   ) => 0

// 15.7.2.1 new Number ( [ value ] )

rule Construct(@NumberOid, Vs:Vals) => @NewNumber(Vs)

syntax K /* Oid */ ::= "@NewNumber" "(" K /* Val */ ")" [seqstrict(1)]
rule @NewNumber(@Cons(V:Val,_:Vals)) => @CreateNumber(ToNumber(V))
rule @NewNumber(            @Nil   ) => @CreateNumber(0)

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

// 15.7.4.5 Number.prototype.toFixed (fractionDigits)

syntax K /* String */ ::= "@NumberPrototypeToFixed" "(" Oid "," K /* Int */ ")" [seqstrict(2)]
rule <k> @NumberPrototypeToFixed(O:Oid,D:Int) => #external("new Number(" +String Int2String(I) +String ").toFixed(" +String Int2String(D) +String ")") ... </k>
     <obj>
       <oid> O </oid>
       <internalProperties>
         "PrimitiveValue" |-> I:Int
         _
       </internalProperties>
       _
     </obj>
rule <k> @NumberPrototypeToFixed(O:Oid,D:Int) => #external("new Number(" +String Float2String(F) +String ").toFixed(" +String Int2String(D) +String ")") ... </k>
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

syntax K ::= "@MathFloor" "(" Number ")"
rule @MathFloor(I:Int)      => I
rule @MathFloor(F:Float)    => Float2Int(F)
rule @MathFloor(@nz)        => @nz
rule @MathFloor(@NaN)       => @NaN
rule @MathFloor(@+Infinity) => @+Infinity
rule @MathFloor(@-Infinity) => @-Infinity

// 15.8.2.13 pow (x, y)

// TODO:STD: other cases
syntax K ::= "@MathPow" "(" Number "," Number ")"
rule @MathPow(I1:Int,  I2:Int)   => I1 ^Int   I2
rule @MathPow(F1:Float,F2:Float) => F1 ^Float F2

//////////////////////////////////////////////////////////////////////////////
// 15.9 Date Objects
// TODO:STD:

// 15.9.2.1 Date ( [ year [, month [, date [, hours [, minutes [, seconds [, ms ] ] ] ] ] ] ] )

rule Call(@DateOid, _, _:Vals) => %call(%mem(%new(%var("Date"), %nil), %con("toString")), %nil) // (new Date()).toString()

// 15.9.3.1 new Date (year, month [, date [, hours [, minutes [, seconds [, ms ] ] ] ] ] )
// 15.9.3.2 new Date (value)
// 15.9.3.3 new Date ( )
// TODO:STD: Implement correctly

// XXX: HACK for test262 ch9 and ch11
rule Construct(@DateOid, @Cons(V:Val,@Nil)) => @CreateDate(TimeClip(ToNumber(V)))
rule Construct(@DateOid,             @Nil ) => @CreateDate(0) // HACK: 0 is used instead of the current time in milli-seconds

syntax K /* Oid */ ::= "@CreateDate" "(" K /* Number */ ")" [seqstrict(1)]
rule <k> @CreateDate(V:Number) => @o(N) ... </k>
     <objs>
       (. => <obj>
               <oid> @o(N) </oid>
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
     when fresh(N:Int)

// 15.9.1.14 TimeClip (time)

// TODO:STD: Consider Step 2. If abs(N) > 8.64 * 10^15, return NaN.
syntax K /* Number */ ::= "TimeClip" "(" K /* Number */ ")" [seqstrict(1)]
rule TimeClip(N:Number)
  => If @IsFinite(N) = true then {
       Return ToInteger(N);
     } else {
       Return @NaN;
     }

syntax K /* Bool */ ::= "@IsFinite" "(" Number ")"
rule @IsFinite(N:Number) => N =/=K @NaN andBool N =/=K @+Infinity andBool N =/=K @-Infinity

// 15.9.5.2 Date.prototype.toString ( )

// TODO:STD: HACK
syntax K /* String */ ::= "@DatePrototypeToString" "(" Oid ")"
rule @DatePrototypeToString(O:Oid) => "[date ...]"

//////////////////////////////////////////////////////////////////////////////
// 15.10 RegExp (RegularExpression) Objects
// TODO:STD:

// 15.10.3.1 RegExp(pattern, flags)
// TODO: consider the first case: pattern is "RegExp" object and flags is undefined.

rule Call(@RegExpOid, _, Vs:Vals) => Construct(@RegExpOid, Vs)

// 15.10.4.1 new RegExp(pattern, flags)
// TODO:STD: Implement correctly

// XXX: HACK for test262 ch9 and ch11
rule Construct(@RegExpOid, _:Vals) => @CreateRegExp

syntax K /* Oid */ ::= "@CreateRegExp"
rule <k> @CreateRegExp => @o(N) ... </k>
     <objs>
       (. => <obj>
               <oid> @o(N) </oid>
               <properties> .Map </properties>
               <internalProperties>
                 "Prototype"      |-> @RegExpProtoOid
                 "Class"          |-> "RegExp"
                 "Extensible"     |-> true
               </internalProperties>
             </obj>)
       _
     </objs>
     when fresh(N:Int)

//////////////////////////////////////////////////////////////////////////////
// 15.11 ErrorObjects

// 15.11.1.1 Error (message)

rule Call(@ErrorOid, _, Vs:Vals) => @NewError(Vs)

// 15.11.2.1 new Error (message)

rule Construct(@ErrorOid, Vs:Vals) => @NewError(Vs)

syntax K /* Oid */ ::= "@NewError" "(" K /* Vals */ ")" [seqstrict(1)]
rule @NewError(@Cons(V:Val,_:Vals)) => @CreateError(ToString(V))
rule @NewError(            @Nil   ) => @CreateError("")

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

//////////////////////////////////////////////////////////////////////////////
// 15.11.6 Native Error Types Used in This Standard
// 15.11.7 NativeError Object Structure

// 15.11.7.2 NativeError (message)

rule Call(NativeError:Oid, _, Vs:Vals) => @NewNativeError(NativeError, Vs)
     when (NativeError ==K @EvalErrorOid     )
   orBool (NativeError ==K @RangeErrorOid    )
   orBool (NativeError ==K @ReferenceErrorOid)
   orBool (NativeError ==K @SyntaxErrorOid   )
   orBool (NativeError ==K @TypeErrorOid     )
   orBool (NativeError ==K @URIErrorOid      )

// 15.11.7.4 new NativeError (message)

rule Construct(NativeError:Oid, Vs:Vals) => @NewNativeError(NativeError, Vs)
     when (NativeError ==K @EvalErrorOid     )
   orBool (NativeError ==K @RangeErrorOid    )
   orBool (NativeError ==K @ReferenceErrorOid)
   orBool (NativeError ==K @SyntaxErrorOid   )
   orBool (NativeError ==K @TypeErrorOid     )
   orBool (NativeError ==K @URIErrorOid      )

syntax K /* Oid */ ::= "@NewNativeError" "(" K /* Oid */ "," K /* Vals */ ")" [seqstrict(1,2)]
rule @NewNativeError(NativeError:Oid, @Cons(V:Val,_)) => @CreateNativeError(NativeError, ToString(V), "@NewNativeError") // NOTE: multiple arguments are allowed: e.g. ch12/12.14/S12.14_A19_T2.js; ch12/12.14/S12.14_A19_T1.js
rule @NewNativeError(NativeError:Oid, @Nil)           => @CreateNativeError(NativeError, "",           "@NewNativeError")

// NOTE: The third argument is only for debugging purpose, not a language standard. It should be non-strict.
syntax K /* Oid */ ::= "@CreateNativeError" "(" K /* Oid */ "," K /* String */ "," K ")" [seqstrict(1,2)]
rule <k> @CreateNativeError(NativeError:Oid, Msg:String, KDebug:K) => @o(N) ... </k>
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

syntax Oid ::= "@ResolveNativeError" "(" Oid ")" [function]
rule @ResolveNativeError(@EvalErrorOid     ) => @EvalErrorProtoOid
rule @ResolveNativeError(@RangeErrorOid    ) => @RangeErrorProtoOid
rule @ResolveNativeError(@ReferenceErrorOid) => @ReferenceErrorProtoOid
rule @ResolveNativeError(@SyntaxErrorOid   ) => @SyntaxErrorProtoOid
rule @ResolveNativeError(@TypeErrorOid     ) => @TypeErrorProtoOid
rule @ResolveNativeError(@URIErrorOid      ) => @URIErrorProtoOid

// TODO: more elegantly
syntax K /* Oid */ ::= "@EvalError"      "(" String "," K ")"
syntax K /* Oid */ ::= "@RangeError"     "(" String "," K ")"
syntax K /* Oid */ ::= "@ReferenceError" "(" String "," K ")"
syntax K /* Oid */ ::= "@SyntaxError"    "(" String "," K ")"
syntax K /* Oid */ ::= "@TypeError"      "(" String "," K ")"
syntax K /* Oid */ ::= "@URIError"       "(" String "," K ")"
rule @EvalError     (Msg:String, KDebug:K) => @CreateNativeError(@EvalErrorOid     , Msg, KDebug)
rule @RangeError    (Msg:String, KDebug:K) => @CreateNativeError(@RangeErrorOid    , Msg, KDebug)
rule @ReferenceError(Msg:String, KDebug:K) => @CreateNativeError(@ReferenceErrorOid, Msg, KDebug)
rule @SyntaxError   (Msg:String, KDebug:K) => @CreateNativeError(@SyntaxErrorOid   , Msg, KDebug)
rule @TypeError     (Msg:String, KDebug:K) => @CreateNativeError(@TypeErrorOid     , Msg, KDebug)
rule @URIError      (Msg:String, KDebug:K) => @CreateNativeError(@URIErrorOid      , Msg, KDebug)

//////////////////////////////////////////////////////////////////////////////
// 15.12 The JSON Object

// NOTE: We do not need to have a Call or Construct for the JSON object:
// 15.12 The JSON object does not have a [[Construct]] internal property; it is not possible to use the JSON object as a constructor with the new operator.
// 15.12 The JSON object does not have a [[Call]] internal property; it is not possible to invoke the JSON object as a function.

//////////////////////////////////////////////////////////////////////////////
// APIs
//////////////////////////////////////////////////////////////////////////////

syntax K /* .K */ ::= "@RegisterAPIs"
rule <k> @RegisterAPIs => . ... </k>
     <objs>
       <obj>
         <oid> @GlobalOid </oid>
         <properties>
           (. => "IsObject"                 |-> @desc("Value" |-> @("IsObject")                 "Writable" |-> false "Enumerable" |-> false "Configurable" |-> false)
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
           _
         </properties>
         _
       </obj>
       _
     </objs>

// NOTE: All these APIs should return a value of type Val

rule Call(@("IsObject"),           Undefined, @Cons(V:Val,@Nil)) => @IsOid(V)
rule Call(@("ToObject"),           Undefined, @Cons(V:Val,@Nil)) => ToObject(V)
rule Call(@("ToString"),           Undefined, @Cons(V:Val,@Nil)) => ToString(V)
rule Call(@("ToNumber"),           Undefined, @Cons(V:Val,@Nil)) => ToNumber(V)
rule Call(@("ToInteger"),          Undefined, @Cons(V:Val,@Nil)) => ToInteger(V)
rule Call(@("ToUint32"),           Undefined, @Cons(V:Val,@Nil)) => ToUint32(V)
rule Call(@("ToUint16"),           Undefined, @Cons(V:Val,@Nil)) => ToUint16(V)
rule Call(@("IsNaN"),              Undefined, @Cons(V:Val,@Nil)) => V ==K @NaN
rule Call(@("IsPositiveZero"),     Undefined, @Cons(V:Val,@Nil)) => V ==K 0 orBool V ==K 0.0
rule Call(@("IsNegativeZero"),     Undefined, @Cons(V:Val,@Nil)) => V ==K @nz
rule Call(@("IsFunction"),         Undefined, @Cons(V:Val,@Nil)) => IsCallable(V)
rule Call(@("IsCallable"),         Undefined, @Cons(V:Val,@Nil)) => IsCallable(V)

rule <k> Call(@("NoConstructor"), Undefined, @Cons(O:Val,@Nil)) => Undefined ... </k>
     <objs>
       <obj>
         <oid> O </oid>
         <properties>
           ("prototype" |-> @desc("Value" |-> P:Oid _) => .)
           _
         </properties>
         <internalProperties>
           "Strict" |-> (_ => false)
           _
         </internalProperties>
         _
       </obj>
       (<obj> <oid> P </oid> _ </obj> => .)
       _
     </objs>

rule Call(@("GetInternalProperty"), Undefined, @Cons(O:Val,@Cons(P:Val,@Nil)))
  => Let $v = GetInternalProperty(O::K::Oid,P::K::Var);
     If @AndBool(@EqVal(P,"Prototype"), @EqVal($v,@NullOid)) = true then {
        Return @NullVal;
     } else {
        Return $v;
     }
rule Call(@("SetInternalProperty"), Undefined, @Cons(O:Val,@Cons(P:Val,@Cons(V:Val,@Nil))))
  => If @AndBool(@EqVal(P,"Prototype"), @EqVal(V,@NullVal)) = true then {
       Do SetInternalProperty(O::K::Oid,P::K::Var,@NullOid);
     } else {
       Do SetInternalProperty(O::K::Oid,P::K::Var,V);
     }
     Return Undefined;

rule Call(@("GetOwnProperty"),         Undefined, @Cons(O:Val,@Cons(P:Val,                             @Nil  ))) => GetOwnProperty(O,P)
rule Call(@("DefineOwnProperty"),      Undefined, @Cons(O:Val,@Cons(P:Val,@Cons(V:Val,@Cons(Strict:Val,@Nil))))) => DefineOwnProperty(O,P,V,Strict)

rule Call(@("FromPropertyDescriptor"), Undefined, @Cons(V:Val,@Nil)) => FromPropertyDescriptor(V)
rule Call(@(  "ToPropertyDescriptor"), Undefined, @Cons(V:Val,@Nil)) =>   ToPropertyDescriptor(V)

rule Call(@("CheckObjectCoercible"),   Undefined, @Cons(V:Val,@Nil)) => CheckObjectCoercible(V) ~> Undefined

rule Call(@("ObjectGetOwnPropertyNames"),  Undefined, @Cons(O:Val,@Nil)) => @ObjectGetOwnPropertyNames(O::K::Oid)

rule Call(@("FunctionPrototypeToString"),  Undefined, @Cons(Func:Val,@Nil)) => @FunctionPrototypeToString(Func::K::Oid)
rule Call(@("FunctionPrototypeApply"   ),  Undefined, @Cons(Func:Val,@Cons(ThisArg:Val,@Cons(ArgArray:Val,@Nil)))) => @FunctionPrototypeApply(Func,ThisArg,ArgArray)
rule Call(@("FunctionPrototypeBind"    ),  Undefined, @Cons(Func:Val,@Cons(ThisArg:Val,@Cons(ArgArray:Val,@Nil)))) => @FunctionPrototypeBind(Func,ThisArg,ArgArray)

rule Call(@("NumberPrototypeToFixed"), Undefined, @Cons(O:Val,@Cons(V:Val,@Nil))) => @NumberPrototypeToFixed(O::K::Oid, ToInteger(V))

rule Call(@("MathFloor"),          Undefined, @Cons(N:Val,@Nil)) => @MathFloor(N::K::Number)
rule Call(@("MathPow"),            Undefined, @Cons(N1:Val,@Cons(N2:Val,@Nil))) => @MathPow(N1::K::Number, N2::K::Number)
rule Call(@("MathSin"),            Undefined, @Cons(N:Val,@Nil))
  => Let $n = ToString(N);
     Return ToNumber(#external("Math.sin(" +String $n::K::String +String ")"));

rule Call(@("DatePrototypeToString"), Undefined, @Cons(O:Val,@Nil)) => @DatePrototypeToString(O::K::Oid)

rule Call(@("LengthString"),       Undefined, @Cons(S:Val,@Nil)) => lengthString(S::K::String)
rule Call(@("Trim"),               Undefined, @Cons(S:Val,@Nil)) => trim(S::K::String) // TODO:STD: check the builtin's trim has correct whitespaces and lineterminators.
rule Call(@("Int2Char"),           Undefined, @Cons(I:Val,@Nil)) => @Int2Char(I::K::Int)
rule Call(@("Char2Int"),           Undefined, @Cons(S:Val,@Nil)) => @Char2Int(S::K::String)
rule Call(@("CharAt"),             Undefined, @Cons(S:Val,@Cons(N:Val,@Nil))) => @CharAt(S::K::String, N::K::Number)
rule Call(@("FindString"),         Undefined, @Cons(S1:Val,@Cons(S2:Val,@Cons(I:Val,@Nil)))) => @FindString(S1::K::String, S2::K::String, I::K::Int)
rule Call(@("SubstrString"),       Undefined, @Cons(S:Val,@Cons(I1:Val,@Cons(I2:Val,@Nil)))) => @SubstrString(S::K::String, I1::K::Int, I2::K::Int)

rule Call(@("NumberToString"),     Undefined, @Cons(N:Val,@Cons(R:Val,@Nil))) => @NumberToString(N::K::Number, R::K::Int)

rule Call(@("Print"),              Undefined, @Cons(V:Val,@Nil)) => @PrintNewline(V)

rule Call(@("CurrentTimeMillis"),  Undefined, @Nil) => 0 // TODO:STD: do correctly
