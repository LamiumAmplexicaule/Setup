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
if [[ $GPU != *Advanced* ]]; then
    echo "Cannot find amd gpu."
    exit 1
fi

# Install dependencies
echo "Install dependencies."
sudo apt-get -qq update >/dev/null
sudo apt-get -qq -y install wget gnupg lsb-release >/dev/null

# Check version
OS_VERSION=$(lsb_release -rs)
KERNEL_VERSION=$(uname -r)
if [[ $OS_VERSION != 20.04 ]] && [[ $OS_VERSION != 18.04 ]]; then
    echo "Your os version is not supported."
    exit 1
elif [[ $KERNEL_VERSION != 5.4.* ]]; then
    echo "ROCm is only supported in 5.4 or 5.6-oem."
    exit 1
fi

# Remove old
if (apt-cache pkgnames | grep -e "rocm-dkms" >/dev/null) ; then
    sudo apt-get -qq -y remove rocm-opencl rocm-dkms rocm-dev rocm-utils >/dev/null
fi

# Install rocm
echo "Install rocm."
sudo apt-get -qq update >/dev/null
sudo apt-get -qq -y install libnuma-dev >/dev/null
(echo 'ADD_EXTRA_GROUPS=1' | sudo tee -a /etc/adduser.conf) >/dev/null
(echo 'EXTRA_GROUPS=video' | sudo tee -a /etc/adduser.conf) >/dev/null
(echo 'EXTRA_GROUPS=render' | sudo tee -a /etc/adduser.conf) >/dev/null
sudo usermod -aG video $(whoami) >/dev/null
sudo usermod -aG render $(whoami) >/dev/null
(wget -qO - https://repo.radeon.com/rocm/rocm.gpg.key | sudo apt-key add -) >/dev/null
(echo 'deb [arch=amd64] https://repo.radeon.com/rocm/apt/debian/ ubuntu main' | sudo tee /etc/apt/sources.list.d/rocm.list) >/dev/null
sudo apt-get -qq update >/dev/null
sudo apt-get -qq -y install rocm-dkms >/dev/null
