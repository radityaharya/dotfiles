# Define the function with default parameters
function oi() {
  # Set default values
  local api_base="${OPENAI_BASE_URL}"
  local api_key="${OPENAI_API_KEY}"
  local model="command-r-plus"
  local context_window="10000"
  local extra_params=()
  local flags=()

  # Check if required environment variables are set
  if [ -z "$api_base" ] || [ -z "$api_key" ]; then
    echo "Error: OPENAI_BASE_URL and OPENAI_API_KEY must be set."
    return 1
  fi

  # Parse the arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -ab|--api_base) api_base="$2"; shift ;;
      -m|--model) model="$2"; shift ;;
      -cw|--context_window) context_window="$2"; shift ;;
      -p|--profile) extra_params+=("--profile" "$2"); shift ;;
      -ci|--custom_instructions) extra_params+=("--custom_instructions" "$2"); shift ;;
      -s|--system_message) extra_params+=("--system_message" "$2"); shift ;;
      -t|--temperature) extra_params+=("--temperature" "$2"); shift ;;
      -x|--max_tokens) extra_params+=("--max_tokens" "$2"); shift ;;
      -b|--max_budget) extra_params+=("--max_budget" "$2"); shift ;;
      -av|--api_version) extra_params+=("--api_version" "$2"); shift ;;
      -xo|--max_output) extra_params+=("--max_output" "$2"); shift ;;
      -safe|--safe_mode) extra_params+=("--safe_mode" "$2"); shift ;;
      -y|--auto_run) flags+=("--auto_run") ;;
      -nhl|--no_highlight_active_line) flags+=("--no_highlight_active_line") ;;
      -v|--verbose) flags+=("--verbose") ;;
      -lsv|--llm_supports_vision) flags+=("--llm_supports_vision") ;;
      --no-llm_supports_vision) flags+=("--no_llm_supports_vision") ;;
      -lsf|--llm_supports_functions) flags+=("--llm_supports_functions") ;;
      --no-llm_supports_functions) flags+=("--no_llm_supports_functions") ;;
      --loop) flags+=("--loop") ;;
      -dt|--disable_telemetry) flags+=("--disable_telemetry") ;;
      -o|--offline) flags+=("--offline") ;;
      -sm|--speak_messages) flags+=("--speak_messages") ;;
      --debug) flags+=("--debug") ;;
      -f|--fast) flags+=("--fast") ;;
      -ml|--multi_line) flags+=("--multi_line") ;;
      -l|--local) flags+=("--local") ;;
      --codestral) flags+=("--codestral") ;;
      --assistant) flags+=("--assistant") ;;
      --llama3) flags+=("--llama3") ;;
      --groq) flags+=("--groq") ;;
      -vi|--vision) flags+=("--vision") ;;
      -os|--os) flags+=("--os") ;;
      --reset_profile) flags+=("--reset_profile") ;;
      --profiles) flags+=("--profiles") ;;
      --local_models) flags+=("--local_models") ;;
      --conversations) flags+=("--conversations") ;;
      --server) flags+=("--server") ;;
      --version) flags+=("--version") ;;
      --contribute_conversation) flags+=("--contribute_conversation") ;;
      -pl|--plain) flags+=("--plain") ;;
      *) extra_params+=("$1") ;;  # Collect unknown parameters
    esac
    shift
  done

  # Construct and run the command
  interpreter --api_base "$api_base" --api_key "$api_key" --model "$model" --context_window "$context_window" \
    "${extra_params[@]}" \
    "${flags[@]}"
}

# Function to fetch models from OpenAI API
function fetch_openai_models() {
  local api_key="$OPENAI_API_KEY"
  local api_base="$OPENAI_BASE_URL"
  curl -s -H "Authorization: Bearer $api_key" "$api_base/models" | jq -r '.data[].id'
}

# Zsh completion function for oi command
function _oi_completion() {
  local curcontext="$curcontext" state line
  typeset -A opt_args

  _arguments -C \
    '(-ab --api_base)'{-ab,--api_base}'[API base URL]:api_base:_files' \
    '(-m --model)'{-m,--model}'[Model]:model:->models' \
    '(-cw --context_window)'{-cw,--context_window}'[Context window]:context_window:_files' \
    '(-p --profile)'{-p,--profile}'[Profile]:profile:_files' \
    '(-ci --custom_instructions)'{-ci,--custom_instructions}'[Custom instructions]:custom_instructions:_files' \
    '(-s --system_message)'{-s,--system_message}'[System message]:system_message:_files' \
    '(-t --temperature)'{-t,--temperature}'[Temperature]:temperature:_files' \
    '(-x --max_tokens)'{-x,--max_tokens}'[Max tokens]:max_tokens:_files' \
    '(-b --max_budget)'{-b,--max_budget}'[Max budget]:max_budget:_files' \
    '(-av --api_version)'{-av,--api_version}'[API version]:api_version:_files' \
    '(-xo --max_output)'{-xo,--max_output}'[Max output]:max_output:_files' \
    '(-safe --safe_mode)'{-safe,--safe_mode}'[Safe mode]:safe_mode:_files' \
    '(-y --auto_run)'{-y,--auto_run}'[Auto run]' \
    '(-nhl --no_highlight_active_line)'{-nhl,--no_highlight_active_line}'[No highlight active line]' \
    '(-v --verbose)'{-v,--verbose}'[Verbose]' \
    '(-lsv --llm_supports_vision)'{-lsv,--llm_supports_vision}'[LLM supports vision]' \
    '(--no-llm_supports_vision)--no-llm_supports_vision[No LLM supports vision]' \
    '(-lsf --llm_supports_functions)'{-lsf,--llm_supports_functions}'[LLM supports functions]' \
    '(--no-llm_supports_functions)--no-llm_supports_functions[No LLM supports functions]' \
    '(--loop)--loop[Loop]' \
    '(-dt --disable_telemetry)'{-dt,--disable_telemetry}'[Disable telemetry]' \
    '(-o --offline)'{-o,--offline}'[Offline]' \
    '(-sm --speak_messages)'{-sm,--speak_messages}'[Speak messages]' \
    '(--debug)--debug[Debug]' \
    '(-f --fast)'{-f,--fast}'[Fast]' \
    '(-ml --multi_line)'{-ml,--multi_line}'[Multi line]' \
    '(-l --local)'{-l,--local}'[Local]' \
    '(--codestral)--codestral[Codestral]' \
    '(--assistant)--assistant[Assistant]' \
    '(--llama3)--llama3[Llama3]' \
    '(--groq)--groq[Groq]' \
    '(-vi --vision)'{-vi,--vision}'[Vision]' \
    '(-os --os)'{-os,--os}'[OS]' \
    '(--reset_profile)--reset_profile[Reset profile]' \
    '(--profiles)--profiles[Profiles]' \
    '(--local_models)--local_models[Local models]' \
    '(--conversations)--conversations[Conversations]' \
    '(--server)--server[Server]' \
    '(--version)--version[Version]' \
    '(--contribute_conversation)--contribute_conversation[Contribute conversation]' \
    '(-pl --plain)'{-pl,--plain}'[Plain]' \
    '*:flags:->flags'

  case $state in
    models)
      local models
      models=($(fetch_openai_models))
      _describe -t models 'model' models
      ;;
  esac
}

# Register the completion function
compdef _oi_completion oi