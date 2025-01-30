set -o emacs
unsetopt BEEP

bindkey '^[' deselect-region

bindkey '^p' history-search-backward
bindkey '^o' history-search-forward
bindkey '^a' select-all
bindkey '^d' deselect-region

deselect-region() {
    REGION_ACTIVE=0
    zle reset-prompt
}
zle -N deselect-region

select-all() {
    REGION_ACTIVE=1
    MARK=0
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N select-all

select-word-and-region() {
    REGION_ACTIVE=1
    zle select-word
}
zle -N select-word-and-region
bindkey '\eq' select-word-and-region

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

handle-right-arrow() {
    if ((REGION_ACTIVE)); then
        REGION_ACTIVE=0
        zle reset-prompt
    else
        zle autosuggest-accept || zle forward-char
    fi
}
zle -N handle-right-arrow

handle-left-arrow() {
    if ((REGION_ACTIVE)); then
        REGION_ACTIVE=0
        zle reset-prompt
    fi
    zle backward-char
}
zle -N handle-left-arrow

handle-up-arrow() {
    REGION_ACTIVE=0
    zle up-line-or-history
}
zle -N handle-up-arrow

handle-down-arrow() {
    REGION_ACTIVE=0
    zle down-line-or-history
}
zle -N handle-down-arrow

bindkey $'\e[C' handle-right-arrow
bindkey $'\e[D' handle-left-arrow
bindkey $'\e[A' handle-up-arrow
bindkey $'\e[B' handle-down-arrow

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

