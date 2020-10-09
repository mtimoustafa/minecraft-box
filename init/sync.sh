#!/usr/bin/env bash
set -eu

if [ -n "$AWS_BUCKET" ]; then
  if aws s3 ls "s3://$AWS_BUCKET" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "Bucket $AWS_BUCKET not found; creating"
    aws s3 mb "s3://$AWS_BUCKET"
  fi

  echo "Syncing to S3"
  aws s3 sync . "s3://$AWS_BUCKET" \
    --only-show-errors \
    --exclude "*" \
    --include "world/*" \
    --include "world_nether/*" \
    --include "world_the_end/*" \
    --include "plugins/*" \
    --include "cache/*" \
    --include "logs/*"
  echo "Sync completed"
else
  echo "Failed to sync: could not find $AWS_BUCKET"
fi

exit
