#!/usr/bin/env bash

get_if_does_not_exist() {
  if [ ! -d $1 ] then
    mkdir -p $1
    aws s3 cp --recursive s3://$AWS_BUCKET/$1 $1
  fi
}

if [ -n "$AWS_BUCKET" ]; then
  cat << EOF > .s3cfg
[default]
access_key = ${AWS_ACCESS_KEY}
secret_key = ${AWS_SECRET_KEY}
EOF

  if aws s3 ls s3://$AWS_BUCKET 2>&1 | grep -q 'NoSuchBucket'; then
    aws s3 mb s3://$AWS_BUCKET
  fi

  get_if_does_not_exist world
  get_if_does_not_exist world_nether
  get_if_does_not_exist world_the_end
  get_if_does_not_exist plugins
  get_if_does_not_exist cache
  get_if_does_not_exist logs

  aws s3 sync . s3://$AWS_BUCKET --recursive \
    --exclude "*" \
    --include "world/*" \
    --include "world_nether/*" \
    --include "world_the_end/*" \
    --include "plugins/*" \
    --include "cache/*" \
    --include "logs/*"
fi
