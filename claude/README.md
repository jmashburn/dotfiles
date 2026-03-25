# Claude Code Configuration

This directory contains portable Claude Code settings that can be synced across machines.

## Dependencies

The statusline script requires:
- `jq` - JSON processor
- `bc` - Basic calculator for arithmetic

Install on macOS: `brew install jq bc`
Install on Linux: `apt install jq bc` or `yum install jq bc`

Run `claude/install.sh` to install dependencies automatically.

## Files Included

- **CLAUDE.md** - Global instructions for Claude Code workflow and preferences
- **statusline.sh** - Custom statusline script with rate limit tracking (v2.1.80+)
- **settings.json** - Portable settings (permissions, statusline config, security)
- **keybindings.json** - Custom keybindings (v2.1.82+)
- **hooks/** - Event-driven scripts (v2.1.82+)
  - `cwd-changed.sh` - Runs when directory changes (direnv-like)
  - `file-changed.sh` - Runs when files are modified (auto-format, lint)
- **commands/** - Custom slash commands
- **skills/** - Reusable skills
- **agents/** - Custom agents
- **rules/** - Project-specific rules

## Files Excluded (Machine-Specific)

These are in `.gitignore` and should remain local:
- `settings.local.json` - Machine-specific overrides
- `history.jsonl` - Conversation history
- `projects/` - Project-specific configurations
- `sessions/`, `cache/`, `session-env/` - Runtime data

## Installation

When you run `script/bootstrap`, these files will be symlinked to:
- `~/.claude/CLAUDE.md`
- `~/.claude/statusline.sh`
- `~/.claude/settings.json`

## Testing the Statusline

Test the statusline script manually:
```bash
echo '{"workspace":{"current_dir":"/test"},"model":{"display_name":"Sonnet 4.5"}}' | ~/.claude/statusline.sh
```

Expected output: `📁 /test │ 🤖 Sonnet 4.5`

Test with rate limits (v2.1.80+):
```bash
echo '{"workspace":{"current_dir":"/test"},"model":{"display_name":"Sonnet 4.5"},"rate_limits":{"5h":{"used_percentage":65},"7d":{"used_percentage":45}}}' | ~/.claude/statusline.sh
```

Expected output: `📁 /test │ 🤖 Sonnet 4.5 │ 🟡 Rate: 65% (5h)`

## Adding Machine-Specific Settings

Create `~/.claude/settings.local.json` for machine-specific overrides:

```json
{
  "permissions": {
    "allow": [
      "Bash(some-machine-specific-command:*)"
    ]
  }
}
```

This file will NOT be tracked in git and will override settings from `settings.json`.

## How Settings Merge

Claude Code loads settings in this order:
1. `settings.json` (from dotfiles - portable, version-controlled)
2. `settings.local.json` (machine-specific, overrides/extends above)

Settings are merged, not replaced. Local permissions append to global ones, allowing you to maintain both portable and machine-specific configurations.

## New Features (v2.1.80 - v2.1.82)

### Statusline Enhancements
- **Rate limit tracking** - Shows 5-hour and 7-day rate limit usage with color indicators
- Displays warning when limits exceed 50%, alerts at 80%

### Keybindings (v2.1.82+)
- **Ctrl+X Ctrl+K** - Stop all background agents (changed from Ctrl+F)
- **Ctrl+X Ctrl+E** - Open external editor (readline-native binding)
- **Ctrl+L** - Clear screen and force full redraw
- **Ctrl+Shift+F** - Toggle fast mode
- All bindings are rebindable via `keybindings.json`

### Security Settings (v2.1.82+)
- **`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1`** - Strips Anthropic and cloud provider credentials from subprocess environments (Bash tool, hooks, MCP servers)
- **`sandbox.failIfUnavailable`** - Exit with error if sandbox is enabled but can't start

### Hooks (v2.1.82+)
- **CwdChanged** - Executes when working directory changes
  - Use for direnv-like environment loading
  - Auto-detect project requirements (.nvmrc, .python-version)
  - Show project-specific reminders
- **FileChanged** - Executes when files are modified
  - Auto-format on save
  - Trigger linting or builds
  - Notify about dependency file changes

### Other Settings
- **`showClearContextOnPlanAccept: true`** - Show clear context option in plan mode
- **`managed-settings.d/`** - Drop-in directory for policy fragments (team deployments)
