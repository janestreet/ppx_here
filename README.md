A ppx rewriter that defines an extension node whose value is its source position.

Syntax
------

`ppx_here` rewrites the extension `[%here]` in expressions, by
replacing it by a value of type `Source_code_position.t`
(i.e. `Lexing.position`) corresponding to the current position. It
respects line number directives.

For instance:

```ocaml
let _ =
  print_endline [%here].Lexing.pos_fname
```

becomes:

```ocaml
let _ =
  print_endline
    {
      Lexing.pos_fname = ppx/ppx_here/test/test.ml";
      pos_lnum = 2;
      pos_cnum = 26;
      pos_bol = 8;
    }.Lexing.pos_fname
```

Usage
-----

This is normally used so exceptions can contain better positions. An example is
`Core_kernel.Std.Option.value_exn`, which takes an optional position so that if you have a
stack trace, you can get still the origin of the exception.

It can also be used in cases where stack traces are useless (for instance in monads with a
complicated control flow).

Command line flag
-----------------

If the filename given to the compiler (or overriden by line directive) is a relative path,
then `ppx_here` rewrites it into an absolute path, unless a flag `-dirname root` is given,
in which case relative filenames are made relative to that `root` filename instead. `root`
can be a relative path.

The goal of this behavior is to

* avoid ambiguity: there are many files called `server.ml`, `common.ml` or `config.ml` in
a tree
* when `-dirname` is passed, avoid being overly specific by giving a path that only exists
on your machine, by allowing the build system to specify where the source file is,
relative to the root of the project
