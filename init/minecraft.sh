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
java -Xmx512M -Xms384M -jar minecraft.jar nogui
