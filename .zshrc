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
export FLYCTL_INSTALL="$HOME/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"
export DONT_PROMPT_WSL_INSTALL=true

# Aliases
alias lzd='lazydocker'
alias vsc='code-insiders serve-web --host 127.0.0.1 --port 8888 --without-connection-token'


# Sourced scripts
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
source <(ng completion script)
eval "$(starship init zsh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(zoxide init zsh --cmd cd)"