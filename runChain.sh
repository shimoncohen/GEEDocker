#!/bin/bash

function runIfImageDoesNotExists {

    local IMAGE_NAME=$1
    # Check if image does not exists
    if [[ "$(docker images -q $IMAGE_NAME 2>/dev/null)" == "" ]]; then
        # Run given command
        "${@:2}"
    fi
}

# Default values of arguments
BUILD_TAG=""
BUILD_TAG_STRING=""
SHOULD_TEST=0
INSTALL_TUTORIAL=0

# Loop through arguments and process them
# Taken from: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"; do
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
    --test)
        SHOULD_TEST=1
        shift # Remove --test from processing
        ;;
    --tutorial)
        INSTALL_TUTORIAL=1
        shift # Remove --tutorial from processing
        ;;
    esac
done

# Check if a build tag was given
if [ -n "$BUILD_TAG" ]; then
    BUILD_TAG_STRING="--tag $BUILD_TAG"
fi

# Build google earth enterprise
cd geeBuild && runIfImageDoesNotExists geebuild:v1 bash build.sh $BUILD_TAG_STRING

# Run tests
if [ "$SHOULD_TEST" -eq 1 ]; then
    cd ../geeTest && bash run.sh
fi

# Install server
cd ../server && runIfImageDoesNotExists geeserver:v1 bash install.sh

# Install fusion
cd ../fusion && runIfImageDoesNotExists geefusion:v1 bash install.sh

# Check if should install tutorial files
if [ "$INSTALL_TUTORIAL" -eq 1 ]; then
    # Download tutorial files to fusion
    cd tutorial && runIfImageDoesNotExists fusiontutorial:v1 bash install.sh
fi
