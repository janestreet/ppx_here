open Ppxlib
module Filename = Stdlib.Filename

let dirname = ref None
let set_dirname dn = dirname := dn

let () =
  Driver.add_arg
    "-dirname"
    (String (fun s -> dirname := Some s))
    ~doc:"<dir> Name of the current directory relative to the root of the project"
;;

let chop_dot_slash_prefix ~fname =
  match Base.String.chop_prefix ~prefix:"./" fname with
  | Some fname -> fname
  | None -> fname
;;

let expand_filename fname =
  match Filename.is_relative fname, !dirname with
  | true, Some dirname ->
    (* If [dirname] is given and [fname] is relative, then prepend [dirname]. *)
    Filename.concat dirname (chop_dot_slash_prefix ~fname)
  | _ -> fname
;;

let lift_position ~loc =
  let loc = { loc with loc_ghost = true } in
  let open (val Ast_builder.make loc) in
  let pos = loc.Location.loc_start in
  let id = Located.lident in
  pexp_record
    [ id "Ppx_here_lib.pos_fname", estring (expand_filename pos.Lexing.pos_fname)
    ; id "pos_lnum", eint pos.Lexing.pos_lnum
    ; id "pos_cnum", eint pos.Lexing.pos_cnum
    ; id "pos_bol", eint pos.Lexing.pos_bol
    ]
    None
;;

let lift_position_as_string ~loc =
  let { pos_fname; pos_lnum; pos_cnum; pos_bol } = loc.loc_start in
  Ast_builder.Default.estring
    ~loc
    (Printf.sprintf "%s:%d:%d" (expand_filename pos_fname) pos_lnum (pos_cnum - pos_bol))
;;

let name_of_simple_value_binding_pattern { ppat_desc; ppat_loc; _ } =
  match ppat_desc with
  | Ppat_var name -> name
  | _ ->
    Location.raise_errorf
      ~loc:ppat_loc
      "[let%%with_pos] is only supported on simple value names"
;;

let with_pos_position_binding ~loc original_binding =
  let open (val Ast_builder.make loc) in
  let name = name_of_simple_value_binding_pattern original_binding.pvb_pat in
  let position_name = name.txt ^ "__pos" in
  value_binding
    ~pat:(ppat_var { txt = position_name; loc })
    ~expr:(lift_position ~loc:name.loc)
;;

let expand_with_pos ~ctxt original_binding =
  let loc =
    { (Expansion_context.Extension.extension_point_loc ctxt) with loc_ghost = true }
  in
  let open (val Ast_builder.make loc) in
  let position_binding = with_pos_position_binding ~loc original_binding in
  [ pstr_value Nonrecursive [ position_binding ]
  ; pstr_value Nonrecursive [ original_binding ]
  ]
;;

let expand_with_pos_expression ~ctxt expr =
  let loc =
    { (Expansion_context.Extension.extension_point_loc ctxt) with loc_ghost = true }
  in
  let open (val Ast_builder.make loc) in
  match Ppxlib_jane.Shim.Expression_desc.of_parsetree expr.pexp_desc ~loc with
  | Pexp_let (Immutable, Nonrecursive, [ original_binding ], body) ->
    let position_binding = with_pos_position_binding ~loc original_binding in
    pexp_let
      Nonrecursive
      [ position_binding ]
      (pexp_let Nonrecursive [ original_binding ] body)
  | Pexp_let (Immutable, Recursive, _, _) ->
    Location.raise_errorf ~loc "[let%%with_pos] cannot be recursive"
  | Pexp_let (Mutable, _, _, _) ->
    Location.raise_errorf ~loc "[let%%with_pos] cannot be mutable"
  | Pexp_let (Immutable, Nonrecursive, _, _) ->
    Location.raise_errorf ~loc "[let%%with_pos] requires exactly one binding"
  | _ -> Location.raise_errorf ~loc "[%%with_pos] can only be used with let bindings"
;;
