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
  txt_trim "${conffile}" | txt_rmblank \
  | txt_rmcomment | sed 's/\s*=\s*/=/'
}
