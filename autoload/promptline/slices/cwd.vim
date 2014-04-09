fun! promptline#slices#cwd#function_body( options )
  let dir_limit = get(a:options, 'dir_limit', 3)
  let dir_sep = promptline#symbols#get().dir_sep
  let truncation = promptline#symbols#get().truncation
  let lines = [
        \'function __promptline_cwd {',
        \'  local dir_limit="' . dir_limit . '"',
        \'  local truncation="' . truncation . '"',
        \'  local first_char',
        \'  local part_count=0',
        \'  local formatted_cwd=""',
        \'  local dir_sep="' . dir_sep . '"',
        \'  local tilde="~"',
        \'',
        \'  local cwd="${PWD/#$HOME/$tilde}"',
        \'',
        \'  # get first char of the path, i.e. tilde or slash',
        \'  [[ -n ${ZSH_VERSION-} ]] && first_char=$cwd[1,1] || first_char=${cwd::1}',
        \'',
        \'  # remove leading tilde',
        \'  cwd="${cwd#\~}"',
        \'',
        \'  while [[ "$cwd" == */* && "$cwd" != "/" ]]; do',
        \'    # pop off last part of cwd',
        \'    local part="${cwd##*/}"',
        \'    cwd="${cwd%/*}"',
        \'',
        \'    formatted_cwd="$dir_sep$part$formatted_cwd"',
        \'    part_count=$((part_count+1))',
        \'',
        \'    [[ $part_count -eq $dir_limit ]] && first_char="$truncation" && break',
        \'  done',
        \'',
        \'  printf "%s" "$first_char$formatted_cwd"',
        \'}']
  return lines
endfun
