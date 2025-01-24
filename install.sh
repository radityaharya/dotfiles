#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

backup_and_link() {
  local source=$1
  local target=$2
  local backup_dir=$3

  if [ -e "$target" ]; then
    mv "$target" "$backup_dir/"
    echo "Backed up existing $(basename $target) to $backup_dir"
  fi
  ln -sf "$source" "$target"
  echo "Linked $(basename $source) to $(dirname $target)"
}

link_dotfiles() {
  local backup_dir="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
  mkdir -p "$backup_dir"

  for file in $HOME/dotfiles/.*; do
    local filename="${file##*/}"
    local target_file="$HOME/$filename"

    if [ -f "$file" ] && [ "$filename" != ".git" ] && [ "$filename" != "." ] && [ "$filename" != ".." ]; then
      backup_and_link "$file" "$target_file" "$backup_dir"
    fi
  done

  echo "Backup of existing dotfiles created in $backup_dir"
}

link_config_folders() {
  local backup_dir="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
  mkdir -p "$backup_dir"

  for folder in $HOME/dotfiles/config/*; do
    local foldername="${folder##*/}"
    local target_folder="$HOME/.config/$foldername"

    if [ -d "$folder" ] && [ "$foldername" != ".git" ] && [ "$foldername" != "." ] && [ "$foldername" != ".." ]; then
      backup_and_link "$folder" "$target_folder" "$backup_dir"
    fi
  done

  echo "Backup of existing config folders created in $backup_dir"
}

install_if_not_present() {
  local package=$1
  if ! command -v $package &>/dev/null; then
    echo -e "${YELLOW}$package is not installed. Installing $package...${NC}"
    if ! sudo apt-get update || ! sudo apt-get install -y $package; then
      echo -e "${RED}Failed to install $package${NC}"
      exit 1
    fi
    echo -e "${GREEN}$package installed successfully.${NC}"
  else
    echo -e "${GREEN}$package is already installed.${NC}"
  fi
}

install_homebrew() {
  if ! command -v brew &>/dev/null; then
    echo -e "${YELLOW}Installing Homebrew...${NC}"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    if ! brew doctor; then
      echo -e "${RED}Homebrew installation seems broken. Please check the errors above.${NC}"
      return 1
    fi
  else
    echo -e "${GREEN}Homebrew is already installed.${NC}"
  fi
}

switch_to_zsh() {
  if [[ $SHELL != *"zsh"* ]]; then
    echo -e "${YELLOW}Changing default shell to Zsh...${NC}"

    # Skip password prompt in test environment
    if [[ -n "$DOTFILES_TEST" ]]; then
      echo -e "${GREEN}Test environment detected, skipping shell change${NC}"
      return 0
    fi

    if ! grep -q "$(which zsh)" /etc/shells; then
      echo "$(which zsh)" | sudo tee -a /etc/shells
    fi

    chsh -s "$(which zsh)"

    echo -e "${GREEN}Shell changed to Zsh. Please log out and log back in to use Zsh.${NC}"
    echo -e "${YELLOW}Note: You may need to restart your terminal or log out/in for all changes to take effect.${NC}"
    return 0
  else
    echo -e "${GREEN}Zsh is already the default shell.${NC}"
    return 0
  fi
}

main() {
  if ! sudo -v; then
    echo -e "${RED}Error: This script requires sudo privileges${NC}"
    exit 1
  fi

  mkdir -p "$HOME/.config"

  install_if_not_present zsh
  install_if_not_present git
  install_if_not_present curl
  install_if_not_present make
  install_if_not_present gcc

  install_homebrew

  if [ ! -d "$HOME/dotfiles" ]; then
    echo -e "${YELLOW}Cloning dotfiles repository...${NC}"
    if ! git clone https://github.com/radityaharya/dotfiles $HOME/dotfiles; then
      echo -e "${RED}Error: Failed to clone dotfiles repository${NC}"
      exit 1
    fi
    echo -e "${GREEN}Dotfiles repository cloned successfully.${NC}"
  else
    echo -e "${GREEN}Dotfiles repository already exists.${NC}"
  fi

  link_dotfiles
  link_config_folders

  switch_to_zsh

  if [[ -f "$HOME/.zshrc" ]]; then
    echo -e "${GREEN}Zsh configuration is ready.${NC}"
    echo -e "${YELLOW}To complete installation:${NC}"
    echo "1. Log out and log back in"
    echo "2. Run 'source ~/.zshrc'"
  fi
}

main
