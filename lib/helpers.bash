
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
