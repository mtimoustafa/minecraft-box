#!/usr/bin/env bash
set -eu

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

# Start the TCP tunnel
echo "-----> Starting ngrok"
ngrok_cmd="./ngrok start -authtoken $NGROK_API_TOKEN -log stdout --log-level debug -config=ngrok.yml --all"
eval "$ngrok_cmd | tee ngrok.log &"
ngrok_pid=$!

trap "kill $ngrok_pid" SIGTERM
trap "kill -9 $ngrok_pid; exit" SIGKILL

# Start minecraft server
init/minecraft.sh
