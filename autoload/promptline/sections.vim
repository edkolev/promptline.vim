
fun! promptline#sections#make_section(section_name, slices, is_left_section, is_first_section) abort

  let [ section_prefix, section_middle, section_suffix ] = s:get_section_prefix_and_suffix(a:section_name, a:is_left_section, a:is_first_section)

  let [ section_content, used_functions ] =
        \   s:is_possibly_empty_section( a:slices, a:is_first_section )
        \ ? s:append_possibly_empty_section( a:slices, section_prefix, section_middle, section_suffix  )
        \ : s:append_simple_section( a:slices, section_prefix, section_suffix  )
  return [section_content, used_functions]
endfun

fun! s:get_section_prefix_and_suffix(section_name, is_left_section, is_first_section)
  if a:is_left_section
    let leading_separator = a:is_first_section ? '' : '${'. a:section_name .'_bg}${sep}'
    let section_prefix =
          \ '"' .
          \ leading_separator .
          \ '${'. a:section_name .'_fg}' .
          \ '${'. a:section_name .'_bg}' .
          \ '${space}' .
          \ '"'
    let section_suffix = '"$space${' . a:section_name . '_sep_fg}"'
  else
    let section_prefix =
          \ '"' .
          \ '${'. a:section_name .'_sep_fg}' .
          \ '${rsep}' .
          \ '${'. a:section_name .'_fg}' .
          \ '${'. a:section_name .'_bg}' .
          \ '${space}' .
          \ '"'
    let section_suffix = '"$space${' . a:section_name . '_sep_fg}"'
  endif

  let section_middle =
        \ '"' .
        \'${' . a:section_name . '_fg}' .
        \'${' . a:section_name . '_bg}' .
        \ ( a:is_left_section ? '${alt_sep}' : '${alt_rsep}' ).
        \'${space}' .
        \ '"'
  return [ section_prefix, section_middle, section_suffix ]
endfun

let s:c = 0
fun! s:append_possibly_empty_section( section_slices, section_prefix, section_middle, section_suffix  ) abort
  let used_functions_in_section = {}
  let section_content = ''

  " if len(a:section_slices) == 1
  "   let slice = a:section_slices[0]
  "   let section_content = '$(' . slice.function_name . ' ' . a:section_prefix . ' ' . a:section_suffix . ')'
  "   let used_functions_in_section[slice.function_name] = slice.function_body
  "   return [ section_content, used_functions_in_section ]
  " endif

  let func_name = 'empty_sections_' . s:c
  let s:c += 1
  let section_content = '$(' . func_name . ')'
  let func_body = [
        \'function ' . func_name .' {',
        \'  local P=' . a:section_prefix,
        \'  local S=' . a:section_suffix,
        \'  local J=' . a:section_middle,
        \'',
        \'  local slice_pref="$pref"',
        \'']

  for slice in a:section_slices
    if type(slice) == type({}) && get(slice, 'can_be_empty')
      let func_body += [ '  ' . slice.function_name . ' "$P" "$S" && P="$J"' ]
      let used_functions_in_section[slice.function_name] = slice.function_body
    elseif type(slice) == type({})
      let func_body += [ '  printf "%s" "$P"; ' . slice.function_name . '; printf "%s" "$S"; P="$J"' ]
      let used_functions_in_section[slice.function_name] = slice.function_body
    else
      let func_body += [ '  printf "%s%s%s" "$P"  "' . slice . '" "$S" && P="$J"' ]
    endif
    unlet slice
  endfor

  let func_body += ['', '}', '']

  let used_functions_in_section[func_name] = func_body
  return [ section_content, used_functions_in_section ]
endfun


fun! s:append_simple_section( section_slices, section_prefix, section_suffix  ) abort
  let section_content = ''
  let used_functions_in_section = {}

  let processed_section_slices = []

  for slice in (a:section_slices)
    if type(slice) == type("")
      let processed_section_slices += [ slice ]
    elseif type(slice) == type({})
      let processed_section_slices += [ '$(' . slice.function_name . ')' ]
      let used_functions_in_section[slice.function_name] = slice.function_body
    endif
    unlet slice
  endfor

  let section_content = join( processed_section_slices, '${space}${alt_sep}${space}' )
  let section_content = a:section_prefix . section_content . a:section_suffix

  return [ section_content, used_functions_in_section ]
endfun

fun! s:is_possibly_empty_section(section_slices, is_first_section)
  return 1
  let ret = 0
  let possibly_empty_slices = 0
  for slice in a:section_slices
    if type(slice) == type({}) && get(slice, 'can_be_empty')
      " let possibly_empty_slices += 1
      let ret = 1
    endif
    unlet slice
  endfor

  return ret
  " return len(a:section_slices) == possibly_empty_slices
endfun

