#!/bin/bash

# Older images set PermitRootLogin yes and allowed root password login
if docker image inspect geefusion-ssh:v1 >/dev/null 2>&1 &&
   docker run --pull never --rm --entrypoint grep geefusion-ssh:v1 -q '^PermitRootLogin yes' /etc/ssh/sshd_config; then
    docker rmi geefusion-ssh:v1 || { echo "Could not remove the old geefusion-ssh:v1 image. Stop the container using it and run install.sh again." >&2; exit 1; }
fi

docker build --rm -t geefusion-ssh:v1 -f Dockerfile .
