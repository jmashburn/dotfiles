#!/bin/bash
# CwdChanged hook (v2.1.82+)
# Executes when the working directory changes
# Similar to direnv - can load environment variables, configs, etc.

# Get the new directory from the hook context
# The hook receives JSON on stdin with event details
input=$(cat)
new_dir=$(echo "$input" | jq -r '.cwd // ""')

if [ -z "$new_dir" ]; then
    exit 0
fi

# Example: Load .envrc if it exists (direnv-style)
if [ -f "$new_dir/.envrc" ]; then
    # Source the .envrc file (BE CAREFUL - only in trusted directories!)
    # You might want to add whitelist checking here
    source "$new_dir/.envrc"
fi

# Example: Check for .nvmrc and suggest node version
if [ -f "$new_dir/.nvmrc" ]; then
    required_version=$(cat "$new_dir/.nvmrc")
    echo "📌 This project uses Node $required_version"
fi

# Example: Check for .python-version
if [ -f "$new_dir/.python-version" ]; then
    required_version=$(cat "$new_dir/.python-version")
    echo "🐍 This project uses Python $required_version"
fi

# Example: Show project-specific reminders
if [ -f "$new_dir/.claude-notes" ]; then
    echo "📝 Project notes:"
    cat "$new_dir/.claude-notes"
fi
