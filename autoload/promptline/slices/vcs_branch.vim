fun! promptline#slices#vcs_branch#function_body(...)
  let branch_symbol = promptline#symbols#get().vcs_branch
  let lines = [
        \'',
        \'function __promptline_vcs_branch {',
        \'  hash git 2>/dev/null || return 1',
        \'',
        \'  local branch=$( { git symbolic-ref --quiet HEAD || git rev-parse --short HEAD; } 2>/dev/null )',
        \'  [[ -n $branch ]] || return 1;',
        \'  branch=${branch##*/}',
        \'',
        \'  local branch_symbol="' . branch_symbol . '"',
        \'  printf "%s" "${1}${branch_symbol}${branch:-unknown}${2}"',
        \'}',]
  return lines
endfun
