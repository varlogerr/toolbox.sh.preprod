log_stage() {
  local msg="${1}"
  printf -- '[%s] >>> %s ...\n' \
    "${KEEPER[tool]}" "${msg}"
}

log_info() {
  local msg="${1}"
  printf -- '[%s] >>> %s\n' \
    "${KEEPER[tool]}" "${msg}"
}

conffile_strip() {
  local conffile="${1}"
  sed -E -e 's/^\s+//' -e 's/\s+$//' "${conffile}" \
  | grep -E -v -e '^$' -e '^#' | sed 's/\s*=\s*/=/'
}
