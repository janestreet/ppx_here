let () =
  let p = [%here] in
  Printf.printf "fname=%s line=%d column=%d\n"
    p.pos_fname p.pos_lnum (p.pos_cnum - p.pos_bol)
