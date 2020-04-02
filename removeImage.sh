if [ "$#" -eq 0 ]; then
	echo "Error. Please specify the name of an image."
	exit
fi

IMAGE_NAME=$1

# Extract image id
IMAGE_INFO=$(docker image ls -a | grep -w "$IMAGE_NAME")

# Check if image exists
if [[ $IMAGE_INFO ]]; then 
	echo "Image exists."
else 
	echo "Image does not exist."
fi

# Split image information to array
IMAGE_INFO=($IMAGE_INFO)

# Get image ID
IMAGE_ID=${IMAGE_INFO[2]}

# Remove image
docker rmi $IMAGE_ID
