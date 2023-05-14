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
sudo apt-get -qq -y install wget gnupg2 gawk curl >/dev/null

# Check version
OS_VERSION=$(lsb_release -rs)
if [[ $OS_VERSION != 22.04 ]] && [[ $OS_VERSION != 20.04 ]]; then
    echo "Your os version is not supported."
    exit 1
fi

# Remove old
result=0
output=$(dpkg -s 'rocm-core' &>/dev/null) || result=$?
if [[ $result == 0 ]]; then
    sudo apt autoremove rocm-core >/dev/null
fi

# Install rocm
echo "Install rocm."
(echo 'ADD_EXTRA_GROUPS=1' | sudo tee -a /etc/adduser.conf) >/dev/null
(echo 'EXTRA_GROUPS=render' | sudo tee -a /etc/adduser.conf) >/dev/null
sudo usermod -aG render "$LOGNAME" >/dev/null
(echo 'EXTRA_GROUPS=video' | sudo tee -a /etc/adduser.conf) >/dev/null
sudo usermod -aG video "$LOGNAME" >/dev/null
curl -fsSL https://repo.radeon.com/rocm/rocm.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/rocm-keyring.gpg
CODE_NAME=$(lsb_release -cs)
(echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/rocm-keyring.gpg] https://repo.radeon.com/amdgpu/latest/ubuntu $CODE_NAME main" | sudo tee /etc/apt/sources.list.d/amdgpu.list) >/dev/null
sudo apt-get -qq update >/dev/null
sudo apt-get -qq install amdgpu-dkms
(echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/rocm-keyring.gpg] https://repo.radeon.com/rocm/apt/debian/ $CODE_NAME main" | sudo tee /etc/apt/sources.list.d/rocm.list) >/dev/null
(echo -e 'Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600' | sudo tee /etc/apt/preferences.d/rocm-pin-600) >/dev/null
sudo apt-get -qq update >/dev/null
sudo apt-get -qq install rocm-dkms >/dev/null
