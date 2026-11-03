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

# Grant X access to root only, and revoke it only if this script added it
XHOST_ADDED=0
if ! xhost | grep -qx 'SI:localuser:root'; then
    xhost +si:localuser:root && XHOST_ADDED=1
fi
xhost_revoke() {
    if [ $XHOST_ADDED -eq 1 ]; then
        xhost -si:localuser:root
    fi
}

if [ $ENTERYPOINT -eq 1 ]; then
    trap xhost_revoke EXIT
    docker run --rm -it --entrypoint /bin/bash --net host --env="DISPLAY" --privileged -v $GEVOL/fusion:/gevol/fusion --name fusioncontainer geefusion:v1
else
    # The watcher outlives the script; ignore HUP so closing the terminal does not skip the revoke
    (
        trap '' HUP
        docker run --rm --net host --env="DISPLAY" --privileged -v $GEVOL/fusion:/gevol/fusion --name fusioncontainer geefusion:v1
        xhost_revoke
    ) &
fi
