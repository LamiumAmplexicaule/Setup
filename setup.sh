#!/bin/bash
set -eu

name=$(uname -s)
SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE:-$0}")")

if [[ $name == 'Darwin' ]]; then
    echo 'Setup for macOS.'
    bash "$SCRIPT_DIR/setup-mac.sh"
elif [[ $name == 'Linux' ]]; then
    os_id="$(sed -n 's/^ID="\?\([^"]*\)"\?/\1/p' /etc/os-release)"
    if [[ "$os_id" == ubuntu ]]; then
        echo 'Setup for Ubuntu.'
        bash "$SCRIPT_DIR/setup-ubuntu.sh"
    else
        echo 'Not supported.'
    fi
else
    echo 'Not supported.'
fi
