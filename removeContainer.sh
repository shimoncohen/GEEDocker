if [ "$#" -eq 0 ]; then
	echo "Error. Please specify the name pf  a container."
	exit
fi

CONTAINER_NAME=$1
docker rm -f $CONTAINER_NAME
