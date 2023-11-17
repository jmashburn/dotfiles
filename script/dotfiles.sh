#!/usr/bin/env bash
# Load composure first, so we support function metadata
# shellcheck source-path=SCRIPTDIR/vendor/github.com/erichs/composure
source "${DOTFILES_ROOT}/vendor/github.com/erichs/composure/composure.sh"

for lib_file in "${DOTFILES_ROOT}/lib"/*.bash
do 
    source "${lib_file}"
done


if [[ -n "${DOTFILES_THEME}" ]]; then  
    source "${DOTFILES_ROOT}"/themes/base.theme.bash
    source "${DOTFILES_ROOT}"/lib/appearance.bash
fi


# Load the file paths.bash files
source "${DOTFILES_ROOT}"/system/_path.bash
for path_file in "${DOTFILES_ROOT}"/**/path*.bash
do 
    if [[ -s "${path_file}" ]]; then
        source "${path_file}" 
    fi
done

# Load everything but the path and completion files
for main_file_type in "${DOTFILES_ROOT}"/**/aliases*.bash "${DOTFILES_ROOT}"/**/completion*.bash "${DOTFILES_ROOT}"/**/env*.bash;
do 
    if [[ -s "${main_file_type}" ]]; then
        source "${main_file_type}"
    fi
done


