# shellcheck shell=bash
# about-alias 'RipGrep aliases for convenience.'

# set apt aliases
function _set_pkg_aliases() {
	if _command_exists rg; then
		# hilight seraches 
		alias hl='rg --passthru'
	fi
}

_set_pkg_aliases
