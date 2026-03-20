#!/usr/bin/env bash
# Install Claude Code dependencies

set -e

echo "Installing Claude Code dependencies..."

if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &> /dev/null; then
        echo "  Installing jq and bc via Homebrew..."
        brew install jq bc
    else
        echo "  Homebrew not found. Please install jq and bc manually:"
        echo "    brew install jq bc"
        exit 1
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt-get &> /dev/null; then
        echo "  Installing jq and bc via apt..."
        sudo apt-get update
        sudo apt-get install -y jq bc
    elif command -v yum &> /dev/null; then
        echo "  Installing jq and bc via yum..."
        sudo yum install -y jq bc
    elif command -v dnf &> /dev/null; then
        echo "  Installing jq and bc via dnf..."
        sudo dnf install -y jq bc
    else
        echo "  Package manager not found. Please install jq and bc manually."
        exit 1
    fi
else
    echo "  Unsupported OS: $OSTYPE"
    echo "  Please install jq and bc manually."
    exit 1
fi

echo "✓ Claude Code dependencies installed successfully"

# Register local plugin
PLUGIN_DIR="$HOME/.claude/plugins/local"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Registering jared-workflow plugin..."
mkdir -p "$PLUGIN_DIR"
ln -sfn "$DOTFILES_DIR" "$PLUGIN_DIR/jared-workflow"

INSTALLED_PLUGINS="$HOME/.claude/plugins/installed_plugins.json"
if [[ -f "$INSTALLED_PLUGINS" ]] && command -v jq &>/dev/null; then
    if ! jq -e '.plugins["jared-workflow@local"]' "$INSTALLED_PLUGINS" &>/dev/null; then
        tmp=$(mktemp)
        jq --arg path "$PLUGIN_DIR/jared-workflow" \
           '.plugins["jared-workflow@local"] = [{"scope":"user","installPath":$path,"version":"local","installedAt":"2026-03-20T00:00:00.000Z","lastUpdated":"2026-03-20T00:00:00.000Z"}]' \
           "$INSTALLED_PLUGINS" > "$tmp" && mv "$tmp" "$INSTALLED_PLUGINS"
        echo "  Registered in installed_plugins.json"
    else
        echo "  Already registered"
    fi
else
    echo "  Skipping installed_plugins.json update (file not found or jq missing)"
fi

echo "✓ jared-workflow plugin installed"
