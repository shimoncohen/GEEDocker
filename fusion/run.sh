#!/bin/bash

xhost +local:root

# Default values of arguments
GEVOL="/gevol"
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
    --entrypoint)
        ENTERYPOINT=1
        shift # Remove
        ;;
    esac
done

if [ ! -d $GEVOL ]; then
    echo "No such path $GEVOL" && exit 1
fi

if [ $ENTERYPOINT -eq 1 ]; then
    docker run --rm -it --entrypoint /bin/bash --net host --env="DISPLAY" --privileged -v $GEVOL/fusion:/gevol/fusion --name fusioncontainer geefusion:v1
else
    docker run --rm --net host --env="DISPLAY" --privileged -v $GEVOL/fusion:/gevol/fusion --name fusioncontainer geefusion:v1 &
fi
