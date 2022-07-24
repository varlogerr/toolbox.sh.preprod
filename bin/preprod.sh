#!/usr/bin/env bash

declare RETVAL
declare -a ERRBAG=()
declare -A DEFAULTS=(
  [action]='preprod'
  [curver]='v0.0.0'
  [conffile]="$(pwd)/.preprod.conf"
)

declare -A KEEPER=(
  [tool]="$(basename "${BASH_SOURCE[0]}")"
  [bindir]="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
)
KEEPER[tooldir]="$(realpath "${KEEPER[bindir]}/..")"
KEEPER[incdir]="${KEEPER[tooldir]}/inc"

declare -A RELEASE_TYPE_MAP=(
  [patch]=3
  [minor]=2
  [major]=1
)
RELEASE_TYPES_LIST="$(
  tr ' ' '\n' <<< "${!RELEASE_TYPE_MAP[@]}" \
  | sort -n
)"

. "${KEEPER[tooldir]}/vendor/.lib/lib/lib/txt.sh"

. "${KEEPER[incdir]}/opts.sh"
. "${KEEPER[incdir]}/run.sh"
