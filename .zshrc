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
export QT_SCALE_FACTOR=2
export GDK_SCALE=2

export BUN_INSTALL="$HOME/.bun"

# flyctl
export FLYCTL_INSTALL="$HOME/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

# Code disable wsl install prompt
export DONT_PROMPT_WSL_INSTALL=true

# Aliases
alias lzd='lazydocker'
alias vsc='code-insiders serve-web --host 127.0.0.1 --port 8888 --without-connection-token --log off --accept-server-license-terms'
alias py='python3'

# Functions
dcu() {
  docker context use $1
}

# Sourced scripts
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
[ -s "/usr/local/bin/starship" ] && eval "$(starship init zsh)"
[ -s "/home/linuxbrew/.linuxbrew/bin/brew" ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
[ -s "$HOME/.local/bin/zoxide" ] && eval "$(zoxide init zsh --cmd cd)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end