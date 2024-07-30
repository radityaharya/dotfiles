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

_tmux_sessions() {
  local -a sessions
  sessions=($(tmux list-sessions -F "#{session_name}" 2>/dev/null))
  _describe -t sessions 'tmux sessions' sessions
}

_t() {
  _arguments \
    '1:session name:->sessions' && return 0

  case $state in
    sessions)
      _tmux_sessions
      ;;
  esac
}

_tk() {
  _arguments \
    '1:session name:->sessions' && return 0

  case $state in
    sessions)
      _tmux_sessions
      ;;
  esac
}

_tkall() {
  _arguments && return 0
}

_tls() {
  _arguments && return 0
}

_trn() {
  _arguments \
    '1:current session name:->sessions' \
    '2:new session name:' && return 0

  case $state in
    sessions)
      _tmux_sessions
      ;;
  esac
}

compdef _t t
compdef _tk tk
compdef _tkall tkall
compdef _tls tls
compdef _trn trn