#!/bin/bash
# Enhanced Claude Code statusline
# Receives JSON session info on stdin and outputs formatted statusline
# Requires: jq, bc

# Check dependencies
if ! command -v jq &> /dev/null; then
    echo "⚠️  statusline: jq not found"
    exit 1
fi

if ! command -v bc &> /dev/null; then
    echo "⚠️  statusline: bc not found"
    exit 1
fi

# Validate input
input=$(cat)
if ! echo "$input" | jq empty 2>/dev/null; then
    echo "⚠️  statusline: invalid JSON input"
    exit 1
fi

# Extract key information using jq
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "~"')
MODEL=$(echo "$input" | jq -r '.model.name // "claude"')
CONTEXT_PCT=$(echo "$input" | jq -r '.context_window.percent_used // 0')
TOKENS_USED=$(echo "$input" | jq -r '.context_window.tokens_used // 0')
TOKENS_TOTAL=$(echo "$input" | jq -r '.context_window.tokens_total // 0')
COST=$(echo "$input" | jq -r '.cost.usd // 0')
VIM_MODE=$(echo "$input" | jq -r '.vim.mode // ""')
AGENT=$(echo "$input" | jq -r '.agent.name // ""')
WORKTREE=$(echo "$input" | jq -r '.worktree.name // ""')

# Build statusline components
components=()

# Directory (always shown)
components+=("📁 $CURRENT_DIR")

# Model info
if [ "$MODEL" != "null" ] && [ -n "$MODEL" ]; then
    # Simplify model name (e.g., "claude-sonnet-4-5@20250929" -> "Sonnet 4.5")
    MODEL_SHORT=$(echo "$MODEL" | sed -E 's/claude-([a-z]+)-([0-9])-([0-9]).*/\1 \2.\3/' | awk '{print toupper(substr($1,1,1)) tolower(substr($1,2)) " " $2}')
    components+=("🤖 $MODEL_SHORT")
fi

# Context window usage with visual indicator
if [ "$CONTEXT_PCT" != "null" ] && [ -n "$CONTEXT_PCT" ]; then
    CONTEXT_INT=$(echo "$CONTEXT_PCT" | cut -d. -f1)

    # Choose icon based on usage
    if [ "$CONTEXT_INT" -lt 25 ]; then
        CONTEXT_ICON="🟢"
    elif [ "$CONTEXT_INT" -lt 50 ]; then
        CONTEXT_ICON="🟡"
    elif [ "$CONTEXT_INT" -lt 75 ]; then
        CONTEXT_ICON="🟠"
    else
        CONTEXT_ICON="🔴"
    fi

    # Format tokens (e.g., 15K/200K)
    TOKENS_K_USED=$(echo "scale=0; $TOKENS_USED / 1000" | bc)
    TOKENS_K_TOTAL=$(echo "scale=0; $TOKENS_TOTAL / 1000" | bc)

    components+=("${CONTEXT_ICON} ${TOKENS_K_USED}K/${TOKENS_K_TOTAL}K (${CONTEXT_INT}%)")
fi

# Cost tracking
if [ "$COST" != "null" ] && [ -n "$COST" ] && [ "$(echo "$COST > 0" | bc)" -eq 1 ]; then
    COST_FORMATTED=$(printf "%.3f" "$COST")
    components+=("💰 \$$COST_FORMATTED")
fi

# Vim mode indicator
if [ "$VIM_MODE" != "null" ] && [ -n "$VIM_MODE" ] && [ "$VIM_MODE" != "disabled" ]; then
    components+=("⌨️  $VIM_MODE")
fi

# Agent indicator
if [ "$AGENT" != "null" ] && [ -n "$AGENT" ]; then
    components+=("🔧 $AGENT")
fi

# Worktree indicator
if [ "$WORKTREE" != "null" ] && [ -n "$WORKTREE" ]; then
    components+=("🌳 $WORKTREE")
fi

# Join components with separator
output=""
for i in "${!components[@]}"; do
    if [[ $i -eq 0 ]]; then
        output="${components[$i]}"
    else
        output="$output │ ${components[$i]}"
    fi
done

echo "$output"
