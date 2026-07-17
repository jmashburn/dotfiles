#!/usr/bin/env bash
#
# Install or update GitHub CLI (gh) and diff-so-fancy
# macOS: via Homebrew
# Linux: via GitHub apt repo (Debian/Ubuntu) or binary download
#

set -euo pipefail

# --- GitHub CLI Installation Functions ---

install_macos() {
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Install it first: https://brew.sh" >&2
        exit 1
    fi
    
    # gh is part of Homebrew core; no external tap is required
    if brew list gh &>/dev/null 2>&1; then
        echo "> Upgrading GitHub gh via Homebrew"
        brew upgrade gh || true
    else
        echo "> Installing GitHub gh via Homebrew"
        brew install gh
    fi
}

install_linux_apt() {
    echo "> Installing GitHub CLI via official apt repo"
    
    # Download the official GitHub CLI keyring
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
    
    # Add the GitHub CLI repository to your apt sources list
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
    https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    
    # Update repository index and install the gh package
    sudo apt-get update -q
    sudo apt-get install -y gh
}

# --- Diff-So-Fancy Installation Function ---

install_diff_so_fancy() {
    # Ensure dependencies like jq are present before crawling the GitHub API
    if ! command -v jq &>/dev/null; then
        echo "> Installing jq dependency for diff-so-fancy version targeting..."
        if command -v brew &>/dev/null; then brew install jq; 
        elif command -v apt-get &>/dev/null; then sudo apt-get install -y jq; fi
    fi

    BIN_DIR="$HOME/.bin"
    # Safely source path variables if the file exists
    if [[ -f "${DOTFILES_ROOT:-}/git/path.bash" ]]; then
        source "$DOTFILES_ROOT/git/path.bash"
    fi

    if [[ ! -d "$BIN_DIR" ]]; then
        mkdir -p "$BIN_DIR"
    fi

    # Fetch latest version tag from GitHub Releases API
    VER=$(curl -s https://api.github.com/repos/so-fancy/diff-so-fancy/releases | jq -r '.[].tag_name' | sort -V | tail -n 1)
    
    # Choose optimal down-loader
    if [[ -x /usr/bin/wget ]]; then
        download_command="wget --quiet --output-document"
    else
        download_command="curl --location --output"
    fi

    # Check if correct version is already active
    if [[ -x "$BIN_DIR/diff-so-fancy" ]]; then
        CURRENT_VER="v$($BIN_DIR/diff-so-fancy --version | awk '{print $NF}')"
        if [[ "$CURRENT_VER" == "$VER" ]]; then
            echo "> diff-so-fancy ($VER) is up to date."
            return 0
        fi
    fi

    echo "Setup diff-so-fancy ($VER)..."
    rm -f "$BIN_DIR/diff-so-fancy"
    ${download_command} "$BIN_DIR/diff-so-fancy" "https://github.com/so-fancy/diff-so-fancy/releases/download/${VER}/diff-so-fancy"
    chmod 755 "$BIN_DIR/diff-so-fancy"
}

# ==========================================
# EXECUTION ROUTINE
# ==========================================

# 1. Manage GitHub CLI Installation Status
if command -v gh &>/dev/null; then
    echo "> GitHub CLI $(gh --version | head -1) already installed"
    
    if command -v brew &>/dev/null && brew list gh &>/dev/null 2>&1; then
        echo "> Upgrading via Homebrew"
        brew upgrade gh || true
    elif command -v apt-get &>/dev/null && apt-cache show gh &>/dev/null 2>&1; then
        sudo apt-get install -y --only-upgrade gh
    else
        echo "> Update manually: https://github.com"
    fi
else
    # Run targeted installer based on OS engine matching
    case "$(uname -s)" in
        Darwin)
            install_macos
            ;;
        Linux)
            if command -v apt-get &>/dev/null; then
                install_linux_apt
            else
                echo "Unsupported Linux distro — install manually: https://github.com" >&2
                exit 1
            fi
            ;;
        *)
            echo "Unsupported OS: $(uname -s)" >&2
            exit 1
            ;;
    esac
    echo "> $(gh --version | head -1) installed successfully"
fi

# 2. Run standalone diff-so-fancy setup
install_diff_so_fancy

