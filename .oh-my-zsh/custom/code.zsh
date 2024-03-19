function code() {
  args=("$@")
  workspace_files=(*.code-workspace(N))
  if (( $#workspace_files )); then
    code --profile "${workspace_files[1]}" "${args[@]}"
  else
    code "${args[@]}"
  fi
}
