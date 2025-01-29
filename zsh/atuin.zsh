eval "$(atuin init zsh)"

if ! grep -q "sync_address" "$HOME/.config/atuin/config.toml" 2>/dev/null; then
  echo "Warning: Atuin server configuration not found"
fi

# Source variables if logged in
if atuin status | grep -q "Username"; then
  if timeout 2s atuin dotfiles var list >/dev/null 2>&1; then
    eval "$(timeout 2s atuin dotfiles var list | sed 's/=\(.*\)$/="\1"/')"
  else
    echo "Error: Retrieving variables timed out. Check server connectivity."
  fi
else
  echo "Error: Not logged in to Atuin. Run 'atuin login' and check server configuration."
fi

atuin status >/dev/null 2>&1 || echo "Warning: Atuin service may not be running properly"
