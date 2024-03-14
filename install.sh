#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

package_install_confirmations() {
  echo -e "${YELLOW}Do you want to install $1? [y/n]${NC}"
  read -r response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    return 0
  else
    echo -e "${RED}Aborting installation.${NC}"
    exit 1
  fi
}

install_stow() {
  package_install_confirmations "GNU Stow" || return 0
  echo -e "${YELLOW}Installing GNU Stow...${NC}"
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get install stow
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install stow
  else
    echo -e "${RED}Unsupported OS for this script${NC}"
    exit 1
  fi
}

install_starship() {
  package_install_confirmations "Starship" || return 0
  echo -e "${YELLOW}Installing Starship...${NC}"
  curl -sS https://starship.rs/install.sh | sh
}

install_zsh() {
  package_install_confirmations "zsh" || return 0
  echo -e "${YELLOW}Installing Zsh...${NC}"
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get install zsh
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install zsh
  else
    echo -e "${RED}Unsupported OS for this script${NC}"
    exit 1
  fi
}

install_oh_my_zsh() {
  package_install_confirmations "Oh My Zsh" || return 0
  echo -e "${YELLOW}Installing Oh My Zsh...${NC}"
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_oh_my_zsh_plugins() {
  echo -e "${YELLOW}Installing Oh My Zsh plugins...${NC}"
  
  if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  fi

  if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  fi
}

install_tmux() {
  package_install_confirmations "tmux" || return 0
  echo -e "${YELLOW}Installing tmux...${NC}"
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get install tmux
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install tmux
  else
    echo -e "${RED}Unsupported OS for this script${NC}"
    exit 1
  fi
}

install_tmux_plugin_manager() {
  echo -e "${YELLOW}Installing tmux plugin manager...${NC}"
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  echo -e "${GREEN}Press prefix + I to install plugins${NC}"
}

install_bun() {
  package_install_confirmations "bun" || return 0
  echo -e "${YELLOW}Installing bun...${NC}"

  if ! command_exists unzip; then
    echo -e "${YELLOW}Installing unzip...${NC}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo apt-get install unzip
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      brew install unzip
    else
      echo -e "${RED}Unsupported OS for this script${NC}"
      exit 1
    fi
  fi

  curl -fsSL https://bun.sh/install | bash
}

install_brew() {
  package_install_confirmations "Homebrew" || return 0
  echo -e "${YELLOW}Installing Homebrew...${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_zoxide() {
  package_install_confirmations "zoxide" || return 0
  echo -e "${YELLOW}Installing zoxide...${NC}"
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
  echo -e "${GREEN}zoxide installed. Add the following line to your .zshrc:${NC}"
}

command_exists() {
  which "$1" 1>/dev/null 2>&1
}

dir_exists() {
  [ -d "$1" ]
}

update_package_manager() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get update
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew update
  else
    echo -e "${RED}Unsupported OS for this script${NC}"
    exit 1
  fi
}

echo -e "${GREEN}Dotfiles Installer${NC}"
echo -e "${YELLOW}This script will install the following packages:${NC}"
echo -e "${YELLOW}- GNU Stow (https://www.gnu.org/software/stow/)${NC}"
echo -e "${YELLOW}- Starship (https://starship.rs/) ${NC}"
echo -e "${YELLOW}- Zsh${NC}"
echo -e "${YELLOW}- Oh My Zsh (https://github.com/ohmyzsh/ohmyzsh/)${NC}"
echo -e "${YELLOW}- Oh My Zsh plugins (zsh-autosuggestions) ${NC}"
echo -e "${YELLOW}- tmux${NC}"
echo -e "${YELLOW}- tpm ${NC}"
echo -e "${YELLOW}- bun (https://bun.sh/)${NC}"
echo -e "${YELLOW}- Homebrew (https://brew.sh/)${NC}"

echo -e "${RED}This script will overwrite your existing dotfiles located in your home directory.${NC}"
echo -e "${RED}Please backup your existing dotfiles before running this script.${NC}"
echo -e "${RED}--------------------------------${NC}"


echo -e "${RED}Do you want to continue? [y/n]${NC}"
read -r response
if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo -e "${RED}Aborting installation.${NC}"
  exit 1
fi

cd "$HOME/dotfiles"

git submodule update --init --recursive
git submodule update

echo -e "${YELLOW}Updating package manager...${NC}"
update_package_manager

if ! command_exists stow; then
  install_stow
fi

if ! command_exists starship; then
  install_starship
fi

if ! command_exists zsh; then
  install_zsh
fi

if ! dir_exists ~/.oh-my-zsh; then
  install_oh_my_zsh
fi

if ! command_exists tmux; then
  install_tmux
fi

if ! command_exists bun; then
  install_bun
fi

if ! command_exists brew; then
  install_brew
fi

if ! command_exists zoxide; then
  install_zoxide
fi

# echo -e "${YELLOW}Installing Oh My Zsh plugins...${NC}"
# install_oh_my_zsh_plugins

echo -e "${YELLOW}Stowing dotfiles...${NC}"
stow . || {
  echo -e "${RED}Stowing failed${NC}"
  exit 1
}

echo -e "${GREEN}Dotfiles installation completed.${NC}"
