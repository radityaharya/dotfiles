zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -la $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -la $realpath'

_tmux_sessions() {
  tmux list-sessions -F "#{session_name}" 2>/dev/null
}

zstyle ':fzf-tab:complete:t:*' command _tmux_sessions