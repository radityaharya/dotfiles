ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  if ! mkdir -p "$(dirname $ZINIT_HOME)" 2>/dev/null; then
    echo "Error: Could not create zinit directory"
    return 1
  fi
  if ! git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"; then
    echo "Error: Could not clone zinit repository"
    return 1
  fi
fi

source "${ZINIT_HOME}/zinit.zsh"
zinit wait lucid for \
  OMZP::git \
  OMZP::sudo \
  OMZP::ubuntu \
  OMZP::command-not-found \
  OMZP::systemd

zinit wait lucid for \
  atinit"zicompinit; zicdreplay" \
  zdharma-continuum/fast-syntax-highlighting \
  zsh-users/zsh-completions \
  zsh-users/zsh-autosuggestions \
  atload"!_zsh_autosuggest_start" \
  zsh-users/zsh-autosuggestions \
  blockf \
  zsh-users/zsh-completions \
  atload"!_zsh_autosuggest_start" \
  zsh-users/zsh-autosuggestions

zinit ice wait"0" lucid
zinit load Aloxaf/fzf-tab
