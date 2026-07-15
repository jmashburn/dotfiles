# Add vendored pass to PATH and load its bash completion
PASS_DIR="${DOTFILES_ROOT}/vendor/github.com/jmashburn/pass"

if [[ -d "${PASS_DIR}" ]]; then
  export PATH="${PASS_DIR}:${PATH}"
  # shellcheck source=/dev/null
  [[ -f "${PASS_DIR}/completion/pass.bash-completion" ]] \
    && source "${PASS_DIR}/completion/pass.bash-completion"
fi
