#!/bin/bash
set -eu

name=$(uname -s)
SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE:-$0}")")

if [[ $name == 'Darwin' ]]; then
    echo 'Setup for macOS.'
    bash "$SCRIPT_DIR/setup-mac.sh"
elif [[ $name == 'Linux' ]]; then
    if [[ -f /etc/lsb-release ]]; then 
        echo 'Setup for Ubuntu.'
        bash "$SCRIPT_DIR/setup-ubuntu.sh"
    else
        echo 'Not supported.'
    fi
else
    echo 'Not supported.'
fi
