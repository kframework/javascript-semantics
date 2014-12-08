module JS-STR-NUMERIC-LITERAL

syntax StrNumericLiteral ::= StrDecimalLiteral
                           | HexIntegerLiteral

syntax StrDecimalLiteral ::= StrUnsignedDecimalLiteral
                           | "+" StrUnsignedDecimalLiteral
                           | "-" StrUnsignedDecimalLiteral

syntax StrUnsignedDecimalLiteral ::= InfinityLiteral
                                   | DecimalDigits "." DecimalDigits ExponentPart
                                   | DecimalDigits "." DecimalDigits                [klabel('dotDecimalLiteral)]
                                   | DecimalDigits "."               ExponentPart   [klabel('dotDecimalLiteral)]
                                   | DecimalDigits "."
                                   | "." DecimalDigits ExponentPart
                                   | "." DecimalDigits
                                   | DecimalDigits ExponentPart
                                   | DecimalDigits

syntax InfinityLiteral ::= Token{ "Infinity" } [notInRules, notInGround, noAutoReject]

syntax DecimalDigits ::= DecimalDigit
                       | DecimalDigits DecimalDigit

syntax DecimalDigit ::= Token{ [0-9] } [notInRules, notInGround]

syntax ExponentPart ::= ExponentIndicator SignedInteger

syntax ExponentIndicator ::= Token{ [eE] } [notInRules, notInGround]

syntax SignedInteger ::= DecimalDigits
                       | "+" DecimalDigits
                       | "-" DecimalDigits

syntax HexIntegerLiteral ::= "0x" HexDigit 
                           | "0X" HexDigit
                           | HexIntegerLiteral HexDigit

syntax HexDigit ::= Token{ [0-9a-fA-F] } [notInRules, notInGround]

endmodule
