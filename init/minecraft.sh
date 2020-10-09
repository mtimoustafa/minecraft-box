#!/usr/bin/env bash
set -eu

mc_port=25566

# Create or complete Minecraft server configuration
echo "server-port=${mc_port}" >> /app/server.properties
test ! -f eula.txt && echo "eula=true" > eula.txt
for f in banned-players banned-ips ops; do
  test ! -f $f.json && echo -n "[]" > $f.json
done

echo "-----> Starting Minecraft Server on port $mc_port"
eval "java -Xmx512m -Xms512m -jar minecraft.jar nogui &"
main_pid=$!

trap 'kill $main_pid' SIGTERM

# Start web server
init/web.sh
