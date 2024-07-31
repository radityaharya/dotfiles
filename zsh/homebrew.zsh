if ! [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if ! command -v oh-my-posh &> /dev/null; then
  echo "oh-my-posh not found. Installing..."
  brew install oh-my-posh
fi

if ! command -v fzf &> /dev/null; then
  echo "fzf not found. Installing..."
  brew install fzf
fi

if ! command -v zoxide &> /dev/null; then
  echo "zoxide not found. Installing..."  
  brew install zoxide
fi

if ! command -v eza &> /dev/null; then
  echo "exa not found. Installing..."
  brew install eza
fi

if ! command -v bat &> /dev/null; then
  echo "bat not found. Installing..."
  brew install bat
fi

if ! command -v aichat &> /dev/null; then
  echo "aichat not found. Installing..."
  brew install aichat
fi
