fun! promptline#slices#cwd#function_body( options )
  let dir_count = get(a:options, 'dir_count', 3)
  let lines = [
        \'',
        \'function __promptline_cwd {',
        \'  local cwd="${PWD/#$HOME/~}"',
        \'',
        \'  local dir_limit=' . dir_count,
        \'  local root=${cwd::1}',
        \'  local cwd="${cwd/#~/}"',
        \'',
        \'  local parts=($root ${cwd//\// })',
        \'  local parts_count=${#parts[@]}',
        \'  local start_index=$((parts_count - dir_limit))',
        \'',
        \'  if [ $dir_limit -eq -1 ]; then',
        \'    start_index=0',
        \'  fi',
        \'',
        \'  # bold the current dir',
        \'  parts[${#parts[@]} - 1]="$bold${parts[${#parts[@]} - 1]}$unbold"',
        \'',
        \'  if [ $start_index -gt 0 ]; then',
        \'    parts=( $truncation "${parts[@]:$start_index}" )',
        \'  fi',
        \'',
        \'  out=$(printf "$dir_sep%s" "${parts[@]}")',
        \'  out="${out/#$dir_sep/}"',
        \'',
        \'  printf "%s" "$out"',
        \'}']
  return lines
endfun
