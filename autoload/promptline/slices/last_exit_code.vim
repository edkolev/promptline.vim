fun! promptline#slices#last_exit_code#function_body(...)
  let lines = [
        \'',
        \'function __promptline_last_exit_code {',
        \'',
        \'  [[ $last_exit_code -gt 0 ]] || return 1;',
        \'',
        \'  printf "%s" "${1}$last_exit_code${2}"',
        \'}',]
  return lines
endfun
