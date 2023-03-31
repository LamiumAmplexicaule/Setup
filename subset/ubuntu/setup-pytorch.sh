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
sudo apt-get -qq -y install python3-pip >/dev/null
pip3 install -U pip

GPU=$(lspci | grep VGA | cut -d ":" -f3)

echo "Install PyTorch."
if [[ $GPU == *NVIDIA* ]]; then
    CUDA_VERSION=$(nvcc --version | grep release | cut -d ' ' -f 5 | tr -d ',')
    case $CUDA_VERSION in
        10.[012]* ) pip install torch==1.12.1+cu102 torchvision==0.13.1+cu102 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu102 ;;
        11.[0123]* ) pip install torch==1.12.1+cu113 torchvision==0.13.1+cu113 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu113 ;;
        11.[456]* ) pip install torch==1.13.1+cu116 torchvision==0.14.1+cu116 torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cu116 ;;
        11.8 ) pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 ;;
        * ) pip3 install torch torchvision torchaudio ;;
    esac
elif [[ $GPU == *Advanced* ]]; then
    pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/rocm5.4.2
else
    pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu
fi

