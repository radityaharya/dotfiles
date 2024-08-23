#!/bin/zsh

ENV_FILE="$HOME/.infisical.env"
TOKEN_TTL_DAYS=25

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

read_env_file() {
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

  if [[ -z "${(P)var_name}" ]]; then
    prompt_for_input "$var_name" "$prompt_message"
    update_env_file "$var_name" "${(P)var_name}"
  fi
}

install_infisical_cli() {
  if ! command -v infisical &> /dev/null; then
    echo "Infisical CLI is not installed. Please install it using 'brew install infisical/get-cli/infisical'."
    return 1
  fi
}

is_token_expired() {
  local current_date
  local token_expiry

  current_date=$(date +%s)
  token_expiry=$(date -d "$INFISICAL_TOKEN_EXPIRY" +%s 2>/dev/null || date -jf "%Y-%m-%d %H:%M:%S" "$INFISICAL_TOKEN_EXPIRY" +%s 2>/dev/null)

  [[ $current_date -ge $token_expiry ]]
}

update_env_file() {
  local key=$1
  local value=$2

  if grep -q "^$key=" "$ENV_FILE"; then
    sed -i.bak "s/^$key=.*/$key=$value/" "$ENV_FILE"
  else
    echo "$key=$value" >> "$ENV_FILE"
  fi

  chmod 600 "$ENV_FILE"
}

unset_sensitive_vars() {
  unset INFISICAL_CLIENT_ID
  unset INFISICAL_CLIENT_SECRET
  unset INFISICAL_PROJECT_ID
  unset INFISICAL_TOKEN
  unset INFISICAL_TOKEN_EXPIRY
}

main() {
  install_infisical_cli || return 1

  [[ -f "$ENV_FILE" ]] || touch "$ENV_FILE"

  read_env_file "$ENV_FILE"

  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BOLD='\033[1m'
  UNDERLINE='\033[4m'
  MUTED='\033[0;37m'
  DARK_GRAY='\033[1;30m'
  LIGHT_FONT='\033[2m'
  NC='\033[0m' # No Color

  if [[ -z "$INFISICAL_CLIENT_ID" || -z "$INFISICAL_CLIENT_SECRET" || -z "$INFISICAL_PROJECT_ID" ]]; then
    echo -e "${YELLOW}${BOLD}${UNDERLINE} Infiscal Credentials${NC}"
    echo -e "${LIGHT_FONT}${DARK_GRAY}For more information, visit: https://infisical.com/docs/documentation/platform/identities/machine-identities${NC}"
  fi

  check_and_prompt_var "INFISICAL_CLIENT_ID" "INFISICAL_CLIENT_ID:"
  check_and_prompt_var "INFISICAL_CLIENT_SECRET" "INFISICAL_CLIENT_SECRET:"
  check_and_prompt_var "INFISICAL_PROJECT_ID" "INFISICAL_PROJECT_ID:"

  if [[ -z "$INFISICAL_TOKEN" || -z "$INFISICAL_TOKEN_EXPIRY" || $(is_token_expired) == 1 ]]; then
    INFISICAL_TOKEN=$(infisical login --method=universal-auth --client-id="$INFISICAL_CLIENT_ID" --client-secret="$INFISICAL_CLIENT_SECRET" --silent --plain)
    
    if [[ -z "$INFISICAL_TOKEN" ]]; then
      echo "Failed to obtain INFISICAL_TOKEN. Please check your credentials and try again."
      return 1
    fi

    INFISICAL_TOKEN_EXPIRY=$(date -d "+${TOKEN_TTL_DAYS} days" +"%Y-%m-%d %H:%M:%S" 2>/dev/null || date -v+${TOKEN_TTL_DAYS}d +"%Y-%m-%d %H:%M:%S")
    
    update_env_file "INFISICAL_TOKEN" "$INFISICAL_TOKEN"
    update_env_file "INFISICAL_TOKEN_EXPIRY" "$INFISICAL_TOKEN_EXPIRY"
  fi

  eval "$(infisical export --projectId="$INFISICAL_PROJECT_ID" --env prod --token="$INFISICAL_TOKEN" | sed 's/^/export /')"

  unset_sensitive_vars
}

main "$@"