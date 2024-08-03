install_tmux_plugin_manager() {
  mkdir -p $HOME/.tmux/plugins
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