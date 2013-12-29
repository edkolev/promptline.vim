
fun! promptline#presets#clear#get()
  return {
        \'b' : [ '$USER' ],
        \'a' : [ promptline#slices#vcs_branch(), promptline#slices#last_exit_code() ],
        \'c' : [ promptline#slices#cwd() ],
        \'options': {
          \'left_sections' : [ 'b', 'a', 'c' ],
          \'left_only_sections' : [ 'b', 'a', 'c' ]}}
endfun
