
(** Lift a lexing position to a expression *)
val lift_position : loc:Location.t -> Lexing.position -> Parsetree.expression
