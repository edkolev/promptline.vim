
fun! promptline#presets#clear#get()
  return {
        \'b' : [ '$USER' ],
        \'a' : [ promptline#slices#vcs_branch() ],
        \'c' : [ promptline#slices#cwd() ],
        \'order' : [ 'b', 'a', 'c' ]}
endfun
