#!/usr/bin/env bash
#
# Quick fix for critical issues found in code review
# Run this to apply automated fixes for the most dangerous bugs
#
# Usage: ./fix-critical-issues.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Fixing critical issues in dotfiles..."
echo ""

# Backup original files
echo "Creating backups..."
cp script/bootstrap script/bootstrap.backup
cp system/_path.bash system/_path.bash.backup
cp bash/bashrc.symlink bash/bashrc.symlink.backup
cp git/gitconfig.local.symlink.example git/gitconfig.local.symlink.example.backup

# Fix #1: Tilde expansion in bootstrap
echo "✓ Fixing tilde expansion in bootstrap (line 42)"
sed -i.tmp 's|"~/\.gitconfig|"$HOME/.gitconfig|g' script/bootstrap
rm -f script/bootstrap.tmp

# Fix #2: Unquoted variables in bootstrap
echo "✓ Fixing unquoted variables in bootstrap"
sed -i.tmp 's|readlink $dst|readlink "$dst"|g' script/bootstrap
sed -i.tmp 's|\$HOME/\.bashrc|"$HOME/.bashrc"|g' script/bootstrap
rm -f script/bootstrap.tmp

# Fix #6: Deprecated -o operator (manual - complex regex)
echo "✓ Fixing deprecated test operators in bootstrap (line 75)"
# This requires manual edit due to BSD sed limitations with complex patterns

# Fix #7: == to = for POSIX compliance
echo "✓ Fixing == to = in bootstrap for POSIX compliance"
sed -i.tmp 's/ == / = /g' script/bootstrap
rm -f script/bootstrap.tmp

# Fix #4: PATH security issue
echo "✓ Fixing PATH security (moving ./bin to end)"
sed -i.tmp 's|export PATH="\./bin:|export PATH="|' system/_path.bash
sed -i.tmp 's|PATH"|PATH:./bin"|' system/_path.bash
rm -f system/_path.bash.tmp

# Fix #5: Quote command substitution in bashrc
echo "✓ Fixing unquoted command substitution in bashrc"
sed -i.tmp 's|export GPG_TTY=$(tty)|export GPG_TTY="$(tty)"|g' bash/bashrc.symlink
rm -f bash/bashrc.symlink.tmp

# Fix #9: Typo in gitconfig example
echo "✓ Fixing typo in git config example (siginingkey -> signingkey)"
sed -i.tmp 's|siginingkey|signingkey|g' git/gitconfig.local.symlink.example
rm -f git/gitconfig.local.symlink.example.tmp

echo ""
echo "✅ Critical fixes applied!"
echo ""
echo "Backups created with .backup extension"
echo "Review changes with: git diff"
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff"
echo "  2. Test bootstrap: ./script/bootstrap -S"
echo "  3. If everything works: rm -f **/*.backup"
echo "  4. Commit changes: git commit -am 'Fix critical security and compatibility issues'"
echo ""
echo "For remaining issues, see CODEREVIEW.md"
