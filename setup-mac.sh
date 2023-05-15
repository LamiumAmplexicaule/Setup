#!/bin/bash
set -eu

if [[ ! $(command -v brew) ]]; then
    echo "Homebrew is not installed."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Homebrew has been successfully installed."
else
    echo "Homebrew is already installed."
fi

echo "Update homebrew."
brew update >/dev/null

echo "Install homebrew packages."
brew tap homebrew/bundle >/dev/null
brew bundle >/dev/null

echo "Upgrade homebrew."
brew upgrade >/dev/null

echo "Install fish plugins."
if [[ $(command -v fish) ]]; then
    mkdir -p ~/.config/fish/ >/dev/null
    cp -n config-mac.fish ~/.config/fish/config.fish >/dev/null
    fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher" >/dev/null
    fish -c "fisher install jethrokuan/z" >/dev/null
    fish -c "fisher install PatrickF1/fzf.fish" >/dev/null
fi

echo "Install hyper terminal plugins."
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

echo "Install rust."
if [[ ! $(command -v rustup) ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &>/dev/null
fi

echo "Finishup."
brew cleanup >/dev/null
if ! grep -q fish /etc/shells; then
    (echo "$(which fish)" | sudo tee -a /etc/shells) >/dev/null
fi
if ! echo $SHELL | grep -q 'fish'; then
    echo "Change default shell to $(which fish)"
    chsh -s "$(which fish)"
fi
