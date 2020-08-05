#!/bin/bash

VOLUME_CONNECT="/gevol/server:/gevol/server"
STORAGE_MOUNT="source=gee-server-storage,target=/var/opt/google/pgsql/data"

# Default values of arguments
ENTERYPOINT=0

# Loop through arguments and process them
# Taken from: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"
do
    case $arg in
        --entrypoint)
        ENTERYPOINT=1
        shift # Remove
        ;;
    esac
done

if [ $ENTERYPOINT -eq 1 ]; then
    docker run --rm -it --entrypoint /bin/bash --privileged -v $VOLUME_CONNECT --mount $STORAGE_MOUNT --name servercontainer -p 8081:80 geeserver:v1
else
    docker run --rm --privileged -v $VOLUME_CONNECT --mount $STORAGE_MOUNT --name servercontainer -p 8081:80 geeserver:v1 &
fi