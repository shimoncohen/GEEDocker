
#docker build --rm --build-arg user=$USER --build-arg uid=$(id -u) --build-arg gid=$(id -g) -t fusion:v1 -f Dockerfile .
docker build --rm -t geefusion:v1 -f Dockerfile.slim .

#xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f /tmp/.docker.xauth nmerge -

#XSOCK=/tmp/.X11-unix
#XAUTH=/tmp/.docker.xauth

#docker run -e DISPLAY=unix$DISPLAY --privileged -v $XSOCK -v $XAUTH:/$XAUTH:rw -e XAUTHORITY=$XAUTH --name fusioncontainer -p 8082:80 geefusion:v1 && rm -rf /var/lib/apt/lists/*
