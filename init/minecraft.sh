#!/usr/bin/env bash
set -eu

mc_port=25566
dynmap_port=8123

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

# Do an inline sync first, then start the background job
echo "-----> Starting sync..."
init/sync.sh
echo "done"
eval "while true; do sleep ${AWS_SYNC_INTERVAL:-60}; init/sync.sh; done &"
sync_pid=$!

# Start the TCP tunnel
echo "-----> Starting ngrok"
ngrok_cmd="./ngrok start -authtoken $NGROK_API_TOKEN -log stdout --log-level debug -config=ngrok.yml --all"
eval "$ngrok_cmd | tee ngrok.log &"
ngrok_pid=$!


# Create or complete Minecraft server configuration
echo "server-port=${mc_port}" >> /app/server.properties
test ! -f eula.txt && echo "eula=true" > eula.txt
for f in banned-players banned-ips ops; do
  test ! -f $f.json && echo -n "[]" > $f.json
done

echo "-----> Starting Minecraft Server on port $mc_port"
eval "java -Xmx384m -Xms384m -jar minecraft.jar nogui &"
main_pid=$!

trap "kill $ngrok_pid $main_pid $sync_pid" SIGTERM
trap "kill -9 $ngrok_pid $main_pid $sync_pid; exit" SIGKILL

# Start web server
./web.sh
