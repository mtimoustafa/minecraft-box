#!/usr/bin/env bash
set -eu

get_if_does_not_exist() {
  echo "Pulling directories from S3"

  for dir in "$@"; do
    if [ ! -d "$dir" ]; then
      echo "Creating $dir directory"
      mkdir -p "$dir"
      aws s3 cp --recursive --only-show-errors "s3://$AWS_BUCKET/$dir" "$dir"
    fi
  done

  echo "Completed S3 directory pull"
}

if [ -n "$AWS_BUCKET" ]; then
  if aws s3 ls "s3://$AWS_BUCKET" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "Bucket $AWS_BUCKET not found; creating"
    aws s3 mb "s3://$AWS_BUCKET"
  fi

  get_if_does_not_exist \
    world \
    world_nether \
    world_the_end \
    plugins \
    cache \
    logs

  echo "Syncing to S3"
  ls -lah .
  pwd
  aws s3 sync /app "s3://$AWS_BUCKET" --dryrun --exclude "*" --include "world/*"
    # --include "world_nether/*" \
    # --include "world_the_end/*" \
    # --include "plugins/*" \
    # --include "cache/*" \
    # --include "logs/*"
  echo "Sync completed"
else
  echo "Failed to sync: could not find $AWS_BUCKET"
fi
