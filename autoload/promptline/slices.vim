fun! promptline#slices#cwd(...)
  let options = get(a:, 1, {})
  return {
        \'function_name': '__promptline_cwd',
        \'function_body': promptline#slices#cwd#function_body( options )}
endfun

fun! promptline#slices#vcs_branch(...)
  let options = get(a:, 1, {})
  return {
        \'function_name': '__promptline_vcs_branch',
        \'can_be_empty': 1,
        \'function_body': promptline#slices#vcs_branch#function_body(options)}
endfun

fun! promptline#slices#last_exit_code(...)
  return {
        \'function_name': '__promptline_last_exit_code',
        \'can_be_empty': 1,
        \'function_body': promptline#slices#last_exit_code#function_body()}
endfun

fun! promptline#slices#jobs(...)
  return {
        \'function_name': '__promptline_jobs',
        \'can_be_empty': 1,
        \'function_body': promptline#slices#jobs#function_body()}
endfun

fun! promptline#slices#host(...)
  " host is \h in bash, %m in zsh
  return '$(if [[ -n ${ZSH_VERSION-} ]]; then print %m; else printf "%s" \\h; fi)'
endfun

fun! promptline#slices#battery(...)
  let options = get(a:, 1, {})
  return {
        \'function_name': '__promptline_battery',
        \'can_be_empty': 1,
        \'function_body': promptline#slices#battery#function_body(options)}
endfun

" internally used to wrap any string, like \w, \h, $(command) with the given colors / separators
fun! promptline#slices#wrapper(...)
  return {
        \'function_name': '__promptline_wrapper',
        \'function_body': [
          \'function __promptline_wrapper {',
          \'  # wrap the text in $3 with $1 and $2, only if $3 is not empty',
          \'  # $1 and $2 should contain non-content-text, like color escape codes and separators',
          \'',
          \'  [[ -n "$3" ]] || return 1',
          \'  printf "%s" "${1}${3}${2}"',
          \'}']}
endfun
