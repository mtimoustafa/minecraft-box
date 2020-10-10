#!/usr/bin/env bash
set -eu

# Create or complete Minecraft server configuration
test ! -f eula.txt && echo "eula=true" > eula.txt
for f in banned-players banned-ips ops; do
  test ! -f $f.json && echo -n "[]" > $f.json
done

echo "-----> Starting Minecraft Server"
$ram=1024M
java -Xmx$ram -Xms$ram -jar minecraft.jar nogui
