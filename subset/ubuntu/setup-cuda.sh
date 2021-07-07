#!/bin/bash
set -eu

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
sudo apt-get -qq update >/dev/null
sudo apt-get -qq -y install wget lsb-release >/dev/null

# Check version
OS_VERSION=$(lsb_release -rs)
if [[ $OS_VERSION != 20.04 ]] && [[ $OS_VERSION != 18.04 ]]; then
    echo "Your os version is not supported."
    exit 1
fi

# Remove old
sudo apt-get -qq -y autoremove cuda >/dev/null
sudo rm -rf /usr/local/cuda*

# Install cuda
case $OS_VERSION in 
    20.04)
        wget -q https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
        sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
        sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub >/dev/null
        sudo add-apt-repository -y "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" >/dev/null
        ;;
    18.04)
        wget -q https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin
        sudo mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600
        sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub >/dev/null
        sudo add-apt-repository -y "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/ /" >/dev/null
        ;;
esac

sudo apt-get -qq update >/dev/null
sudo apt-get -qq -y install cuda >/dev/null