# Dotfiles Code Review - Suggested Improvements

## Critical Issues (Fix Immediately)

### 1. **bootstrap: Tilde Expansion in Quotes** (Line 42)
**Problem:** `~` doesn't expand inside double quotes
```bash
# BROKEN
if ! [ -f "~/.gitconfig.$git_profile" ]

# FIXED
if ! [ -f "$HOME/.gitconfig.$git_profile" ]
```

### 2. **bootstrap: Unquoted Variables** (Multiple locations)
**Problem:** Missing quotes can cause word splitting and glob expansion
```bash
# Line 81 - BROKEN
local currentSrc="$(readlink $dst)"

# FIXED
local currentSrc="$(readlink "$dst")"

# Line 214 - BROKEN
if [ ! -L $HOME/.bashrc ]

# FIXED
if [ ! -L "$HOME/.bashrc" ]
```

### 3. **bootstrap: File Iteration with Spaces** (Line 152)
**Problem:** Using find in command substitution breaks with filenames containing spaces
```bash
# BROKEN
for src in $(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*')

# FIXED (use null-delimited)
while IFS= read -r -d '' src; do
    # ... processing
done < <(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*' -print0)
```

### 4. **system/_path.bash: Security Risk** (Line 1)
**Problem:** `./bin` first in PATH allows local binary hijacking
```bash
# RISKY - an attacker can drop malicious ./bin/ls
export PATH="./bin:/usr/local/bin:..."

# SAFER - put local bin at end, or remove entirely
export PATH="/usr/local/bin:/usr/local/sbin:$DOTFILES_ROOT/bin:$HOME/.bin:$HOME/.local/bin:./bin:$PATH"
```

### 5. **bashrc: Unquoted Command Substitution** (Line 24)
```bash
# BROKEN
export GPG_TTY=$(tty)

# FIXED
export GPG_TTY="$(tty)"
```

---

## High Priority Issues

### 6. **bootstrap: Deprecated Test Operator** (Line 75)
```bash
# OLD SYNTAX
if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]

# MODERN SYNTAX
if [ -f "$dst" ] || [ -d "$dst" ] || [ -L "$dst" ]
# OR use [[
if [[ -f "$dst" || -d "$dst" || -L "$dst" ]]
```

### 7. **bootstrap: Using == Instead of =** (Multiple locations)
**Problem:** `==` is bash-specific, not POSIX compliant
```bash
# Lines 33, 49, 78, 83, 122, 128, 134
if [ "$skip_all" == "false" ]

# SHOULD BE
if [ "$skip_all" = "false" ]
```

### 8. **dotfiles.sh: Missing shopt for Globstar** (Line 22)
**Problem:** Using `**` without enabling globstar
```bash
# Add at top of file
shopt -s globstar nullglob

# Then use
for _main_file_path in "${DOTFILES_ROOT}"/**/path*.bash
```

### 9. **git/gitconfig.local.symlink.example: Typo** (Line 4)
```bash
# TYPO
siginingkey = AUTHORKEY

# FIXED
signingkey = AUTHORKEY
```

### 10. **helpers.bash: Unquoted Variables in type Command** (Line 26)
```bash
# BROKEN
type ${cmd} >/dev/null 2>&1

# FIXED
type "${cmd}" >/dev/null 2>&1
```

---

## Medium Priority Issues

### 11. **bootstrap: Improve Error Handling**
Add error handling for critical operations:
```bash
# Current
ln -s "$src" "$dst"
success "linked $src to $dst"

# Improved
if ln -s "$src" "$dst"; then
    success "linked $src to $dst"
else
    fail "failed to link $src to $dst"
fi
```

### 12. **bootstrap: set -e Hides Errors**
**Problem:** `set -e` exits on error but doesn't show useful error messages
```bash
# Better approach
set -euo pipefail  # Add -u for unset vars, -o pipefail for pipe errors

# OR trap errors
trap 'fail "Error on line $LINENO"' ERR
```

### 13. **dotfiles.sh: Unset Variables Risk**
Add protective checks:
```bash
# Add near top
set -u  # Exit on unset variables

# OR check before use
if [[ -z "${DOTFILES_ROOT:-}" ]]; then
    echo "ERROR: DOTFILES_ROOT not set"
    exit 1
fi
```

### 14. **Multiple Files: ShellCheck Warnings**
Run shellcheck on all bash files:
```bash
shellcheck script/bootstrap script/dotfiles.sh lib/*.bash
```

Common issues to fix:
- SC2086: Quote variables to prevent word splitting
- SC2046: Quote command substitutions
- SC2006: Use $(...) instead of backticks
- SC2154: Check if referenced variable is assigned

---

## Low Priority / Style Improvements

### 15. **Consistent Quoting Style**
Use consistent quoting throughout:
```bash
# Prefer
"${VARIABLE}"  # over ${VARIABLE} or $VARIABLE
```

### 16. **Function Naming Convention**
Be consistent with underscores:
```bash
# Current mix
_pathmunge()      # leading underscore
is_sudo()         # no underscore
_echo_info()      # leading underscore

# Recommend: Leading underscore for "private" functions only
```

### 17. **Add Set Flags to All Scripts**
```bash
#!/usr/bin/env bash
set -euo pipefail  # Exit on error, unset vars, pipe failures
```

### 18. **bootstrap: Simplify Boolean Logic**
```bash
# Current
if [ "$skip" != "true" ]  # "false" or empty

# Clearer
if [ "${skip:-false}" != "true" ]; then
```

### 19. **Add Script Headers**
Add consistent headers to all bash scripts:
```bash
#!/usr/bin/env bash
#
# Description: What this script does
# Usage: script-name [options]
# Dependencies: list required commands
#

set -euo pipefail
```

### 20. **helpers.bash: Line 26 - Better Command Checking**
```bash
# Current
type ${cmd} >/dev/null 2>&1

# Better
command -v "${cmd}" >/dev/null 2>&1
# OR
hash "${cmd}" 2>/dev/null
```

---

## Performance Improvements

### 21. **dotfiles.sh: Avoid Multiple Glob Expansions**
```bash
# Current - globs expanded multiple times
for _main_file_type in "${DOTFILES_ROOT}"/**/aliases*.bash \
    "${DOTFILES_ROOT}"/**/completion*.bash \
    "${DOTFILES_ROOT}"/**/env*.bash; do

# Better - single loop with array
files=( "${DOTFILES_ROOT}"/**/{aliases,completion,env}*.bash )
for file in "${files[@]}"; do
    [[ -f "$file" ]] && source "$file"
done
```

### 22. **Reduce Subshells in Loops**
Minimize process creation for better performance

---

## Documentation Improvements

### 23. **Add README Sections**
- Bootstrap usage examples
- Troubleshooting common issues
- macOS vs Linux differences
- How to add new tool configurations

### 24. **Document Shell Compatibility**
State minimum versions:
- Bash 3.2+ (macOS compatibility)
- Bash 4.0+ for some features (document which)

### 25. **Add Installation Script Logging**
```bash
# In install.sh files
exec 1> >(tee -a "install.log")
exec 2>&1
```

---

## Testing Recommendations

### 26. **Add Test Suite**
Create `tests/` directory with:
- Unit tests for helper functions
- Integration tests for bootstrap
- Compatibility tests for Bash 3.2 vs 5.x

### 27. **Add CI/CD**
Use GitHub Actions to:
- Run shellcheck on all bash files
- Test on macOS and Linux
- Verify symlink creation works

### 28. **Create Test Environment**
```bash
# test/test-bootstrap.sh
export HOME=/tmp/dotfiles-test
export DOTFILES_ROOT="$(cd .. && pwd)"
./script/bootstrap -S  # Skip all to test non-interactively
```

---

## Security Hardening

### 29. **Validate User Input**
```bash
# In setup_gitconfig
if [[ ! "$git_authoremail" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    fail "Invalid email address"
fi
```

### 30. **Check File Permissions**
```bash
# Before sourcing files
if [[ "$(stat -f '%p' ~/.localrc 2>/dev/null)" =~ [0-9]*[0-7][0-7][0-7]$ ]]; then
    if [[ "${BASH_REMATCH[0]: -2:1}" != "0" ]]; then
        echo "WARNING: ~/.localrc is group/world readable!"
    fi
fi
```

---

## Priority Order for Fixes

**Week 1 - Critical:**
1. Fix tilde expansion (Issue #1)
2. Quote all variables (Issue #2)
3. Fix PATH security (Issue #4)
4. Fix file iteration (Issue #3)

**Week 2 - High Priority:**
5. Fix deprecated operators (Issue #6, #7)
6. Add globstar (Issue #8)
7. Fix typo in gitconfig (Issue #9)

**Week 3 - Medium Priority:**
8. Add error handling (Issues #11-13)
9. Run shellcheck and fix (Issue #14)

**Month 2 - Low Priority & Polish:**
10. Style improvements (Issues #15-20)
11. Performance (Issues #21-22)
12. Documentation (Issues #23-25)
13. Testing & CI/CD (Issues #26-28)
14. Security hardening (Issues #29-30)
