#!/bin/bash -e

# This script installs or updates to the latest version of Go.
# Multi-platform (Linux and macOS)
# Multi-architecture (amd64, arm64, arm) support
#
# Add to your .profile, .bash_profile or .zshenv:
# export PATH=$PATH:/usr/local/go/bin


BIN_DIR="$HOME/.local/"
source $DOTFILES_ROOT/go/path.bash

if [[ ! -d $BIN_DIR ]]
then
    mkdir $BIN_DIR
fi


deps=( curl jq )
unset bail
for i in "${deps[@]}"; do command -v "$i" >/dev/null 2>&1 || { bail="$?"; echo "$i" is not available; }; done
if [ "$bail" ]; then exit "$bail"; fi

version="$(curl -s 'https://go.dev/dl/?mode=json' | jq -r '.[0].version')"
current="$(${HOME}/.local/go/bin/go version 2>/dev/null | awk '{print $3}')"
if [[ "$current" == "$version" ]]; then
  echo "Go is already up-to-date at version ${version}"
  exit 0
fi

update_go() {
  local arch="$1"
  local os="$2"

  local go_url="https://golang.org/dl/${version}.${os}-${arch}.tar.gz"

  curl -so "/tmp/${version}.${os}-${arch}.tar.gz" -L "$go_url" && \
    rm -rf $HOME/.local/go && tar -C $HOME/.local -xzf /tmp/${version}.${os}-${arch}.tar.gz

  tar -C $HOME/.local/ -xzf "/tmp/${version}.${os}-${arch}.tar.gz" && \
    echo "Go updated to version ${version}"

  rm "/tmp/${version}.${os}-${arch}.tar.gz"
}

case "$(uname -s)" in
  Linux)
    case "$(uname -m)" in
      armv6l|armv7l)
        update_go "armv6l" "linux"
        ;;
      arm64)
        update_go "arm64" "linux"
        ;;
      x86_64)
        update_go "amd64" "linux"
        ;;
      *)
        echo "Unsupported architecture: $(uname -m)" >&2
        exit 1
        ;;
    esac
    ;;
  Darwin)
    case "$(uname -m)" in
      arm64)
        update_go "arm64" "darwin"
        ;;
      x86_64)
        update_go "amd64" "darwin"
        ;;
      *)
        echo "Unsupported architecture: $(uname -m)" >&2
        exit 1
        ;;
    esac
    ;;
  *)
    echo "Unsupported operating system: $(uname -s)" >&2
    exit 1
    ;;
esac

$HOME/.local/go/bin/go version
