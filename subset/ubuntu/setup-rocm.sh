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
sudo apt-get -qq -y install wget gnupg2 >/dev/null

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
result=0
output=$(dpkg -s | grep -e "amdgpu-dkms" >/dev/null) || result=$?
if [[ $result == 0 ]]; then
    sudo amdgpu-uninstall >/dev/null
fi

# Install rocm
echo "Install rocm."
sudo apt-get -qq update >/dev/null
(echo 'ADD_EXTRA_GROUPS=1' | sudo tee -a /etc/adduser.conf) >/dev/null
(echo 'EXTRA_GROUPS=video' | sudo tee -a /etc/adduser.conf) >/dev/null
(echo 'EXTRA_GROUPS=render' | sudo tee -a /etc/adduser.conf) >/dev/null
sudo usermod -aG video "$LOGNAME" >/dev/null
sudo usermod -aG render "$LOGNAME" >/dev/null
wget -qO amdgpu-install_all.deb https://repo.radeon.com/amdgpu-install/22.20.3/ubuntu/bionic/amdgpu-install_22.20.50203-1_all.deb >/dev/null
sudo apt-get install ./amdgpu-install_all.deb >/dev/null
sudo apt-get -qq update >/dev/null
sudo amdgpu-install --usecase=rocm
