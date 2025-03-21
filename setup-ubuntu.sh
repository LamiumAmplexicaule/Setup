#!/bin/bash
set -eu

SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE:-$0}")")
# shellcheck source=utils.sh
. "$SCRIPT_DIR/utils.sh"

OS_VERSION=$(sed -n 's/^VERSION_ID="\?\([^"]*\)"\?/\1/p' /etc/os-release)
IMPISH=21.10
NOBLE=24.04

echo "Update packages."
run_as_root apt-get -qq update >/dev/null
run_as_root apt-get -qq -y upgrade >/dev/null

echo "Install common tools."
run_as_root apt-get -qq -y install git curl wget apt-transport-https gnupg lsb-release pciutils bzip2 >/dev/null

echo "Install fzf, bat, fd."
run_as_root apt-get -qq -y install fzf bat fd-find >/dev/null
mkdir -p ~/.local/bin >/dev/null
ln -sf "$(which batcat)" ~/.local/bin/bat
ln -sf "$(which fdfind)" ~/.local/bin/fd

echo "Install clipboard utilities."
if [[ ${XDG_SESSION_TYPE-undef} == wayland ]]; then
    run_as_root apt-get -qq install wl-clipboard >/dev/null
elif [[ ${XDG_SESSION_TYPE-undef} == x11 ]]; then
    run_as_root apt-get -qq install xclip >/dev/null
fi
 
echo "Install fish."
if [[ ! $(command -v fish) ]]; then
    run_as_root add-apt-repository -y ppa:fish-shell/release-4 >/dev/null
    run_as_root apt-get -qq update >/dev/null
    run_as_root apt-get -qq -y install fish >/dev/null
fi
if [[ $(command -v fish) ]]; then
    mkdir -p ~/.config/fish/ >/dev/null
    cp -n "$SCRIPT_DIR/config-linux.fish" ~/.config/fish/config.fish >/dev/null
    fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher" >/dev/null
    fish -c "fisher install jethrokuan/z" >/dev/null
    fish -c "fisher install PatrickF1/fzf.fish" >/dev/null
fi

echo "Install hyper terminal."
if [[ ! $(command -v hyper) ]]; then
    wget -qO hyper.deb https://releases.hyper.is/download/deb
    run_as_root apt-get -qq -y install ./hyper.deb >/dev/null
    rm -f hyper.deb >/dev/null
    if version_lt "$OS_VERSION" "$NOBLE"; then
        run_as_root apt-get -qq -y install libasound2 >/dev/null
    else
        run_as_root apt-get -qq -y install libasound2t64 >/dev/null
    fi
fi
if [[ $(command -v hyper) ]]; then
    cp -n "$SCRIPT_DIR/.hyper.js" ~/.hyper.js
    hyper_plugins=(
        "hyper-akari"
        "hyper-tab-icons-plus"
        "hyper-statusline"
        "hyperlinks"
        "hypercwd"
    )
    for plugin in "${hyper_plugins[@]}" ; do
        if ! grep -q "$plugin" ~/.hyper.js; then
            hyper i "$plugin" >/dev/null
        fi
    done
fi

echo "Install tools for gpu."
run_as_root apt-get -qq -y install nvtop >/dev/null
GPU=$(lspci | grep VGA | cut -d ":" -f3)
if [[ $GPU == *NVIDIA* ]]; then
    . "$SCRIPT_DIR/subset/ubuntu/setup-cuda.sh"
elif [[ $GPU == *Advanced* ]]; then
    . "$SCRIPT_DIR/subset/ubuntu/setup-rocm.sh"
fi

echo "Install firefox developer edition."
if [[ ! -d /opt/firefox-dev ]]; then
    lang=$(cut -d "." -f 1 <<< "$LANG")
    if [[ $lang != "ja_JP" ]]; then
        lang="en-US"
    else
        lang="ja"
    fi
    wget -qO firefox-dev.tar.bz2 "https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=$lang"
    mkdir -p firefox-dev && tar -xjf firefox-dev.tar.bz2 -C firefox-dev --strip-components 1
    run_as_root mv firefox-dev /opt
    (run_as_root tee /usr/share/applications/firefox-dev.desktop <<< "[Desktop Entry]
Name=Firefox Developer Edition
GenericName=Web Browser
Exec=/opt/firefox-dev/firefox %u
Icon=/opt/firefox-dev/browser/chrome/icons/default/default128.png
Terminal=false
X-MultipleArgs=false
Type=Application
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
StartupNotify=true
Categories=Network;WebBrowser;
Keywords=web;browser;internet;
Actions=new-window;new-private-window;
StartupWMClass=firefox-aurora
[Desktop Action new-window]
Name=Open a New Window
Exec=/opt/firefox-dev/firefox -new-window
[Desktop Action new-private-window]
Name=Open a New Private Window
Exec=/opt/firefox-dev/firefox -private-window") >/dev/null
    rm -f firefox-dev.tar.bz2
fi

echo "Install google chrome."
if [[ ! $(command -v google-chrome) ]]; then
    wget -qO google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    run_as_root apt-get -qq -y install ./google-chrome.deb >/dev/null
    rm -f google-chrome.deb
fi

echo "Install jetbrains toolbox."
if [[ ! -f ~/.local/share/applications/jetbrains-toolbox.desktop ]]; then
    if version_lte "$OS_VERSION" "$IMPISH"; then
        run_as_root apt-get -qq install fuse libfuse2 >/dev/null
        run_as_root modprobe fuse >/dev/null
        run_as_root groupadd fuse >/dev/null
        user="$(whoami)"
        run_as_root usermod -a -G fuse "$user" >/dev/null
    elif version_lt "$OS_VERSION" "$NOBLE"; then
        run_as_root add-apt-repository -y universe >/dev/null
        run_as_root apt-get -qq install libfuse2 >/dev/null
    else
        run_as_root add-apt-repository -y universe >/dev/null
        run_as_root apt-get -qq install libfuse2t64 >/dev/null
    fi
    wget -qO jetbrains-toolbox.tar.gz "https://data.services.jetbrains.com/products/download?platform=linux&code=TBA"
    mkdir -p jetbrains-toolbox && tar -xzf jetbrains-toolbox.tar.gz -C jetbrains-toolbox --strip-components 1
    ./jetbrains-toolbox/jetbrains-toolbox
    rm -rf jetbrains-toolbox && rm -f jetbrains-toolbox.tar.gz
fi

echo "Install ulauncher."
if [[ ! $(command -v ulauncher) ]]; then
    run_as_root add-apt-repository -y ppa:agornostal/ulauncher >/dev/null
    run_as_root apt-get -qq update >/dev/null
    run_as_root apt-get -qq -y install ulauncher >/dev/null
fi

echo "Install 1password."
if [[ ! $(command -v 1password) ]]; then
    (curl -sS https://downloads.1password.com/linux/keys/1password.asc | run_as_root gpg -q --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg) >/dev/null
    (echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | run_as_root tee /etc/apt/sources.list.d/1password.list) >/dev/null
    run_as_root mkdir -p /etc/debsig/policies/AC2D62742012EA22/ >/dev/null
    (curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | run_as_root tee /etc/debsig/policies/AC2D62742012EA22/1password.pol) >/dev/null
    run_as_root mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 >/dev/null
    (curl -sS https://downloads.1password.com/linux/keys/1password.asc | run_as_root gpg -q --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg) >/dev/null
    run_as_root apt-get -qq update >/dev/null
    run_as_root apt-get -qq -y install 1password >/dev/null
fi

echo "Install eclipse temurin jdk."
(wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | run_as_root tee /etc/apt/trusted.gpg.d/adoptium.gpg) >/dev/null
(echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | run_as_root tee /etc/apt/sources.list.d/adoptium.list) >/dev/null
run_as_root apt-get -qq update >/dev/null
run_as_root apt-get -qq install temurin-21-jdk >/dev/null

echo "Install rust."
if [[ ! $(command -v rustup) ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &>/dev/null
fi

echo "Finishup."
run_as_root apt-get -qq clean >/dev/null
if [[ $SHELL != *fish* ]]; then
    echo "Change default shell to $(which fish)"
    chsh -s "$(which fish)"
fi
