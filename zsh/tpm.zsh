# Add color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

install_tmux_plugin_manager() {
  if ! mkdir -p $HOME/.tmux/plugins 2>/dev/null; then
    echo -e "${RED}Error: Could not create tmux plugins directory${NC}"
    return 1
  fi

  if [ ! -d $HOME/.tmux/plugins/tpm ]; then
    echo -e "${YELLOW}Installing tmux plugin manager...${NC}"
    if git clone --depth 1 https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm; then
      echo -e "${GREEN}Press prefix + I to install plugins${NC}"
    else
      echo -e "${RED}Error: Failed to clone tmux plugin manager${NC}"
    fi
  fi
}

install_tmux_plugin_manager
