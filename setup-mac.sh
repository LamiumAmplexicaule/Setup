#!/bin/bash
set -eu

if [[ ! $(which brew) ]]; then
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
if [[ $(which fish) ]]; then
    mkdir -p ~/.config/fish/ >/dev/null
    cp -n config-mac.fish ~/.config/fish/config.fish >/dev/null
    fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher" >/dev/null
    fish -c "fisher install jethrokuan/z" >/dev/null
    fish -c "fisher install PatrickF1/fzf.fish" >/dev/null
fi

echo "Install hyper terminal plugins."
if [[ $(which hyper) ]]; then
    cp -n .hyper.js ~/.hyper.js
    hyper i hyper-akari >/dev/null
    hyper i hyper-tab-icons-plus >/dev/null
    hyper i hyper-statusline >/dev/null
    hyper i hyperlinks >/dev/null
    hyper i hypercwd >/dev/null
fi

echo "Install rust."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &>/dev/null

echo "Finishup."
brew cleanup >/dev/null
(echo $(which fish) | sudo tee -a /etc/shells) >/dev/null
echo "Change default shell to $(which fish)"
chsh -s $(which fish)
