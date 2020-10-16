#!/bin/sh
docker build -t minecraft-box .
docker rm -f minecraft-box
docker run \
  --detach \
  --rm \
  -it \
  -p 25566:25566 -p 8080:8080 -p 8123:8123 \
  -v $(pwd)/minecraft:/minecraft-box/minecraft \
  --name minecraft-box \
  minecraft-box:latest
docker logs -f minecraft-box
