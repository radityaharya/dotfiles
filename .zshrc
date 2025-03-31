# export QT_SCALE_FACTOR=2
export DONT_PROMPT_WSL_INSTALL=true
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
export GPG_TTY=$(tty)
export FLYCTL_INSTALL="$HOME/.fly"
export PNPM_HOME="$HOME/.local/share/pnpm"

autoload -Uz compinit
compinit

if [ -f "$HOME/.env" ]; then
  set -a
  source $HOME/.env
  set +a
fi

# SSH Agent Auto-Registration (Silent)
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" >/dev/null 2>&1
fi

# Add SSH Keys Silently (if they exist)
for key in $HOME/.ssh/id_rsa $HOME/.ssh/id_ed25519 $HOME/.ssh/id_ecdsa; do
  if [ -f "$key" ]; then
    ssh-add "$key" >/dev/null 2>&1
  fi
done

if [ -f "$HOME/.global.env" ]; then
  set -a
  while IFS= read -r line || [ -n "$line" ]; do
    line=$(echo "$line" | xargs)
    if [[ -z "$line" || "$line" =~ ^# ]]; then
      continue
    fi
    if [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
      eval "$line"
    else
      echo "Ignoring invalid line: $line"
    fi
  done <"$HOME/.global.env"
  set +a
fi

if [ -f "/usr/bin/tailscale" ] && [ "$(pgrep tailscaled)" ]; then
  export TAILSCALE_IP=$(tailscale ip -4)
fi

path_dirs=(
  "$HOME/bin"
  "/usr/local/bin"
  "$HOME/.local/bin"
  "$FLYCTL_INSTALL/bin"
  "/snap/bin"
  "/usr/lib/postgresql/16/bin"
  "/home/linuxbrew/.linuxbrew"
  "$HOME/go/bin"
  "/usr/local/go/bin"
  "$HOME/flutter/bin"
  "$PNPM_HOME"
)

export PATH=$(
  IFS=:
  echo "${path_dirs[*]}"
):$PATH

# Add Android SDK to PATH
export ANDROID_HOME=~/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

if [ ! -d "$HOME/dotfiles" ]; then
  echo "Dotfiles repository not found. Cloning..."
  git clone https://github.com/radityaharya/dotfiles $HOME/dotfiles
  echo "Dotfiles repository cloned successfully."
  cd $HOME/dotfiles
  sh install.sh
fi

# Homebrew
source $HOME/dotfiles/zsh/homebrew.zsh

# Oh-My-Posh
eval "$(/home/linuxbrew/.linuxbrew/bin/oh-my-posh init zsh --config $HOME/dotfiles/omp.json)"

# Zinit and Plugins
source $HOME/dotfiles/zsh/zinit.zsh

# Atuin
source $HOME/dotfiles/zsh/atuin.zsh

# Keybindings
source $HOME/dotfiles/zsh/keybindings.zsh

# Configs
source $HOME/dotfiles/zsh/config/history.zsh
source $HOME/dotfiles/zsh/config/zstyle.zsh
# source $HOME/dotfiles/zsh/config/autosuggestions.zsh

# Aliases
source $HOME/dotfiles/zsh/aliases.zsh

# Infisical
# source $HOME/dotfiles/zsh/infisical.zsh

# Functions
for file in $HOME/dotfiles/zsh/functions/*.zsh; do
  [[ $(basename "$file") != _* ]] && source "$file"
done

# Completions
for file in $HOME/dotfiles/zsh/completions/*.zsh; do
  [[ $(basename "$file") != _* ]] && source "$file"
done

# Bun Completions
[ -s "$HOME/.bun/_bun" ] || (mkdir -p "$HOME/.bun" && bun completions >"$HOME/.bun/_bun" 2>/dev/null)
[ -s "$HOME/.bun/_bun" ] && fpath=("$HOME/.bun" $fpath)

[ -s "/home/linuxbrew/.linuxbrew/bin/fzf" ] &&
  eval "$(/home/linuxbrew/.linuxbrew/bin/fzf --zsh)"
[ -s "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# AiChat
source $HOME/dotfiles/zsh/aichat.zsh

# Zoxide
eval "$(zoxide init zsh)"
