#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

banner() {
  echo -e "${GREEN}
         ██████   ███  ████                  
      ███░░███ ░░░  ░░███                  
     ░███ ░░░  ████  ░███   ██████   █████ 
    ███████   ░░███  ░███  ███░░███ ███░░  
   ░░░███░     ░███  ░███ ░███████ ░░█████ 
     ░███      ░███  ░███ ░███░░░   ░░░░███
 ██  █████     █████ █████░░██████  ██████ 
░░  ░░░░░     ░░░░░ ░░░░░  ░░░░░░  ░░░░░░  
  ${NC}"
  echo -e "${YELLOW}
  https://github.com/radityaharya/dotfiles
  ${NC}"
}

countdown() {
  echo -e "${YELLOW}Installation will begin in 5 seconds...${NC}"
  echo -e "${YELLOW}Press Ctrl+C to cancel${NC}"

  if [ -t 0 ]; then
    for i in {5..1}; do
      echo -ne "\r$i "
      read -t 1 -n 1 key 2>/dev/null || true
      if [ $? -eq 0 ]; then
        echo -e "\n${RED}Installation cancelled${NC}"
        exit 1
      fi
    done
  else
    for i in {5..1}; do
      echo -ne "\r$i "
      sleep 1
    done
  fi
  echo
}

setup_dotfiles() {
  local dotfiles_dir="$HOME/dotfiles"

  if [ ! -d "$dotfiles_dir" ]; then
    echo -e "${YELLOW}Cloning dotfiles repository...${NC}"
    git clone https://github.com/radityaharya/dotfiles "$dotfiles_dir"
  fi

  cd "$dotfiles_dir"

  if [[ -n "$(git status --porcelain)" ]]; then
    git stash --include-untracked
  fi
  git pull origin main

  echo -e "${GREEN}Dotfiles repository is ready.${NC}"
}

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
  ansible-galaxy collection install -r "$(pwd)/ansible/requirements.yml"
  echo -e "${GREEN}Ansible collections installed successfully.${NC}"
  echo -e "${YELLOW}Installing required Ansible roles...${NC}"
  ansible-galaxy role install -r "$(pwd)/ansible/requirements.yml"
  echo -e "${GREEN}Ansible roles installed successfully.${NC}"
}

run_ansible() {
  echo -e "${YELLOW}Running Ansible playbook...${NC}"
  cd "$HOME/dotfiles/ansible"
  ansible-playbook playbook.yml
}

main() {
  banner
  countdown

  if ! command -v git &>/dev/null; then
    echo -e "${YELLOW}Installing git...${NC}"
    sudo apt-get update && sudo apt-get install -y git
  fi

  setup_dotfiles
  install_ansible
  run_ansible

  echo -e "${GREEN}Installation complete!${NC}"
}

main
