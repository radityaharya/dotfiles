#!/bin/zsh

ENV_FILE="$HOME/.infisical.env"
TOKEN_TTL_DAYS=25

prompt_for_input() {
  local var_name=$1
  local prompt_message=$2
  local input_value=""

  echo -n "$prompt_message: "
  stty -echo
  trap 'stty echo' EXIT
  while IFS= read -r -s -n 1 char; do
    if [[ -z $char ]]; then
      break
    elif [[ $char == $'\177' ]]; then
      if [[ -n $input_value ]]; then
        input_value=${input_value%?}
        echo -ne "\b \b"
      fi
    else
      input_value+=$char
      echo -n '*'
    fi
  done
  stty echo
  trap - EXIT
  echo
  export "$var_name"="$input_value"
}

read_env_file() {
  local file=$1
  [[ -f "$file" ]] || return 1

  while IFS='=' read -r key value; do
    [[ -n $key && -n $value ]] && export "$key"="$value"
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
  token_expiry=$(date -d "$INFISICAL_TOKEN_EXPIRY" +%s)

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

  read_env_file "$ENV_FILE"

  check_and_prompt_var "INFISICAL_CLIENT_ID" "Enter INFISICAL_CLIENT_ID (input is hidden)"
  check_and_prompt_var "INFISICAL_CLIENT_SECRET" "Enter INFISICAL_CLIENT_SECRET (input is hidden)"
  check_and_prompt_var "INFISICAL_PROJECT_ID" "Enter INFISICAL_PROJECT_ID"

  if [[ -z "$INFISICAL_TOKEN" || -z "$INFISICAL_TOKEN_EXPIRY" || $(is_token_expired) == 1 ]]; then
    INFISICAL_TOKEN=$(infisical login --method=universal-auth --client-id="$INFISICAL_CLIENT_ID" --client-secret="$INFISICAL_CLIENT_SECRET" --silent --plain)
    
    if [[ -z "$INFISICAL_TOKEN" ]]; then
      echo "Failed to obtain INFISICAL_TOKEN. Please check your credentials and try again."
      return 1
    fi

    INFISICAL_TOKEN_EXPIRY=$(date -d "+${TOKEN_TTL_DAYS} days" +"%Y-%m-%d %H:%M:%S")
    
    update_env_file "INFISICAL_TOKEN" "$INFISICAL_TOKEN"
    update_env_file "INFISICAL_TOKEN_EXPIRY" "$INFISICAL_TOKEN_EXPIRY"
  fi

  eval "$(infisical export --projectId="$INFISICAL_PROJECT_ID" --env prod --token="$INFISICAL_TOKEN" | sed 's/^/export /')"

  unset_sensitive_vars
}

main "$@"