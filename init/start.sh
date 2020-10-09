#!/usr/bin/env bash
set -eu

aws_sync_interval=${AWS_SYNC_INTERVAL:-1800} # 30 minutes

if [ -z "$NGROK_API_TOKEN" ]; then
  echo "You must set the NGROK_API_TOKEN config var to create a TCP tunnel!"
  exit 1
fi

echo -n "-----> Installing ngrok..."
curl --silent -o ngrok.zip -L "https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip"
unzip ngrok.zip > /dev/null 2>&1
rm ngrok.zip
echo "done"

echo -n "-----> Installing Minecraft..."
minecraft_url="https://papermc.io/api/v1/paper/1.16.3/216/download"
curl -o minecraft.jar -s -L $minecraft_url
echo "done"

echo "-----> Starting ngrok TCP tunnel"
ngrok_cmd="./ngrok start -authtoken $NGROK_API_TOKEN -log stdout -config=ngrok.yml --all"
eval "$ngrok_cmd | tee ngrok.log &"
ngrok_pid=$!

# Start minecraft server
init/minecraft.sh &
mc_pid=$!

echo "-----> Starting sync"
eval "while true; init/sync.sh; do sleep $aws_sync_interval; done &"
sync_pid=$!

# Set up graceful shutdown
_term() {
  echo "-----> Syncing files before shutting down"
  init/sync.sh
}
trap _term SIGTERM
trap 'kill $ngrok_pid $sync_pid $sync_pid' SIGTERM

wait $mc_pid
