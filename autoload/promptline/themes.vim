" The MIT License (MIT)
"
" Copyright (c) 2013 Evgeni Kolev

fun! promptline#themes#load_theme(theme) abort
  if type(a:theme) == type("")
    return promptline#themes#load_stock_theme(a:theme)
  elseif type(a:theme) == type({})
    return deepcopy(a:theme)
  endif

  throw "promptline: invalid theme type of g:promptline_theme"
endfun

fun! promptline#themes#load_airline_theme(...)
  let mode = get(a:, 1, 'normal')

  if !has_key(g:, 'airline_theme') || !has_key(g:, 'airline#themes#' . g:airline_theme . '#palette')
    throw "promptline: Can't load theme from airline. Is airline loaded?"
  endif

  let mode_palette = g:airline#themes#{g:airline_theme}#palette[mode]
  return {
        \'a'    : mode_palette.airline_a[2:4],
        \'b'    : mode_palette.airline_b[2:4],
        \'c'    : mode_palette.airline_c[2:4],
        \'x'    : mode_palette.airline_x[2:4],
        \'y'    : mode_palette.airline_y[2:4],
        \'z'    : mode_palette.airline_z[2:4],
        \'warn' : mode_palette.airline_warning[2:4]}
endfun

fun! promptline#themes#load_stock_theme(theme_name) abort
  try
    let theme = promptline#themes#{a:theme_name}#get()
  catch /^Vim(let):E117: Unknown function: promptline#themes#.*#get/
    throw "promptline: Theme cannot be found '" . a:theme_name . "'"
  endtry
  return theme
endfun

