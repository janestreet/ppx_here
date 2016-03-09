let package_name = "ppx_here"

let sections =
  [ ("lib",
    [ ("built_lib_ppx_here", None)
    ; ("built_lib_ppx_here_expander", None)
    ],
    [ ("META", None)
    ])
  ; ("bin",
    [ ("built_exec_ppx", Some "../lib/ppx_here/ppx")
    ],
    [])
  ]
