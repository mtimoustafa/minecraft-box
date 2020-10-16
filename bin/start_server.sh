#!/usr/bin/env bash
set -eu

minecraft_image_url="https://papermc.io/api/v1/paper/1.16.3/216/download"
java_ram_min="1024M"
java_ram_max="2048M"

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
mkdir -p minecraft-properties && rsync -r minecraft-properties/. minecraft/.
mkdir -p plugins && rsync -r plugins/. minecraft/plugins/.
cd minecraft

echo "[INIT] Installing Minecraft"
curl -o minecraft.jar -s -L $minecraft_image_url

echo "[INIT] Starting Minecraft Server"
java -Xmx$java_ram_max -Xms$java_ram_min -jar minecraft.jar nogui &
mc_pid=$!

_term() {
  echo "[TERM] Shutting down threads"
  kill $web_pid $mc_pid
  wait $web_pid $mc_pid
}
trap '_term' SIGTERM

wait $web_pid $mc_pid
