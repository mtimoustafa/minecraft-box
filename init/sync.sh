#!/usr/bin/env bash
set -eu

get_if_does_not_exist() {
  for dir in "$@"; do
    if [ ! -d "$dir" ]; then
      mkdir -p "$dir"
      aws s3 cp --recursive "s3://$AWS_BUCKET/$dir" "$dir"
    fi
  done
}

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

  aws s3 sync . "s3://$AWS_BUCKET" --only-show-errors \
    --exclude "*" \
    --include "world/*" \
    --include "world_nether/*" \
    --include "world_the_end/*" \
    --include "plugins/*" \
    --include "cache/*" \
    --include "logs/*"
fi
