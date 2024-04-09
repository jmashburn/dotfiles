#!/bin/bash
# 
# Install AWSCli
#
# This install some of the common dependencies needed for using awscli
#
#
set -e
BIN_DIR="$HOME/.bin"

if [ ! -d $BIN_DIR ]; then
    mkdir -p $BIN_DIR
fi


if test ! $(which aws)
then
    cd $BIN_DIR

    echo "   Install awscli"

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        arch_output=$(uname -m)
        arch=""
            case $arch_output in

            x86_64)
            arch="x86_64"
            ;;

            aarch64)
            arch="aarch64"
            ;;

        esac

        echo "arch: " $arch

        awscli_url=$(echo "https://awscli.amazonaws.com/awscli-exe-linux-ARCH.zip" | sed "s/ARCH/$arch/" )
        echo "awscli url: $awscli_url"

        pwd
        # download
        curl -L $awscli_url -o awscliv2.zip

        # unzip
        unzip -qq awscliv2.zip -d aws_install

        # cleanup
        rm -f awscliv2.zip

        # Install
        $BIN_DIR/aws_install/aws/install --bin-dir $BIN_DIR --install-dir $BIN_DIR/aws-cli --update
    
        #cleanup
        rm -rf aws_install
        
        awscli_version=$(aws --version)

        echo "awscli version: " $awscli_version


    elif [[ "$OSTYPE" == "darwin"* ]]; then

        # Mac OSX
        awscli_url=$(echo "https://awscli.amazonaws.com/AWSCKUV2.pkg")
        echo "awscli url: $awscli_url"

        # download
        curl -s -L $awscli_url -o "AWSCLIV2.pkg"

    fi
fi
