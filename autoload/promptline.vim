" The MIT License (MIT)
"
" Copyright (c) 2013 Evgeni Kolev

let s:FG = 0
let s:BG = 1
let s:SHELL_FG = 38
let s:SHELL_BG = 48
let s:DEFAULT_SECTION_ORDER = [ 'a', 'b', 'c', 'warn' ]

let s:default_theme = 'powerlineclone'
let s:default_preset = 'powerlineclone'

let s:powerline_symbols = {
    \ 'left'       : '',
    \ 'left_alt'   : '',
    \ 'dir_sep'    : '  ',
    \ 'truncation' : '⋯',
    \ 'vcs_branch' : ' ',
    \ 'space'      : ' '}

let s:simple_symbols = {
    \ 'left'       : '',
    \ 'left_alt'   : '|',
    \ 'dir_sep'    : ' / ',
    \ 'truncation' : '...',
    \ 'vcs_branch' : '',
    \ 'space'      : ' '}

let s:snapshot = []

fun! promptline#get_symbols()
  let use_powerline_symbols = get(g:, 'promptline_powerline_symbols', 1)
  let separators = use_powerline_symbols ? s:powerline_symbols : s:simple_symbols
  return extend(separators, get(g:, 'promptline_symbols', {}))
endfun

fun! promptline#bash_snapshot(overwrite, file, ...) abort
  let input_theme = get(a:, 1, get(g:, 'promptline_theme', s:default_theme))
  let input_preset = get(a:, 2, get(g:, 'promptline_preset', s:default_preset))

  try
    let file = s:validate_file(a:overwrite, a:file)
    let theme = promptline#themes#load_theme(input_theme)
    let preset = promptline#presets#load_preset(input_preset)
    call promptline#create_bash_snapthot(file, theme, preset)
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
  return printf('"\[\e[%d;5;%dm\]"', s:SHELL_BG, a:color)
endfun

fun! s:fg(color)
  return printf('"\[\e[%d;5;%dm\]"', s:SHELL_FG, a:color)
endfun

fun! promptline#create_bash_snapthot(file, theme, preset) abort
  let prompt = {
        \'functions': {},
        \'sections': []}

  let shell_colors = []
  let section_count = 0

  let ordered_sections = s:get_ordered_section_names(a:preset)

  for section_name in (ordered_sections)
    if !has_key(a:theme, section_name)
      echohl WarningMsg | echomsg "promptline: theme doesn't define colors for '". section_name . "' section. Skipping section" | echohl None
      continue
    endif

    let section_count += 1
    let [fg, bg] = a:theme[section_name][s:FG : s:BG]

    let shell_colors += [ '  local ' .section_name. '_fg=' . s:fg(fg) ]
    let shell_colors += [ '  local ' .section_name. '_bg=' . s:bg(bg) ]
    let shell_colors += [ '  local ' .section_name. '_sep_fg=' . s:fg(bg) ]

    let section_slices = a:preset[section_name]
    call s:append_section( prompt, section_name, section_slices, section_count )
  endfor

  call s:append_closing_section( prompt )

  let symbols = promptline#get_symbols()
  let snapshot_lines = []
  for function_body in values(prompt.functions)
    let snapshot_lines += function_body
  endfor
  let snapshot_lines += [
        \'',
        \'function __promptline {',
        \'  local last_exit_code="$?"',
        \'  local space=" "',
        \'  local bold="\[\e[1m\]"',
        \'  local faint="\[\e[2m\]"',
        \'  local unbold="\[\e[22m\]"',
        \'  local reset="\[\e[0m\]"',
        \'  local reset_bg="\[\e[49m\]"',
        \'  local sep="' . symbols.left . '"',
        \'  local alt_sep="' . symbols.left_alt . '"',
        \'  local dir_sep="' . symbols.dir_sep . '"',
        \'  local vcs_branch="' . symbols.vcs_branch . '"',
        \'  local truncation="' . symbols.truncation . '"',
        \'']

  let snapshot_lines += shell_colors
  let snapshot_lines += [ '  PS1="' . join(prompt.sections, '') . '"' ]
  let snapshot_lines += [ '}' ]
  let snapshot_lines += [ 'PROMPT_COMMAND=__promptline' ]

  if writefile(snapshot_lines, a:file) != 0
    throw "promptline: Failed writing file " . a:file
  endif
endfun

fun! s:get_ordered_section_names(preset)
  let order = get(a:preset, 'order', s:DEFAULT_SECTION_ORDER)

  return filter(copy(order), 'has_key(a:preset, v:val)')
endfun

fun! s:append_section( prompt, section_name, section_slices, section_order ) abort
  if len(a:section_slices) == 1
    let slice = a:section_slices[0]
    if type(slice) == type({}) && get(slice, 'can_be_empty')
      return s:append_possibly_empty_section( a:prompt, a:section_name, a:section_slices, a:section_order )
    endif
  endif
  return s:append_simple_section( a:prompt, a:section_name, a:section_slices, a:section_order )
endfun

fun! s:append_possibly_empty_section( prompt, section_name, section_slices, section_order ) abort
  let slice = a:section_slices[0]

  let leading_separator = a:section_order > 1 ? '${'. a:section_name .'_bg}${sep}' : ''

  let section_prefix =
        \ '"' .
        \ leading_separator .
        \ '${'. a:section_name .'_fg}' .
        \ '${'. a:section_name .'_bg}' .
        \ '${space}' .
        \ '"'
  let section_suffix = '"$space${' . a:section_name . '_sep_fg}"'

  let possibly_empty_section = '$(' . slice.function_name . ' ' . section_prefix . ' ' . section_suffix . ')'
  let a:prompt.functions[slice.function_name] = slice.function_body
  let a:prompt.sections += [ possibly_empty_section ]
endfun

fun! s:append_simple_section( prompt, section_name, section_slices, section_order ) abort
  let section_content = ''

  let leading_separator = a:section_order > 1 ? '${'. a:section_name .'_bg}${sep}' : ''

  let section_colors =
        \ leading_separator .
        \ '${'. a:section_name .'_fg}' .
        \ '${'. a:section_name .'_bg}' .
        \ '${space}'
  let section_suffix = '$space${' . a:section_name . '_sep_fg}'

  let processed_section_slices = []
  for slice in (a:section_slices)
    if type(slice) == type("")
      let processed_section_slices += [ slice ]
    elseif type(slice) == type({})
      let processed_section_slices += [ '$(' . slice.function_name . ')' ]
      let a:prompt.functions[slice.function_name] = slice.function_body
    endif
    unlet slice
  endfor

  let section_content = join( processed_section_slices, '${space}${alt_sep}${space}' )

  let a:prompt.sections += [ section_colors . section_content . section_suffix ]
endfun

fun! s:append_closing_section( prompt ) abort
  let closing_section =
        \ '${reset_bg}' .
        \ '${sep}' .
        \ '$reset' .
        \ '$space'

  let a:prompt.sections += [ closing_section ]
endfun

fun! s:process_slice(slice)

endfun

