#!/bin/bash
set -eu

is_supported_version() {
    local OS_VERSION=$1
    shift
    local SUPPORTED_VERSIONS=("$@")
    for supported in "${SUPPORTED_VERSIONS[@]}"; do
        if [[ $supported == "$OS_VERSION" ]]; then
            return 0
        fi
    done
    return 1
}