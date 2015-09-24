open StdLabels
open Ppx_core.Std

let dirname = ref None

let () =
  Ppx_driver.add_arg "-dirname"
    (Arg.String (fun s -> dirname := Some s))
    ~doc:"<dir> Name of the current directory relative to the root of the project"

let is_prefix ~prefix x =
  let prefix_len = String.length prefix in
  String.length x >= prefix_len && prefix = String.sub x ~pos:0 ~len:prefix_len

let chop_prefix ~prefix x =
  if is_prefix ~prefix x then
    let prefix_len = String.length prefix in
    Some (String.sub x ~pos:prefix_len ~len:(String.length x - prefix_len))
  else
    None

let correct_fname ~fname =
  match chop_prefix ~prefix:"./" fname with
  | Some fname -> fname
  | None -> fname

let get_filename ~fname =
  let fname = correct_fname ~fname in
  match Filename.is_relative fname, !dirname with
  | true, Some dirname ->
    (* If [dirname] is given and [fname] is relative, then prepend [dirname]. *)
    Filename.concat dirname fname
  | true, None
  | false, _
    (* Otherwise, use the absolute [fname] *)
    -> Location.absolute_path fname

let lift_position ~loc p =
  let (module Builder) = Ast_builder.make loc in
  let open Builder in
  let id = Located.lident in
  pexp_record
    [ id "Lexing.pos_fname" , estring (get_filename ~fname:p.Lexing.pos_fname)
    ; id "pos_lnum"         , eint    p.Lexing.pos_lnum
    ; id "pos_cnum"         , eint    p.Lexing.pos_cnum
    ; id "pos_bol"          , eint    p.Lexing.pos_bol
    ] None
