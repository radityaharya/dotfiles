zinit ice as"command" from"gh-r" bpick"atuin-*.tar.gz" mv"atuin*/atuin -> atuin" \
  atclone"./atuin init zsh > init.zsh; ./atuin gen-completions --shell zsh > _atuin" \
  atpull"%atclone" src"init.zsh"
zinit light atuinsh/atuin

# Source variables if logged in
if atuin status | grep -q "Username"; then
  if timeout 2s atuin dotfiles var list > /dev/null 2>&1; then
    eval "$(timeout 2s atuin dotfiles var list)"
  else
    echo "Retrieving variables timed out."
  fi
else
  echo "Please login to Atuin by running 'atuin login'"
fi