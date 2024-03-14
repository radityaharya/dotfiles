hlp() {
  local TMPFILE=$(mktemp)
  trap 'rm -f $TMPFILE' EXIT
  if /usr/local/bin/github-copilot-cli what-the-shell "$@" "[this is a zsh shell]" --shellout "$TMPFILE"
  then
    if [[ -e "$TMPFILE" ]]
    then
      local FIXED_CMD=$(cat "$TMPFILE")
      eval "$FIXED_CMD"
    else
      echo "Apologies! Extracting command failed"
    fi
  else
    return 1
  fi
}
