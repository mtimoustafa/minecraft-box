#!/usr/bin/env bash
set -eu

# aws_sync_interval=${AWS_SYNC_INTERVAL:-1800} # 30 minutes
minecraft_image_url="https://papermc.io/api/v1/paper/1.16.3/216/download"
java_ram_min="1024M"
java_ram_max="2048M"

# echo "[INIT] Pulling directories from S3"
# aws s3 sync "s3://$AWS_BUCKET" . --only-show-errors
# echo "[INIT] Completed S3 directory pull"

# echo "[INIT] Starting sync schedule every $aws_sync_interval seconds"
# eval "while true; do sleep $aws_sync_interval; bin/sync.sh; done &"
# sync_pid=$!

echo "[INIT] Starting WEBrick"
ruby \
  -r webrick \
  -e 'WEBrick::HTTPServer.new(:BindAddress => "0.0.0.0", :Port => 8080, :MimeTypes => {"rhtml" => "text/html"}, :DocumentRoot => Dir.pwd).start' \
  &
web_pid=$!

if [ ! -d "minecraft" ]; then
  echo "[INIT] Warning: minecraft directory doesn't exist; creating"
  mkdir minecraft
fi
cp -R minecraft-properties/. minecraft/.
cd minecraft

echo -n "[INIT] Installing Minecraft..."
curl -o minecraft.jar -s -L $minecraft_image_url
echo "done"

echo "[INIT] Starting Minecraft Server"
java -Xmx$java_ram_max -Xms$java_ram_min -jar minecraft.jar nogui &
mc_pid=$!

_term() {
  echo "[TERM] Shutting down threads"
  kill $web_pid $mc_pid
  wait $web_pid $mc_pid

  # echo "[TERM] Syncing files before shutting down"
  # bin/sync.sh
}
trap '_term' SIGTERM

wait $web_pid $mc_pid

# echo "[DONE] Syncing files before shutting down"
# bin/sync.sh
