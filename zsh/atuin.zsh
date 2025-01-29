eval "$(atuin init zsh)"

# Source variables if logged in
if atuin status | grep -q "Username"; then
  if timeout 2s atuin dotfiles var list >/dev/null 2>&1; then
    eval "$(timeout 2s atuin dotfiles var list | sed 's/=\(.*\)$/="\1"/')"
  else
    echo "Retrieving variables timed out."
  fi
else
  echo "Please login to Atuin by running 'atuin login'"
fi
