#!/bin/bash

# Default values of arguments
GEVOL="/gevol"
ENTERYPOINT=0
AUTHORIZED_KEYS=""

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
    --authorized_keys=*)
        AUTHORIZED_KEYS="${arg#*=}"
        shift
        ;;
    --authorized_keys)
        AUTHORIZED_KEYS="$2"
        shift
        shift
        ;;
    esac
done

if [ ! -d $GEVOL ]; then
    echo "No such path $GEVOL" && exit 1
fi

if [ ! -s "$AUTHORIZED_KEYS" ]; then
    echo "--authorized_keys <path> is required: an SSH public key file for root login" && exit 1
fi
KEYS_MOUNT="-v $(realpath "$AUTHORIZED_KEYS"):/run/secrets/authorized_keys:ro"

if [ $ENTERYPOINT -eq 1 ]; then
    docker run --rm -it --entrypoint /bin/bash --privileged -p 127.0.0.1:30022:22 $KEYS_MOUNT -v $GEVOL/fusion:/gevol/fusion --name fusioncontainer geefusion-ssh:v1
else
    docker run --rm --privileged -p 127.0.0.1:30022:22 $KEYS_MOUNT -v $GEVOL/fusion:/gevol/fusion --name fusioncontainer geefusion-ssh:v1 &
fi
