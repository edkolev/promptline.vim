fun! promptline#slices#host#function_body( options )
  let only_if_ssh = get(a:options, 'only_if_ssh', 0)
  let only_if_ssh_bool = only_if_ssh ? 'true' : 'false'
  let lines = [
        \'function __promptline_host {',
        \'  local only_if_ssh=' . only_if_ssh_bool,
        \'',
        \'  if [ "$only_if_ssh" = false -o -n "${SSH_CLIENT}" ]; then',
        \'    if [[ -n ${ZSH_VERSION-} ]]; then print %m; elif [[ -n ${FISH_VERSION-} ]]; then hostname -s; else printf "%s" \\h; fi',
        \'  fi',
        \'}']
	return lines
endfun
