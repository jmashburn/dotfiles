# shellcheck shell=bash
# Navigation shortcuts

# Jump into a project directory: c <tab>
# Must be a function (not a script) so cd affects the current shell
function c() {
  if [[ -z "${PROJECTS:-}" ]]; then
    echo "c: PROJECTS is not set" >&2
    return 1
  fi
  cd "${PROJECTS}/${1}"
}
