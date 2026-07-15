#!/usr/bin/env bash
#
# Install or update Go
# macOS: via Homebrew
# Linux: via official binary from go.dev
#

set -euo pipefail

install_macos() {
  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Install it first: https://brew.sh" >&2
    exit 1
  fi

  if brew list go &>/dev/null; then
    echo "> Upgrading Go via Homebrew"
    brew upgrade go || true  # 'already up-to-date' exits non-zero
  else
    echo "> Installing Go via Homebrew"
    brew install go
  fi
}

install_linux() {
  if ! command -v curl &>/dev/null || ! command -v jq &>/dev/null; then
    echo "curl and jq are required for Linux Go install" >&2
    exit 1
  fi

  local version
  version="$(curl -fsSL 'https://go.dev/dl/?mode=json' | jq -r '.[0].version')"

  local current
  current="$(/usr/local/go/bin/go version 2>/dev/null | awk '{print $3}' || true)"

  if [[ "$current" == "$version" ]]; then
    echo "Go is already up-to-date at $version"
    return
  fi

  local arch
  case "$(uname -m)" in
    x86_64)        arch="amd64" ;;
    arm64|aarch64) arch="arm64" ;;
    armv6l|armv7l) arch="armv6l" ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
  esac

  local tarball="/tmp/${version}.linux-${arch}.tar.gz"
  echo "> Downloading $version for linux/$arch"
  curl -fsSL "https://golang.org/dl/${version}.linux-${arch}.tar.gz" -o "$tarball"

  echo "> Installing to /usr/local/go"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "$tarball"
  rm "$tarball"

  echo "> Go $version installed"
  /usr/local/go/bin/go version
}

case "$(uname -s)" in
  Darwin) install_macos ;;
  Linux)  install_linux ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac
