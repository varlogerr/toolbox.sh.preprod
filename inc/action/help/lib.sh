print_help() {
  _print "
    USAGE
    =====
    \`\`\`sh
    # generate conffile to stdout
    ${KEEPER[tool]} --genconf
   !
    # preprod relese.
    # RELEASE_TYPE - one of:
    $(sed 's/^/# * /' <<< "${RELEASE_TYPES_LIST}")
    # CONFFILE - path to preprod conffile.
    #   optional, defaults to \$(pwd)/$(basename -- "${DEFAULTS[conffile]}")
    ${KEEPER[tool]} RELEASE_TYPE [CONFFILE]
    \`\`\`
  "
}

_print() {
  local lines="${1}"
  local line_symbol="${2:-!}"

  while read -r line; do
    [[ -z "${line}" ]] && continue

    [[ "${line:0:1}" == "${line_symbol}" ]] \
      && line="${line:1}"

    printf -- '%s\n' "${line}"
  done <<< "${lines}"
}
