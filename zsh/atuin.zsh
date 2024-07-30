zinit ice as"command" from"gh-r" bpick"atuin-*.tar.gz" mv"atuin*/atuin -> atuin" \
  atclone"./atuin init zsh > init.zsh; ./atuin gen-completions --shell zsh > _atuin" \
  atpull"%atclone" src"init.zsh"
zinit light atuinsh/atuin

mkdir -p "$HOME/.config/atuin"

if [ ! -L "$HOME/.config/atuin/config.toml" ] || [ "$(readlink "$HOME/.config/atuin/config.toml")" != "$HOME/dotfiles/.config/atuin/config.toml" ]; then
  ln -sf "$HOME/dotfiles/.config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
fi

# Source variables if logged in
if atuin status | grep -q "Username"; then
  eval "$(atuin dotfiles var list)"
else
  echo "Please login to Atuin by running 'atuin login'"
fi
