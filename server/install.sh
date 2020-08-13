#!/bin/bash

PERSISTENT_VOLUME="gee-server-storage"

# Inspect persistent volume
RESULT=$(docker volume inspect $PERSISTENT_VOLUME)

# Create a persistent volume for the server if does not exist
if [[ $RESULT == "[]" ]]; then
	docker volume create $PERSISTENT_VOLUME
fi;

# Build the image
docker build --rm --build-arg ADMIN_PASSWORD=<your_password> -t geeserver:v1 -f Dockerfile .
