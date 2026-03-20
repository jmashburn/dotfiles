# Testing Guide for Dotfiles

## Automated Testing

### Syntax Validation

Check all bash files for syntax errors:

```bash
# Test all files
find . -name "*.sh" -o -name "*.bash" | while read -r file; do
    echo "Checking $file..."
    bash -n "$file" || echo "FAILED: $file"
done

# Quick test main files
bash -n script/bootstrap
bash -n lib/helpers.bash
bash -n script/dotfiles.sh
```

### ShellCheck

Install and run shellcheck:

```bash
# Install
brew install shellcheck  # macOS
apt install shellcheck   # Linux

# Check main files
shellcheck script/bootstrap
shellcheck lib/helpers.bash
shellcheck script/dotfiles.sh

# Check all bash files
find . -name "*.bash" -o -name "*.sh" | xargs shellcheck
```

### Unit Testing Helper Functions

Test individual helper functions:

```bash
# Source helpers
source lib/helpers.bash

# Test pathmunge
TEST_PATH="/usr/bin:/bin"
PATH="$TEST_PATH"
_pathmunge /new/path
[[ "$PATH" = "/new/path:$TEST_PATH" ]] && echo "✓ pathmunge prepend works"

PATH="$TEST_PATH"
_pathmunge -a /new/path
[[ "$PATH" = "$TEST_PATH:/new/path" ]] && echo "✓ pathmunge append works"

# Test command validation
_is_command_is_available bash && echo "✓ command check works"
```

## Manual Testing

### Bootstrap Testing

Test bootstrap without making changes:

```bash
# Dry run (skip all)
./script/bootstrap -S

# Test with overwrite
./script/bootstrap -O

# Test with backup
./script/bootstrap -B
```

### Symlink Testing

Verify symlinks are created correctly:

```bash
# Check symlinks exist
ls -la ~/.bashrc
ls -la ~/.gitconfig
ls -la ~/.claude/CLAUDE.md

# Verify they point to dotfiles
readlink ~/.bashrc
# Should output: /Users/jared/.dotfiles/bash/bashrc.symlink
```

### Path Testing

Verify PATH is set correctly:

```bash
# Check PATH order
echo "$PATH" | tr ':' '\n' | head -10

# Verify ./bin is at END (security)
echo "$PATH" | grep -o '\./bin' && echo "WARNING: ./bin found"
[[ "$PATH" =~ \.\/bin$ ]] && echo "✓ ./bin at end (secure)"

# Check dotfiles bin is included
echo "$PATH" | grep -q "$HOME/.dotfiles/bin" && echo "✓ dotfiles/bin in PATH"
```

### Environment Testing

Check environment variables:

```bash
# Required variables
[[ -n "$DOTFILES_ROOT" ]] && echo "✓ DOTFILES_ROOT set"
[[ -n "$DOTFILES_THEME" ]] && echo "✓ DOTFILES_THEME set"
[[ -n "$GPG_TTY" ]] && echo "✓ GPG_TTY set"
```

### Function Testing

Test key functions are available:

```bash
# Check pathmunge
type _pathmunge >/dev/null && echo "✓ _pathmunge loaded"

# Check git helpers (if installed)
type get_default_branch >/dev/null 2>&1 && echo "✓ git helpers loaded"

# Check color variables
[[ -n "$echo_green" ]] && echo "✓ color variables loaded"
```

### Claude Code Testing

If using Claude Code:

```bash
# Test statusline
echo '{"workspace":{"current_dir":"/test"},"model":{"name":"claude-sonnet-4-5"}}' | ~/.claude/statusline.sh

# Check dependencies
command -v jq >/dev/null && echo "✓ jq installed"
command -v bc >/dev/null && echo "✓ bc installed"

# Verify settings
[[ -f ~/.claude/settings.json ]] && echo "✓ Claude settings exist"
```

## Compatibility Testing

### Bash Version Testing

Test on different bash versions:

```bash
# Show current version
bash --version | head -1

# Test with explicit bash 3.2 (macOS)
/bin/bash --version  # System bash on macOS

# Test with homebrew bash (newer)
/opt/homebrew/bin/bash --version  # If installed
```

### Cross-Platform Testing

Test on different platforms:

```bash
# Check OS detection
uname -s
# Darwin = macOS
# Linux = Linux

# Check platform-specific code
case "$(uname -s)" in
    Darwin) echo "macOS detected" ;;
    Linux)  echo "Linux detected" ;;
esac
```

## Regression Testing

### Before/After Comparison

```bash
# Capture before state
echo "$PATH" > /tmp/path-before.txt
env > /tmp/env-before.txt
type _pathmunge > /tmp/functions-before.txt 2>&1

# Make changes / reload shell

# Capture after state
echo "$PATH" > /tmp/path-after.txt
env > /tmp/env-after.txt
type _pathmunge > /tmp/functions-after.txt 2>&1

# Compare
diff /tmp/path-before.txt /tmp/path-after.txt
diff /tmp/env-before.txt /tmp/env-after.txt
diff /tmp/functions-before.txt /tmp/functions-after.txt
```

### Shell Reload Testing

Test that reloading works:

```bash
# Reload dotfiles
source ~/.bashrc

# Or start new shell
bash -l -c 'echo "New shell works"'
```

## Performance Testing

### Startup Time

Measure shell startup time:

```bash
# Baseline (no dotfiles)
time bash -c 'exit'

# With dotfiles
time bash -l -c 'exit'

# Detailed timing
bash -x -l -c 'exit' 2>&1 | grep -E '^\+'
```

### Function Load Time

Time individual operations:

```bash
time _pathmunge /test/path
time source lib/helpers.bash
```

## Error Testing

### Test Error Handling

```bash
# Test with invalid input
_pathmunge ""
_is_command_is_available nonexistentcommand

# Test with spaces in filenames
touch "file with spaces.txt"
./script/bootstrap -S  # Should handle it
```

### Test Error Messages

```bash
# Unset DOTFILES_ROOT
unset DOTFILES_ROOT
source script/dotfiles.sh  # Should show error

# Missing dependency
mv ~/.dotfiles/bin/dot ~/.dotfiles/bin/dot.bak
./script/bootstrap  # Should handle gracefully
```

## CI/CD Testing (Future)

Example GitHub Actions workflow:

```yaml
name: Test Dotfiles
on: [push, pull_request]
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
    steps:
      - uses: actions/checkout@v2
      - name: Install shellcheck
        run: |
          if [ "$RUNNER_OS" == "Linux" ]; then
            sudo apt-get install -y shellcheck
          else
            brew install shellcheck
          fi
      - name: Syntax check
        run: bash -n script/bootstrap
      - name: ShellCheck
        run: shellcheck script/bootstrap
      - name: Test bootstrap
        run: ./script/bootstrap -S
```

## Test Checklist

Before committing changes:

- [ ] All files pass `bash -n` syntax check
- [ ] ShellCheck warnings reviewed and addressed
- [ ] Bootstrap runs without errors (`-S` mode)
- [ ] Symlinks created correctly
- [ ] PATH contains expected directories
- [ ] Functions load and work
- [ ] Works in new shell (`bash -l`)
- [ ] No errors in `~/.bashrc` reload
- [ ] Compatible with Bash 3.2 (macOS)
- [ ] Compatible with Bash 5.x (Linux)

## Debugging

Enable debugging:

```bash
# Trace execution
bash -x script/bootstrap

# Verbose output
set -x
source ~/.bashrc
set +x

# Check what's loaded
declare -F | grep -E '^declare -f'  # List all functions
```
