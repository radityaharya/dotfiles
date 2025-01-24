#!/bin/bash

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >>"$HOME/backup.log"
}

if ! command -v restic &>/dev/null; then
  log "restic is not installed. Attempting to install..."
  sudo apt-get update && sudo apt-get install -y restic

  if ! command -v restic &>/dev/null; then
    log "Error: restic installation failed."
    exit 1
  else
    log "restic installed successfully."
  fi
fi

if ! command -v atuin &>/dev/null; then
  log "Error: atuin is not installed."
  exit 1
fi

if [ -z "$RESTIC_REPO" ]; then
  log "Error: RESTIC_REPO environment variable is not set."
  exit 1
fi

EXCLUDE_FILE="$HOME/dotfiles/restic/restic_exclude.txt"

# Initialize the Restic repository if it is not already initialized
if ! restic snapshots --repo "$RESTIC_REPO" --password-file <(atuin kv get repo_pass) &>/dev/null; then
  log "Restic repository is not initialized. Initializing..."
  restic init --repo "$RESTIC_REPO" --password-file <(atuin kv get repo_pass)
  if [ $? -eq 0 ]; then
    log "Restic repository initialized successfully."
  else
    log "Error: Failed to initialize Restic repository."
    exit 1
  fi
else
  echo "Restic repository is already initialized at $RESTIC_REPO."
  log "Restic repository is already initialized at $RESTIC_REPO."
fi

log "Starting backup"
restic backup --repo "$RESTIC_REPO" "$HOME" --exclude-file "$EXCLUDE_FILE" --password-file <(atuin kv get repo_pass) --verbose 2>&1 | tee -a "$HOME/backup.log"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
  log "Backup completed successfully."
  echo "Backup completed successfully."
else
  log "Backup failed. Check the log file for details."
  echo "Backup failed. Check the log file for details."
  exit 1
fi
