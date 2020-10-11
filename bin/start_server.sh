#!/usr/bin/env bash
set -eu

aws_sync_interval=${AWS_SYNC_INTERVAL:-1800} # 30 minutes
java_ram="1024M"

echo "[INIT] Pulling directories from S3"
aws s3 sync "s3://$AWS_BUCKET" .
echo "[INIT] Completed S3 directory pull"

echo -n "[INIT] Installing Minecraft..."
minecraft_url="https://papermc.io/api/v1/paper/1.16.3/216/download"
curl -o minecraft.jar -s -L $minecraft_url
echo "done"

echo "[INIT] Starting sync schedule every $aws_sync_interval seconds"
eval "while true; do sleep $aws_sync_interval; bin/sync.sh; done &" 
sync_pid=$!

echo "[INIT] Starting WEBrick"
ruby \
  -r webrick \
  -e 'WEBrick::HTTPServer.new(:BindAddress => "0.0.0.0", :Port => 8080, :MimeTypes => {"rhtml" => "text/html"}, :DocumentRoot => Dir.pwd).start' \
  &
web_pid=$!

# Create or complete Minecraft server configuration
test ! -f eula.txt && echo "eula=true" > eula.txt
for f in banned-players banned-ips ops; do
  test ! -f $f.json && echo -n "[]" > $f.json
done

echo "[INIT] Starting Minecraft Server"
java -Xmx$java_ram -Xms$java_ram -jar minecraft.jar nogui &
mc_pid=$!

_term() {
  echo "[TERM] Syncing files before shutting down"
  bin/sync.sh &
  term_sync_pid=$!

  echo "[TERM] Shutting down threads"
  kill $sync_pid $web_pid $mc_pid

  wait $term_sync_pid
}
trap '_term' SIGTERM

wait $sync_pid $web_pid $mc_pid
