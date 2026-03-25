#!/bin/bash
# FileChanged hook (v2.1.82+)
# Executes when a file is modified
# Useful for auto-formatting, linting, or triggering builds

# Get the changed file from the hook context
input=$(cat)
changed_file=$(echo "$input" | jq -r '.file // ""')

if [ -z "$changed_file" ]; then
    exit 0
fi

# Get the file extension
ext="${changed_file##*.}"

# Example: Auto-format Go files
if [ "$ext" = "go" ]; then
    if command -v gofmt &> /dev/null; then
        gofmt -w "$changed_file"
        echo "✓ Formatted Go file: $changed_file"
    fi
fi

# Example: Lint JavaScript/TypeScript files
if [ "$ext" = "js" ] || [ "$ext" = "ts" ] || [ "$ext" = "jsx" ] || [ "$ext" = "tsx" ]; then
    if [ -f "$(dirname "$changed_file")/package.json" ]; then
        project_dir=$(dirname "$changed_file")
        if [ -f "$project_dir/.eslintrc" ] || [ -f "$project_dir/.eslintrc.js" ]; then
            echo "🔍 ESLint available - run 'npm run lint' to check"
        fi
    fi
fi

# Example: Notify about important file changes
case "$changed_file" in
    *package.json)
        echo "📦 package.json changed - you may need to run 'npm install'"
        ;;
    *requirements.txt)
        echo "🐍 requirements.txt changed - you may need to run 'pip install -r requirements.txt'"
        ;;
    *go.mod)
        echo "📦 go.mod changed - you may need to run 'go mod download'"
        ;;
    *.env*)
        echo "⚠️  Environment file changed - restart services if needed"
        ;;
esac
