set -xg fish_greeting
set -xg HOMEBREW_INSTALL_CLEANUP 1
set -xg FZF_DEFAULT_COMMAND "fd --type file --color=always --follow --hidden --exclude .git"
set -xg FZF_DEFAULT_OPTS "--ansi"

alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias la='ls -a'
alias nproc='sysctl -n hw.logicalcpu'

alias update='brew update; brew upgrade; brew upgrade --cask'

if test -d /usr/local/sbin
        set -xg PATH /usr/local/sbin $PATH
end

if test -d /opt/homebrew/bin
        set -xg PATH /opt/homebrew/bin $PATH
end

if test -d $HOME/.cargo
        set -xg PATH $HOME/.cargo/bin $PATH
end