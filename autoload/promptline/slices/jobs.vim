fun! promptline#slices#jobs#function_body(...)
  let lines = [
        \'',
        \'function __promptline_jobs {',
        \'',
        \'  local jobs_list=( $(jobs -p) )',
        \'  local jobs_count=${#jobs_list[@]}',
        \'  [[ $jobs_count -gt 0 ]] || return 1;',
        \'',
        \'  printf "%s" "${1}$jobs_count${2}"',
        \'}',]
  return lines
endfun
