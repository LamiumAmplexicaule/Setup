#!/bin/bash
set -eu

# Install dependencies
echo "Install dependencies."
sudo apt-get -qq update >/dev/null
sudo apt-get -qq -y install apt-transport-https ca-certificates curl gnupg lsb-release >/dev/null

# Remove old
result=0
output=$(dpkg -s | grep -e "docker" >/dev/null) || result=$?
if [[ $result == 0 ]]; then
    ssudo apt-get -qq -y purge docker-ce docker-ce-cli containerd.io >/dev/null
fi

# Add pgp key
(curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg) >/dev/null

# Add repository
(echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list) > /dev/null

# Install docker
echo "Install docker."
sudo apt-get -qq update >/dev/null
sudo apt-get -qq -y install docker-ce docker-ce-cli containerd.io >/dev/null
