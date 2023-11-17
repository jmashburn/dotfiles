
function _command_exists() {
	# _about 'checks for existence of a command'
	# _param '1: command to check'
	# _param '2: (optional) log message to include when command not found'
	# _example '$ _command_exists ls && echo exists'
	# _group 'lib'
	local msg="${2:-Command '$1' does not exist}"
	if type -t "$1" > /dev/null; then
		return 0
	else
		return 1
	fi
}

function _is_function() {
	# _about 'sets $? to true if parameter is the name of a function'
	# _param '1: name of alleged function'
	# _param '2: (optional) log message to include when function not found'
	# _group 'lib'
	# _example '$ _is_function ls && echo exists'
	# _group 'lib'
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

# Runs `grep` with fixed-string expressions (-F)
function _fgrep() {
	: "${BASH_IT_GREP:=$(type -P grep)}"
	"${BASH_IT_GREP:-/usr/bin/grep}" -F "$@"
}