require "../../../js.k"
require "modules/verification_lemmas.k"
require "list_pattern.k"

module JS-VERIFIER

  imports JS
  imports VERIFICATION_LEMMAS
  imports LIST-PATTERN

  syntax NullableObject ::= Oid | NullType
  syntax Val ::= NullableObject

endmodule
