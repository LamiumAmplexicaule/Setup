set -xg fish_greeting
set -xg FZF_DEFAULT_COMMAND "fd --type file --color=always --follow --hidden --exclude .git"
set -xg FZF_DEFAULT_OPTS "--ansi"
    
abbr --add rm 'rm -vi'
abbr --add mv 'mv -vi'
abbr --add cp 'cp -vi'
abbr --add la 'ls -a'

alias update='sudo apt update && sudo apt upgrade'

if type xclip >/dev/null 2>&1
    alias pbcopy='xclip -selection c'
    alias pbpaste='xclip -selection c -o'
end
if type wl-copy >/dev/null 2>&1
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste'
end

if test -d $HOME/.local/bin
    fish_add_path $HOME/.local/bin
end

if test -d /usr/local/cuda
    fish_add_path /usr/local/cuda/bin
    set -xg LD_LIBRARY_PATH /usr/local/cuda/lib64 $LD_LIBRARY_PATH
end

if test -d /opt/rocm/
    fish_add_path /opt/rocm/bin /opt/rocm/rocprofiler/bin /opt/rocm/opencl/bin
    set -xg LD_LIBRARY_PATH /opt/rocm/lib:/opt/rocm/lib64 $LD_LIBRARY_PATH
end

if test -d /usr/local/go
    fish_add_path /usr/local/go/bin
end

if test -d $HOME/go
    set -xg GOPATH $HOME/go
    fish_add_path $GOPATH/bin
end

if test -d $HOME/.cargo
    fish_add_path $HOME/.cargo/bin
end
