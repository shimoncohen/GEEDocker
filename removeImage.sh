#!/bin/bash

if [ "$#" -eq 0 ] || [ -z "${1:-}" ]; then
	echo "Error. Please specify the name of an image."
	exit
fi

IMAGE_NAME=$1

# Extract image id. docker's positional filter is a glob (*, ?, []), not
# an exact match, but it respects repository boundaries unlike grep -w.
IMAGE_ID=$(docker image ls -a -q "$IMAGE_NAME")

# Check if image exists
if [[ $IMAGE_ID ]]; then
	echo "Image exists."
else
	echo "Image does not exist."
fi

# Remove image
docker rmi $IMAGE_ID
