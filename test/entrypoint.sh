#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Verifying Ansible collections and roles...${NC}"
ansible-galaxy collection list | grep -q "community.general" || {
  echo -e "${RED}Required Ansible collections not found. Installing...${NC}"
  ansible-galaxy collection install -r /home/testuser/dotfiles/ansible/requirements.yml
}

echo -e "${YELLOW}Installing required Ansible roles...${NC}"
ansible-galaxy role install -r /home/testuser/dotfiles/ansible/requirements.yml

echo -e "${YELLOW}Running ansible-lint checks...${NC}"
ansible-lint /home/testuser/dotfiles/ansible/playbook.yml || {
  echo -e "${RED}Ansible-lint failed. Please fix the issues above.${NC}"
  exit 1
}

echo -e "${GREEN}Lint checks passed. Running install...${NC}"
if [ ! -x "/home/testuser/dotfiles/install.sh" ]; then
  echo -e "${RED}Error: install.sh is not executable${NC}"
  ls -l /home/testuser/dotfiles/install.sh
  exit 1
fi

cd /home/testuser/dotfiles
./install.sh || {
  echo -e "${RED}Install failed with exit code $?${NC}"
  exit 1
}

echo -e "${GREEN}All tests passed successfully!${NC}"
exit 0
