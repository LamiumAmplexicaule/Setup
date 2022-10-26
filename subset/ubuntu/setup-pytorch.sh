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

GPU=$(lspci | grep VGA | cut -d ":" -f3)

echo "Install PyTorch."
if [[ $GPU == *NVIDIA* ]]; then
    CUDA_VERSION=$(nvcc --version | grep release | cut -d ' ' -f 5 | tr -d ',')
    CUDA_10_2=10.2
    CUDA_11_3=11.3
    CUDA_11_6=11.6
    if [[ $(printf "$CUDA_10_2\n$CUDA_VERSION" | sort -V | head -n 1) == $CUDA_10_2 ]]; then
        if [[ $(printf "$CUDA_11_3\n$CUDA_VERSION" | sort -V | head -n 1) == $CUDA_11_3 ]]; then
            if [[ $(printf "$CUDA_11_6\n$CUDA_VERSION" | sort -V | head -n 1) == $CUDA_11_6 ]]; then
                # 11.6 <= v
                pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu116
                exit;
            fi
            # 11.3 <= v < 11.6
            pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113
            exit;
        fi
        # 10.2 <= v < 11.3
        pip3 install torch torchvision torchaudio
    else
        # v < 10.2
        pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu
    fi
elif [[ $GPU == *Advanced* ]]; then
    pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/rocm5.1.1
else
    pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu
fi

