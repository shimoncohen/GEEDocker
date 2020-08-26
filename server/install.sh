#!/bin/bash

# Default values of arguments
ADMIN_PASSWORD=""
ADMIN_PASSWORD_STRING=""

# Loop through arguments and process them
# Taken from: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"
do
    case $arg in
        --admin_password=*)
        ADMIN_PASSWORD="${arg#*=}"
        shift # Remove
        ;;
        --admin_password)
        ADMIN_PASSWORD="$2"
        shift # Remove
        shift
        ;;
    esac
done

PERSISTENT_VOLUME="gee-server-storage"

# Inspect persistent volume
RESULT=$(docker volume inspect $PERSISTENT_VOLUME)

# Create a persistent volume for the server if does not exist
if [[ $RESULT == "[]" ]]; then
	docker volume create $PERSISTENT_VOLUME
fi;

# Check if a password was given
if [ -n "$ADMIN_PASSWORD" ]; then
	ADMIN_PASSWORD_STRING="--build-arg ADMIN_PASSWORD=$ADMIN_PASSWORD"
fi;

# Build the image
docker build --rm $ADMIN_PASSWORD_STRING -t geeserver:v1 -f Dockerfile .
