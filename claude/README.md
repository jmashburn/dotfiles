# Claude Code Configuration

This directory contains portable Claude Code settings that can be synced across machines.

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
