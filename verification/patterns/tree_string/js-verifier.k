require "../../../js.k"
require "modules/verification_lemmas.k"
require "string_set.k"
require "string_tree_pattern.k"

module JS-VERIFIER

  imports JS
  imports VERIFICATION_LEMMAS
  imports STRING-TREE-PATTERN

  syntax NullableObject ::= Oid | NullType
  syntax Val ::= NullableObject

endmodule
