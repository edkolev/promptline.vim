fun! promptline#themes#vim_statusline_1#get()
  let colors = promptline#themes#get_theme_from_vim()
  return {
        \ 'a'    : colors.statusline,
        \ 'b'    : colors.reversed_statusline_nc,
        \ 'c'    : colors.statusline_nc,
        \ 'x'    : colors.statusline_nc,
        \ 'y'    : colors.reversed_statusline_nc,
        \ 'z'    : colors.statusline,
        \ 'warn' : colors.warning}
endfun
