fun! promptline#presets#powerlineclone#get()
  " host is \h in bash, %m in zsh
  let portable_host = '$(if [[ -n ${ZSH_VERSION-} ]]; then print %m; else printf "%s" \\h; fi)'
  return {
        \'a' : [ portable_host ],
        \'b' : [ '$USER'],
        \'c' : [ promptline#slices#cwd() ],
        \'y' : [ promptline#slices#vcs_branch() ],
        \'warn' : [ promptline#slices#last_exit_code() ]}
endfun
