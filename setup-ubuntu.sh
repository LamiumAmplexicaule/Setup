#!/bin/bash
set -eu

echo "Install common tools."
sudo apt-get -qq update >/dev/null
sudo apt-get -qq -y upgrade >/dev/null
sudo apt-get -qq -y install git curl wget apt-transport-https gnupg lsb-release >/dev/null

echo "Install fzf, bat, fd."
sudo apt-get -qq -y install fzf bat fd-find >/dev/null
mkdir -p ~/.local/bin >/dev/null
ln -sf "$(which batcat)" ~/.local/bin/bat
ln -sf "$(which fdfind)" ~/.local/bin/fd

echo "Install clipboard utilities."
if [[ $XDG_SESSION_TYPE == wayland ]]; then
    sudo apt-get -qq install wl-clipboard >/dev/null
elif [[ $XDG_SESSION_TYPE == x11 ]]; then
    sudo apt-get -qq install xclip >/dev/null
fi
 
echo "Install fish."
if [[ ! $(command -v fish) ]]; then
    sudo add-apt-repository -y ppa:fish-shell/release-3 >/dev/null
    sudo apt-get -qq update >/dev/null
    sudo apt-get -qq -y install fish >/dev/null
fi
if [[ $(command -v fish) ]]; then
    mkdir -p ~/.config/fish/ >/dev/null
    cp -n config-linux.fish ~/.config/fish/config.fish >/dev/null
    fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher" >/dev/null
    fish -c "fisher install jethrokuan/z" >/dev/null
    fish -c "fisher install PatrickF1/fzf.fish" >/dev/null
fi

echo "Install hyper terminal."
if [[ ! $(command -v hyper) ]]; then
    wget -qO hyper.deb https://releases.hyper.is/download/deb
    sudo apt-get -qq -y install ./hyper.deb >/dev/null
    rm -f hyper.deb >/dev/null
fi
if [[ $(command -v hyper) ]]; then
    cp -n .hyper.js ~/.hyper.js
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
sudo apt-get -qq -y install nvtop >/dev/null
GPU=$(lspci | grep VGA | cut -d ":" -f3)
if [[ $GPU == *NVIDIA* ]]; then
    source ./subset/ubuntu/setup-cuda.sh
elif [[ $GPU == *Advanced* ]]; then
    source ./subset/ubuntu/setup-rocm.sh
fi

echo "Install firefox developer edition."
if [[ ! -d /opt/firefox-dev ]]; then
    lang=$(echo "$LANG" | cut -d "." -f 1)
    if [[ $lang != "ja_JP" ]]; then
        lang="en-US"
    else
        lang="ja"
    fi
    wget -qO firefox-dev.tar.bz2 "https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=$lang"
    mkdir -p firefox-dev && tar -xjf firefox-dev.tar.bz2 -C firefox-dev --strip-components 1
    sudo mv firefox-dev /opt
    (echo -e "[Desktop Entry]
    Name=Firefox Developer Edition
    GenericName=Web Browser
    Exec=/opt/firefox-dev/firefox %u
    Icon=/opt/firefox-dev/browser/chrome/icons/default/default128.png
    Terminal=false
    X-MultipleArgs=false
    Type=Application
    MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
    StartupNotify=true
    Categories=Network;WebBrowser;Favorite;
    Keywords=web;browser;internet;
    Actions=new-window;new-private-window;
    StartupWMClass=firefox-aurora
    [Desktop Action new-window]
    Name=Open a New Window
    Exec=/opt/firefox-dev/firefox %u
    [Desktop Action new-private-window]
    Name=Open a New Private Window
    Exec=/opt/firefox-dev/firefox --private-window %u" | sudo tee -a /usr/share/applications/firefox-dev.desktop) >/dev/null
    rm -f firefox-dev.tar.bz2
fi

echo "Install google chrome."
if [[ ! $(command -v google-chrome) ]]; then
    wget -qO google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt-get -qq -y install ./google-chrome.deb >/dev/null
    rm -f google-chrome.deb
fi

echo "Install jetbrains toolbox."
if [[ ! -f ~/.local/share/applications/jetbrains-toolbox.desktop ]]; then
    OS_VERSION=$(lsb_release -rs)
    IMPISH=21.10
    if [[ $(printf "%s\n%s" "$IMPISH" "$OS_VERSION" | sort -V | head -n 1) == "$IMPISH" ]]; then
        sudo apt-get -qq install fuse libfuse2 >/dev/null
        sudo modprobe fuse >/dev/null
        sudo groupadd fuse >/dev/null
        user="$(whoami)"
        sudo usermod -a -G fuse "$user" >/dev/null
    else
        sudo add-apt-repository -y universe >/dev/null
        sudo apt-get -qq install libfuse2 >/dev/null
    fi
    wget -qO jetbrains-toolbox.tar.gz "https://data.services.jetbrains.com/products/download?platform=linux&code=TBA"
    mkdir -p jetbrains-toolbox && tar -xzf jetbrains-toolbox.tar.gz -C jetbrains-toolbox --strip-components 1
    ./jetbrains-toolbox/jetbrains-toolbox
    rm -rf jetbrains-toolbox && rm -f jetbrains-toolbox.tar.gz
fi

echo "Install ulauncher."
if [[ ! $(command -v ulauncher) ]]; then
    sudo add-apt-repository -y ppa:agornostal/ulauncher >/dev/null
    sudo apt-get -qq update >/dev/null
    sudo apt-get -qq -y install ulauncher >/dev/null
fi

echo "Install 1password."
if [[ ! $(command -v 1password) ]]; then
    (curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg -q --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg) >/dev/null
    (echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list) >/dev/null
    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/ >/dev/null
    (curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol) >/dev/null
    sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 >/dev/null
    (curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg -q --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg) >/dev/null
    sudo apt-get -qq update >/dev/null
    sudo apt-get -qq -y install 1password >/dev/null
fi

echo "Install eclipse adoptium jdk."
(wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo tee /usr/share/keyrings/adoptium.asc) >/dev/null
(echo "deb [signed-by=/usr/share/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list) >/dev/null
sudo apt-get -qq update >/dev/null
sudo apt-get -qq install temurin-21-jdk >/dev/null

echo "Install rust."
if [[ ! $(command -v rustup) ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &>/dev/null
fi

echo "Finishup."
sudo apt-get -qq clean >/dev/null
if ! echo "$SHELL" | grep -q 'fish'; then
    echo "Change default shell to $(which fish)"
    chsh -s "$(which fish)"
fi
