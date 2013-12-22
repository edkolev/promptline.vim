" The MIT License (MIT)
"
" Copyright (c) 2013 Evgeni Kolev

fun! promptline#presets#load_preset(preset) abort
  if type(a:preset) == type("")
    return promptline#presets#load_stock_preset(a:preset)
  elseif type(a:preset) == type({})
    return deepcopy(a:preset)
  endif

  throw "promptline: invalid preset type of g:promptline_preset"
endfun

fun! promptline#presets#load_stock_preset(preset_name) abort
  try
    let line = promptline#presets#{a:preset_name}#get()
  catch /^Vim(let):E117: Unknown function: promptline#presets#.*#get/
    throw "promptline: Preset cannot be found '" . a:preset_name . "'"
  endtry
  return line
endfun

