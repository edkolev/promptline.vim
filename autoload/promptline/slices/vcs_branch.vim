fun! promptline#slices#vcs_branch#function_body(options)
  let branch_symbol = promptline#symbols#get().vcs_branch
  let git = get(a:options, 'git', 1)
  let svn = get(a:options, 'svn', 0)
  let hg = get(a:options, 'hg', 0)
  let fossil = get(a:options, 'fossil', 0)

  let lines = [
        \'function __promptline_vcs_branch {',
        \'  local branch',
        \'  local branch_symbol="' . branch_symbol . '"']

  if git
    let lines += [
        \'',
        \'  # git',
        \'  if hash git 2>/dev/null; then',
        \'    if branch=$( { git symbolic-ref --quiet --short HEAD || git describe --tags --exact-match || git rev-parse --short HEAD; } 2>/dev/null ); then',
        \'      printf "%s" "${branch_symbol}${branch:-unknown}"',
        \'      return',
        \'    fi',
        \'  fi']
  endif

  if hg
    let lines += [
        \'',
        \'  # mercurial',
        \'  if hash hg 2>/dev/null; then',
        \'    if branch=$(hg branch 2>/dev/null); then',
        \'      printf "%s" "${branch_symbol}${branch:-unknown}"',
        \'      return',
        \'    fi',
        \'  fi']
  endif

  if svn
    let lines += [
        \'',
        \'  # svn',
        \'  if hash svn 2>/dev/null; then',
        \'    local svn_info',
        \'    if svn_info=$(svn info 2>/dev/null); then',
        \'      local svn_url=${svn_info#*URL:\ }',
        \'      svn_url=${svn_url/$' . "'" . '\n' . "'" . '*/}',
        \'',
        \'      local svn_root=${svn_info#*Repository\ Root:\ }',
        \'      svn_root=${svn_root/$' . "'" . '\n' . "'" . '*/}',
        \'',
        \'      if [[ -n $svn_url ]] && [[ -n $svn_root ]]; then',
        \'        # https://github.com/tejr/dotfiles/blob/master/bash/bashrc.d/prompt.bash#L179',
        \'        branch=${svn_url/$svn_root}',
        \'        branch=${branch#/}',
        \'        branch=${branch#branches/}',
        \'        branch=${branch%%/*}',
        \'',
        \'        printf "%s" "${branch_symbol}${branch:-unknown}"',
        \'        return',
        \'      fi',
        \'    fi',
        \'  fi',
        \'']
  endif

  if fossil
    let lines += [
        \'',
        \'  # fossil',
        \'  if hash fossil 2>/dev/null; then',
        \'    if branch=$( fossil branch 2>/dev/null ); then',
        \'      branch=${branch##* }',
        \'      printf "%s" "${branch_symbol}${branch:-unknown}"',
        \'      return',
        \'    fi',
        \'  fi']
  endif

  let lines += [
        \'  return 1',
        \'}']
  return lines
endfun

