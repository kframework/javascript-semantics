require "../../../js.k"
require "modules/verification_lemmas.k"
require "float_set.k"
require "float_tree_pattern.k"

module JS-VERIFIER

  imports JS
  imports VERIFICATION_LEMMAS
  imports FLOAT-TREE-PATTERN

  syntax NullableObject ::= Oid | NullType
  syntax Val ::= NullableObject

endmodule
