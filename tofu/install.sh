#!/usr/bin/env bash
#
# Install OpenTofu (open-source Terraform alternative)
# macOS: via Homebrew
# Linux: via official install script (standalone)
#

set -euo pipefail

install_macos() {
  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Install it first: https://brew.sh" >&2
    exit 1
  fi

  if brew list opentofu &>/dev/null; then
    echo "> Upgrading OpenTofu via Homebrew"
    brew upgrade opentofu || true
  else
    echo "> Installing OpenTofu via Homebrew"
    brew install opentofu
  fi
}

install_linux() {
  local bin_dir="${HOME}/.bin"
  local install_dir="${bin_dir}/opentofu"

  mkdir -p "${bin_dir}"

  echo "> Installing OpenTofu to ${install_dir}"
  bash -c -- "$(curl -fsSL https://get.opentofu.org/install-opentofu.sh)" -- \
    --install-method standalone \
    --install-path "${install_dir}" \
    --symlink-path -
}

if command -v tofu &>/dev/null; then
  echo "> OpenTofu $(tofu version | head -1) already installed"
  exit 0
fi

case "$(uname -s)" in
  Darwin) install_macos ;;
  Linux)  install_linux ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

echo "> $(tofu version | head -1) installed"
