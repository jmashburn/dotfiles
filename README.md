# dotfiles

## Installation

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./script/bootstrap
```

## Troubleshooting

### Shell Startup Errors

If you see errors when starting a new shell:

```bash
# Check syntax of all bash files
bash -n ~/.dotfiles/script/bootstrap
bash -n ~/.dotfiles/lib/helpers.bash

# Check for shellcheck warnings
shellcheck ~/.dotfiles/script/bootstrap
```

### Symlink Issues

If symlinks aren't being created:

```bash
# Manually create symlinks
cd ~/.dotfiles
./script/bootstrap -O  # Overwrite all
```

### macOS vs Linux Differences

- **macOS**: Uses Bash 3.2 by default (install newer bash: `brew install bash`)
- **Linux**: Usually has Bash 4.0+
- **PATH Security**: `./bin` is at the end of PATH to prevent hijacking

### Permission Issues

```bash
# Fix script permissions
find ~/.dotfiles -name "*.sh" -exec chmod +x {} \;
```

### GPG/Pass Issues

If password-store isn't working:

```bash
# Ensure GPG_TTY is set (already in bashrc)
export GPG_TTY="$(tty)"

# Check GPG keys
gpg --list-keys
```

## Testing

Test the bootstrap without making changes:

```bash
./script/bootstrap -S  # Skip all prompts
```

## Dependencies

Required for full functionality:

- `git` - Version control
- `curl` - Downloads
- `jq` - JSON processing (for Claude Code statusline)
- `bc` - Calculator (for Claude Code statusline)

Install on macOS:
```bash
brew install git curl jq bc
```

Install on Linux:
```bash
# Debian/Ubuntu
sudo apt-get install git curl jq bc

# RHEL/CentOS
sudo yum install git curl jq bc
```

## Documentation

- `CODEREVIEW.md` - Comprehensive code review and improvement recommendations
- `IMPROVEMENTS_APPLIED.md` - Changelog of fixes applied
- `claude/README.md` - Claude Code configuration documentation
