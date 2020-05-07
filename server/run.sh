VOLUME_CONNECT="/gevol/server:/gevol/server"
STORAGE_MOUNT="source=gee-server-storage,target=/var/opt/google/pgsql/data"

docker run --rm --privileged -v $VOLUME_CONNECT --mount $STORAGE_MOUNT --name servercontainer -p 8081:80 geeserver:v1 &