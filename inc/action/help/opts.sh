__opts_detect() {
  unset __opts_detect

  while :; do
    [[ -z "${1+x}" ]] && break

    case "${1}" in
      * ) ERRBAG+=("Invalid argument: ${1}") ;;
    esac

    shift
  done
} && __opts_detect "${@}"
