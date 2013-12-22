
fun! promptline#presets#full#get()
  return {
        \'a': [ '\h', '$USER' ],
        \'b': [ promptline#slices#cwd() ],
        \'c' : [ promptline#slices#vcs_branch() ],
        \'warn' : [ promptline#slices#last_exit_code() ]}
endfun

