fun! promptline#slices#vcs_branch#function_body(...)
  let lines = [
        \'',
        \'function __promptline_vcs_branch {',
        \'  hash git 2>/dev/null || return 1',
        \'',
        \'  local branch=$( { git symbolic-ref --quiet HEAD || git rev-parse --short HEAD; } 2>/dev/null )',
        \'  [[ -n $branch ]] || return 1;',
        \'  branch=${branch##*/}',
        \'',
        \'  printf "%s" "${1}${vcs_branch}${branch:-unknown}${2}"',
        \'}',]
  return lines
endfun
