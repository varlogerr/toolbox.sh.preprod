declare -A OPTS=(
  [action]=
)
declare -a NEW_ARGS=()

__opts_detect() {
  unset __opts_detect

  local endopt=0
  local arg_clone

  while :; do
    [[ -z "${1+x}" ]] && break
    arg_clone="${1}"

    # when action is found or endopt we just want to
    # pass the rest to the new args stack
    [[ (-n "${OPTS[action]}" || ${endopt} -gt 0) ]] && arg_clone='*'

    case "${arg_clone}" in
      --genconf     ) OPTS[action]=genconf ;;
      -v|--version  ) OPTS[action]=version ;;
      -h|-\?|--help ) OPTS[action]=help ;;
      *             ) NEW_ARGS+=("${1}")
    esac

    shift
  done

  OPTS[action]="${OPTS[action]:-${DEFAULTS[action]}}"
} && __opts_detect "${@}"

# return survivors to the args
set -- "${NEW_ARGS[@]}"
unset NEW_ARGS
