function _is_sudo {
    if [[ $(id -u) -ne 0 ]]; then
        _die "This script must be run as root!"
    fi
}

function _echo_info {
    echo -e "${echo_green}$@${reset}"
}

function _echo_important {
    echo -e "${echo_yellow}$@${reset}"
}

function _echo_warn {
    echo -e "${echo_red}$@${reset}"
}

function _die {
    echo >&2 -e "${echo_red}$@${reset}"
    exit 1
}

function _is_command_is_available {
    local cmd=${1}
    type ${cmd} >/dev/null 2>&1 || _die "Canceling because required command '${cmd}' is not available."
}

function _is_file_exists {
    local  file=${1}
    if [[ ! -f "${file}" ]]; then
        _die "Canceling because required file '${file}' does not exists."
    fi
}

function _is_file_does_not_exist {
    local file=${1}
    if [[ -e "${file}" ]]; then
        _die "Cancelling because file '${file}' exists."
    fi
}

function _ask_to_continue {
  local msg=${1}
  local waitingforanswer=true
  while ${waitingforanswer}; do
    read -p "${msg} (hit 'y/Y' to continue, 'n/N' to cancel) " -n 1 ynanswer
    case ${ynanswer} in
      [Yy] ) waitingforanswer=false; break;;
      [Nn] ) echo ""; _die "Operation cancelled as requested!";;
      *    ) echo ""; echo "Please answer either yes (y/Y) or no (n/N).";;
    esac
  done
  echo ""
}

function _ask_for_password {
  local VARIABLE_NAME=${1}
  local MESSAGE=${2}

  echo -n "${MESSAGE}: "
  stty -echo
  local CHARCOUNT=0
  local PROMPT=''
  local CHAR=''
  local PASSWORD=''
  while IFS= read -p "${PROMPT}" -r -s -n 1 CHAR
  do
    # Enter -> accept password
    if [[ ${CHAR} == $'\0' ]] ; then
      break
    fi
    # Backspace -> delete last char
    if [[ ${CHAR} == $'\177' ]] ; then
      if [ ${CHARCOUNT} -gt 0 ] ; then
        CHARCOUNT=$((CHARCOUNT-1))
        PROMPT=$'\b \b'
        PASSWORD="${PASSWORD%?}"
      else
        PROMPT=''
      fi
    # All other cases -> read last char
    else
      CHARCOUNT=$((CHARCOUNT+1))
      PROMPT='*'
      PASSWORD+="${CHAR}"
    fi
  done
  stty echo
  readonly ${VARIABLE_NAME}=${PASSWORD}
  echo
}
# Print to the Screen
#

function _ask_for_password_twice {
  local VARIABLE_NAME=${1}
  local MESSAGE=${2}
  local VARIABLE_NAME_1="${VARIABLE_NAME}_1"
  local VARIABLE_NAME_2="${VARIABLE_NAME}_2"

  _ask_for_password "${VARIABLE_NAME_1}" "${MESSAGE}"
  _ask_for_password "${VARIABLE_NAME_2}" "${MESSAGE} (again)"

  if [ "${!VARIABLE_NAME_1}" != "${!VARIABLE_NAME_2}" ] ; then
    _die "Error: password mismatch"
  fi

  readonly ${VARIABLE_NAME}="${!VARIABLE_NAME_2}"
}


function _replace_in_files {

  local search=${1}
  local replace=${2}
  local files=${@:3}

  for file in ${files[@]}; do
    if [[ -e "${file}" ]]; then
      if ( grep --fixed-strings --quiet "${search}" "${file}" ); then
        perl -pi -e "s/\Q${search}/${replace}/g" "${file}"
      else
        _echo_warn "Could not find search string '${search}' (thus, cannot replace with '${replace}') in file: ${file}"
      fi
    else
        _echo_warn "File '${file}' does not exist (thus, cannot replace '${search}' with '${replace}')."
    fi
  done

}


function _command_exists() {
	local msg="${2:-Command '$1' does not exist}"
	if type -t "$1" > /dev/null; then
		return 0
	else
		return 1
	fi
}

function _is_function() {
	local msg="${2:-Function '$1' does not exist}"
	if LC_ALL=C type -t "$1" | _fgrep -q 'function'; then
		return 0
	else
		return 1
	fi
}

function _find-in-ancestor() (
	local kin
	# To keep things simple, we do not search the root dir.
	while [[ "${PWD}" != '/' ]]; do
		for kin in "$@"; do
			if [[ -r "${PWD}/${kin}" ]]; then
				printf '%s' "${PWD}"
				return "$?"
			fi
		done
		command cd .. || return "$?"
	done
	return 1
)

function _get-component-name-from-path() {
	local filename
	# filename without path
	filename="${1##*/}"
	# filename without path or priority
	filename="${filename##*"${_LOAD_PRIORITY_SEPARATOR?}"}"
	# filename without path, priority or extension
	echo "${filename%.*.bash}"
}

function _get-component-type-from-path() {
	local filename
	# filename without path
	filename="${1##*/}"
	# filename without extension
	filename="${filename%.bash}"
	# extension without priority or name
	filename="${filename##*.}"
	echo "${filename}"
}

# This function searches an array for an exact match against the term passed
# as the first argument to the function. This function exits as soon as
# a match is found.
#
# Returns:
#   0 when a match is found, otherwise 1.
#
# Examples:
#   $ declare -a fruits=(apple orange pear mandarin)
#
#   $ _array-contains-element apple "@{fruits[@]}" && echo 'contains apple'
#   contains apple
#
#   $ if _array-contains-element pear "${fruits[@]}"; then
#       echo "contains pear!"
#     fi
#   contains pear!
#
#
function _array-contains-element() {
	local e element="${1?}"
	shift
	for e in "$@"; do
		[[ "$e" == "${element}" ]] && return 0
	done
	return 1
}

# Dedupe an array (without embedded newlines).
function _array-dedup() {
	printf '%s\n' "$@" | sort -u
}

# Runs `grep` with *just* the provided arguments
function _grep() {
	: "${_GREP:=$(type -P grep)}"
	"${_GREP:-/usr/bin/grep}" "$@"
}

# Runs `grep` with fixed-string expressions (-F)
function _fgrep() {
	: "${_GREP:=$(type -P grep)}"
	"${_GREP:-/usr/bin/grep}" -F "$@"
}

# Runs `grep` with extended regular expressions (-E)
function _egrep() {
	: "${_GREP:=$(type -P grep)}"
	"${_GREP:-/usr/bin/grep}" -E "$@"
}

function _pathmunge() {
    if ! echo $PATH | egrep "(^|:)$1($|:)" ; then
        if [ "$2" = "after" ] ; then
            PATH=$PATH:$1
        else
            PATH=$1:$PATH
        fi
    fi
}
