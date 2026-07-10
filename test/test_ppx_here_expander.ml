[@@@expand_inline let _ = [%here]]

let _ =
  { Ppx_here_lib.pos_fname = "ppx/ppx_here/test/test_ppx_here_expander.ml"
  ; pos_lnum = 1
  ; pos_cnum = 26
  ; pos_bol = 0
  }
;;

[@@@end]
[@@@expand_inline let%with_pos foo = 13]

let foo__pos =
  { Ppx_here_lib.pos_fname = "ppx/ppx_here/test/test_ppx_here_expander.ml"
  ; pos_lnum = 12
  ; pos_cnum = 218
  ; pos_bol = 187
  }
;;

let foo = 13

[@@@end]

[@@@expand_inline
  let _ =
    let%with_pos bar = 0 in
    bar, bar__pos
  ;;]

let _ =
  let bar__pos =
    { Ppx_here_lib.pos_fname = "ppx/ppx_here/test/test_ppx_here_expander.ml"
    ; pos_lnum = 28
    ; pos_cnum = 451
    ; pos_bol = 434
    }
  in
  let bar = 0 in
  bar, bar__pos
;;

[@@@end]
