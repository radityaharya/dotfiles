# ==============================
# Environment Variables
# ==============================
# export QT_SCALE_FACTOR=2
export DONT_PROMPT_WSL_INSTALL=true
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

export BUN_INSTALL="$HOME/.bun"
export FLYCTL_INSTALL="$HOME/.fly"
export PNPM_HOME="$HOME/.local/share/pnpm"

if [ -f "$HOME/.env" ]; then
    export $(cat $HOME/.env | xargs)
fi

export PATH=$HOME/bin:/usr/local/bin:$HOME/.local/bin:"$HOME/.bun/bin/bun":"$BUN_INSTALL/bin":"$FLYCTL_INSTALL/bin":$PATH:/snap/bin:/usr/lib/postgresql/16/bin:/home/linuxbrew/.linuxbrew/

if [ ! -d "$HOME/dotfiles" ]; then
  echo "Dotfiles repository not found. Cloning..."
  git clone https://github.com/radityaharya/dotfiles ~/dotfiles
  echo "Dotfiles repository cloned successfully."
  cd ~/dotfiles
  sh install.sh
fi

# ==============================
# Oh My Posh Configuration
# ==============================
if ! command -v oh-my-posh &> /dev/null; then
  echo "oh-my-posh not found. Installing..."
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
fi
eval "$(~/.local/bin/oh-my-posh init zsh --config ~/dotfiles/.omp.toml)"


# ==============================
# Homebrew
# ==============================

if ! [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if ! command -v fzf &> /dev/null; then
  echo "fzf not found. Installing..."
  brew install fzf
fi

if ! command -v zoxide &> /dev/null; then
  echo "zoxide not found. Installing..."  
  brew install zoxide
fi

if ! command -v exa &> /dev/null; then
  echo "exa not found. Installing..."
  brew install exa
fi

if ! command -v batcat &> /dev/null; then
  echo "bat not found. Installing..."
  brew install bat
fi

if ! command -v aichat &> /dev/null; then
  echo "aichat not found. Installing..."
  brew install aichat
fi


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


# ==============================
# Zinit and Plugins
# ==============================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
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


# ==============================
# Keybindings
# ==============================
bindkey '^p' history-search-backward
bindkey '^o' history-search-forward

# https://stackoverflow.com/questions/5407916/zsh-zle-shift-selection
r-delregion() {
  if ((REGION_ACTIVE)) then
     zle kill-region
  else
    local widget_name=$1
    shift
    zle $widget_name -- $@
  fi
}

r-deselect() {
  ((REGION_ACTIVE = 0))
  local widget_name=$1
  shift
  zle $widget_name -- $@
}

r-select() {
  ((REGION_ACTIVE)) || zle set-mark-command
  local widget_name=$1
  shift
  zle $widget_name -- $@
}

for key kcap seq mode widget in \
    sleft   kLFT   $'\e[1;2D' select   backward-char \
    sright  kRIT   $'\e[1;2C' select   forward-char \
    sup     kri    $'\e[1;2A' select   up-line-or-history \
    sdown   kind   $'\e[1;2B' select   down-line-or-history \
    send    kEND   $'\E[1;2F' select   end-of-line \
    send2   x      $'\E[4;2~' select   end-of-line \
    shome   kHOM   $'\E[1;2H' select   beginning-of-line \
    shome2  x      $'\E[1;2~' select   beginning-of-line \
    left    kcub1  $'\EOD'    deselect backward-char \
    right   kcuf1  $'\EOC'    deselect forward-char \
    end     kend   $'\EOF'    deselect end-of-line \
    end2    x      $'\E4~'    deselect end-of-line \
    home    khome  $'\EOH'    deselect beginning-of-line \
    home2   x      $'\E1~'    deselect beginning-of-line \
    csleft  x      $'\E[1;6D' select   backward-word \
    csright x      $'\E[1;6C' select   forward-word \
    csend   x      $'\E[1;6F' select   end-of-line \
    cshome  x      $'\E[1;6H' select   beginning-of-line \
    cleft   x      $'\E[1;5D' deselect backward-word \
    cright  x      $'\E[1;5C' deselect forward-word \
    del     kdch1  $'\E[3~'   delregion delete-char \
    bs      x      $'^?'      delregion backward-delete-char
do
  eval "key-$key() {
    r-$mode $widget \$@
  }"
  zle -N key-$key
  bindkey ${terminfo[$kcap]-$seq} key-$key
done

# ==============================
# History Configuration
# ==============================
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# ==============================
# Completion Styling
# ==============================
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -la $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'exa -la $realpath'

_tmux_sessions() {
  tmux list-sessions -F "#{session_name}" 2>/dev/null
}

zstyle ':fzf-tab:complete:t:*' command _tmux_sessions

# ==============================
# Aliases
# ==============================
alias vim='nvim'
alias c='clear'
alias ls='exa'
alias la='exa -la'
alias l='exa -la'
alias ll='exa -la'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias cat='batcat -p -u --paging=never --color=always'
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

# ==============================
# Functions
# ==============================
dcu() {
  docker context use $1
}

t() {
  if ! tmux list-sessions &>/dev/null; then
    echo "Starting tmux server..."
    tmux start-server
  fi
  
  if [ -z "$1" ]; then
    session_name=$( (echo "Create new session"; tmux list-sessions -F "#{session_name}" 2>/dev/null) | fzf )
    if [ "$session_name" = "Create new session" ]; then
      echo "Enter new session name: "
      read session_name
      tmux new-session -s "$session_name" -d
    elif [ -n "$session_name" ]; then
      echo "Attaching to session $session_name"
    else
      echo "No session selected."
      return 1
    fi
  else
    session_name=$1
    if tmux has-session -t $session_name 2>/dev/null; then
      echo "Session $session_name already exists. Attaching..."
    else
      echo "Creating new session $session_name"
      tmux new-session -s "$session_name" -d
    fi
  fi
  tmux attach-session -t "$session_name"
}


tk() {
  session=$(tmux list-sessions -F "#{session_name}" | fzf)
  if [ -n "$session" ]; then
    tmux kill-session -t "$session"
  else
    echo "No session selected."
  fi
}


tkall() {
  if tmux ls &> /dev/null; then
    tmux ls | cut -d: -f1 | while read -r session; do
      echo "Terminating session: $session"
      tmux kill-session -t "$session"
    done
  else
    echo "No tmux sessions found."
  fi
}

tls() {
  if tmux ls &> /dev/null; then
    tmux list-sessions
  else
    echo "No tmux sessions found."
  fi
}

trn() {
  session=$(tmux list-sessions -F "#{session_name}" | fzf)
  if [ -n "$session" ]; then
    new_name=$1
    if [ -z "$new_name" ]; then
      echo "Please provide a new name for the session."
      return 1
    fi
    tmux rename-session -t "$session" $new_name
  else
    echo "No session selected."
  fi
}

rc-mount(){
  rclone mount $1: $2 --allow-other -vvv &
  RCLONE_PID=$!
  trap "fusermount -u $2; kill $RCLONE_PID" EXIT
  wait $RCLONE_PID
}

# ==============================
# Sourced Scripts
# ==============================
[ -s "/home/linuxbrew/.linuxbrew/bin/brew" ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
precmd () { echo -n "\x1b]1337;CurrentDir=$(pwd)\x07" }

# ==============================
# Shell Integrations
# ==============================
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Cargo Completions
[ -s "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# bun completions
[ -s "/home/radityaharya/.bun/_bun" ] && source "/home/radityaharya/.bun/_bun"

# ==============================
# Aichat
# ==============================
spinner=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
_aichat_zsh() {
    if [[ -n "$BUFFER" ]]; then
        local _old=$BUFFER
        BUFFER+=" "
        zle -I && zle redisplay
        BUFFER=$(aichat -e "$_old")
        zle end-of-line
    fi
}
zle -N _aichat_zsh
bindkey '\ee' _aichat_zsh

autoload -U is-at-least

_aichat() {
    typeset -A opt_args
    typeset -a _arguments_options
    local ret=1

    if is-at-least 5.2; then
        _arguments_options=(-s -S -C)
    else
        _arguments_options=(-s -C)
    fi

    local context curcontext="$curcontext" state line
    local common=(
'-m[Select a LLM model]:MODEL:->models' \
'--model[Select a LLM model]:MODEL:->models' \
'--prompt[Use the system prompt]:PROMPT: ' \
'-r[Select a role]:ROLE:->roles' \
'--role[Select a role]:ROLE:->roles' \
'-s[Start or join a session]:SESSION:->sessions' \
'--session[Start or join a session]:SESSION:->sessions' \
'--save-session[Forces the session to be saved]' \
'-a[Start a agent]:AGENT:->agents' \
'--agent[Start a agent]:AGENT:->agents' \
'-R[Start a RAG]:RAG:->rags' \
'--rag[Start a RAG]:RAG:->rags' \
'--serve[Serve the LLM API and WebAPP]' \
'-e[Execute commands in natural language]' \
'--execute[Execute commands in natural language]' \
'-c[Output code only]' \
'--code[Output code only]' \
'*-f[Include files with the message]:FILE:_files' \
'*--file[Include files with the message]:FILE:_files' \
'-S[Turn off stream mode]' \
'--no-stream[Turn off stream mode]' \
'-w[Control text wrapping (no, auto, <max-width>)]:WRAP: ' \
'--wrap[Control text wrapping (no, auto, <max-width>)]:WRAP: ' \
'-H[Turn off syntax highlighting]' \
'--no-highlight[Turn off syntax highlighting]' \
'--light-theme[Use light theme]' \
'--dry-run[Display the message without sending it]' \
'--info[Display information]' \
'--list-models[List all available chat models]' \
'--list-roles[List all roles]' \
'--list-sessions[List all sessions]' \
'--list-agents[List all agents]' \
'--list-rags[List all RAGs]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
'*::text -- Input text:' \
    )


    _arguments "${_arguments_options[@]}" $common \
        && ret=0 
    case $state in
        models|roles|sessions|agents|rags)
            local -a values expl
            values=( ${(f)"$(_call_program values aichat --list-$state)"} )
            _wanted values expl $state compadd -a values && ret=0
            ;;
    esac
    return ret
}

(( $+functions[_aichat_commands] )) ||
_aichat_commands() {
    local commands; commands=()
    _describe -t commands 'aichat commands' commands "$@"
}

if [ "$funcstack[1]" = "_aichat" ]; then
    _aichat "$@"
else
    compdef _aichat aichat
fi
