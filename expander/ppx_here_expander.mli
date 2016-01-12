
(** Lift a lexing position to a expression *)
val lift_position : loc:Location.t -> Parsetree.expression

(** Lift a lexing position to a string expression *)
val lift_position_as_string : loc:Location.t -> Parsetree.expression
