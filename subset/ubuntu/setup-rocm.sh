#!/bin/bash
set -eu

SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE:-$0}")")
# shellcheck source=utils.sh
. "$SCRIPT_DIR/../../utils.sh"

SUPPORTED_VERSIONS=("20.04" "22.04" "24.04")

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
run_as_root apt-get -qq update >/dev/null
run_as_root apt-get -qq -y install wget gnupg2 >/dev/null

# Check version
OS_VERSION=$(sed -n 's/^VERSION_ID="\?\([^"]*\)"\?/\1/p' /etc/os-release)
if ! is_supported_version "$OS_VERSION" "${SUPPORTED_VERSIONS[@]}"; then
    echo "Your os version is not supported."
    exit 1
fi

# Remove old
result=0
# shellcheck disable=SC2034
output=$(dpkg -s 'rocm-core' &>/dev/null) || result=$?
if [[ $result == 0 ]]; then
    run_as_root apt autoremove rocm >/dev/null
fi

# Install rocm
echo "Install rocm."
(echo 'ADD_EXTRA_GROUPS=1' | run_as_root tee -a /etc/adduser.conf) >/dev/null
(echo 'EXTRA_GROUPS=render' | run_as_root tee -a /etc/adduser.conf) >/dev/null
run_as_root usermod -aG render "$LOGNAME" >/dev/null
(echo 'EXTRA_GROUPS=video' | run_as_root tee -a /etc/adduser.conf) >/dev/null
run_as_root usermod -aG video "$LOGNAME" >/dev/null
run_as_root mkdir --parents --mode=0755 /etc/apt/keyrings
(wget -q https://repo.radeon.com/rocm/rocm.gpg.key -O - | gpg --dearmor | run_as_root tee /etc/apt/keyrings/rocm.gpg) > /dev/null
CODE_NAME=$(lsb_release -cs)
(echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/amdgpu/latest/ubuntu $CODE_NAME main" | run_as_root tee /etc/apt/sources.list.d/amdgpu.list) >/dev/null
run_as_root apt-get -qq update >/dev/null
run_as_root apt-get -qq -y install amdgpu-dkms >/dev/null
(echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/latest/ $CODE_NAME main" | run_as_root tee /etc/apt/sources.list.d/rocm.list) >/dev/null
(echo -e 'Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600' | run_as_root tee /etc/apt/preferences.d/rocm-pin-600) >/dev/null
run_as_root apt-get -qq update >/dev/null
run_as_root apt-get -qq -y install rocm >/dev/null

# Post-install
echo "Post-install rocm."
run_as_root tee /etc/ld.so.conf.d/rocm.conf >/dev/null <<EOF
/opt/rocm/lib
/opt/rocm/lib64
EOF
run_as_root ldconfig
