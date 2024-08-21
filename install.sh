#!/bin/bash

set -e

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
  if ! command -v $package &> /dev/null; then
    echo "$package is not installed. Installing $package..."
    sudo apt-get update
    sudo apt-get install -y $package
    echo "$package installed successfully."
  else
    echo "$package is already installed."
  fi
}

main() {
  install_if_not_present zsh
  install_if_not_present git

  if [ ! -d "$HOME/dotfiles" ]; then
    git clone https://github.com/radityaharya/dotfiles $HOME/dotfiles
    echo "Dotfiles repository cloned successfully."
  else
    echo "Dotfiles repository already exists."
  fi

  link_dotfiles
  link_config_folders

  if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh)
    echo "Default shell changed to Zsh. Please restart your terminal to use Zsh."
    exit 1
  fi
}

main