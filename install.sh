#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

install_ansible() {
  if ! command -v ansible &>/dev/null; then
    echo -e "${YELLOW}Installing Ansible...${NC}"
    sudo apt-get update
    sudo apt-get install -y ansible
    echo -e "${GREEN}Ansible installed successfully.${NC}"
  else
    echo -e "${GREEN}Ansible is already installed.${NC}"
  fi

  echo -e "${YELLOW}Installing required Ansible collections...${NC}"
  ansible-galaxy collection install -r "$HOME/dotfiles/ansible/requirements.yml"
  echo -e "${GREEN}Ansible collections installed successfully.${NC}"
}

setup_dotfiles() {
  local dotfiles_dir="$HOME/dotfiles"

  if [ ! -d "$dotfiles_dir" ]; then
    echo -e "${YELLOW}Cloning dotfiles repository...${NC}"
    git clone https://github.com/radityaharya/dotfiles "$dotfiles_dir"
    cd "$dotfiles_dir"
  else
    echo -e "${YELLOW}Updating existing dotfiles repository...${NC}"
    cd "$dotfiles_dir"

    if [[ -n "$(git status --porcelain)" ]]; then
      git stash --include-untracked
    fi

    git pull origin main
  fi

  echo -e "${GREEN}Dotfiles repository is ready.${NC}"
}

run_ansible() {
  echo -e "${YELLOW}Running Ansible playbook...${NC}"
  cd "$HOME/dotfiles/ansible"
  ansible-playbook playbook.yml
}

main() {
  if [ ! -f "$0" ]; then
    TEMP_SCRIPT=$(mktemp)
    cat >"$TEMP_SCRIPT"
    chmod +x "$TEMP_SCRIPT"
    exec "$TEMP_SCRIPT"
    exit 0
  fi

  if ! command -v git &>/dev/null; then
    echo -e "${YELLOW}Installing git...${NC}"
    sudo apt-get update && sudo apt-get install -y git
  fi

  install_ansible
  setup_dotfiles
  run_ansible

  if [ -n "$TEMP_SCRIPT" ] && [ -f "$TEMP_SCRIPT" ]; then
    rm "$TEMP_SCRIPT"
  fi

  echo -e "${GREEN}Installation complete!${NC}"
}

main
