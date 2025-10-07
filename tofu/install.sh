#!/bin/bash
#
# OpenTofu
#
# This in/kciontalls some of the command dependencies for tofu
#
#

# Check for tofu
BIN_DIR="$HOME/.bin"
source $DOTFILES_ROOT/tofu/path.bash


if [[ ! -d $BIN_DIR ]]
then
    mkdir $BIN_DIR
fi

if test ! $(which tofu)
then
    echo "   Installing tofu"
    cd $BIN_DIR

    bash -c -- "$(curl -fsSL https://get.opentofu.org/install-opentofu.sh)" -- --install-method standalone --install-path $BIN_DIR/opentofu --symlink-path -

fi
exit 0
