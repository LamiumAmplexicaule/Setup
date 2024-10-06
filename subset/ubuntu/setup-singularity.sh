#!/bin/bash
set -eu

OS=$(uname -s)
ARCH=$(uname -m)
if [[ $OS != Linux ]] || [[ $ARCH != x86_64 ]]; then
    echo "Your system is not supported."
    exit 1
fi

# Remove old
sudo rm -rf /usr/local/libexec/singularity /usr/local/var/singularity /usr/local/etc/singularity /usr/local/bin/singularity /usr/local/bin/run-singularity /usr/local/etc/bash_completion.d/singularity
sudo rm -rf /usr/local/go

# Definitions
sudo apt-get -qq update >/dev/null
sudo apt-get -qq -y install jq >/dev/null
SINGULARITY_VERSION=$(curl -s https://api.github.com/repos/sylabs/singularity/releases/latest | jq .tag_name | grep -oE "([0-9])+\.([0-9])+\.([0-9])+")
GO_VERSION=1.22.6
echo "Singularity version: ${SINGULARITY_VERSION}"
echo "Go version: ${GO_VERSION}"

# Install dependencies
echo "Install dependencies."
sudo apt-get -qq update >/dev/null
sudo apt-get -qq -y install autoconf automake cryptsetup fuse fuse2fs git libfuse-dev libglib2.0-dev libseccomp-dev libtool pkg-config runc squashfs-tools squashfs-tools-ng uidmap wget zlib1g-dev >/dev/null

# Install go
echo "Install go."
wget -qO go.tar.gz https://dl.google.com/go/go$GO_VERSION.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go.tar.gz
rm -f go.tar.gz
export PATH="/usr/local/go/bin:${PATH}"

# Install singularity
echo "Install singularity."
wget -qO singularity-ce.tar.gz https://github.com/sylabs/singularity/releases/download/v"${SINGULARITY_VERSION}"/singularity-ce-"${SINGULARITY_VERSION}".tar.gz
mkdir -p singularity-ce && tar -xzf singularity-ce.tar.gz -C singularity-ce --strip-components 1
cd singularity-ce
./mconfig >/dev/null
make -C ./builddir >/dev/null
sudo make -C ./builddir install >/dev/null
cd .. && rm -rf singularity-ce && rm -f singularity-ce.tar.gz
