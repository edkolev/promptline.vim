" The MIT License (MIT)
"
" Copyright (c) 2013-2019 Evgeni Kolev

let s:DEFAULT_LEFT_ONLY_SECTIONS = [ 'a', 'b', 'c', 'x', 'y', 'z', 'warn' ]
let s:DEFAULT_LEFT_SECTIONS      = [ 'a', 'b', 'c' ]
let s:DEFAULT_RIGHT_SECTIONS     = [ 'warn', 'x', 'y', 'z' ]

fun! promptline#presets#load_preset(preset) abort
  if type(a:preset) == type("")
    let preset = promptline#presets#load_stock_preset(a:preset)
  elseif type(a:preset) == type({})
    let preset = deepcopy(a:preset)
  else
    throw "promptline: invalid preset type of g:promptline_preset"
  endif

  let preset.options = extend(get(preset, 'options', {}), {
        \'left_sections': filter(copy(s:DEFAULT_LEFT_SECTIONS), 'has_key(preset, v:val)'),
        \'right_sections': filter(copy(s:DEFAULT_RIGHT_SECTIONS), 'has_key(preset, v:val)'),
        \'left_only_sections': filter(copy(s:DEFAULT_LEFT_ONLY_SECTIONS), 'has_key(preset, v:val)')}, 'keep')

  return preset
endfun

fun! promptline#presets#load_stock_preset(preset_name) abort
  try
    let line = promptline#presets#{a:preset_name}#get()
  catch /^Vim(let):E117: Unknown function: promptline#presets#.*#get/
    throw "promptline: Preset cannot be found '" . a:preset_name . "'"
  endtry
  return line
endfun

