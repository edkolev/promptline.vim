fun! promptline#slices#host#function_body( options )
  let only_if_ssh = get(a:options, 'only_if_ssh', 0)
  let lines = [
        \'function __promptline_host {',
        \'  local only_if_ssh="' . only_if_ssh . '"',
        \'',
        \'  if [ $only_if_ssh -eq 0 -o -n "${SSH_CLIENT}" ]; then',
        \'    if [[ -n ${ZSH_VERSION-} ]]; then print %m; elif [[ -n ${FISH_VERSION-} ]]; then hostname -s; else printf "%s" \\h; fi',
        \'  fi',
        \'}']
	return lines
endfun
