# Setup Homebrew path and environment
if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -d "$HOME/.linuxbrew" ]]; then
  eval "$($HOME/.linuxbrew/bin/brew shellenv)"
fi
