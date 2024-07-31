_cli_zsh_autocomplete() {
    local -a opts
    local cur last_word FLAGS

    local wordsLen=${#words}

    cur="${words[CURRENT]}"

    if [[ "$wordsLen" -eq 2 ]]; then
        help_output=$(tailscale --help 2>&1)

        commands_with_descriptions=$(echo "$help_output" | awk '/SUBCOMMANDS/{ f = 1; next } /FLAGS/{ f = 0 } f && $1{ print $1 ":" substr($0, index($0,$2)) }')
        command_descriptions=("${(@f)commands_with_descriptions}")

        FLAGS=($(echo "$help_output" | awk '
            /FLAGS/ { f = 1; next }
            /EXAMPLES/ { f = 0 }
            f && $1 ~ /^--/ {
                flag = $1
                sub(/,.*$/, "", flag)  # Remove everything after the comma
                print flag ":" substr($0, index($0,$2))
            }
        '))
        _describe 'command_with_description' command_descriptions -- FLAGS

    elif [[ "$wordsLen" -ge 3 ]]; then
        local subcommand="${words[2]}"
        case "$subcommand" in
            ping)
                _cli_complete_ip_addresses
                return
                ;;
            status)
                _cli_complete_status
                return
                ;;
            *)
                _cli_complete_subcommand "$subcommand"
                return
                ;;
        esac
    fi

    return 1
}

_cli_complete_ip_addresses() {
    local output
    output=$(tailscale status 2>&1)

    local ip_description_list
    ip_description_list=($(echo "$output" | awk '/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/ {print $1 ":" $2}'))

    _describe "IP addresses with descriptions" ip_description_list
}

_cli_complete_status() {
    local output
    output=$(tailscale status 2>&1)

    local ip_description_list
    ip_description_list=($(echo "$output" | awk '/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/ {print $1 ":" $2}'))

    local help_output
    help_output=$(tailscale status --help 2>&1)

    local subcommands_with_descriptions
    subcommands_with_descriptions=$(echo "$help_output" | awk '/SUBCOMMANDS/{ f = 1; next } /FLAGS/{ f = 0 } f && $1{ print $1 ":" substr($0, index($0,$2)) }')
    local subcommand_descriptions=("${(@f)subcommands_with_descriptions}")

    local flags_with_descriptions
    flags_with_descriptions=$(echo "$help_output" | awk '
        /FLAGS/ { f = 1; next }
        /EXAMPLES/ { f = 0 }
        f && $1 ~ /^--/ {
            flag = $1
            sub(/,.*$/, "", flag)  # Remove everything after the comma
            print flag ":" substr($0, index($0,$2))
        }
    ')
    local flag_descriptions=("${(@f)flags_with_descriptions}")

    local combined_list=("${ip_description_list[@]}" "${subcommand_descriptions[@]}" "${flag_descriptions[@]}")

    _describe 'status options' combined_list
}

_cli_complete_subcommand() {
    local subcommand="$1"
    local help_output
    help_output=$(tailscale "$subcommand" --help 2>&1)

    local subcommands_with_descriptions
    subcommands_with_descriptions=$(echo "$help_output" | awk '/SUBCOMMANDS/{ f = 1; next } /FLAGS/{ f = 0 } f && $1{ print $1 ":" substr($0, index($0,$2)) }')
    local subcommand_descriptions=("${(@f)subcommands_with_descriptions}")

    local flags_with_descriptions
    flags_with_descriptions=$(echo "$help_output" | awk '
        /FLAGS/ { f = 1; next }
        /EXAMPLES/ { f = 0 }
        f && $1 ~ /^--/ {
            flag = $1
            sub(/,.*$/, "", flag)  # Remove everything after the comma
            print flag ":" substr($0, index($0,$2))
        }
    ')
    local flag_descriptions=("${(@f)flags_with_descriptions}")

    _describe 'subcommand_with_description' subcommand_descriptions -- flag_descriptions
}

compdef _cli_zsh_autocomplete tailscale