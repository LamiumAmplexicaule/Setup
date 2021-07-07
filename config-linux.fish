set -xg fish_greeting
set -xg FZF_DEFAULT_COMMAND "fd --type file --color=always --follow --hidden --exclude .git"
set -xg FZF_DEFAULT_OPTS "--ansi"
  
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias la='ls -a'
alias update='sudo apt update && sudo apt upgrade'

if test -d $HOME/.local/bin
        set -xg PATH $HOME/.local/bin $PATH
end

if test -d /usr/local/cuda
        set -xg PATH /usr/local/cuda/bin $PATH
        set -xg LD_LIBRARY_PATH /usr/local/cuda/lib64 $LD_LIBRARY_PATH
end

if test -d /opt/rocm/
        set -xg PATH /opt/rocm/bin:/opt/rocm/rocprofiler/bin:/opt/rocm/opencl/bin $PATH
end

if test -d /usr/local/go
        set -xg PATH /usr/local/go/bin $PATH
end

if test -d $HOME/go
        set -xg GOPATH $HOME/go
        set -xg PATH $GOPATH/bin $PATH
end

if test -d $HOME/.cargo
        set -xg PATH $HOME/.cargo/bin $PATH
end