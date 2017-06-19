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
        \'function_body': promptline#slices#vcs_branch#function_body(options)}
endfun

fun! promptline#slices#last_exit_code(...)
  return {
        \'function_name': '__promptline_last_exit_code',
        \'function_body': promptline#slices#last_exit_code#function_body()}
endfun

fun! promptline#slices#jobs(...)
  return {
        \'function_name': '__promptline_jobs',
        \'function_body': promptline#slices#jobs#function_body()}
endfun

fun! promptline#slices#host(...)
  let options = get(a:, 1, {})
  return {
        \'function_name': '__promptline_host',
        \'function_body': promptline#slices#host#function_body(options)}
endfun

fun! promptline#slices#user(...)
  " user is \u in bash, %n in zsh
  return '$(if [[ -n ${ZSH_VERSION-} ]]; then print %n; elif [[ -n ${FISH_VERSION-} ]]; then printf "%s" "$USER"; else printf "%s" \\u; fi )'
endfun

fun! promptline#slices#battery(...)
  let options = get(a:, 1, {})
  return {
        \'function_name': '__promptline_battery',
        \'function_body': promptline#slices#battery#function_body(options)}
endfun

fun! promptline#slices#python_virtualenv(...)
  return '${VIRTUAL_ENV##*/}'
endfun

fun! promptline#slices#conda_env(...)
  return '$CONDA_DEFAULT_ENV'
endfun

fun! promptline#slices#git_status(...)
  return { 'function_name': '__promptline_git_status',
          \'function_body': readfile(globpath(&rtp, "autoload/promptline/slices/git_status.sh"))}
endfun

" internally used to wrap any string, like \w, \h, $(command) with the given colors / separators
fun! promptline#slices#wrapper(...)
  return {
        \'function_name': '__promptline_wrapper',
        \'function_body': [
          \'function __promptline_wrapper {',
          \'  # wrap the text in $1 with $2 and $3, only if $1 is not empty',
          \'  # $2 and $3 typically contain non-content-text, like color escape codes and separators',
          \'',
          \'  [[ -n "$1" ]] || return 1',
          \'  printf "%s" "${2}${1}${3}"',
          \'}']}
endfun
