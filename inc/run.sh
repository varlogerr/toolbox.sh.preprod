KEEPER[actdir]="${KEEPER[incdir]}/action/${OPTS[action]}"

# source action hooks
while read -r f; do
  [[ -z "${f}" ]] && continue
  [[ -f "${KEEPER[actdir]}/${f}.sh" ]] && . "${KEEPER[actdir]}/${f}.sh"
done <<< "
  init
  lib
  opts
  opts.after
  run.before
"

[[ ${#ERRBAG[@]} -lt 1 ]] || {
  echo
  for e in "${ERRBAG[@]}"; do
    printf -- '%s\n' "${e}"
  done

  echo
  echo "Issue \`${KEEPER[tool]} -h\` for help"
  exit 1
}

. "${KEEPER[actdir]}/run.sh"

[[ ${#ERRBAG[@]} -lt 1 ]] || {
  echo
  for e in "${ERRBAG[@]}"; do
    printf -- '%s\n' "${e}"
  done
}
