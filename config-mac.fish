set -xg fish_greeting
set -xg HOMEBREW_INSTALL_CLEANUP 1
set -xg FZF_DEFAULT_COMMAND "fd --type file --color=always --follow --hidden --exclude .git"
set -xg FZF_DEFAULT_OPTS "--ansi"

alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias la='ls -a'
alias nproc='sysctl -n hw.logicalcpu'

alias update='brew update; brew upgrade; brew upgrade --cask; brew autoremove'

if test -d /usr/local/bin
    fish_add_path /usr/local/bin
end

if test -d /usr/local/sbin
    fish_add_path /usr/local/sbin
end

if test -d /opt/homebrew/bin
    fish_add_path /opt/homebrew/bin
end

if test -d /opt/homebrew/sbin
    fish_add_path /opt/homebrew/sbin
end

if test -d $HOME/.cargo
    fish_add_path $HOME/.cargo/bin
end
