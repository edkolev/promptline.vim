
" TODO should /proc/acpi/battery/BAT0 be checked for linux battery?
" http://www.basicallytech.com/blog/index.php?/archives/110-Colour-coded-battery-charge-level-and-status-in-your-bash-prompt.html
fun! promptline#slices#battery#function_body()
  return [
        \'function __promptline_battery {',
        \'  local percent_sign',
        \'  [[ -n ${ZSH_VERSION-} ]] && percent_sign="%%" || percent_sign="%"',
        \'',
        \'  # osx',
        \'  if hash ioreg 2>/dev/null; then',
        \'    local ioreg_output',
        \'    if ioreg_output=$(ioreg -rc AppleSmartBattery 2>/dev/null); then',
        \'      local battery_capacity=${ioreg_output#*MaxCapacity\"\ \=}',
        \'      battery_capacity=${battery_capacity%%\ \"*}',
        \'',
        \'      local current_capacity=${ioreg_output#*CurrentCapacity\"\ \=}',
        \'      current_capacity=${current_capacity%%\ \"*}',
        \'      current_capacity=$(($current_capacity * 100))',
        \'',
        \'      printf "%s" "${1}$(($current_capacity / $battery_capacity))${percent_sign}${2}"',
        \'      return',
        \'    fi',
        \'  fi',
        \'',
        \'',
        \'  # linux',
        \'  for possible_battery_dir in /sys/class/power_supply/BAT*; do',
        \'    if [[ -d $possible_battery_dir && -f "$possible_battery_dir/energy_full" && -f "$possible_battery_dir/energy_now" ]]; then',
        \'      current_capacity=$( <"$possible_battery_dir/energy_now" )',
        \'      battery_capacity=$( <"$possible_battery_dir/energy_full" )',
        \'      current_capacity=$(($current_capacity * 100))',
        \'      printf "%s" "${1}$(($current_capacity / $battery_capacity))${percent_sign}${2}"',
        \'    fi',
        \'  done',
        \'}']
endfun
