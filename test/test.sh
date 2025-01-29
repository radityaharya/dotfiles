#!/bin/bash

set -e

echo "Building and running tests..."
docker compose -f test/docker-compose.yml up --build --abort-on-container-exit

CONTAINER_ID=$(docker compose ps -q dotfiles-test)
if [ -n "$CONTAINER_ID" ]; then
  EXIT_CODE=$(docker inspect "$CONTAINER_ID" -f '{{.State.ExitCode}}')
else
  echo "Error: Container ID not found"
  EXIT_CODE=1
fi

docker compose down

exit ${EXIT_CODE:-1}
