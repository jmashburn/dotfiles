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
