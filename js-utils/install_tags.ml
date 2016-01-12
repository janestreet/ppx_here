let package_name = "ppx_here"

let sections =
  [ ("lib",
    [ ("built_lib_ppx_here", None)
    ; ("built_lib_ppx_here_expander", None)
    ],
    [ ("META", None)
    ])
  ; ("libexec",
    [ ("built_exec_ppx", Some "ppx")
    ],
    [])
  ]
