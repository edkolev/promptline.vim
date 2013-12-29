" The MIT License (MIT)
"
" Copyright (c) 2013 Evgeni Kolev

let s:FG = 0
let s:BG = 1
let s:SHELL_FG_CODE = 38
let s:SHELL_BG_CODE = 48

let s:default_theme = 'powerlineclone'
let s:default_preset = 'powerlineclone'

fun! promptline#snapshot(overwrite, file, ...) abort
  let input_theme = get(a:, 1, get(g:, 'promptline_theme', s:default_theme))
  let input_preset = get(a:, 2, get(g:, 'promptline_preset', s:default_preset))

  try
    let file = s:validate_file(a:overwrite, a:file)
    let theme = promptline#themes#load_theme(input_theme)
    let preset = promptline#presets#load_preset(input_preset)
    call promptline#create_snapshot(file, theme, preset)
  catch /^promptline:/
    echohl ErrorMsg | echomsg v:exception | echohl None
  endtry
endfun

fun! s:validate_file(overwrite, file)
  let file = fnamemodify(a:file, ":p")
  let dir = fnamemodify(file, ':h')

  if empty(file)
    throw "promptline: Bad file name: \"" . file . "\""
  elseif (filewritable(dir) != 2)
    throw "promptline: Cannot write to directory \"" . dir . "\""
  elseif (glob(file) || filereadable(file)) && !a:overwrite
    throw "promptline: File exists (add ! to override)"
  endif

  return file
endfun

fun! s:bg(color)
  return printf('"${wrap}%d;5;%d${end_wrap}"', s:SHELL_BG_CODE, a:color)
endfun

fun! s:fg(color)
  return printf('"${wrap}%d;5;%d${end_wrap}"', s:SHELL_FG_CODE, a:color)
endfun

fun! promptline#create_snapshot(file, theme, preset) abort
  let prompt = {
        \'functions': {},
        \'left_sections': [],
        \'right_sections': [],
        \'sections': []}

  call s:append_sections_to_prompt(prompt, a:preset)

  let shell_escape_codes            = s:get_shell_escape_codes()
  let symbol_definitions            = s:get_symbol_definitions()
  let text_attribute_modifiers      = s:get_text_attribute_modifiers()
  let color_variables               = s:get_color_variables(a:theme, a:preset)
  let function_definitions          = s:get_function_definitions(prompt)
  let prompt_variables_installation = s:get_prompt_variables_installation(prompt)
  let prompt_installation           = s:get_prompt_installation()

  let snapshot_lines =
        \ [ '#'] +
        \ [ '# This shell prompt config file was created by promptline.vim'] +
        \ [ '#'] +
        \ function_definitions +
        \ ['function __promptline {'] +
        \ ['  local last_exit_code="$?"'] +
        \ [''] +
        \ shell_escape_codes +
        \ symbol_definitions +
        \ text_attribute_modifiers +
        \ color_variables +
        \ prompt_variables_installation +
        \ ['}' ] +
        \ prompt_installation

  if writefile(snapshot_lines, a:file) != 0
    throw "promptline: Failed writing file " . a:file
  endif
endfun

fun! s:get_shell_escape_codes()
  return [
        \"  local esc=$'\e[' end_esc=m",
        \'  if [[ -n ${ZSH_VERSION-} ]]; then',
        \"    local noprint='%{' end_noprint='%}'",
        \'  else',
        \"    local noprint='\\[' end_noprint='\\]'",
        \'  fi',
        \'  local wrap="$noprint$esc" end_wrap="$end_esc$end_noprint"']
endfun

fun! s:get_prompt_variables_installation(prompt)
  return [
        \'  if [[ -n ${ZSH_VERSION-} ]]; then',
        \'    PROMPT="' . join(a:prompt.left_sections, '') . '"',
        \'    RPROMPT="' . join(a:prompt.right_sections, '') . '"',
        \'  else',
        \'    PS1="' . join(a:prompt.sections, '') . '"',
        \'  fi']
endfun

fun! s:get_color_variables( theme, preset )
  let color_variables = []

  for section_name in sort(keys(a:preset))
    if section_name ==# 'options'
      continue
    endif

    if !has_key(a:theme, section_name)
      throw "promptline: theme doesn't define colors for '". section_name . "' section"
    endif

    let [fg, bg] = a:theme[section_name][s:FG : s:BG]
    let color_variables += [ '  local ' .section_name. '_fg=' . s:fg(fg) ]
    let color_variables += [ '  local ' .section_name. '_bg=' . s:bg(bg) ]
    let color_variables += [ '  local ' .section_name. '_sep_fg=' . s:fg(bg) ]
  endfor
  return color_variables
endfun

fun! s:append_sections_to_prompt( prompt, preset ) abort
  " TODO check if func_body is not empty
  let a:prompt.functions['__promptline_ps1'] = promptline#sections#make_ps1( '__promptline_ps1', a:preset )
  let a:prompt.functions['__promptline_left_prompt'] = promptline#sections#make_prompt( '__promptline_left_prompt', a:preset )
  let a:prompt.functions['__promptline_right_prompt'] = promptline#sections#make_right_prompt( '__promptline_right_prompt', a:preset )

  let used_functions = promptline#sections#used_functions( a:preset )
  call extend(a:prompt.functions, used_functions)

  " TODO check if func_body is not empty
  let a:prompt.sections = [ '$(__promptline_ps1)' ]
  let a:prompt.left_sections = [ '$(__promptline_left_prompt)' ]
  let a:prompt.right_sections = [ '$(__promptline_right_prompt)' ]

endfun

fun! s:get_text_attribute_modifiers()
  return [
        \'  local reset="${wrap}0${end_wrap}"',
        \'  local reset_bg="${wrap}49${end_wrap}"']
endfun

fun! s:get_function_definitions(prompt)
  let function_definitions = []
  for function_body in values(a:prompt.functions)
    let function_definitions += function_body
  endfor
  return function_definitions
endfun

fun! s:get_symbol_definitions()
  let symbols = promptline#symbols#get()

  return [
        \'  local space="' . symbols.space . '"',
        \'  local sep="' . symbols.left . '"',
        \'  local rsep="' . symbols.right . '"',
        \'  local alt_sep="' . symbols.left_alt . '"',
        \'  local alt_rsep="' . symbols.right_alt . '"']
endfun

fun! s:get_prompt_installation()
  return [
      \'',
      \'if [[ -n ${ZSH_VERSION-} ]]; then',
      \'  if [[ ! ${precmd_functions[(r)__promptline]} == __promptline ]]; then',
      \'    precmd_functions+=(__promptline)',
      \'  fi',
      \'else',
      \'  PROMPT_COMMAND=__promptline',
      \'fi']
endfun

fun! s:get_ordered_section_names(preset)
  let order = get(a:preset, 'order', s:DEFAULT_SECTION_ORDER)

  return filter(copy(order), 'has_key(a:preset, v:val)')
endfun

" fun! s:is_possibly_empty_section(section_slices, is_first_section)
"   let is_possibly_empty = 0
"   if len(a:section_slices) == 1 && !a:is_first_section
"     let slice = a:section_slices[0]
"     if type(slice) == type({}) && get(slice, 'can_be_empty')
"       let is_possibly_empty = 1
"     endif
"   endif

"   " TODO check if any of the slices 'can_be_empty'
"   return is_possibly_empty
" endfun

" fun! s:get_section_prefix_and_suffix(section_name, is_left_section, is_first_section)
"   if a:is_left_section
"     let leading_separator = a:is_first_section ? '' : '${'. a:section_name .'_bg}${sep}'
"     let section_prefix =
"           \ '"' .
"           \ leading_separator .
"           \ '${'. a:section_name .'_fg}' .
"           \ '${'. a:section_name .'_bg}' .
"           \ '${space}' .
"           \ '"'
"     let section_suffix = '"$space${' . a:section_name . '_sep_fg}"'
"   else
"     let section_prefix =
"           \ '"' .
"           \ '${'. a:section_name .'_sep_fg}' .
"           \ '${rsep}' .
"           \ '${'. a:section_name .'_fg}' .
"           \ '${'. a:section_name .'_bg}' .
"           \ '${space}' .
"           \ '"'
"     let section_suffix = '"$space${' . a:section_name . '_sep_fg}"'
"   endif
"   return [ section_prefix, section_suffix ]
" endfun

" fun! s:make_section(section_name, slices, is_left_section, is_first_section)
"   let [ section_prefix, section_suffix ] = s:get_section_prefix_and_suffix(a:section_name, a:is_left_section, a:is_first_section)
"   let [ section_content, used_functions ] = s:get_section_content_and_used_functions( a:slices, section_prefix, section_suffix, a:is_first_section )
"   return [ section_content, used_functions ]
" endfun

" fun! s:get_section_content_and_used_functions(section_slices, section_prefix, section_suffix, is_first_section)
"   " let [ section_content, used_functions ] =
"   "       \   s:is_possibly_empty_section( a:section_slices, a:is_first_section )
"   "       \ ? s:append_possibly_empty_section( a:section_slices, a:section_prefix, a:section_suffix  )
"   "       \ : s:append_simple_section( a:section_slices, a:section_prefix, a:section_suffix  )
"   let [ section_content, used_functions ] = s:append_simple_section( a:section_slices, a:section_prefix, a:section_suffix  )
"   return [section_content, used_functions]
" endfun

" fun! s:append_possibly_empty_section( section_slices, section_prefix, section_suffix  ) abort
"   let slice = a:section_slices[0]

"   let used_functions_in_section = {}
"   let section_content = '$(' . slice.function_name . ' ' . a:section_prefix . ' ' . a:section_suffix . ')'
"   let used_functions_in_section[slice.function_name] = slice.function_body

"   return [ section_content, used_functions_in_section ]
" endfun

" let s:c = 0

" fun! s:append_simple_section( section_slices, section_prefix, section_suffix  ) abort
"   let section_content = ''
"   let used_functions_in_section = {}

"   let s:c += 1
"   let func_name = '__promptline_section_' . s:c
"   let func_body = [
"         \'function ' . func_name . ' {',
"         \'  local pref=' . a:section_prefix,
"         \'  local suff=' . a:section_suffix,
"         \'  local join=' . '${space}${alt_sep}${space}',
"         \'  local slice_pref="$pref"']

"   let processed_section_slices = []
"   for slice in (a:section_slices)
"     if type(slice) == type("")
"       let func_body += [ '  printf "%s%s%s" "$slice_pref" "' . slice . '" "$suff"' ]
"     elseif type(slice) == type({})
"       if get(slice, 'can_be_empty', 0)
"         let used_functions_in_section[slice.function_name] = slice.function_body
"         let func_body += [ '  ' . slice.function_name . ' "$slice_pref" "$suff"' ]
"       else
"         let func_body += [ '  ' . slice.function_name  ]
"       endif
"     endif
"     unlet slice
"   endfor

"   " let section_content = join( processed_section_slices, '${space}${alt_sep}${space}' )
"   " let section_content = join( processed_section_slices, '' )
"   " let section_content = section_content . '${suf}'
"   "

"   let func_body += [
"         \'}',
"         \'']

"   let used_functions_in_section[func_name] = func_body

"   return [ '$(' . func_name . ')', used_functions_in_section ]
" endfun

fun! s:append_closing_section( prompt ) abort
  let closing_section =
        \ '${reset_bg}' .
        \ '${sep}' .
        \ '$reset' .
        \ '$space'

  let a:prompt.sections += [ closing_section ]
  let a:prompt.left_sections += [ closing_section ]

  if len(a:prompt.right_sections) > 0
    let a:prompt.right_sections += [ '${reset}' ]
  endif
endfun

