#!/bin/bash
set -eu

run_as_root() {
    if [ -z "$1" ]; then
        return 1
    fi
    if [[ "${EUID:-0}" == 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

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

version_lte() {
    printf "%s\n%s" "$1" "$2" | sort -C -V
}

version_gte() {
    printf "%s\n%s" "$2" "$1" | sort -C -V
}

version_lt() {
    ! version_lte "$2" "$1"
}

version_gt() {
    ! version_gte "$2" "$1"
}
