jctl() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: jctl [SERVICE_NAME]"
    echo "Monitor systemd logs for the specified service."
    echo "Example: jctl nginx"
    return 0
  fi

  if [[ -z "$1" ]]; then
    echo "Error: No service name provided."
    echo "Usage: jctl [SERVICE_NAME]"
    return 1
  fi

  sudo journalctl -fu "$1"
}

_jctl() {
  local -a services
  services=($(systemctl list-units --type=service --no-pager --no-legend | awk '{print $1}'))

  _arguments \
    '-h[Print help]' \
    '--help[Print help]' \
    ':service name:->services' && return 0

  case $state in
    services)
      _describe -t services 'systemd services' services
      ;;
  esac
}

compdef _jctl jctl