#!/bin/bash

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
    docker run --rm -it --entrypoint /bin/bash --privileged -p 30022:22 -v $GEVOL/fusion:/gevol/fusion --name fusioncontainer geefusion-ssh:v1
else
    docker run --rm --privileged -p <wanted_port>:22 -v $GEVOL/fusion:/gevol/fusion --name fusioncontainer geefusion-ssh:v1 &
fi
