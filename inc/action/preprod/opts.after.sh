__check_release_type() {
  unset __check_release_type

  [[ -n "${OPTS[release_type]}" ]] || {
    ERRBAG+=("RELEASE_TYPE is required")
    return
  }

  grep -qFx "${RELEASE_TYPES_LIST}" <<< "${OPTS[release_type]}" || {
    ERRBAG+=("Invalid RELEASE_TYPE value")
    return
  }
} && __check_release_type

__check_conffile() {
  unset __check_conffile

  [[ -f "${OPTS[conffile]}" ]] || {
    ERRBAG+=("CONFFILE must be a file: ${OPTS[conffile]}")
    return
  }

  OPTS[conffile]="$(realpath -- "${OPTS[conffile]}")"
} && __check_conffile
