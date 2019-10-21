function __promptline_kubernetes {
  if [ -x "$(command -v kubectl)" ]; then
    printf "\u2388 %s" "$(kubectl config current-context)"
  fi
}
