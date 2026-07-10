{
  let _ = [%here]

  let%with_pos foo = 0
  let _ = foo, foo__pos
}

rule a = parse
| _ { ignore ([%here]); assert false }
