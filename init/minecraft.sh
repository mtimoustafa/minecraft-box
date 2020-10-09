#!/usr/bin/env bash
set -eu

mc_port=25566
aws_sync_interval=${AWS_SYNC_INTERVAL:-1800} # 30 minutes

# Do an inline sync first, then start the background job
echo "-----> Starting sync"
init/sync.sh
eval "while true; do sleep $aws_sync_interval; init/sync.sh; done &"
sync_pid=$!

_term() {
  echo "Sync files before shutting down..."
  init/sync.sh
}
trap _term SIGTERM

# Create or complete Minecraft server configuration
echo "server-port=${mc_port}" >> /app/server.properties
test ! -f eula.txt && echo "eula=true" > eula.txt
for f in banned-players banned-ips ops; do
  test ! -f $f.json && echo -n "[]" > $f.json
done

echo "-----> Starting Minecraft Server on port $mc_port"
eval "java -Xmx512m -Xms512m -jar minecraft.jar nogui &"
main_pid=$!

trap "kill $main_pid $sync_pid" SIGTERM
trap "kill -9 $main_pid $sync_pid; exit" SIGKILL

# Start web server
./web.sh
