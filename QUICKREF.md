# Dotfiles Quick Reference

## Daily Commands

### Path Management
```bash
# Add directory to PATH (prepend)
pathmunge /new/path

# Add directory to PATH (append)
pathmunge -a /new/path

# Add to custom variable with separator
pathmunge -s ":" MYVAR /new/value
```

### Git Shortcuts
```bash
# Quick status
gs                    # git status -sb

# Stage and commit
gac "commit message"  # git add -A && git commit -m

# Pull and push
gl                    # git pull --prune
gp                    # git push origin HEAD

# Fancy log
glog                  # Pretty formatted git log
gg                    # Graph view
```

### File Operations
```bash
# Extract any archive
extract file.tar.gz
extract file.zip

# Search files
gu                    # Show untracked files
```

## Helper Functions

### Validation
```bash
_is_command_is_available curl     # Check if command exists
_is_file_exists /path/to/file     # Check if file exists
_ask_to_continue "Continue?"      # Prompt user y/n
```

### Output Formatting
```bash
_echo_info "Information"          # Green text
_echo_important "Warning"         # Yellow text
_echo_warn "Error"                # Red text
_die "Fatal error"                # Red text + exit
```

### Password Input
```bash
_ask_for_password VARNAME "Enter password: "
# Password stored in $VARNAME
```

## Bootstrap Options

```bash
./script/bootstrap         # Interactive install
./script/bootstrap -O      # Overwrite all
./script/bootstrap -B      # Backup all
./script/bootstrap -S      # Skip all (test mode)
```

## Directory Structure

```
~/.dotfiles/
├── script/          # Bootstrap and main loader
├── lib/             # Helper functions and libraries
├── bin/             # Executable scripts
├── <tool>/          # Tool-specific configurations
│   ├── *.symlink    # Files to symlink to ~/.<name>
│   ├── aliases.bash # Aliases for this tool
│   ├── path.bash    # PATH additions
│   ├── env.bash     # Environment variables
│   ├── install.sh   # Installation script
│   └── completion.bash # Shell completions
├── themes/          # Prompt themes
└── vendor/          # Third-party tools
```

## File Naming Conventions

- `*.symlink` - Symlinked to `~/.<basename>`
- `aliases.bash` - Loaded for aliases
- `path.bash` - Loaded for PATH modifications
- `env.bash` - Loaded for environment variables
- `completion.bash` - Loaded for shell completions
- `install.sh` - Run during bootstrap for dependencies

## Adding New Tools

1. Create directory: `mkdir newtool`
2. Add symlink file: `touch newtool/config.symlink`
3. Add aliases: `touch newtool/aliases.bash`
4. Add path: `echo 'export PATH="$PATH:/new/bin"' > newtool/path.bash`
5. Run bootstrap: `./script/bootstrap`

## Themes

Set theme in `~/.bashrc`:
```bash
export DOTFILES_THEME='90210'  # Current theme
```

Available themes:
- `90210` - Colorful with git info
- `bobby` - Minimalist
- `brunton` - Git-focused
- `parrot` - Detailed status
- `wanelo` - Clean and simple

## Environment Variables

Set in `~/.localrc` (not tracked in git):
```bash
# Custom environment variables
export API_KEY="secret"
export CUSTOM_PATH="/my/path"

# Machine-specific settings
export EDITOR="vim"
```

## Claude Code Integration

Configuration stored in `~/.dotfiles/claude/`:
- `CLAUDE.md.symlink` - Workflow instructions
- `statusline.sh.symlink` - Custom statusline
- `settings.json.symlink` - Permissions and config

Machine-specific: `~/.claude/settings.local.json`

## Useful Bash Settings

Dotfiles includes:
```bash
set -euo pipefail  # Exit on error, unset vars, pipe failures
shopt -s globstar  # Enable ** recursive globbing
```

## Color Variables

Available in all bash files:
```bash
echo -e "${echo_green}Success${echo_normal}"
echo -e "${echo_red}Error${echo_normal}"
echo -e "${echo_yellow}Warning${echo_normal}"
```

For prompts:
```bash
PS1="${green}\u${normal}@${blue}\h${normal}:\w\$ "
```

## Git Profiles

Create different git configs:
```bash
# During bootstrap, specify profile
./script/bootstrap work

# Creates: git/gitconfig.work.symlink
# Symlinked to: ~/.gitconfig.work
```

## Shell Compatibility

- **Bash 3.2+** - macOS compatible
- **Bash 4.0+** - Full features
- **POSIX** - Core functions work in sh/dash

## Security Notes

- `./bin` at END of PATH (not beginning) - prevents hijacking
- All user input properly quoted
- No eval of untrusted data
- GPG_TTY set for password-store

## Performance Tips

- Functions are autoloaded on first use
- Composure allows metadata on functions
- Use `type functionname` to see definition
