open Ppx_core

module Filename = Caml.Filename

let dirname = ref None

let set_dirname dn = dirname := dn

let () =
  Ppx_driver.add_arg "-dirname"
    (String (fun s -> dirname := Some s))
    ~doc:"<dir> Name of the current directory relative to the root of the project"

let correct_fname ~fname =
  match String.chop_prefix ~prefix:"./" fname with
  | Some fname -> fname
  | None -> fname

(* Copy&pasted from location.ml in the OCaml sources *)
let absolute_path s = (* This function could go into Filename *)
  let open Filename in
  let s = if is_relative s then concat (Caml.Sys.getcwd ()) s else s in
  (* Now simplify . and .. components *)
  let rec aux s =
    let base = basename s in
    let dir = dirname s in
    if String.equal dir s then dir
    else if String.equal base current_dir_name then aux dir
    else if String.equal base parent_dir_name then dirname (aux dir)
    else concat (aux dir) base
  in
  aux s

let expand_filename fname =
  let fname = correct_fname ~fname in
  match Filename.is_relative fname, !dirname with
  | true, Some dirname ->
    (* If [dirname] is given and [fname] is relative, then prepend [dirname]. *)
    Filename.concat dirname fname
  | true, None
  | false, _
    (* Otherwise, use the absolute [fname] *)
    -> absolute_path fname

let lift_position ~loc =
  let (module Builder) = Ast_builder.make loc in
  let open Builder in
  let pos = loc.Location.loc_start in
  let id = Located.lident in
  pexp_record
    [ id "Lexing.pos_fname" , estring (expand_filename pos.Lexing.pos_fname)
    ; id "pos_lnum"         , eint    pos.Lexing.pos_lnum
    ; id "pos_cnum"         , eint    pos.Lexing.pos_cnum
    ; id "pos_bol"          , eint    pos.Lexing.pos_bol
    ] None

let lift_position_as_string ~(loc : Location.t) =
  let { Lexing. pos_fname; pos_lnum; pos_cnum; pos_bol } = loc.loc_start in
  Ast_builder.Default.estring ~loc
    (Printf.sprintf "%s:%d:%d" (expand_filename pos_fname) pos_lnum
       (pos_cnum - pos_bol))
;;
