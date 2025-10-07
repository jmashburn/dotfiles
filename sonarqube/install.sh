#!/bin/bash
# 
# Install AWSCli
#
# This install some of the common dependencies needed for using awscli
#
#
set -e
BIN_DIR="$HOME/.bin"
source $DOTFILES_ROOT/sonarqube/path.bash

if [ ! -d $BIN_DIR ]; then
    mkdir -p $BIN_DIR
fi

VER=6.1.0.4477
[[ -x /usr/bin/wget ]]&& download_command="wget --quiet --show-progress --output-document" || download_command="curl --location --output"
[[ -x ${BIN_DIR}/sonar-scanner ]]&& [[ "x$(${BIN_DIR}/sonar-scanner --version | grep 'SonarScanner' | awk '{print $NF}')" == "x${VER}" ]]&& exit 0
echo -n "Downloading sonar-scanner-cli-$VER-linux-"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    arch_output=$(uname -m)
    arch=""
    case $arch_output in

        x86_64)
            arch="x64"
            ;;

        aarch64)
            arch="aarch64"
            ;;
    esac

    echo -e $arch

    mkdir -p "${BIN_DIR}/sonar-scanner-cli/"

    ${download_command} ${BIN_DIR}/sonar-scanner-cli/sonar-scanner-cli-${VER}-linux-${arch}.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${VER}-linux-${arch}.zip

    unzip -oqq "${BIN_DIR}/sonar-scanner-cli/sonar-scanner-cli-${VER}-linux-${arch}.zip" -d "${BIN_DIR}/sonar-scanner-cli/"
    rm "/${BIN_DIR}/sonar-scanner-cli/sonar-scanner-cli-${VER}-linux-${arch}.zip"
    
    ln -s ${BIN_DIR}/sonar-scanner-cli/sonar-scanner-cli-${VER}-linux-${arch}/ ${BIN_DIR}/sonar-scanner-cli/current
fi
