venv() {
    set -e

    local venv_name="${1:-venv}"
    local venv_path="$PWD/$venv_name"

    if ! command -v python3 &> /dev/null; then
        echo "python3 is not installed. Please install it first."
        return 1
    fi

    if [[ ! -d "$venv_path" ]]; then
        echo "Virtual environment not found. Creating one..."
        python3 -m venv "$venv_path"
        echo "Virtual environment created successfully."
    else
        echo "Virtual environment found."
    fi

    source "$venv_path/bin/activate"
    echo "Virtual environment activated."
}