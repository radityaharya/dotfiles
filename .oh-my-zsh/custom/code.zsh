function code() {
  args=("$@")
  workspace_files=(*.code-workspace(N))
  if (( $#workspace_files )); then
    echo "Workspace detected! Opening with profile: ${workspace_files[1]}"
    command code --profile "${workspace_files[1]}" "${args[@]}"
  else
    command code "${args[@]}"
  fi
}