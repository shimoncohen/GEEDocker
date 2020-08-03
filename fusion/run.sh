#!/bin/bash

xhost +local:root

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
	docker run --rm -it --entrypoint /bin/bash --net host --env="DISPLAY" --privileged -v /gevol/fusion:/gevol/fusion --name fusioncontainer geefusion:v1
else
	docker run --rm --net host --env="DISPLAY" --privileged -v /gevol/fusion:/gevol/fusion --name fusioncontainer geefusion:v1 &
fi
