#!/bin/bash

set -e

function print_usage() {
  echo "Usage: $0 [local|remote] [options]"
  echo ""
  echo "Options:"
  echo "  -h, --host HOST     Specify remote host(s)"
  echo "  -t, --tags TAGS     Specify tags to run"
  echo "  -v, --verbose       Increase verbosity"
  echo ""
  echo "Examples:"
  echo "  $0 local"
  echo "  $0 remote -h dev"
  echo "  $0 remote -h 'dev,staging' -t 'system,dotfiles'"
}

function validate_inventory() {
  if [[ "$1" == "remote" ]] && ! grep -q "\[remote\]" .hosts; then
    echo "Error: No remote hosts defined in .hosts file"
    echo "Please add remote hosts under the [remote] section in .hosts"
    exit 1
  fi
}

PLAYBOOK="ansible/playbook.yml"
VERBOSITY=""
LIMIT=""
TAGS=""

case "$1" in
local)
  PLAYBOOK="ansible/playbook.yml"
  ;;
remote)
  PLAYBOOK="ansible/playbook-remote.yml"
  validate_inventory "remote"
  LIMIT=${LIMIT:-"-l remote"}
  ;;
*)
  print_usage
  exit 1
  ;;
esac

shift

while [[ $# -gt 0 ]]; do
  case "$1" in
  -h | --host)
    LIMIT="-l $2"
    shift 2
    ;;
  -t | --tags)
    TAGS="--tags $2"
    shift 2
    ;;
  -v | --verbose)
    VERBOSITY="-v"
    shift
    ;;
  *)
    print_usage
    exit 1
    ;;
  esac
done

ansible-playbook -i .hosts $PLAYBOOK $LIMIT $TAGS $VERBOSITY
