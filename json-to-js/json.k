//JSON syntax 
module JSON
  syntax OBJECT ::= "{" "}"
  		 | "{" MEMBERS "}"
  syntax MEMBERS ::= PAIR
	 	  | PAIR "," MEMBERS
  syntax PAIR ::= String ":" VALUE
  syntax ARRAY ::= "[" "]"
  		| "[" ELEMENTS "]"
  syntax ELEMENTS ::= VALUE
		   | VALUE "," ELEMENTS
  syntax VALUE ::= String
		| NUMBER
		| OBJECT
		| ARRAY
		| "true" | "false"
		| "null"
		
  syntax DIGIT ::= Token{"[0-9]"}
  syntax DIGIT19 ::= Token{"[1-9]"}

  syntax NUMBER ::= INT | INT FRAC | INT EXP | INT FRAC EXP
  syntax INT ::= DIGIT | DIGIT19 DIGITS | "-" DIGIT | "-" DIGIT19 DIGITS
  syntax FRAC ::= "." DIGITS
  syntax EXP ::= ESCI DIGITS
  syntax DIGITS ::= DIGIT | DIGIT DIGITS
  syntax ESCI ::= "e0" | "e+" | "e-" | "E0" | "E+" | "E-"  // E/e conflicts with dist/include/io/uris.k --> E0/e0
		
//  syntax NUMBER ::= JInt
//		   | JFloat
//
//  syntax JInt ::= Token{"-?[1-9][0-9]*"}
//  syntax JFloat ::= Token{"-?[1-9][0-9]*.[0-9]*"}

endmodule
