
(** Lift a lexing position to a expression *)
val lift_position : loc:Location.t -> Parsetree.expression

(** Lift a lexing position to a string expression *)
val lift_position_as_string : loc:Location.t -> Parsetree.expression

(** Same as setting the directory name with [-dirname], for tests *)
val set_dirname : string option -> unit

(** Expand a filename to get a filename unique to the current repository *)
val expand_filename : string -> string
