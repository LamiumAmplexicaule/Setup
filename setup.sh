#!/bin/bash
set -eu

name=$(uname -s)

if [[ $name == 'Darwin' ]]; then
    echo 'Setup for macOS.'
    bash ./setup-mac.sh
elif [[ $(echo "$name" | cut -c 1-5) == 'Linux' ]]; then
    if [[ -f /etc/lsb-release ]]; then 
        echo 'Setup for Ubuntu.'
        bash ./setup-ubuntu.sh
    else
        echo 'Not supported.'
    fi
else
    echo 'Not supported.'
fi
