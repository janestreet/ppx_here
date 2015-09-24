open Ppx_core.Std

let map = object
  inherit Ast_traverse.map as super
  method! expression x =
    match x.pexp_desc with
    | Pexp_ident { txt = Longident.Lident "_here_"; loc } ->
      Ppx_here_expander.lift_position ~loc (loc.Location.loc_start)
    | _ ->
      super#expression x
end

let () =
  Ppx_driver.register_code_transformation
    ~name:"here"
    ~impl:map#structure
    ~intf:map#signature
;;
