#!/usr/bin/env bash
#
# Install pass dependencies: gnupg, oath-toolkit (for OTP), and tree
#

set -euo pipefail

install_macos() {
  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Install it first: https://brew.sh" >&2
    exit 1
  fi

  for pkg in gnupg oath-toolkit tree; do
    if brew list "$pkg" &>/dev/null 2>&1; then
      echo "> $pkg already installed"
    else
      echo "> Installing $pkg"
      brew install "$pkg"
    fi
  done
}

install_linux() {
  echo "> Installing pass dependencies via apt"
  sudo apt-get update -q
  sudo apt-get install -y gnupg oathtool tree
}

case "$(uname -s)" in
  Darwin) install_macos ;;
  Linux)
    if command -v apt-get &>/dev/null; then
      install_linux
    else
      echo "Install manually: gnupg, oathtool, tree" >&2
      exit 1
    fi
    ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

echo "> Dependencies installed. Pass is ready at:"
echo "  ${DOTFILES_ROOT}/vendor/github.com/jmashburn/pass/pass"

# Disable conventional commits check for the password store
# (pass auto-generates commit messages that don't follow that format)
if [[ -d "${HOME}/.password-store/.git" ]]; then
  git -C "${HOME}/.password-store" config hooks.conventionalcommits false
  echo "> Disabled conventional commits hook for password store"
fi
