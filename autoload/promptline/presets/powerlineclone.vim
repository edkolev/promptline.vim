fun! promptline#presets#powerlineclone#get()
  " XXX section x,y,z is a hack. Officially only a,b,c are supported at this time
  return {
        \'a' : [ '\h' ],
        \'b' : [ '$USER'],
        \'c' : [ promptline#slices#cwd() ],
        \'y' : [ promptline#slices#vcs_branch() ],
        \'warn' : [ promptline#slices#last_exit_code() ],
        \'order': ['a', 'b', 'c', 'y', 'warn']}
endfun
