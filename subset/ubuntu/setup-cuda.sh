#!/bin/bash
set -eu

SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE:-$0}")")
# shellcheck source=utils.sh
. "$SCRIPT_DIR/../../utils.sh"

SUPPORTED_VERSIONS=("18.04" "20.04" "22.04" "24.04")

# Check platform
OS=$(uname -s)
ARCH=$(uname -m)
if [[ $OS != Linux ]] || [[ $ARCH != x86_64 ]]; then
    echo "Your system is not supported."
    exit 1
fi

# Check gpu
GPU=$(lspci | grep VGA | cut -d ":" -f3)
if [[ $GPU != *NVIDIA* ]]; then
    echo "Cannot find nvidia gpu."
    exit 1
fi

# Install dependencies
echo "Install dependencies."
run_as_root apt-get -qq update >/dev/null
run_as_root apt-get -qq -y install wget >/dev/null

# Check version
OS_VERSION=$(sed -n 's/^VERSION_ID="\?\([^"]*\)"\?/\1/p' /etc/os-release)
if ! is_supported_version "$OS_VERSION" "${SUPPORTED_VERSIONS[@]}"; then
    echo "Your os version is not supported."
    exit 1
fi

# Remove old
result=0
# shellcheck disable=SC2034
output=$(dpkg -s "cuda" &>/dev/null) || result=$?
if [[ $result == 0 ]]; then
    run_as_root apt-get -qq -y remove cuda >/dev/null
    run_as_root rm -rf /usr/local/cuda*
fi

# Install cuda
case $OS_VERSION in
    24.04)
        wget -q -O cuda-keyring_all.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb >/dev/null
        ;;
    22.04)
        wget -q -O cuda-keyring_all.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb >/dev/null
        ;;
    20.04)
        wget -q -O cuda-keyring_all.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb >/dev/null
        ;;
    18.04)
        wget -q -O cuda-keyring_all.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-keyring_1.1-1_all.deb >/dev/null
        ;;
esac

run_as_root dpkg -i cuda-keyring_all.deb >/dev/null
run_as_root apt-get -qq update >/dev/null
run_as_root apt-get -qq -y install cuda
