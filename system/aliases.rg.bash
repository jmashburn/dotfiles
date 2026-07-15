# shellcheck shell=bash
# about-alias 'RipGrep aliases for convenience.'

if _command_exists rg; then
	alias hl='rg --passthru'
fi
