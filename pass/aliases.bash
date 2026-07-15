# shellcheck shell=bash
# pass — password store aliases and helpers

# ── Core shortcuts ────────────────────────────────────────────────────────────
alias pc='pass -c'          # copy to clipboard
alias pi='pass insert'      # insert new entry
alias pe='pass edit'        # edit existing entry
alias prm='pass rm'         # remove entry
alias pmv='pass mv'         # rename / move entry
alias pcp='pass cp'         # copy entry
alias pls='pass ls'         # list entries
alias pfind='pass find'     # search by name
alias pgrep='pass grep'     # search by content
alias pgit='pass git'       # git operations on the store

# ── Extension shortcuts ───────────────────────────────────────────────────────
alias potp='pass otp'       # 2FA / TOTP codes
alias penv='pass env'       # export secrets as env vars
alias pflat='pass flat'     # flat sorted list (great for grepping)
alias page='pass age'       # show entry ages from git log
alias pgen='pass gen'       # generate password via sysbox

# ── Functions ─────────────────────────────────────────────────────────────────

# Copy only the first line (the password itself, skipping metadata)
pcc() {
  local entry="${1:?Usage: pcc <entry>}"
  pass "$entry" | head -1 | tr -d '\n' | pbcopy
  echo "Copied ${entry} to clipboard."
}

# cd into the password store directory
pcd() {
  cd "${PASSWORD_STORE_DIR:-${HOME}/.password-store}"
}

# Fuzzy find an entry with fzf and copy it to clipboard
pf() {
  if ! command -v fzf &>/dev/null; then
    echo "pf: fzf is required" >&2; return 1
  fi
  local entry
  entry=$(pass flat 2>/dev/null | fzf --height=20 --reverse --prompt="pass > " --exit-0)
  [[ -n "$entry" ]] && pass -c "$entry"
}
