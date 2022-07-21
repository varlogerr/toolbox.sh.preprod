declare rc

(
  if [[ -n "${OPTS[before_version_cmd]}" ]]; then
    eval "${OPTS[before_version_cmd]}"
  fi
)
rc=$?
[[ $rc -lt 1 ]] \
  || ERRBAG+=("(${rc}) Error running before_version_cmd")

__update_version_file() {
  unset __update_version_file

  [[ -n "${OPTS[version_file]}" ]] || return

  log_stage "Updating version file (${OPTS[newver]})"

  declare rc=0

  printf -- '%s\n' "${OPTS[newver]}" > "${OPTS[version_file]}"
  rc=$?
  [[ ${rc} -gt 0 ]] \
    && ERRBAG+=("(${rc}) Error saving version file")
} && __update_version_file

cd "${OPTS[repo_dir]}"
__commit_and_tag() {
  unset __commit_and_tag
  log_stage "Commiting and tagging (${OPTS[newver]})"

  declare rc=0

  git add .
  git commit --allow-empty -m "Release ${OPTS[newver]} ..."$'\n'$'\n'"${OPTS[msg]}" > /dev/null
  rc=$?
  [[ $rc -gt 0 ]] && {
    ERRBAG+=("(${rc}) Error creating commit")
    return
  }

  git tag -a "${OPTS[newver]}" -m "Version: ${OPTS[newver]#v}"$'\n'$'\n'"${OPTS[msg]}" > /dev/null
  rc=$?
  [[ $rc -gt 0 ]] && {
    ERRBAG+=("(${rc}) Error tagging")
    return
  }
} && __commit_and_tag
cd "${OPTS[conffile_dir]}"

(
  if [[ -n "${OPTS[before_tag_cmd]}" ]]; then
    eval "${OPTS[before_tag_cmd]}"
  fi
)
rc=$?
[[ $rc -lt 1 ]] \
  || ERRBAG+=("(${rc}) Error running before_tag_cmd")

[[ ${#ERRBAG[@]} -lt 1 ]] \
&& __print_postmsg() {
  unset __print_postmsg

  # https://stackoverflow.com/a/21127037 for retagging
  while read -r l; do
    [[ -n "${l}" ]] && printf -- '%s\n' "${l}"
  done <<< "
    ######################
    ##### POST STEPS #####
    ######################
    Run the following commands to complete the release:
    \`\`\`sh
    # check the release commit and tag
    git show ${OPTS[newver]}
    # change commit and tag message if required
    git commit --amend --allow-empty
    git tag -f -a ${OPTS[newver]}
    # push changes
    git push
    # push the tag
    git push origin ${OPTS[newver]}
    \`\`\`
  "
} && __print_postmsg
