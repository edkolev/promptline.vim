fun! promptline#slices#cwd(...)
  let options = get(a:, 1, {})
  return {
        \'function_name': '__promptline_cwd',
        \'function_body': promptline#slices#cwd#function_body( options )}
endfun

fun! promptline#slices#vcs_branch(...)
  return {
        \'function_name': '__promptline_vcs_branch',
        \'can_be_empty': 1,
        \'function_body': promptline#slices#vcs_branch#function_body()}
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

