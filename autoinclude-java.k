require "k-prelude.k"
require "builtins/map.k"
require "builtins/set.k"
require "builtins/list.k"
require "io/io.k"

module AUTO-INCLUDED-MODULE-SYNTAX
//imports BUILTIN-SYNTAX-HOOKS

  imports BOOL-SYNTAX-HOOKS
  imports INT-SYNTAX-HOOKS
//imports FLOAT-SYNTAX-HOOKS
//imports STRING-SYNTAX-HOOKS
  imports ID-SYNTAX-HOOKS
endmodule

module AUTO-INCLUDED-MODULE
  imports BUILTIN-HOOKS
  imports K
  imports LIST
  imports MAP
  imports SET
  imports K-IO
endmodule
