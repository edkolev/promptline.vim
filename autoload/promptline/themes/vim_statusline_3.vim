fun! promptline#themes#vim_statusline_3#get()
  let colors = promptline#themes#get_theme_from_vim()
  return {
        \ 'a'    : colors.reversed_statusline_nc,
        \ 'b'    : colors.statusline_nc,
        \ 'c'    : colors.reversed_statusline,
        \ 'x'    : colors.reversed_statusline,
        \ 'y'    : colors.statusline_nc,
        \ 'z'    : colors.reversed_statusline_nc,
        \ 'warn' : colors.warning}
endfun
