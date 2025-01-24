if ! [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Setup Homebrew path and environment
if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -d "$HOME/.linuxbrew" ]]; then
  eval "$($HOME/.linuxbrew/bin/brew shellenv)"
fi

# Function to install Homebrew packages
install_brew_package() {
  local package=$1
  if ! command -v $package &>/dev/null; then
    echo "$package not found. Installing..."
    brew install $package
  fi
}

# Install essential packages
essential_packages=(
  "oh-my-posh"
  "fzf"
  "zoxide"
  "eza"
  "bat"
  "aichat"
)

for package in "${essential_packages[@]}"; do
  install_brew_package "$package"
done

# ...existing commented out packages...
# if ! command -v glow &> /dev/null; then
#   echo "glow not found. Installing..."
#   brew install glow
# fi

# if ! command -v infisical &> /dev/null; then
#   echo "glow not found. Installing..."
#   brew install infisical/get-cli/infisical
# fi
