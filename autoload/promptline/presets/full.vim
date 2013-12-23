
fun! promptline#presets#full#get()
  " host is \h in bash, %m in zsh
  let portable_host = '$(if [[ -n ${ZSH_VERSION-} ]]; then print %m; else printf "%s" \\h; fi)'
  return {
        \'a': [ portable_host, '$USER' ],
        \'b': [ promptline#slices#cwd() ],
        \'c' : [ promptline#slices#vcs_branch() ],
        \'warn' : [ promptline#slices#last_exit_code() ]}
endfun

