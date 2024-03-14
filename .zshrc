# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
plugins=(git zsh-syntax-highlighting git-auto-fetch sudo tmux systemd zsh-autosuggestions docker-compose docker keychain gpg-agent python safe-paste)

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# User configuration

# Environment variables
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$PATH:$HOME/.local/bin
export PATH="$HOME/.bun/bin/bun:$PATH"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH=$PATH:/snap/bin

export BUN_INSTALL="$HOME/.bun"

# flyctl
export FLYCTL_INSTALL="$HOME/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

# Code disable wsl install prompt
export DONT_PROMPT_WSL_INSTALL=true

# Aliases
alias lzd='lazydocker'
alias vsc='code-insiders serve-web --host 127.0.0.1 --port 8888 --without-connection-token'
alias py='python3'

# Sourced scripts
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
[ -s "/usr/local/bin/starship" ] && eval "$(starship init zsh)"
[ -s "/home/linuxbrew/.linuxbrew/bin/brew" ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
[ -s "$HOME/.local/bin/zoxide" ] && eval "$(zoxide init zsh --cmd cd)"