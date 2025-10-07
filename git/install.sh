#!/bin/bash
#
# Diff-so-fancy
#
# This installs some of the command dependencies for diff-so-fancy
#
#

# Check for diff-so-fancy
BIN_DIR="$HOME/.bin"
source $DOTFILES_ROOT/git/path.bash


if [[ ! -d $BIN_DIR ]]
then
    mkdir $BIN_DIR
fi

VER=$(curl https://api.github.com/repos/so-fancy/diff-so-fancy/releases -s | jq -r .[].tag_name | sort -nr | head -n 1)

[[ -x /usr/bin/wget ]]&& download_command="wget --quiet --output-document"  || download_command="curl --location --output"
[[ -x $BIN_DIR/diff-so-fancy ]] && exit 0
#&& [[ "x$($BIN_DIR/diff-so-fancy --version | awk '{print $NF}')" == "xv${VER}" ]]&& return 0
echo "Setup diff-so-fancy..."
rm -f $BIN_DIR/diff-so-fancy
${download_command} $BIN_DIR/diff-so-fancy https://github.com/so-fancy/diff-so-fancy/releases/download/${VER}/diff-so-fancy
chmod 755 $BIN_DIR/diff-so-fancy
