" The MIT License (MIT)
"
" Copyright (c) 2019 Evgeni Kolev

fun! promptline#api#create_snapshot_with_theme(file, theme)
  return promptline#snapshot(1, a:file, a:theme)
endfun

fun! promptline#api#create_theme_from_airline(mode_palette)
  return promptline#themes#create_theme_from_airline(a:mode_palette)
endfun
