xhost +local:root

#docker run --rm --net host --env="DISPLAY" --privileged -v /gevol:/gevol --name fusioncontainer geefusion:v1 && rm -rf /var/lib/apt/lists/*

docker run --rm --net host --env="DISPLAY" --privileged -v /gevol:/gevol -v /opt/google/share/tutorials/fusion:/opt/google/share/tutorials/fusion --name fusioncontainer fusiontutorial:v1 &
