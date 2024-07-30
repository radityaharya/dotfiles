rc-mount(){
  rclone mount $1: $2 --allow-other -vvv &
  RCLONE_PID=$!
  trap "fusermount -u $2; kill $RCLONE_PID" EXIT
  wait $RCLONE_PID
}

rc-copy() {
  local src=$1
  local dest=$2

  if [ -d "$src" ]; then
    src="$src"
  else
    src="$src:"
  fi

  if [ -d "$dest" ]; then
    dest="$dest"
  else
    dest="$dest:"
  fi

  rclone copy "$src" "$dest" -P
}

# Completion for rc-mount
_rc_mount() {
  local -a remotes
  local -a directories

  remotes=($(rclone listremotes | sed 's/://g'))
  directories=($(compgen -d))

  _arguments \
    '1:remote name:->remotes' \
    '2:local directory:->directories' && return 0

  case $state in
    remotes)
      _describe -t remotes 'rclone remotes' remotes
      ;;
    directories)
      _describe -t directories 'local directories' directories
      ;;
  esac
}

compdef _rc_mount rc-mount

_rc_copy() {
  local -a remotes
  local -a directories

  remotes=($(rclone listremotes | sed 's/://g'))
  directories=($(compgen -d))

  _arguments \
    '1:source:->sources' \
    '2:destination:->destinations' && return 0

  case $state in
    sources)
      _describe -t sources 'sources' remotes directories
      ;;
    destinations)
      _describe -t destinations 'destinations' remotes directories
      ;;
  esac
}

compdef _rc_copy rc-copy