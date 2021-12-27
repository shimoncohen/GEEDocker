#!/bin/bash

# Default values of arguments
GEVOL="/gevol"
PGVOL="-v $GEVOL/data:/var/opt/google/pgsql/data"
ENTERYPOINT=0
HOST=""

# Loop through arguments and process them
# Taken from: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"; do
    case $arg in
    --gevol=*)
        GEVOL="${arg#*=}"
        GEVOL=$(realpath $GEVOL)
        shift # Remove
        ;;
    --gevol)
        GEVOL="$2"
        GEVOL=$(realpath $GEVOL)
        shift # Remove
        shift
        ;;
    --entrypoint)
        ENTERYPOINT=1
        shift # Remove
        ;;
    --host=*)
        HOST="${arg#*=}"
        shift # Remove
        ;;
    --host)
        HOST="$2"
        shift # Remove
        shift
        ;;
    esac
done

if [ ! -d $GEVOL ]; then
    echo "No such path $GEVOL" && exit 1
fi

ATTACH_DOCKER_FLAG="-d"
ATTACH_HOST_FLAG=""

docker_command_str="docker run \
    %s \
    %s \
    -v $GEVOL/server:/gevol/server \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    %s \
    --name servercontainer \
    -p 8081:80 \
    geeserver-slim:v1"

docker_command=$(printf "$docker_command_str" "$ATTACH_DOCKER_FLAG" "$ATTACH_HOST_FLAG" "")

# If pgdata isn't present, then copy the initial files
if [ ! -d "/gevol/data" ]; then
    $docker_command
    sudo docker cp servercontainer:/var/opt/google/pgsql/data /gevol/data
    docker rm -f servercontainer
fi

# Edit entrypoint if requested
if [ $ENTERYPOINT -eq 1 ]; then
    ATTACH_DOCKER_FLAG="--entrypoint /bin/bash -it"
fi

# Edit host if requested
if [ ! -z $HOST ]; then
    ATTACH_HOST_FLAG="-h $HOST"
fi

docker_command=$(printf "$docker_command_str" "$ATTACH_DOCKER_FLAG" "$ATTACH_HOST_FLAG" "$PGVOL")
$docker_command
