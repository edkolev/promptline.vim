
" TODO should /proc/acpi/battery/BAT0 be checked for linux battery?
" http://www.basicallytech.com/blog/index.php?/archives/110-Colour-coded-battery-charge-level-and-status-in-your-bash-prompt.html
fun! promptline#slices#battery#function_body(options)
  let battery_symbol = promptline#symbols#get().battery
  let threshold = get(a:options, 'threshold', 10)

  return [
        \'function __promptline_battery {',
        \'  local percent_sign="%"',
        \'  local battery_symbol="' . battery_symbol . '"',
        \'  local threshold="' . threshold . '"',
        \'',
        \'  # escape percent "%" in zsh',
        \'  [[ -n ${ZSH_VERSION-} ]] && percent_sign="${percent_sign//\%/%%}"',
        \'',
        \'  # osx',
        \'  if hash ioreg 2>/dev/null; then',
        \'    local ioreg_output=$(ioreg -rc AppleSmartBattery 2>/dev/null)',
        \'    # ioreg_output will have a value on mac laptops but will be empty on mac desktops',
        \'    if [ -n "${ioreg_output}" ]; then',
        \'      local battery_capacity=${ioreg_output#*MaxCapacity\"\ \=}',
        \'      battery_capacity=${battery_capacity%%\ \"*}',
        \'',
        \'      local current_capacity=${ioreg_output#*CurrentCapacity\"\ \=}',
        \'      current_capacity=${current_capacity%%\ \"*}',
        \'',
        \'      local battery_level=$(($current_capacity * 100 / $battery_capacity))',
        \'      [[ $battery_level -gt $threshold ]] && return 1',
        \'',
        \'      printf "%s" "${battery_symbol}${battery_level}${percent_sign}"',
        \'      return',
        \'    fi',
        \'  fi',
        \'',
        \'  # linux',
        \'  # check for directory existence otherwise attempting to iterate on powersupply/Bat* will fail on mac desktops',
        \'  if [ -d "/sys/class/power_supply" ]; then',
        \'    for possible_battery_dir in /sys/class/power_supply/BAT*; do',
        \'      if [[ -d $possible_battery_dir && -f "$possible_battery_dir/energy_full" && -f "$possible_battery_dir/energy_now" ]]; then',
        \'        current_capacity=$( <"$possible_battery_dir/energy_now" )',
        \'        battery_capacity=$( <"$possible_battery_dir/energy_full" )',
        \'        local battery_level=$(($current_capacity * 100 / $battery_capacity))',
        \'        [[ $battery_level -gt $threshold ]] && return 1',
        \'',
        \'        printf "%s" "${battery_symbol}${battery_level}${percent_sign}"',
        \'        return',
        \'      fi',
        \'    done',
        \'  fi',
        \'',
        \'return 1',
        \'}']
endfun
