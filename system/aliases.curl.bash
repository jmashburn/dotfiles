# shellcheck shell=bash
# about-alias 'Curl aliases for convenience.'

if _command_exists curl; then
	alias cl='curl -L'
	alias clo='curl -L -O'
	alias cloc='curl -L -C - -O'
	alias clocr='curl -L -C - -O --retry 5'
	alias clb='curl -L -I'
	alias clhead='curl -D - -so /dev/null'
fi
