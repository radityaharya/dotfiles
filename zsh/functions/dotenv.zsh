function _dotenv_help {
  cat <<'EOFHELP'
dotenv - Run commands with environment variables from .env files

Usage: 
    dotenv [options] <command>

Options:
    --help          Show this help message
    --env-file      Specify a custom env file path (default: .env.local or .env)

Examples:
    dotenv npm start
    dotenv --env-file .env.production yarn build
    dotenv python script.py

Description:
    Loads environment variables from a .env file and runs the specified command.
    By default, it looks for .env.local first, then .env in the current directory.
EOFHELP
}

function _dotenv {
  local curcontext="$curcontext" state line ret=1
  typeset -A opt_args

  _arguments -C \
    '--help[Show help message]' \
    '--env-file[Specify a custom env file path]:env file:->envfiles' \
    '*::command and arguments:->command' && ret=0

  case $state in
  envfiles)
    [[ -f ".env.local" ]] && _files -W . ".env.local"
    [[ -f ".env" ]] && _files -W . ".env"
    ret=$?
    ;;
  command)
    if [[ $CURRENT -eq 1 ]]; then
      _normal && ret=0
      _command_names -e && ret=0
    else
      _normal && ret=0
    fi
    ;;
  esac

  return ret
}

function dotenv {
  local env_file=""
  local args=()

  if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]]; then
    _dotenv_help
    return 0
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
    --env-file)
      shift
      env_file="$1"
      if [[ -z "$env_file" ]]; then
        echo "Error: --env-file requires a path argument"
        _dotenv_help
        return 1
      fi
      shift
      ;;
    *)
      args+=("$1")
      shift
      ;;
    esac
  done

  if [[ -z "$env_file" ]]; then
    if [[ -f ".env.local" ]]; then
      env_file=".env.local"
    elif [[ -f ".env" ]]; then
      env_file=".env"
    fi
  fi

  if [[ ! -f "$env_file" ]]; then
    echo "Error: No .env file found or specified"
    echo "Tip: Create a .env file in the current directory or specify one with --env-file"
    _dotenv_help
    return 1
  fi

  if [[ ${#args[@]} -eq 0 ]]; then
    echo "Error: No command specified"
    _dotenv_help
    return 1
  fi

  echo "Using environment file: $env_file"

  set -a
  source "$env_file"
  set +a

  "${args[@]}"
}

compdef _dotenv dotenv
