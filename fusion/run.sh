xhost +local:root

docker run --rm --net host --env="DISPLAY" --privileged -v /gevol/fusion:/gevol/fusion --name fusioncontainer geefusion:v1 &