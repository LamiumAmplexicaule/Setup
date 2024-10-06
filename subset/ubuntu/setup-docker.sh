#!/bin/bash
set -eu

# Install dependencies
echo "Install dependencies."
sudo apt-get -qq update >/dev/null
sudo apt-get -qq -y install ca-certificates curl gnupg2 >/dev/null

# Remove old
for pkg in docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add pgp key
sudo mkdir -m 0755 -p /etc/apt/keyrings >/dev/null
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc >/dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc >/dev/null

# Add repository
ARCH=$(dpkg --print-architecture)
VERSION_CODENAME=$(awk -F= '/^VERSION_CODENAME=/ {print $2}' /etc/os-release)
(echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list) > /dev/null

# Install docker
echo "Install docker."
sudo apt-get -qq update >/dev/null
sudo apt-get -qq -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null

# Start on boot 
sudo systemctl enable docker.service >/dev/null
sudo systemctl enable containerd.service >/dev/null

# NVIDIA Container Toolkit
GPU=$(lspci | grep VGA | cut -d ":" -f3)
if [[ $GPU == *NVIDIA* ]]; then
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    sudo apt-get -qq update >/dev/null
    sudo apt-get install -y nvidia-container-toolkit >/dev/null
    sudo nvidia-ctk runtime configure --runtime=docker >/dev/null
    sudo systemctl restart docker >/dev/null
fi
