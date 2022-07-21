__iife() {
  unset __iife

  local curdir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
  PATH="${curdir}/bin:${PATH}"
  ENVAR_NAME=preprod

  export TESTDIR="${curdir}/tests"
} && __iife
