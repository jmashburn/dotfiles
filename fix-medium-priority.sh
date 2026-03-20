#!/usr/bin/env bash
#
# Fix medium-priority issues from code review
# Focuses on error handling, shellcheck warnings, and robustness
#
# Usage: ./fix-medium-priority.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Fixing medium-priority issues in dotfiles..."
echo ""

# Backup files
echo "Creating backups..."
cp script/bootstrap script/bootstrap.backup-medium
cp lib/helpers.bash lib/helpers.bash.backup-medium
cp script/dotfiles.sh script/dotfiles.sh.backup-medium

echo ""
echo "=== Fixing bootstrap script ==="
echo ""

# Fix #11: Add better error handling to bootstrap
echo "✓ Improving error handling in bootstrap"

# Add trap for errors
sed -i.tmp '9a\
trap '\''fail "Error on line $LINENO"'\'' ERR
' script/bootstrap

# Improve set flags (add -u and pipefail)
sed -i.tmp 's/^set -e$/set -euo pipefail/' script/bootstrap

# Fix symlink creation error handling
sed -i.tmp '/^    ln -s "\$src" "\$dst"$/,/^    success "linked \$src to \$dst"$/c\
    if ln -s "$src" "$dst" 2>/dev/null; then\
        success "linked $src to $dst"\
    else\
        fail "failed to link $src to $dst"\
    fi' script/bootstrap

rm -f script/bootstrap.tmp

# Fix printf format strings (SC2059)
echo "✓ Fixing printf format strings in bootstrap"
sed -i.tmp 's/printf "\\r  \[ \\033\[00;34m\.\.\\033\[0m \] \$1\\n"/printf "\\r  [ \\033[00;34m..\\033[0m ] %s\\n" "$1"/' script/bootstrap
sed -i.tmp 's/printf "\\r  \[ \\033\[0;33m??\\033\[0m \] \$1\\n"/printf "\\r  [ \\033[0;33m??\\033[0m ] %s\\n" "$1"/' script/bootstrap
sed -i.tmp 's/printf "\\r\\033\[2K  \[ \\033\[00;32mOK\\033\[0m \] \$1\\n"/printf "\\r\\033[2K  [ \\033[00;32mOK\\033[0m ] %s\\n" "$1"/' script/bootstrap
sed -i.tmp 's/printf "\\r\\033\[2K  \[\\033\[0;31mFAIL\\033\[0m\] \$1\\n"/printf "\\r\\033[2K  [\\033[0;31mFAIL\\033[0m] %s\\n" "$1"/' script/bootstrap
rm -f script/bootstrap.tmp

# Fix read without -r (SC2162)
echo "✓ Adding -r flag to read commands in bootstrap"
sed -i.tmp 's/read -e /read -r -e /g' script/bootstrap
sed -i.tmp 's/read -n 1 action/read -r -n 1 action/g' script/bootstrap
rm -f script/bootstrap.tmp

# Fix SC2086 - quote filename
echo "✓ Quoting git profile filename in bootstrap"
sed -i.tmp 's/git\/gitconfig\.\$git_profile\.symlink/git\/gitconfig."$git_profile".symlink/g' script/bootstrap
rm -f script/bootstrap.tmp

# Fix SC1007 - empty variable assignment
echo "✓ Fixing empty variable assignments in bootstrap"
sed -i.tmp "s/local overwrite= backup= skip=/local overwrite='' backup='' skip=''/g" script/bootstrap
rm -f script/bootstrap.tmp

echo ""
echo "=== Fixing helpers.bash ==="
echo ""

# Fix $@ expansion (SC2145)
echo "✓ Fixing \$@ expansion in helpers.bash"
sed -i.tmp 's/"\${echo_green}\$@\${reset}"/"\${echo_green}\$*\${reset}"/g' lib/helpers.bash
sed -i.tmp 's/"\${echo_yellow}\$@\${reset}"/"\${echo_yellow}\$*\${reset}"/g' lib/helpers.bash
sed -i.tmp 's/"\${echo_red}\$@\${reset}"/"\${echo_red}\$*\${reset}"/g' lib/helpers.bash
rm -f lib/helpers.bash.tmp

# Fix type command quoting (SC2086)
echo "✓ Quoting variables in type command"
sed -i.tmp 's/type \${cmd}/type "\${cmd}"/g' lib/helpers.bash
rm -f lib/helpers.bash.tmp

# Fix readonly variable quoting (SC2086)
echo "✓ Fixing readonly variable assignments"
sed -i.tmp 's/readonly \${VARIABLE_NAME}=\${PASSWORD}/readonly "\${VARIABLE_NAME}"="\${PASSWORD}"/g' lib/helpers.bash
sed -i.tmp 's/readonly \${VARIABLE_NAME}="\${!VARIABLE_NAME_2}"/readonly "\${VARIABLE_NAME}"="\${!VARIABLE_NAME_2}"/g' lib/helpers.bash
rm -f lib/helpers.bash.tmp

# Fix read without -r
echo "✓ Adding -r flag to read commands in helpers"
sed -i.tmp 's/read -p /read -r -p /g' lib/helpers.bash
rm -f lib/helpers.bash.tmp

# Fix array assignment and expansion
echo "✓ Fixing array handling in helpers"
sed -i.tmp 's/local files=\${@:3}/local files=( "\${@:3}" )/g' lib/helpers.bash
sed -i.tmp 's/for file in \${files\[@\]}/for file in "\${files[@]}"/g' lib/helpers.bash
rm -f lib/helpers.bash.tmp

echo ""
echo "=== Fixing dotfiles.sh ==="
echo ""

# Add shellcheck directives to suppress false positives
echo "✓ Adding shellcheck directives to dotfiles.sh"
sed -i.tmp '1a\
# shellcheck disable=SC1090,SC1091  # Dynamic sourcing is intentional
' script/dotfiles.sh
rm -f script/dotfiles.sh.tmp

# Add protection against unset DOTFILES_ROOT
echo "✓ Adding DOTFILES_ROOT validation"
sed -i.tmp '2a\
\
# Validate DOTFILES_ROOT is set\
if [[ -z "${DOTFILES_ROOT:-}" ]]; then\
    echo "ERROR: DOTFILES_ROOT is not set" >&2\
    return 1\
fi
' script/dotfiles.sh
rm -f script/dotfiles.sh.tmp

echo ""
echo "✅ Medium-priority fixes applied!"
echo ""
echo "Files modified:"
echo "  - script/bootstrap (error handling, shellcheck fixes)"
echo "  - lib/helpers.bash (quoting, array handling)"
echo "  - script/dotfiles.sh (validation, directives)"
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Run shellcheck again: shellcheck script/bootstrap lib/helpers.bash"
echo "  3. Test in new shell"
echo "  4. Commit: git commit -am 'Improve error handling and fix shellcheck warnings'"
echo ""
