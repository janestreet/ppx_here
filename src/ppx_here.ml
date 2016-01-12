open Ppx_core.Std

let here =
  Extension.V2.declare "here" Extension.Context.expression
    Ast_pattern.(pstr nil)
    (fun ~loc ~path:_ -> Ppx_here_expander.lift_position ~loc)
;;

let () =
  Ppx_driver.register_transformation "here"
    ~extensions:[ here ]
;;
