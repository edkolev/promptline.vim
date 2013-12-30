fun! promptline#slices#jobs#function_body(...)
  let lines = [
        \'',
        \'function __promptline_jobs {',
        \'  local job_count=0',
        \'',
        \'  local IFS=$' . "'" . '\n' . "'",
        \'  for job in $(jobs); do',
        \'    # count only lines starting with [',
        \'    if [[ $job == \[* ]]; then',
        \'      job_count=$(($job_count+1))',
        \'    fi',
        \'  done',
        \'',
        \'  [[ $job_count -gt 0 ]] || return 1;',
        \'  printf "%s" "${1}$job_count${2}"',
        \'}',]
  return lines
endfun
