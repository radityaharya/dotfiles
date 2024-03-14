#!/bin/bash
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Installing Git..."
    sudo apt-get update
    sudo apt-get install -y git
fi
git clone https://github.com/radityaharya/dotfiles ~/dotfiles
echo "Dotfiles repository cloned successfully."
cd "$HOME/dotfiles"
bash install.sh