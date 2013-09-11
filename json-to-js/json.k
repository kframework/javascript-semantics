//JSON syntax 

require "js-on-common.k"

module JSON
  imports JS-ON-COMMON
/*  
//common parts
  syntax OBJECT ::= "{" "}"
  		 |  "{" MEMBERS "}"
  syntax MEMBERS ::= PAIR
	 	  |  PAIR "," MEMBERS
  syntax ARRAY ::= "[" "]"
  		|  "[" ELEMENTS "]"
  syntax ELEMENTS ::= VALUE
		   |  VALUE "," ELEMENTS
*/

  syntax PAIR ::= String ":" VALUE
  syntax VALUE ::= JValue
		|  String
		|  Bool
		|  Null

/*
//from the actual syntax: json.org
  syntax DIGIT ::= Token{"[0-9]"}
  syntax DIGIT19 ::= Token{"[1-9]"}

  syntax NUMBER ::= INT | INT FRAC | INT EXP | INT FRAC EXP
  syntax INT ::= DIGIT | DIGIT19 DIGITS | "-" DIGIT | "-" DIGIT19 DIGITS
  syntax FRAC ::= "." DIGITS
  syntax EXP ::= ESCI DIGITS
  syntax DIGITS ::= DIGIT | DIGIT DIGITS
  syntax ESCI ::= "e0" | "e+" | "e-" | "E0" | "E+" | "E-"  // E/e conflicts with dist/include/io/uris.k --> E0/e0
*/
endmodule
