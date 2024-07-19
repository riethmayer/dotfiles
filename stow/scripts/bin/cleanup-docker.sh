#!/usr/bin/env bash
# remove untagged images
docker rmi $(docker images -q)
# remove unused volumes
$(docker volume ls -q ) && docker volume rm $(docker volume ls -q )
# `shotgun` remove unused networks
# docker network rm $(docker network ls | grep "_default")
# remove stopped + exited containers, I skip Exit 0 as I have old scripts using data containers.
docker ps -q -a -f status=exited | xargs -n 100 docker rm -v
# docker rm -v $(docker ps -a | grep "Exit [1-255]" | awk '{ print $1 }')
# run spotify docker-gc
# docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc spotify/docker
