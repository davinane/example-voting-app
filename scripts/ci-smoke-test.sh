#!/usr/bin/env bash
set -euo pipefail

cleanup() {
  docker compose down --remove-orphans
}
trap cleanup EXIT

docker compose up -d --build --wait

for port in 8080 8081; do
  echo "Checking http://127.0.0.1:$port"

  success=false

  for attempt in $(seq 1 30); do
    if curl --fail --silent --output /dev/null \
      "http://127.0.0.1:$port"; then
      success=true
      break
    fi
    sleep 2
  done

  if [ "$success" != true ]; then
    echo "FAIL: Application on port $port did not respond."
    exit 1
  fi
done

echo "PASS: Vote and Result applications are responding."
