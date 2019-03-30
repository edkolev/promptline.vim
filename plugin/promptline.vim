" The MIT License (MIT)
"
" Copyright (c) 2013-2019 Evgeni Kolev

fun! s:complete_snapshot_files(A,L,P)
  let files = split(glob(a:A . '*', 1), "\n")

  if len(files) == 1 && isdirectory(files[0]) > 0
    let files[0] .= '/'
  endif

  if a:A[0] ==# '~'
    let files = map(files, 'fnamemodify(v:val, ":~")')
  endif

  return files
endfun

fun! s:complete_themes(A,L,P)
  let files = split(globpath(&rtp, 'autoload/promptline/themes/' . a:A . '*'), "\n")
  return map(files, 'fnamemodify(v:val, ":t:r")')
endfun

fun! s:complete_presets(A,L,P)
  let files = split(globpath(&rtp, 'autoload/promptline/presets/' . a:A . '*'), "\n")
  return map(files, 'fnamemodify(v:val, ":t:r")')
endfun

function! s:command_completion(A,L,P)
  let pre   = a:L[0 : a:P-1]

  let snapshot = matchstr(pre, '\S*\s\+\zs\(\S\+\)\ze\s')
  if snapshot ==# ''
    return s:complete_snapshot_files(a:A, a:L, a:P)
  endif

  let theme = matchstr(pre, '\S*\s\+\S\+\s\+\zs\(\S\+\)\ze\s')
  if theme ==# ''
    return s:complete_themes(a:A, a:L, a:P)
  endif

  let preset = matchstr(pre, '\S*\s\+\S\+\s\+\S\+\s\+\zs\(\S\+\)\ze\s')
  if preset ==# ''
    return s:complete_presets(a:A, a:L, a:P)
  endif

  return []
endfun

command! -nargs=+ -bang -complete=customlist,<sid>command_completion PromptlineSnapshot call promptline#snapshot(strlen("<bang>"), <f-args>)

