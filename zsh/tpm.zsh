install_tmux_plugin_manager() {
  echo -e "${YELLOW}Installing tmux plugin manager...${NC}"
  if [ ! -d ~/.tmux/plugins/tpm ]; then
    if git clone "https://github.com/tmux-plugins/tpm" "~/.tmux/plugins/tpm"; then
      echo -e "${GREEN}Press prefix + I to install plugins${NC}"
    else
      echo -e "${RED}Error: Failed to clone tmux plugin manager${NC}"
    fi
  fi
}

# check if tmux plugin manager is installed
if [ ! -d ~/.tmux/plugins/tpm ]; then
  install_tmux_plugin_manager
fi
