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
    send2   x      $'\E[4;2$HOME' select   end-of-line \
    shome   kHOM   $'\E[1;2H' select   beginning-of-line \
    shome2  x      $'\E[1;2$HOME' select   beginning-of-line \
    end     kend   $'\EOF'    deselect end-of-line \
    end2    x      $'\E4$HOME'    deselect end-of-line \
    home    khome  $'\EOH'    deselect beginning-of-line \
    home2   x      $'\E1$HOME'    deselect beginning-of-line \
    csleft  x      $'\E[1;6D' select   backward-word \
    csright x      $'\E[1;6C' select   forward-word \
    csend   x      $'\E[1;6F' select   end-of-line \
    cshome  x      $'\E[1;6H' select   beginning-of-line \
    cleft   x      $'\E[1;5D' deselect backward-word \
    cright  x      $'\E[1;5C' deselect forward-word \
    del     kdch1  $'\E[3$HOME'   delregion delete-char \
    bs      x      $'^?'      delregion backward-delete-char
do
  eval "key-$key() {
    r-$mode $widget \$@
  }"
  zle -N key-$key
  bindkey ${terminfo[$kcap]-$seq} key-$key
done

