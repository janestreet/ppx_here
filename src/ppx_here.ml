open Ppxlib

let here =
  Extension.declare
    "here"
    Extension.Context.expression
    Ast_pattern.(pstr nil)
    (fun ~loc ~path:_ -> Ppx_here_expander.lift_position ~loc)
;;

let with_pos_structure_item =
  Extension.V3.declare_inline
    "with_pos"
    Extension.Context.structure_item
    Ast_pattern.(pstr (pstr_value nonrecursive (__ ^:: nil) ^:: nil))
    Ppx_here_expander.expand_with_pos
  |> Context_free.Rule.extension
;;

let with_pos_expression =
  Extension.V3.declare
    "with_pos"
    Extension.Context.expression
    Ast_pattern.(single_expr_payload __)
    Ppx_here_expander.expand_with_pos_expression
;;

let () =
  Driver.register_transformation
    "here"
    ~extensions:[ here; with_pos_expression ]
    ~rules:[ with_pos_structure_item ]
;;
