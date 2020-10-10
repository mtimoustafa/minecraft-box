docker build -t minecraft-box .
docker run --detach --env-file env.list -it --rm --name mb minecraft-box:latest
