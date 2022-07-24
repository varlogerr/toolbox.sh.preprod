#!/bin/bash

# Function reading from stdin
# https://unix.stackexchange.com/questions/154485/how-do-i-capture-stdin-to-a-variable-without-stripping-any-trailing-newlines

# left trim all lines in the text. usage:
# ```
# txt_ltrim FILE
# txt_ltrim <<< "  words"
# ```
txt_ltrim() {
  local txt="${1}"
  [[ -z "${1+x}" ]] && {
    txt="$(cat; echo x)"
    txt="${txt%$'\n'x}"
  } || { txt="$(cat -- "${txt}")"; }
  sed -E 's/^\s+//' <<< "${txt}"
}

# right trim all lines in the text. usage:
# ```
# txt_rtrim FILE
# txt_rtrim <<< "words  "
# ```
txt_rtrim() {
  local txt="${1}"
  [[ -z "${1+x}" ]] && {
    txt="$(cat; echo x)"
    txt="${txt%$'\n'x}"
  } || { txt="$(cat -- "${txt}")"; }
  sed -E 's/\s+$//' <<< "${txt}"
}

# trim all lines in the text. usage:
# ```
# txt_trim FILE
# txt_trim <<< "  words  "
# ```
txt_trim() {
  local txt="${1}"
  [[ -z "${1+x}" ]] && {
    txt="$(cat; echo x)"
    txt="${txt%$'\n'x}"
  } || { txt="$(cat -- "${txt}")"; }
  sed -E -e 's/^\s+//' -e 's/\s+$//' <<< "${txt}"
}

# rm blank and spaces only lines in the text. usage:
# ```
# txt_rmblank FILE
# txt_rmblank <<< "line1"$'\n'$'\n'"line3"
# ```
txt_rmblank() {
  local txt="${1}"
  [[ -z "${1+x}" ]] && {
    txt="$(cat; echo x)"
    txt="${txt%$'\n'x}"
  } || { txt="$(cat -- "${txt}")"; }
  grep -v -E '^\s*$' <<< "${txt}"
}

# rm comment lines from the text. usage:
# ```
# txt_rmcomment FILE
# txt_rmcomment <<< "  line1"$'\n'"# comment"
# ```
txt_rmcomment() {
  local txt="${1}"
  [[ -z "${1+x}" ]] && {
    txt="$(cat; echo x)"
    txt="${txt%$'\n'x}"
  } || { txt="$(cat -- "${txt}")"; }
  grep -v -E '^\s*#.*$' <<< "${txt}"
}
