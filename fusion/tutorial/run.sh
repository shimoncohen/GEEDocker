xhost +local:root

docker run --rm --net host --env="DISPLAY" --privileged -v /gevol/fusion:/gevol/fusion -v /opt/google/share/tutorials/fusion:/opt/google/share/tutorials/fusion --name fusioncontainer fusiontutorial:v1 &