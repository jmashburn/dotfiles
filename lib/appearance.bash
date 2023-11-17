: "${CLICOLOR:=$(tput colors)}"
export CLICOLOR

if [[ -n "${DOTFILES_THEME:-}" ]]; then
	if [[ -f "${DOTFILES_THEME}" ]]; then
		source "${DOTFILES_THEME}"
	elif [[ -f "${DOTFILES_ROOT}/themes/${DOTFILES_THEME}/theme.bash" ]]; then
	    source "${DOTFILES_ROOT}/themes/${DOTFILES_THEME}/theme.bash"
	fi
fi