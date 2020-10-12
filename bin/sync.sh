#!/usr/bin/env bash
set -u

if [ -n "$AWS_BUCKET" ]; then
  if aws s3 ls "s3://$AWS_BUCKET" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "[SYNC] Bucket $AWS_BUCKET not found; creating"
    aws s3 mb "s3://$AWS_BUCKET"
  fi

  echo "[SYNC] Syncing to S3"
  aws s3 sync . "s3://$AWS_BUCKET" \
    --only-show-errors \
    --exclude "*" \
    --include "world/*" \
    --include "world_nether/*" \
    --include "world_the_end/*" \
    --include "plugins/*" \
    --include "cache/*" \
    --include "logs/*"
  echo "[SYNC] Sync completed"
else
  echo "[SYNC] Failed to sync: could not find $AWS_BUCKET"
fi
