#!/bin/bash
set -eu

# Check platform
OS=$(uname -s)
ARCH=$(uname -m)
if [[ $OS != Linux ]] || [[ $ARCH != x86_64 ]]; then
    echo "Your system is not supported."
    exit 1
fi

# Install dependencies
echo "Install dependencies."
sudo apt-get -qq update >/dev/null
sudo apt-get -qq -y install wget lsb-release >/dev/null

# Check version
OS_VERSION=$(lsb_release -rs)
if [[ $OS_VERSION != 22.04 ]] && [[ $OS_VERSION != 20.04 ]] && [[ $OS_VERSION != 18.04 ]]; then
    echo "Your os version is not supported."
    exit 1
fi

case $OS_VERSION in 
    20.04)
        sudo apt-get -qq update >/dev/null
        sudo apt-get -qq -y install cmake gcc g++ g++-10 >/dev/null
        sudo apt-get -qq -y install file >/dev/null
        ;;
    *)
        sudo apt-get -qq update >/dev/null
        sudo apt-get -qq -y install cmake gcc g++ >/dev/null
        sudo apt-get -qq -y install file >/dev/null
        ;;
esac

MOLD_VERSION=$(curl -s https://api.github.com/repos/rui314/mold/releases/latest | jq .tag_name | grep -oE "v([0-9])+\.([0-9])+\.([0-9])+")
echo "Mold version: ${MOLD_VERSION}"

# Install mold
echo "Install mold."
rm -rf mold
git clone -q https://github.com/rui314/mold.git >/dev/null
rm -rf mold/build >/dev/null
mkdir -p mold/build >/dev/null
cd mold/build
git checkout -q -b "$MOLD_VERSION" >/dev/null
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=c++ .. >/dev/null
cmake --build . -j $(($(nproc) - 1)) >/dev/null
sudo cmake --install .
