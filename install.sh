#!/bin/bash

link_dotfiles() {
  local backup_dir="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
  mkdir -p "$backup_dir"

  for file in ~/dotfiles/.*; do
    if [[ -f "$file" && "${file##*/}" != ".git" && "${file##*/}" != "." && "${file##*/}" != ".." ]]; then
      local target_file="$HOME/${file##*/}"
      if [[ -e "$target_file" ]]; then
        mv "$target_file" "$backup_dir/"
        echo "Backed up existing ${file##*/} to $backup_dir"
      fi
      ln -sf "$file" "$target_file"
      echo "Linked ${file##*/} to home directory"
    fi
  done

  echo "Backup of existing dotfiles created in $backup_dir"
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

install_if_not_present zsh

install_if_not_present git

if [[ ! -d "$HOME/dotfiles" ]]; then
  git clone https://github.com/radityaharya/dotfiles ~/dotfiles
  echo "Dotfiles repository cloned successfully."
else
  echo "Dotfiles repository already exists."
fi

link_dotfiles

if [[ $SHELL != $(which zsh) ]]; then
  chsh -s $(which zsh)
  echo "Default shell changed to Zsh. Please restart your terminal to use Zsh."
  exit 1
fi
