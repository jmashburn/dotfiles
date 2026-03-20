#!/usr/bin/env bash
#
# Description: Install kconnect for Kubernetes
# Dependencies: curl
#

set -euo pipefail

#
# KConnect
#
# This installs some of the command dependencies for kconnect
#
#

# Check for kconnect
BIN_DIR="$HOME/.bin"
source $DOTFILES_ROOT/kconnect/path.bash


if [[ ! -d $BIN_DIR ]]
then
    mkdir $BIN_DIR
fi

if test ! $(which kconnect)
then
    echo "   Installing kConnect"
    cd $BIN_DIR

    bash -c "$(curl -fsSL https://raw.githubusercontent.com/fidelity/kconnect/main/scripts/install-kconnect.sh)"

fi
exit 0
