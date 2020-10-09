#!/usr/bin/env bash
set -eu

aws_sync_interval=${AWS_SYNC_INTERVAL:-1800} # 30 minutes

_term() {
  echo "-----> Syncing files before shutting down"
  init/sync.sh
}
trap _term SIGTERM

echo "-----> Starting sync schedule every $aws_sync_interval seconds"
while true; do
  sleep $aws_sync_interval
  init/sync.sh
done
