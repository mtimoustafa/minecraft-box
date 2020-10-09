#!/usr/bin/env bash
set -eu

aws_sync_interval=${AWS_SYNC_INTERVAL:-1800} # 30 minutes

get_if_does_not_exist() {
  for dir in "$@"; do
    if [ ! -d "$dir" ]; then
      mkdir -p "$dir"
      aws s3 cp --recursive "s3://$AWS_BUCKET/$dir" "$dir"
    fi
  done
}

sync_s3() {
  if [ -n "$AWS_BUCKET" ]; then
    if aws s3 ls "s3://$AWS_BUCKET" 2>&1 | grep -q 'NoSuchBucket'; then
      aws s3 mb "s3://$AWS_BUCKET"
    fi

    get_if_does_not_exist \
      world \
      world_nether \
      world_the_end \
      plugins \
      cache \
      logs

    aws s3 sync . "s3://$AWS_BUCKET"
      --only-show-errors \
      --exclude "*" \
      --include "world/*" \
      --include "world_nether/*" \
      --include "world_the_end/*" \
      --include "plugins/*" \
      --include "cache/*" \
      --include "logs/*"
  fi
}

_term() {
  echo "-----> Syncing files before shutting down"
  init/sync.sh
}
trap _term SIGTERM

echo "-----> Starting sync"
while true; do
  sync_s3
  sleep $aws_sync_interval
done
