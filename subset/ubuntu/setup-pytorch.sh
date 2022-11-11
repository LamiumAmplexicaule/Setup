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
    CUDA_10_2=10.2
    CUDA_11_3=11.3
    CUDA_11_6=11.6
    CUDA_11_7=11.7
    if [[ $(printf "%s\n%s" "$CUDA_10_2" "$CUDA_VERSION" | sort -V | head -n 1) == $CUDA_10_2 ]]; then
        if [[ $(printf "%s\n%s" "$CUDA_11_3" "$CUDA_VERSION" | sort -V | head -n 1) == $CUDA_11_3 ]]; then
            if [[ $(printf "%s\n%s" "$CUDA_11_6" "$CUDA_VERSION" | sort -V | head -n 1) == $CUDA_11_6 ]]; then
                if [[ $(printf "%s\n%s" "$CUDA_11_7" "$CUDA_VERSION" | sort -V | head -n 1) == $CUDA_11_7 ]]; then
                    # 11.7 <= v
                    pip3 install torch torchvision torchaudio
                    exit;
                fi
                # 11.6 <= v < 11.7
                pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu116
                exit;
            fi
            # 11.3 <= v < 11.6
            pip3 install torch==1.12.1+cu113 torchvision==0.13.1+cu113 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu113
            exit;
        fi
        # 10.2 <= v < 11.3
        pip3 install torch==1.12.1+cu102 torchvision==0.13.1+cu102 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu102
    else
        # v < 10.2
        pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu
    fi
elif [[ $GPU == *Advanced* ]]; then
    pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/rocm5.2
else
    pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu
fi

