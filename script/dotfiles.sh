#!/usr/bin/env bash
# Load composure first, so we support function metadata
# shellcheck source-path=SCRIPTDIR/vendor/github.com/erichs/composure
source "${DOTFILES_ROOT}/vendor/github.com/erichs/composure/composure.sh"

_library_finalize_hook=()

_main_file_appearance=${DOTFILES_ROOT}/lib/appearance.bash
for _main_file_lib in "${DOTFILES_ROOT}/lib"/*.bash
do 
    [[ "$_main_file_lib" == "$_main_file_appearance" ]] && continue
    source "${_main_file_lib}"
done

if [[ -n "${DOTFILES_THEME}" ]]; then  
    source "${DOTFILES_ROOT}"/themes/base.theme.bash
    source "${DOTFILES_ROOT}"/lib/appearance.bash
fi

# Load the file paths.bash files
source "${DOTFILES_ROOT}"/system/_path.bash
for _main_file_path in "${DOTFILES_ROOT}"/**/path*.bash
do 
    if [[ -s "${_main_file_path}" ]]; then
        source "${_main_file_path}" 
    fi
done

# Load everything but the path and completion files
for _main_file_type in "${DOTFILES_ROOT}"/**/aliases*.bash "${DOTFILES_ROOT}"/**/completion*.bash "${DOTFILES_ROOT}"/**/env*.bash;
do 
    if [[ -s "${_main_file_type}" ]]; then
        source "${_main_file_type}"
    fi
done

if [[ -n "${PROMPT:-}" ]]; then
	PS1="${PROMPT}"
fi

for _library_finalize_f in "${_library_finalize_hook[@]:-}"; do
	eval "${_library_finalize_f?}" # Use `eval` to achieve the same behavior as `$PROMPT_COMMAND`.
done
unset "${!_library_finalize_@}" "${!_main_file_@}"
