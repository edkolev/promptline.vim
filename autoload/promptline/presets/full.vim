
fun! promptline#presets#full#get()
  return {
        \'a': [ promptline#slices#host(), promptline#slices#user() ],
        \'b': [ promptline#slices#cwd() ],
        \'c' : [ promptline#slices#vcs_branch() ],
        \'warn' : [ promptline#slices#last_exit_code(), promptline#slices#battery() ]}
endfun

