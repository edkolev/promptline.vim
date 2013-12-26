fun! promptline#presets#powerlineclone#get()
  return {
        \'a' : [ promptline#slices#host() ],
        \'b' : [ '$USER'],
        \'c' : [ promptline#slices#cwd() ],
        \'y' : [ promptline#slices#vcs_branch() ],
        \'warn' : [ promptline#slices#last_exit_code() ]}
endfun
