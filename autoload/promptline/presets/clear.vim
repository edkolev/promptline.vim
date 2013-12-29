
fun! promptline#presets#clear#get()
  return {
        \'b' : [ '$USER' ],
        \'a' : [ promptline#slices#vcs_branch() ],
        \'c' : [ promptline#slices#cwd() ],
        \'options': {
          \'left_sections' : [ 'b', 'a', 'c' ],
          \'left_only_sections' : [ 'b', 'a', 'c' ]}}
endfun
