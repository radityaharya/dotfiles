source "${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git/zinit.zsh"

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

zinit light loiccoyle/zsh-github-copilot

bindkey '^[|' zsh_gh_copilot_explain  # bind Alt+shift+\ to explain
bindkey '^[\' zsh_gh_copilot_suggest  # bind Alt+\ to suggest