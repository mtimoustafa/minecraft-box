#!/usr/bin/env bash

if [ -n "$AWS_BUCKET" ]; then
  cat << EOF > .s3cfg
[default]
access_key = ${AWS_ACCESS_KEY}
secret_key = ${AWS_SECRET_KEY}
EOF

  if [ -d world ]; then
    s3cmd sync world/ s3://${AWS_BUCKET}/world/
  else
    mkdir -p world
    cd world
    s3cmd get --recursive s3://${AWS_BUCKET}/world/
    cd ..
  fi

  if [ -d world_nether ]; then
    s3cmd sync world_nether/ s3://${AWS_BUCKET}/world_nether/
  else
    mkdir -p world_nether
    cd world_nether
    s3cmd get --recursive s3://${AWS_BUCKET}/world_nether/
    cd ..
  fi

  if [ -d world_the_end ]; then
    s3cmd sync world_the_end/ s3://${AWS_BUCKET}/world_the_end/
  else
    mkdir -p world_the_end
    cd world_the_end
    s3cmd get --recursive s3://${AWS_BUCKET}/world_the_end/
    cd ..
  fi

  if [ -d plugins ]; then
    s3cmd sync plugins/ s3://${AWS_BUCKET}/plugins/
  else
    mkdir -p plugins
    cd plugins
    s3cmd get --recursive s3://${AWS_BUCKET}/plugins/
    cd ..
  fi

  if [ -d cache ]; then
    s3cmd sync cache/ s3://${AWS_BUCKET}/cache/
  else
    mkdir -p cache
    cd cache
    s3cmd get --recursive s3://${AWS_BUCKET}/cache/
    cd ..
  fi

  if [ -d logs ]; then
    s3cmd sync logs/ s3://${AWS_BUCKET}/logs/
  else
    mkdir -p logs
    cd logs
    s3cmd get --recursive s3://${AWS_BUCKET}/logs/
    cd ..
  fi

  rm .s3cfg
fi
