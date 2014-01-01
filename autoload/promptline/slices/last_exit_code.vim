fun! promptline#slices#last_exit_code#function_body(...)
  let lines = [
        \'',
        \'function __promptline_last_exit_code {',
        \'',
        \'  [[ $last_exit_code -gt 0 ]] || return 1;',
        \'',
        \'  printf "%s" "$last_exit_code"',
        \'}',]
  return lines
endfun
