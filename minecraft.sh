#!/usr/bin/env bash
set -eu

indent() {
  sed -u 's/^/       /'
}

mc_port=25566
port=${1:-${PORT:-8080}}

if [ -z "$NGROK_API_TOKEN" ]; then
  echo "You must set the NGROK_API_TOKEN config var to create a TCP tunnel!"
  exit 1
fi

echo -n "-----> Installing ngrok... "
curl --silent -o ngrok.zip -L "https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip" | indent
unzip ngrok.zip > /dev/null 2>&1
echo "done"

echo -n "-----> Installing Minecraft... "
minecraft_url="https://launcher.mojang.com/v1/objects/a412fd69db1f81db3f511c1463fd304675244077/server.jar"
curl -o minecraft.jar -s -L $minecraft_url
echo "done"

# Start the TCP tunnel
ngrok_cmd="./ngrok tcp -authtoken $NGROK_API_TOKEN -log stdout --log-level debug ${mc_port}"
echo "Starting ngrok..."
eval "$ngrok_cmd | tee ngrok.log &"
ngrok_pid=$!

# Do an inline sync first, then start the background job
echo "Starting sync..."
chmod +x ./sync.sh && ./sync.sh
eval "while true; do sleep ${AWS_SYNC_INTERVAL:-60}; ./sync.sh; done &"
sync_pid=$!

# create server config
echo "server-port=${mc_port}" >> /app/server.properties
for f in whitelist banned-players banned-ips ops; do
  test ! -f $f.json && echo -n "[]" > $f.json
done

limit=$(ulimit -u)
case $limit in
  512)   # 2X Dyno
  heap="768m"
  ;;
  32768) # PX Dyno
  heap="4g"
  ;;
  *)     # 1X Dyno
  heap="384m"
  ;;
esac

echo "Starting: minecraft ${mc_port}"
eval "minecraft java -Xmx${heap} -Xms${heap} -jar minecraft.jar nogui | tee mc_server.log &"
main_pid=$!

# Flush the logfile every second, and ensure that the logfile exists
screen -X "logfile 1" && sleep 1

# echo "Tailing log"
# eval "tail -f screenlog.0 &"
# tail_pid=$!

trap "kill $ngrok_pid $main_pid $sync_pid" SIGTERM
trap "kill -9 $ngrok_pid $main_pid $sync_pid; exit" SIGKILL

eval "ruby -rwebrick -e'WEBrick::HTTPServer.new(:BindAddress => \"0.0.0.0\", :Port => ${port}, :MimeTypes => {\"rhtml\" => \"text/html\"}, :DocumentRoot => Dir.pwd).start'"
