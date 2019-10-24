function __promptline_kubernetes {
  if [ -x "$(command -v kubectl)" ]; then
    printf "⎈ %s" "$(kubectl config current-context)"
  fi
}
