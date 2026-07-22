#!/usr/bin/env bash
#
# Install GnuPG and a pinentry program, then harden ~/.gnupg permissions
# and reload the agent so gpg.conf / gpg-agent.conf take effect.
#

set -euo pipefail

install_macos() {
  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Install it first: https://brew.sh" >&2
    exit 1
  fi

  for pkg in gnupg pinentry-mac; do
    if brew list "$pkg" &>/dev/null 2>&1; then
      echo "> $pkg already installed"
    else
      echo "> Installing $pkg"
      brew install "$pkg"
    fi
  done
}

install_linux() {
  echo "> Installing GnuPG and pinentry via apt"
  sudo apt-get update -q
  sudo apt-get install -y gnupg pinentry-curses
}

case "$(uname -s)" in
  Darwin) install_macos ;;
  Linux)
    if command -v apt-get &>/dev/null; then
      install_linux
    else
      echo "Install manually: gnupg, pinentry" >&2
      exit 1
    fi
    ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

# GnuPG refuses to use a home directory with loose permissions.
if [[ -d "${HOME}/.gnupg" ]]; then
  chmod 700 "${HOME}/.gnupg"
  echo "> Set ~/.gnupg to mode 700"
fi

# Pick up the symlinked config without waiting for the next login.
if command -v gpgconf &>/dev/null; then
  gpgconf --reload gpg-agent 2>/dev/null || true
  echo "> Reloaded gpg-agent"
fi

echo "> GnuPG configured. Verify with: gpg --list-secret-keys --keyid-format=long"
