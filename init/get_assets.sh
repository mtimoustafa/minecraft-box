#!/usr/bin/env bash
set -eu

echo "Pulling directories from S3"
aws s3 sync "s3://$AWS_BUCKET/world" /app/world --dryrun --only-show-errors
# --exclude "*" --include "world/*"
  # --include "world_nether/*" \
  # --include "world_the_end/*" \
  # --include "plugins/*" \
  # --include "cache/*" \
  # --include "logs/*"
echo "Completed S3 directory pull"

exit
