#!/usr/bin/env bash
#
# Install or update HashiCorp Vault CLI
# macOS: via Homebrew
# Linux: via HashiCorp apt repo (Debian/Ubuntu) or binary download
#

set -euo pipefail

install_macos() {
  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Install it first: https://brew.sh" >&2
    exit 1
  fi

  # Vault is in the hashicorp tap
  brew tap hashicorp/tap 2>/dev/null || true

  if brew list hashicorp/tap/vault &>/dev/null 2>&1; then
    echo "> Upgrading Vault via Homebrew"
    brew upgrade hashicorp/tap/vault || true
  else
    echo "> Installing Vault via Homebrew"
    brew install hashicorp/tap/vault
  fi
}

install_linux_apt() {
  echo "> Installing Vault via HashiCorp apt repo"
  curl -fsSL https://apt.releases.hashicorp.com/gpg \
    | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt-get update -q
  sudo apt-get install -y vault
}

if command -v vault &>/dev/null; then
  echo "> Vault $(vault version | head -1) already installed"

  # Update via the appropriate package manager
  if command -v brew &>/dev/null && brew list hashicorp/tap/vault &>/dev/null 2>&1; then
    echo "> Upgrading via Homebrew"
    brew upgrade hashicorp/tap/vault || true
  elif command -v apt-get &>/dev/null && apt-cache show vault &>/dev/null 2>&1; then
    sudo apt-get install -y --only-upgrade vault
  else
    echo "> Update manually: https://developer.hashicorp.com/vault/downloads"
  fi

  echo "> $(vault version | head -1)"
  exit 0
fi

case "$(uname -s)" in
  Darwin) install_macos ;;
  Linux)
    if command -v apt-get &>/dev/null; then
      install_linux_apt
    else
      echo "Unsupported Linux distro — install manually: https://developer.hashicorp.com/vault/downloads" >&2
      exit 1
    fi
    ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

echo "> $(vault version | head -1) installed"
