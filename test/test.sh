#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

section_count=0
start_time=$(date +%s)

print_header() {
  echo -e "\n${BLUE}${BOLD}=== $1 ===${NC}\n"
}

run_section() {
  ((section_count++))
  echo -e "\n${YELLOW}${BOLD}[$section_count] $1${NC}"
  shift
  "$@"
}

check_command() {
  if command -v $1 &>/dev/null; then
    echo -e "${GREEN}✓ $1 is installed${NC}"
    return 0
  else
    echo -e "${RED}✗ $1 is not installed${NC}"
    return 1
  fi
}

check_docker() {
  print_header "Checking Docker Requirements"

  # Check if Docker is installed
  if ! command -v docker &>/dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
  fi

  # Check if Docker service is running
  if ! docker info &>/dev/null; then
    echo -e "${RED}Error: Docker service is not running${NC}"
    echo -e "${YELLOW}Try running: sudo systemctl start docker${NC}"
    exit 1
  fi

  # Check if user has Docker permissions
  if ! docker ps &>/dev/null; then
    echo -e "${RED}Error: Current user doesn't have permission to use Docker${NC}"
    echo -e "${YELLOW}Try adding your user to the docker group:${NC}"
    echo "sudo usermod -aG docker $USER"
    echo "Then log out and log back in."
    exit 1
  fi

  # Check if docker compose is available
  if ! docker compose version &>/dev/null; then
    echo -e "${RED}Error: Docker Compose is not available${NC}"
    exit 1
  fi

  echo -e "${GREEN}✓ Docker requirements met${NC}"
}

cleanup() {
  print_header "Cleaning Up"
  if [ -n "$(docker compose ps -q 2>/dev/null)" ]; then
    echo "Stopping test containers..."
    docker compose down --remove-orphans
  fi
  end_time=$(date +%s)
  duration=$((end_time - start_time))
  echo -e "\n${BLUE}${BOLD}Test completed in ${duration} seconds${NC}"
}

trap cleanup EXIT ERR

wait_for_container() {
  local container_name="dotfiles-dotfiles-test-1"
  local max_attempts=30
  local attempt=1

  echo "Waiting for container to be ready..."

  while [ $attempt -le $max_attempts ]; do
    if docker inspect "$container_name" --format '{{.State.Health.Status}}' 2>/dev/null | grep -q "healthy"; then
      echo -e "${GREEN}Container is ready!${NC}"
      return 0
    fi
    echo -n "."
    sleep 1
    ((attempt++))
  done

  echo -e "\n${RED}Container failed to become healthy within ${max_attempts} seconds${NC}"
  return 1
}

main() {
  check_docker

  print_header "Starting Dotfiles Installation Test"

  echo "Building test environment..."
  if ! docker compose up -d --build; then
    echo -e "${RED}Error: Failed to build and start test environment${NC}"
    exit 1
  fi

  # Wait for container to be healthy
  if ! wait_for_container; then
    echo -e "${RED}Error: Container failed to start properly${NC}"
    docker compose logs
    exit 1
  fi

  # Run the installation test with proper error handling
  {
    run_section "Running Installation" docker compose exec -T dotfiles-test bash -c '
      set -e
      cd /home/testuser || exit 1
      cp -r dotfiles dotfiles-copy || { echo "Failed to copy dotfiles"; exit 1; }
      cd dotfiles-copy || exit 1
      
      # Source Homebrew
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      
      # Run installation
      bash install.sh || { echo "Installation script failed"; exit 1; }
      
      # Install required packages
      brew install fzf bat eza || { echo "Failed to install Homebrew packages"; exit 1; }
      
      # Setup Tmux plugins
      git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || { echo "Failed to install TPM"; exit 1; }
      
      # Setup Zinit
      mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/zinit" || { echo "Failed to create Zinit directory"; exit 1; }
      
      # Create .gitconfig if it doesnt exist
      touch ~/.gitconfig
    '
  } || {
    echo -e "${RED}Installation failed. Checking container logs:${NC}"
    docker compose logs
    exit 1
  }

  # Run verification tests
  echo -e "\n${YELLOW}Running verification tests...${NC}"
  docker compose exec -T dotfiles-test bash -c '
    errors=0

    # Shell verification
    echo "Checking shell configuration..."
    if [[ $SHELL == */zsh ]]; then
        echo -e "'"${GREEN}"'✓ Zsh is set as default shell'"${NC}"'"
    else
        echo -e "'"${RED}"'✗ Zsh is not set as default shell'"${NC}"'"
        ((errors++))
    fi

    # Package manager verification
    echo -e "\nChecking package managers..."
    if command -v brew &>/dev/null; then
        echo -e "'"${GREEN}"'✓ Homebrew is installed'"${NC}"'"
        # Check Homebrew health
        if brew doctor &>/dev/null; then
            echo -e "'"${GREEN}"'✓ Homebrew is healthy'"${NC}"'"
        else
            echo -e "'"${RED}"'✗ Homebrew has issues'"${NC}"'"
            ((errors++))
        fi
    else
        echo -e "'"${RED}"'✗ Homebrew is not installed'"${NC}"'"
        ((errors++))
    fi

    # Essential tools verification
    echo -e "\nChecking essential tools..."
    tools=("git" "curl" "zsh" "make" "gcc" "fzf" "bat" "eza")
    for tool in "${tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            echo -e "'"${GREEN}"'✓ $tool is installed'"${NC}"'"
        else
            echo -e "'"${RED}"'✗ $tool is not installed'"${NC}"'"
            ((errors++))
        fi
    done

    # Configuration verification
    echo -e "\nChecking configuration files..."
    config_files=(".zshrc" ".tmux.conf")
    for file in "${config_files[@]}"; do
        if [ -L "$HOME/$file" ]; then
            echo -e "'"${GREEN}"'✓ $file is linked'"${NC}"'"
        else
            echo -e "'"${RED}"'✗ $file is not linked'"${NC}"'"
            ((errors++))
        fi
    done

    # Directory structure verification
    echo -e "\nChecking directory structure..."
    dirs=(".config" ".local/share" ".cache")
    for dir in "${dirs[@]}"; do
        if [ -d "$HOME/$dir" ]; then
            echo -e "'"${GREEN}"'✓ $dir exists'"${NC}"'"
        else
            echo -e "'"${RED}"'✗ $dir is missing'"${NC}"'"
            ((errors++))
        fi
    done

    # Plugin manager verification
    echo -e "\nChecking plugin managers..."
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        echo -e "'"${GREEN}"'✓ Tmux Plugin Manager is installed'"${NC}"'"
    else
        echo -e "'"${RED}"'✗ Tmux Plugin Manager is missing'"${NC}"'"
        ((errors++))
    fi

    if [ -d "${XDG_DATA_HOME:-$HOME/.local/share}/zinit" ]; then
        echo -e "'"${GREEN}"'✓ Zinit is installed'"${NC}"'"
    else
        echo -e "'"${RED}"'✗ Zinit is missing'"${NC}"'"
        ((errors++))
    fi

    exit $errors
  ' || {
    echo -e "${RED}Verification failed. Container output:${NC}"
    docker compose logs
    exit 1
  }

  print_header "All Tests Completed Successfully! 🎉"
  return 0
}

main
