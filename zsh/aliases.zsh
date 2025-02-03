# Aliases

alias vim='nvim'
alias c='clear'
alias ls='eza'
alias la='eza -la'
alias l='eza -la'
alias ll='eza -la'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias cat='bat --paging=never --color=always --style=plain'
alias fzf='fzf --preview "bat --color=always --style=plain {}"'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias top='htop'
alias wget='wget -c'
alias p='ps aux | grep'
alias h='history'
alias j='jobs -l'
alias d='docker'
alias dc='docker compose'
alias lzd='lazydocker'
alias vsc='code-insiders serve-web --host 127.0.0.1 --port 8888 --without-connection-token --log off --accept-server-license-terms'
alias py='python3'
alias ".."="cd .."
alias tl="tmux ls"
alias ai="aichat"
alias aif="aichat --role %functions%"
alias run="aichat -e"
alias python="python3"
alias .-="cd -"
