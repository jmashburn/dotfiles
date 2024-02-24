#!/bin/bash
#
# dot
#
# `dot` handles installation, updates.  Run it to make sure youre update to the latest
#

set -e 

parentDirectory="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P)"
dotfilesDirectory="$(cd "$( dirname "$parentDirectory" )" && pwd -P)"

echo "> script/bootstrap"
$dotfilesDirectory/script/bootstrap -B