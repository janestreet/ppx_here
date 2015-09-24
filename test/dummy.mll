{
  let _ = _here_
}

rule a = parse
| _ { ignore (_here_); assert false }
