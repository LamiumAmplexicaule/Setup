#!/bin/bash
set -eu

# Install dependencies
echo "Install dependencies."
sudo apt-get -qq update >/dev/null
sudo apt-get -qq -y install ca-certificates curl gnupg lsb-release >/dev/null

# Remove old
result=0
output=$(dpkg -s "docker" &>/dev/null) || result=$?
if [[ $result == 0 ]]; then
    sudo apt-get -qq -y purge docker-ce docker-ce-cli containerd.io >/dev/null
fi

# Add pgp key
sudo mkdir -m 0755 -p /etc/apt/keyrings >/dev/null
(curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg) >/dev/null
sudo chmod a+r /etc/apt/keyrings/docker.gpg >/dev/null

# Add repository
(echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list) > /dev/null

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
    distribution=$(. /etc/os-release;echo "$ID$VERSION_ID") \
          && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
          && curl -s -L "https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list" | \
                sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
                sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    sudo apt-get -qq update >/dev/null
    sudo apt-get install -y nvidia-container-toolkit >/dev/null
    sudo nvidia-ctk runtime configure --runtime=docker >/dev/null
    sudo systemctl restart docker >/dev/null
fi
