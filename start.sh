docker build -t minecraft-box .
docker rm -f minecraft-box
docker run --detach --rm --env-file env.list -it -p 25566:25566 -p 8080:8080 -p 8123:8123 --name minecraft-box minecraft-box:latest
