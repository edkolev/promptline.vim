fun! promptline#themes#vim_statusline_2#get()
  let colors = promptline#themes#get_theme_from_vim()
  return {
        \ 'a'    : colors.statusline_nc,
        \ 'b'    : colors.statusline,
        \ 'c'    : colors.reversed_statusline,
        \ 'x'    : colors.reversed_statusline,
        \ 'y'    : colors.statusline,
        \ 'z'    : colors.statusline_nc,
        \ 'warn' : colors.warning}
endfun
