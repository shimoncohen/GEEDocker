#!/bin/bash

xhost +local:root

# Default values of arguments
GEVOL="/gevol"
TUTORIAL_SOURCE_VOLUME="/opt/google/share/tutorials/fusion"
ENTERYPOINT=0

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
    --tutorial_volume=*)
        TUTORIAL_SOURCE_VOLUME="${arg#*=}"
        TUTORIAL_SOURCE_VOLUME=$(realpath $TUTORIAL_SOURCE_VOLUME)
        shift # Remove
        ;;
    --tutorial_volume)
        TUTORIAL_SOURCE_VOLUME="$2"
        TUTORIAL_SOURCE_VOLUME=$(realpath $TUTORIAL_SOURCE_VOLUME)
        shift # Remove
        shift
        ;;
    --entrypoint)
        ENTERYPOINT=1
        shift # Remove
        ;;
    esac
done

if [ ! -d $GEVOL ]; then
    echo "No such path $GEVOL" && exit 1
fi

if [ ! -d $TUTORIAL_SOURCE_VOLUME ]; then
    echo "No such path $TUTORIAL_SOURCE_VOLUME" && exit 1
fi

if [ $ENTERYPOINT -eq 1 ]; then
    docker run --rm -it --entrypoint /bin/bash --net host --env="DISPLAY" --privileged -v $GEVOL/fusion:/gevol/fusion -v $TUTORIAL_SOURCE_VOLUME:/opt/google/share/tutorials/fusion --name fusioncontainer fusiontutorial:v1
else
    docker run --rm -d --net host --env="DISPLAY" --privileged -v $GEVOL/fusion:/gevol/fusion -v $TUTORIAL_SOURCE_VOLUME:/opt/google/share/tutorials/fusion --name fusioncontainer fusiontutorial:v1 &
fi
