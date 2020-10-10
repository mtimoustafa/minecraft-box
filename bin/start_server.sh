#!/usr/bin/env bash
set -eu

bin/get_assets.sh

echo -n "-----> Installing Minecraft..."
minecraft_url="https://papermc.io/api/v1/paper/1.16.3/216/download"
curl -o minecraft.jar -s -L $minecraft_url
echo "done"

_term() {
  echo "-----> Syncing files before shutting down"
  bin/sync.sh
}
trap _term SIGTERM

bin/start_sync.sh &

bin/minecraft.sh
