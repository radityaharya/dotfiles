# Environment Variables
# export QT_SCALE_FACTOR=2
export DONT_PROMPT_WSL_INSTALL=true
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

export BUN_INSTALL="$HOME/.bun"
export FLYCTL_INSTALL="$HOME/.fly"
export PNPM_HOME="$HOME/.local/share/pnpm"

if [ -f "$HOME/.env" ]; then
    export $(cat $HOME/.env | xargs)
fi

if [ -f "/usr/bin/tailscale" ]; then
    export TAILSCALE_IP=$(tailscale ip -4)
fi

export PATH=$HOME/bin:/usr/local/bin:$HOME/.local/bin:"$HOME/.bun/bin/bun":"$BUN_INSTALL/bin":"$FLYCTL_INSTALL/bin":$PATH:/snap/bin:/usr/lib/postgresql/16/bin:/home/linuxbrew/.linuxbrew/:$HOME/go/bin

if [ ! -d "$HOME/dotfiles" ]; then
  echo "Dotfiles repository not found. Cloning..."
  git clone https://github.com/radityaharya/dotfiles ~/dotfiles
  echo "Dotfiles repository cloned successfully."
  cd ~/dotfiles
  sh install.sh
fi

# Homebrew
source ~/dotfiles/zsh/homebrew.zsh

# Oh-My-Posh
eval "$(/home/linuxbrew/.linuxbrew/bin/oh-my-posh init zsh --config ~/dotfiles/omp.json)"

# Tmux Plugin Manager
source ~/dotfiles/zsh/tpm.zsh

# Zinit and Plugins
source ~/dotfiles/zsh/zinit.zsh

# Atuin
source ~/dotfiles/zsh/atuin.zsh

# Keybindings
source ~/dotfiles/zsh/keybindings.zsh

# Configs
source ~/dotfiles/zsh/config/history.zsh
source ~/dotfiles/zsh/config/zstyle.zsh

# Aliases
source ~/dotfiles/zsh/aliases.zsh

# Functions
for file in ~/dotfiles/zsh/functions/*.zsh; do
  source $file
done

# Completions
for file in ~/dotfiles/zsh/completions/*.zsh; do
  source $file
done

# Sourced Scripts
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
eval "$(/home/linuxbrew/.linuxbrew/bin/fzf --zsh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/zoxide init --cmd cd zsh)"
[ -s "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# AiChat
source ~/dotfiles/zsh/aichat.zsh