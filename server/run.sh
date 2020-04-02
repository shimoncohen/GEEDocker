#docker run --privileged --name servercontainer -p 8081:80 geeserver:v1 && rm -rf /var/lib/apt/lists/*

docker run --rm --privileged -v /gevol:/gevol --name servercontainer -p 8081:80 geeserver:v1 &
