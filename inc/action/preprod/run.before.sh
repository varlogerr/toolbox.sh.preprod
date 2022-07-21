OPTS+=(
  [conffile_dir]=
  [repo_dir]=
  [main_branch]=
  [version_file]=
  [before_version_cmd]=
  [before_tag_cmd]=
  [curver]=
  [newver]=
  [msg]=
)

#
# Blocking validations
#

[[ "${#ERRBAG[@]}" -lt 1 ]] && {
  __detect_conffile_dir() {
    unset __detect_conffile_dir
    log_stage "Detecting CONFFILE directory"

    OPTS[conffile_dir]="$(dirname -- "${OPTS[conffile]}")"
  } && __detect_conffile_dir

  __detect_repo_dir() {
    unset __detect_repo_dir
    log_stage "Detecting repo base directory"

    cd "${OPTS[conffile_dir]}"

    OPTS[repo_dir]="$(git rev-parse --show-toplevel 2> /dev/null)"
    [[ -n "${OPTS[repo_dir]}" ]] \
      || ERRBAG+=("Not a git repo: ${OPTS[conffile_dir]}")

    cd - > /dev/null
  } && __detect_repo_dir
}

[[ "${#ERRBAG[@]}" -lt 1 ]] && {
  __detect_curver() {
    unset __detect_curver
    log_stage "Detecting current version"

    OPTS[curver]="$(git tag --list --sort=creatordate | tail -n 1)"
    OPTS[curver]="${OPTS[curver]:-${DEFAULTS[curver]}}"

    # validate
    local valid=1
    grep -qE '^v([0-9]+\.){2}[0-9]+$' <<< "${OPTS[curver]}" || valid=0

    local segment
    for i in {1..3}; do
      seg="$(cut -d'.' -f${i} <<< "${OPTS[curver]#v}")"
      [[ ("${seg}" == "0" || "${seg}" =~ ^[1-9][0-9]*$) ]] || valid=0
    done

    if [[ ${valid} -lt 1 ]]; then
      ERRBAG+=("Version format must be v{num}.{num}.{num}: ${OPTS[curver]}")
    else
      log_info "Current version is ${OPTS[curver]}"
    fi
  } && __detect_curver
}

#
# Non-blockin validations
#

[[ "${#ERRBAG[@]}" -lt 1 ]] && {
  # goto conffile directory and continue there
  cd "${OPTS[conffile_dir]}"

  declare VALID_CONFFILE_LINES

  __validate_conffile_format() {
    unset __validate_conffile_format
    log_stage "Validating CONFFILE format"

    local valid_lines_rexes="$(
      conffile_strip "${KEEPER[tooldir]}/tpl/preprod.conf" \
      | cut -d'=' -f1 | sed -e 's/^/^/' -e 's/$/=.*/'
    )"
    local conffile_content="$(
      conffile_strip "${OPTS[conffile]}"
    )"

    VALID_CONFFILE_LINES="$(grep -f <(echo "${valid_lines_rexes}") \
      <<< "${conffile_content}")"

    while read -r inval; do
      [[ -n "${inval}" ]] || continue
      ERRBAG+=("Invalid CONFFILE line: ${inval}")
    done <<< "$(
      grep -vFxf  <(printf -- '%s' "${VALID_CONFFILE_LINES}") \
        <<< "${conffile_content}"
    )"
  } && __validate_conffile_format

  __parse_conffile() {
    unset __parse_conffile
    log_stage "Parsing CONFFILE"

    declare -A multikeys=(
      [before_version_cmd]=
      [before_tag_cmd]=
    )
    local key

    while read -r l; do
      [[ -n "${l}" ]] || continue

      key="${l%%=*}"

      [[ -n "${multikeys[$key]+x}" ]] \
        && OPTS[$key]+="${OPTS[$key]:+$'\n'}"

      OPTS[$key]+="${l#*=}"
    done <<< "${VALID_CONFFILE_LINES}"

    OPTS[version_file]="${OPTS[version_file]:+$(
      realpath -m -- "${OPTS[conffile_dir]}/${OPTS[version_file]}"
    )}"
  } && __parse_conffile

  unset VALID_CONFFILE_LINES

  __validate_conffile_vals() {
    unset __validate_conffile_vals
    log_stage "Validating conffile values"

    local branches="$(git branch --list | sed 's/[\*| ]//g')"

    if [[ -z "${OPTS[main_branch]}" ]]; then
      ERRBAG+=("main_branch is required")
    elif ! grep -qFx "${OPTS[main_branch]}" <<< "${branches}"; then
      ERRBAG+=("main_branch is not a valid branch: ${OPTS[main_branch]}")
    fi

    [[ (-n "${OPTS[version_file]}" && ! -f "${OPTS[version_file]}") ]] && {
      ERRBAG+=("version_file must be a valid file: ${OPTS[version_file]}")
    }
  } && __validate_conffile_vals

  __detect_current_branch() {
    unset __detect_current_branch
    log_stage "Checking branch"

    local curbranch="$(git branch --show-current)"
    [[ "${curbranch}" != "${OPTS[main_branch]}" ]] && {
      ERRBAG+=("Required branch ${OPTS[main_branch]}, actual: ${curbranch}")
    }

    log_info "Current branch is ${curbranch}"
  } && __detect_current_branch

  __mk_newver() {
    unset __mk_newver
    log_stage "Incrementing version"

    local cur_semver="${OPTS[curver]#v}"
    local segment_no=${RELEASE_TYPE_MAP[${OPTS[release_type]}]}
    local segment="$(cut -d'.' -f${segment_no} <<< "${cur_semver}")"
    OPTS[newver]="v$(sed -E -e "s/[0-9]+/$(( segment + 1 ))/${segment_no}" \
      -e "s/[0-9]+/0/$(( segment_no + 1 ))g" <<< "${cur_semver}")"

    log_info "New version is ${OPTS[newver]}"
  } && __mk_newver

  __check_changes() {
    unset __check_changes
    log_stage "Checking for uncommited changes"

    [[ -z  "$(git status --porcelain)" ]] \
      || ERRBAG+=("Uncommited changes detected!")
  } && __check_changes

  __mk_release_msg() {
    unset __mk_release_msg

    local cmd="git log ${OPTS[main_branch]} --format=%s%n%b"
    local log

    [[ "${OPTS[curver]}" == "${DEFAULTS[curver]}" ]] && {
      log="$(${cmd})"
    } || {
      log="$(${cmd} "${OPTS[curver]}"..HEAD)"
    }

    local is_subj=1
    while read -r l; do
      [[ -n "${l}" ]] || {
        is_subj=1
        continue
      }

      [[ ${is_subj} -eq 1 ]] && {
        OPTS[msg]+="${OPTS[msg]:+$'\n'}* ${l}"
        is_subj=0
        continue
      }

      OPTS[msg]+="${OPTS[msg]:+$'\n'}  ${l}"
    done <<< "${log}"
  } && __mk_release_msg
}
