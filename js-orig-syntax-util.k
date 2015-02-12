require "builtins/bool.k"
require "builtins/int.k"
require "builtins/float.k"
require "builtins/string.k"

module JS-ORIG-SYNTAX-UTIL

imports JS-ORIG-SYNTAX

imports BOOL-HOOKS
imports INT-HOOKS
imports FLOAT-HOOKS
imports STRING-HOOKS

// Name

syntax String ::= StringOfName(Name) [function, notInPrograms]
rule StringOfName(N:Name) => #tokenToString(N)

syntax Name ::= NameOfString(String) [function, notInPrograms]
rule NameOfString(S:String) => #parseToken("Name", S)

// APIName

syntax String ::= StringOfAPIName(APIName) [function, notInPrograms]
rule StringOfAPIName(N:APIName) => #tokenToString(N)

// MyFloat

syntax Float ::= "MyFloat2Float" "(" MyFloat ")" [function, notInPrograms]
rule MyFloat2Float(F:MyFloat) => String2Float(#tokenToString(F))

// MyString

syntax String ::= "MyString2String" "(" MyString ")" [function, notInPrograms]
rule MyString2String(S:MyString) => processEscapes(processBackslashes(processQuotes(#tokenToString(S))))

syntax String ::= "processQuotes" "(" String ")" [function, notInPrograms]
rule processQuotes(S:String) => replaceAll(substrString(S, 1, lengthString(S) -Int 1), "\\\"", "\"") when substrString(S,0,1) ==String "\""
rule processQuotes(S:String) => replaceAll(substrString(S, 1, lengthString(S) -Int 1),  "\\'",  "'") when substrString(S,0,1) ==String "'"

syntax String ::= "processBackslashes" "(" String ")" [function, notInPrograms]
rule processBackslashes(S:String) => substrString(S, 0, findString(S, "\\", 0)) +String processBackslashesAux(substrString(S, findString(S, "\\", 0), lengthString(S))) when findString(S, "\\", 0) =/=Int -1
rule processBackslashes(S:String) => S when findString(S, "\\", 0) ==Int -1

syntax String ::= "processBackslashesAux" "(" String ")" [function, notInPrograms]
rule processBackslashesAux(S:String) => processBackslashesAuxAux(S) when lengthString(S) >Int 1
rule processBackslashesAux(S:String) => S when lengthString(S) ==Int 1

syntax String ::= "processBackslashesAuxAux" "(" String ")" [function, notInPrograms]
rule processBackslashesAuxAux(S:String) =>                             processBackslashes(substrString(S,1,lengthString(S))) when notBool(isEscapeChar(substrString(S,1,2)))
rule processBackslashesAuxAux(S:String) => substrString(S,0,2) +String processBackslashes(substrString(S,2,lengthString(S))) when         isEscapeChar(substrString(S,1,2))

syntax Bool ::= "isEscapeChar" "(" String ")" [function, notInPrograms]
rule isEscapeChar(S:String) => S ==String "b"
                        orBool S ==String "t"
                        orBool S ==String "n"
                        orBool S ==String "v"
                        orBool S ==String "f"
                        orBool S ==String "r"
                        orBool S ==String "\\"
                        //
                        orBool S ==String "0"
                        //
                        orBool S ==String "\n"
                        orBool S ==String "\r"
                        orBool S ==String "\u2028"
                        orBool S ==String "\u2029"
                        //
                        orBool S ==String "x"
                        orBool S ==String "u"

syntax String ::= "processEscapes" "(" String ")" [function, notInPrograms]
rule processEscapes(S:String) => S when findString(S, "\\b"      , 0) ==Int -1
                                andBool findString(S, "\\t"      , 0) ==Int -1
                                andBool findString(S, "\\n"      , 0) ==Int -1
                                andBool findString(S, "\\v"      , 0) ==Int -1
                                andBool findString(S, "\\f"      , 0) ==Int -1
                                andBool findString(S, "\\r"      , 0) ==Int -1
                                andBool findString(S, "\\\\"     , 0) ==Int -1
                                //
                                andBool findString(S, "\\0"      , 0) ==Int -1
                                //
                                andBool findString(S, "\\\n"     , 0) ==Int -1
                                andBool findString(S, "\\\r"     , 0) ==Int -1
                                andBool findString(S, "\\\r\n"   , 0) ==Int -1
                                andBool findString(S, "\\\u2028" , 0) ==Int -1
                                andBool findString(S, "\\\u2029" , 0) ==Int -1
                                //
                                andBool findString(S, "\\x"      , 0) ==Int -1
                                andBool findString(S, "\\u"      , 0) ==Int -1
// \ [one of ' " \ b f n r t v]
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\b"     , "\u0008")) when findString(S, "\\b"     , 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\t"     , "\t"    )) when findString(S, "\\t"     , 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\n"     , "\n"    )) when findString(S, "\\n"     , 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\v"     , "\u000B")) when findString(S, "\\v"     , 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\f"     , "\f"    )) when findString(S, "\\f"     , 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\r"     , "\r"    )) when findString(S, "\\r"     , 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\\\"    , "\\"    )) when findString(S, "\\\\"    , 0) =/=Int -1
// \ 0 [lookahead \not\in DecimalDigit]
// FIXME: check if lookahead is not a decimal degit.
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\0"     , "\u0000")) when findString(S, "\\0"     , 0) =/=Int -1
// LineContinuation ::= \ LineTerminatorSequence
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\\n"    , ""      )) when findString(S, "\\\n"    , 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\\r"    , ""      )) when findString(S, "\\\r"    , 0) =/=Int -1 andBool findString(S, "\\\r\n", 0) ==Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\\r\n"  , ""      )) when findString(S, "\\\r\n"  , 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\\u2028", ""      )) when findString(S, "\\\u2028", 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\\u2029", ""      )) when findString(S, "\\\u2029", 0) =/=Int -1
// HexEscapeSequence     ::= x HexDigit HexDigit
// UnicodeEscapeSequence ::= u HexDigit HexDigit HexDigit HexDigit
rule processEscapes(S:String) => processEscapes(processHexEscapes    (S, findString(S, "\\x", 0))) when findString(S, "\\x", 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(processUnicodeEscapes(S, findString(S, "\\u", 0))) when findString(S, "\\u", 0) =/=Int -1

syntax String ::= "processHexEscapes" "(" String "," Int ")" [function, notInPrograms]
rule processHexEscapes    (S:String, I:Int) => substrString(S, 0, I) +String chrChar(String2Base(substrString(S, I +Int 2, I +Int 2 +Int 2), 16)) +String substrString(S, I +Int 2 +Int 2, lengthString(S))

syntax String ::= "processUnicodeEscapes" "(" String "," Int ")" [function, notInPrograms]
rule processUnicodeEscapes(S:String, I:Int) => substrString(S, 0, I) +String chrChar(String2Base(substrString(S, I +Int 2, I +Int 2 +Int 4), 16)) +String substrString(S, I +Int 2 +Int 4, lengthString(S))

endmodule
