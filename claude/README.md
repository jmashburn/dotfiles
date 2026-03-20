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

- **CLAUDE.md.symlink** - Global instructions for Claude Code workflow and preferences
- **statusline.sh.symlink** - Custom statusline script for enhanced Claude Code UI
- **settings.json.symlink** - Portable settings (permissions, statusline config)

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
echo '{"workspace":{"current_dir":"/test"},"model":{"name":"claude-sonnet-4-5"}}' | ~/.claude/statusline.sh
```

Expected output: `📁 /test │ 🤖 Sonnet 4.5`

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
