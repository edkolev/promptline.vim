
" TODO rename section -> slice
fun! s:get_section_prefix_and_suffix(section_name, is_left_section)
  if a:is_left_section
    let section_prefix = '"${'. a:section_name .'_bg}${sep}${'. a:section_name .'_fg}${'. a:section_name .'_bg}${space}"'
    let section_empty_prefix = '"${'. a:section_name .'_fg}${'. a:section_name .'_bg}${space}"'
    let section_suffix = '"$space${' . a:section_name . '_sep_fg}"'

  else
    let section_prefix = '"${'. a:section_name .'_sep_fg}${rsep}${'. a:section_name .'_fg}${'. a:section_name .'_bg}${space}"'
    let section_empty_prefix = '""'
    let section_suffix = '"$space${' . a:section_name . '_sep_fg}"'
  endif

  let alt_sep = a:is_left_section ? '${alt_sep}' : '${alt_rsep}'
  let section_middle = '"${' . a:section_name . '_fg}${' . a:section_name . '_bg}' .  alt_sep .  '${space}"'

  return [ section_prefix, section_empty_prefix, section_middle, section_suffix ]
endfun

fun! promptline#sections#make_ps1( function_name, preset ) abort
  return s:make( a:function_name,  a:preset, a:preset.options.left_only_sections, 1 )
endfun

fun! promptline#sections#make_prompt( function_name, preset ) abort
  return s:make( a:function_name,  a:preset, a:preset.options.left_sections, 1 )
endfun

fun! promptline#sections#make_right_prompt( function_name, preset ) abort
  return s:make( a:function_name,  a:preset, a:preset.options.right_sections, 0 )
endfun

fun! promptline#sections#used_functions( preset ) abort
  let used_functions = {}
  for section_name in keys( a:preset )
    if section_name ==# 'options'| continue | endif
    for slice in a:preset[section_name]
      if type(slice) == type({})
        let used_functions[slice.function_name] = slice.function_body
      endif
      unlet slice
    endfor
  endfor
  return used_functions
endfun

" TODO return nothing if all sections are empty
fun! s:make( function_name, preset, section_names, is_left )

  let section_local_variables = a:is_left ?
        \'  local slice_prefix slice_empty_prefix slice_joiner slice_suffix is_prompt_empty=1' :
        \'  local slice_prefix slice_empty_prefix slice_joiner slice_suffix'
  let slice_command_trailer = a:is_left ? ' && is_prompt_empty=0' : ''

  let func_body = [
        \'function ' . a:function_name . ' {',
        \ section_local_variables]

  for section_name in a:section_names
    let [ section_prefix, section_empty_prefix, section_middle, section_suffix ] = s:get_section_prefix_and_suffix(section_name, a:is_left)
    let func_body += [
          \'',
          \'  # section "' . section_name . '" header',
          \'  slice_prefix=' . section_prefix  . ' slice_suffix=' . section_suffix . ' slice_joiner=' . section_middle . ' slice_empty_prefix=' . section_empty_prefix]

    " only left sections should check $is_prompt_empty
    if a:is_left
      let func_body += ['  [ $is_prompt_empty -eq 1 ] && slice_prefix="$slice_empty_prefix"']
    endif

    let func_body += ['  # section "' . section_name . '" slices']
    for slice in a:preset[section_name]
      if type(slice) == type({}) && get(slice, 'can_be_empty')
        let slice_content =  '  ' . slice.function_name . ' "$slice_prefix" "$slice_suffix" && slice_prefix="$slice_joiner"' . slice_command_trailer
      elseif type(slice) == type({})
        let slice_content = '  printf "%s" "$slice_prefix" && ' . slice.function_name . ' && printf "%s" "$slice_suffix" && slice_prefix="$slice_joiner"' . slice_command_trailer
      else
        let slice_content = '  printf "%s%s%s" "$slice_prefix"  "' . slice . '" "$slice_suffix" && slice_prefix="$slice_joiner"' . slice_command_trailer
      endif

      let func_body += [ slice_content ]
      unlet slice
    endfor
  endfor

  let section_closing = a:is_left ? '"${reset_bg}${sep}$reset$space"' : '"$reset"'
  let func_body += [
        \'',
        \'  # close sections',
        \'  printf "%s" ' . section_closing,
        \'}',
        \'']
  return func_body
endfun
