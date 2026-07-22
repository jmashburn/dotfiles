#!/usr/bin/env bash
# Claude Code Statusline — Focused 90210 + Fun Metrics (Zero-Hanging)

JQ_EXEC="/usr/bin/jq"
BC_EXEC="/usr/bin/bc"

# Completely non-blocking loop structure to prevent hanging
input=""
while IFS= read -r -t 0.02 line; do
    input="${input}${line}\n"
done

# Extract workspace directory safely
if [ -n "$input" ] && echo -e "$input" | $JQ_EXEC empty 2>/dev/null; then
    cwd=$(echo -e "$input" | $JQ_EXEC -r '.workspace.current_dir // .cwd // "~"' | sed "s|$HOME|~|")
    model=$(echo -e "$input" | $JQ_EXEC -r '.model.display_name // .model.name // ""')
    context_pct=$(echo -e "$input" | $JQ_EXEC -r '.context_window.used_percentage // 0' | cut -d. -f1)
    cost=$(echo -e "$input" | $JQ_EXEC -r '.cost.total_cost_usd // 0')
    vim_mode=$(echo -e "$input" | $JQ_EXEC -r '.vim.mode // ""')
    rate_limit_5h=$(echo -e "$input" | $JQ_EXEC -r '.rate_limits.five_hour.remaining_percentage // .usage_limit.remaining_percentage // ""')
    reset_time=$(echo -e "$input" | $JQ_EXEC -r '.rate_limits.five_hour.resets_in_minutes // ""')
    pr_number=$(echo -e "$input" | $JQ_EXEC -r '.git.pull_request // .git.pr // ""')
    pr_status=$(echo -e "$input" | $JQ_EXEC -r '.git.pr_status // .git.status // ""')
    agent_active=$(echo -e "$input" | $JQ_EXEC -r '.agent.is_running // .agent.active // "false"')
    agent_task=$(echo -e "$input" | $JQ_EXEC -r '.agent.current_task // .agent.name // ""')
    last_tool=$(echo -e "$input" | $JQ_EXEC -r '.agent.last_tool_used // ""')
    tokens_total=$(echo -e "$input" | $JQ_EXEC -r '.context_window.context_window_size // 0')
    tokens_used=$(echo -e "$input" | $JQ_EXEC -r "if .context_window.context_window_size > 0 then (.context_window.used_percentage / 100 * .context_window.context_window_size | floor) else 0 end" 2>/dev/null)
    # Prompt-cache tokens from the LAST API call (current_usage is null before
    # the first call and right after /compact — hence the // 0 fallbacks).
    cache_read=$(echo -e "$input" | $JQ_EXEC -r '.context_window.current_usage.cache_read_input_tokens // 0')
    cache_create=$(echo -e "$input" | $JQ_EXEC -r '.context_window.current_usage.cache_creation_input_tokens // 0')
    fresh_input=$(echo -e "$input" | $JQ_EXEC -r '.context_window.current_usage.input_tokens // 0')
else
    cwd=$(pwd | sed "s|$HOME|~|")
fi

# -----------------------------------------------------------------
# BUILD THEME COLORS
# -----------------------------------------------------------------
BOLD_BLACK=$'\033[30;1m'
BLUE=$'\033[0;34m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
PURPLE=$'\033[0;35m'
RED=$'\033[0;31m'
BOLD_GREEN=$'\033[32;1m'
ORANGE=$'\033[38;5;208m'
MAGENTA=$'\033[0;35m'
RESET=$'\033[0m'

time_str=$(date +%I:%M%p)

# Git Parsing (Mirrors your scm_prompt_info layout)
git_segment=""
if [ -d ".git" ] || git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    staged=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    unstaged=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
    
    detail=""
    [ "$staged" -gt 0 ] && detail="${detail} S:${staged}"
    [ "$unstaged" -gt 0 ] && detail="${detail} U:${unstaged}"
    [ "$untracked" -gt 0 ] && detail="${detail} ?:${untracked}"
    
    if [ "$staged" -gt 0 ] || [ "$unstaged" -gt 0 ] || [ "$untracked" -gt 0 ]; then
        state="${RED} ✗${RESET}"
    else
        state="${BOLD_GREEN} ✓${RESET}"
    fi
    git_segment="${BOLD_BLACK} |${GREEN}${branch}${detail}${state}${GREEN}|${RESET}"
fi

# Focused Prompt Left Segment (Just Time, Folder, and Git)
prompt_base="${BOLD_BLACK}[${BLUE}${time_str}${BOLD_BLACK}]-${BOLD_BLACK}[${PURPLE}${cwd}${BOLD_BLACK}]${git_segment}${RESET}"

# -----------------------------------------------------------------
# BUILD FUN CLAUDE METRICS
# -----------------------------------------------------------------
claude_components=()

if [ -n "$model" ] && [ "$model" != "null" ]; then
    model_short=$(echo "$model" | grep -oEi '(sonnet|haiku|opus|claude)' | head -n 1 | awk '{print toupper(substr($1,1,1)) tolower(substr($1,2))}')
    [ -z "$model_short" ] && model_short="Claude"
    claude_components+=("🤖 ${model_short}")
fi

if [ -n "$context_pct" ] && [ "$context_pct" != "null" ] && [ "$context_pct" -ne 0 ]; then
    if [ "$context_pct" -lt 35 ]; then c_color=$GREEN; txt="Fresh"
    elif [ "$context_pct" -lt 65 ]; then c_color=$YELLOW; txt="Growing"
    elif [ "$context_pct" -lt 85 ]; then c_color=$ORANGE; txt="Heavy"
    else c_color=$RED; txt="CRITICAL"; fi
    tokens_k_used=$(echo "scale=0; $tokens_used / 1000" | $BC_EXEC 2>/dev/null)
    tokens_k_total=$(echo "scale=0; $tokens_total / 1000" | $BC_EXEC 2>/dev/null)
    claude_components+=("${c_color}🧠 ${context_pct}% [${tokens_k_used}K/${tokens_k_total}K - ${txt}]${RESET}")
fi

# Cache hit rate = cache reads / total input tokens on the last turn.
input_total=$(( ${cache_read:-0} + ${cache_create:-0} + ${fresh_input:-0} ))
if [ "${cache_read:-0}" -gt 0 ] && [ "$input_total" -gt 0 ]; then
    cache_rate=$(echo "scale=0; (${cache_read} * 100) / ${input_total}" | $BC_EXEC 2>/dev/null)
    if [ "$cache_rate" -ge 70 ]; then cache_color=$GREEN; cache_txt="🔥 Warm"
    else cache_color=$YELLOW; cache_txt="⚡ Lukewarm"; fi
    claude_components+=("${cache_color}◎ Caching: ${cache_rate}% (${cache_txt})${RESET}")
else
    claude_components+=("${BOLD_BLACK}◎ Caching: 🧊 Cold${RESET}")
fi

if [ -n "$rate_limit_5h" ] && [ "$rate_limit_5h" != "null" ] && [ "$rate_limit_5h" != "" ]; then
    if [ "$rate_limit_5h" -gt 60 ]; then l_color=$GREEN
    elif [ "$rate_limit_5h" -gt 25 ]; then l_color=$YELLOW
    else l_color=$RED; fi
    if [ -n "$reset_time" ] && [ "$reset_time" != "null" ] && [ "$reset_time" -gt 0 ]; then
        claude_components+=("${l_color}⏳ Limit: ${rate_limit_5h}% (${reset_time}m remaining)${RESET}")
    else
        claude_components+=("${l_color}⏳ Limit: ${rate_limit_5h}%${RESET}")
    fi
fi

if [ "$cost" != "null" ] && [ -n "$cost" ] && [ "$(echo "$cost > 0" | $BC_EXEC)" -eq 1 ]; then
    cost_formatted=$(printf "%.2f" "$cost")
    claude_components+=("${BOLD_BLACK}💰 \$${cost_formatted}${RESET}")
fi

if [ -n "$vim_mode" ] && [ "$vim_mode" != "null" ] && [ "$vim_mode" != "disabled" ]; then
    claude_components+=("⌨️  ${vim_mode^^}")
fi

if [ -n "$pr_number" ] && [ "$pr_number" != "null" ]; then
    case "$pr_status" in
        "approved") pr_label="✅ Approved" ;;
        "changes_requested") pr_label="❌ Needs Fixes" ;;
        "review_requested") pr_label="👀 Reviewing" ;;
        "draft") pr_label="📝 Draft" ;;
        *) pr_label="Open" ;;
    esac
    claude_components+=("${MAGENTA}🔀 PR #${pr_number} [${pr_label}]${RESET}")
fi

if [ "$agent_active" = "true" ] || { [ -n "$agent_task" ] && [ "$agent_task" != "null" ] && [ "$agent_task" != "false" ]; }; then
    if [ -n "$last_tool" ] && [ "$last_tool" != "null" ]; then t_info="[Running: ${last_tool}]"
    elif [ -n "$agent_task" ] && [ "$agent_task" != "null" ]; then t_info="[${agent_task}]"
    else t_info="[Thinking...]"; fi
    claude_components+=("${YELLOW}${BOLD}🔧 Agent Active ${t_info}${RESET}")
fi

# Print layout
IFS="  •  " claude_line="${claude_components[*]}"
echo -e "${prompt_base}  •  ${claude_line}"

