#!/bin/bash

# Default values of arguments
BUILD_TAG=""
BUILD_TAG_STRING=""

# Loop through arguments and process them
# Taken from: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"
do
    case $arg in
        --tag=*)
        BUILD_TAG="${arg#*=}"
        shift # Remove
        ;;
        --tag)
        BUILD_TAG="$2"
        shift # Remove
        shift
        ;;
    esac
done

# Check if a build tag was given
if [ -n "$BUILD_TAG" ]; then
	BUILD_TAG_STRING="--build-arg TAG=$BUILD_TAG"
fi;
echo $BUILD_TAG
docker build --rm --no-cache $BUILD_TAG_STRING -t geebuild:v1 -f Dockerfile .
