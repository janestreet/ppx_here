open Ppxlib

(** Lift a lexing position to a expression *)
val lift_position : loc:Location.t -> Parsetree.expression

(** Lift a lexing position to a string expression *)
val lift_position_as_string : loc:Location.t -> Parsetree.expression

(** Same as setting the directory name with [-dirname], for tests *)
val set_dirname : string option -> unit

(** Prepend the directory name if [-dirname] was passed on the command line and the
    filename is relative. *)
val expand_filename : string -> string

(** Expand [let%with_pos foo ... = expr] into a companion [foo_pos] value followed by the
    original [foo] binding. *)
val expand_with_pos
  :  ctxt:Expansion_context.Extension.t
  -> value_binding
  -> structure_item list

val expand_with_pos_expression
  :  ctxt:Expansion_context.Extension.t
  -> expression
  -> expression
