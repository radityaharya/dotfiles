#!/bin/zsh

CONFIG_DIR="$HOME/.config/infisical"
CLIENT_ID_FILE="$CONFIG_DIR/client_id"
CLIENT_SECRET_FILE="$CONFIG_DIR/client_secret"

prompt_for_input() {
  local var_name=$1
  local prompt_message=$2

  if command -v systemd-ask-password &>/dev/null; then
    local input=$(systemd-ask-password "$prompt_message")
    eval "$var_name='$input'"
  else
    echo -n "$prompt_message (input is hidden): "
    stty -echo
    read -r input
    stty echo
    echo
    eval "$var_name='$input'"
  fi
}

read_config_file() {
  local file=$1
  [[ -f "$file" ]] || return 1

  while IFS='=' read -r key value; do
    [[ $key =~ ^#.*$ || -z $key || -z $value ]] && continue
    export "$key"="$value"
  done < "$file"
}

check_and_prompt_var() {
  local var_name=$1
  local prompt_message=$2
  local file_path=$3

  if [[ -z "${(P)var_name}" ]]; then
    prompt_for_input "$var_name" "$prompt_message"
    update_config_file "$file_path" "${(P)var_name}"
  fi
}

install_infisical_cli() {
  if ! command -v infisical &> /dev/null; then
    echo "Infisical CLI is not installed. Please install it using 'brew install infisical/get-cli/infisical'."
    return 1
  fi
}

update_config_file() {
  local file=$1
  local value=$2

  echo "$value" > "$file"
  chmod 600 "$file"
}

unset_sensitive_vars() {
  unset INFISICAL_CLIENT_ID
  unset INFISICAL_CLIENT_SECRET
}

main() {
  install_infisical_cli || return 1

  read_config_file "$CLIENT_ID_FILE"
  read_config_file "$CLIENT_SECRET_FILE"

  if [[ -n "$INFISICAL_CLIENT_ID" && -n "$INFISICAL_CLIENT_SECRET" ]]; then
    unset_sensitive_vars
    return 0
  fi

  mkdir -p "$CONFIG_DIR"

  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BOLD='\033[1m'
  UNDERLINE='\033[4m'
  MUTED='\033[0;37m'
  DARK_GRAY='\033[1;30m'
  LIGHT_FONT='\033[2m'
  NC='\033[0m' # No Color

  if [[ -z "$INFISICAL_CLIENT_ID" || -z "$INFISICAL_CLIENT_SECRET" ]]; then
    echo -e "${YELLOW}${BOLD}${UNDERLINE} Infiscal Credentials${NC}"
    echo -e "${LIGHT_FONT}${DARK_GRAY}For more information, visit: https://infisical.com/docs/documentation/platform/identities/machine-identities${NC}"
  fi

  check_and_prompt_var "INFISICAL_CLIENT_ID" "INFISICAL_CLIENT_ID:" "$CLIENT_ID_FILE"
  check_and_prompt_var "INFISICAL_CLIENT_SECRET" "INFISICAL_CLIENT_SECRET:" "$CLIENT_SECRET_FILE"

  unset_sensitive_vars
}

main "$@"