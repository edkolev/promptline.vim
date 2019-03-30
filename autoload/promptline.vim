" The MIT License (MIT)
"
" Copyright (c) 2013-2019 Evgeni Kolev

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
        \ ['  local last_exit_code="${PROMPTLINE_LAST_EXIT_CODE:-$?}"'] +
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
        \'  elif [[ -n ${FISH_VERSION-} ]]; then',
        \"    local noprint='' end_noprint=''",
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
        \'  elif [[ -n ${FISH_VERSION-} ]]; then',
        \'    if [[ -n "$1" ]]; then',
        \'      [[ "$1" = "left" ]] && __promptline_left_prompt || __promptline_right_prompt',
        \'    else',
        \'      __promptline_ps1',
        \'    fi',
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
  let ps1 = promptline#sections#make_ps1( '__promptline_ps1', a:preset )
  let left_prompt = promptline#sections#make_prompt( '__promptline_left_prompt', a:preset )
  let right_prompt = promptline#sections#make_right_prompt( '__promptline_right_prompt', a:preset )

  let used_functions = promptline#sections#used_functions( a:preset )
  let used_functions['__promptline_ps1'] = ps1
  let used_functions['__promptline_left_prompt'] = left_prompt
  let used_functions['__promptline_right_prompt'] = right_prompt
  call extend(a:prompt.functions, used_functions)

  let a:prompt.sections = len(ps1) ? [ '$(__promptline_ps1)' ] : []
  let a:prompt.left_sections = len(left_prompt) ? [ '$(__promptline_left_prompt)' ] : []
  let a:prompt.right_sections = len(right_prompt) ? [ '$(__promptline_right_prompt)' ] : []
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
      \'elif [[ -n ${FISH_VERSION-} ]]; then',
      \'  __promptline "$1"',
      \'else',
      \'  if [[ ! "$PROMPT_COMMAND" == *__promptline* ]]; then',
      \"    PROMPT_COMMAND='__promptline;'$'\\n'\"$PROMPT_COMMAND\"",
      \'  fi',
      \'fi']
endfun

