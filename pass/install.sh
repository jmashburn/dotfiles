#!/bin/bash
#
# Pass the standard unix password manage
#
#

# Check for pass
BIN_DIR="$HOME/.dotfiles/vendor/pass"

if [[ ! -d $BIN_DIR ]]
then
    mkdir $BIN_DIR
fi

if test ! $(which pass)
then
    echo "   Installing Pass "

fi
exit 0
