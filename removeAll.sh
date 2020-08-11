### Stop running containers ###

bash removeContainer.sh serverContainer

bash removeContainer.sh fusionContainer

### Remove images ###

# Remove server
bash removeImage.sh geeserver

# Remove fusion
bash removeImage.sh geefusion

# Remove tutorial
bash removeImage.sh fusiontutorial

# Remove fusion-ssh
bash removeImage.sh geefusion-ssh

# Remove tests
bash removeImage.sh geetest

# Remove build
bash removeImage.sh geebuild

# Remove stopped containers
echo 'Removing stopped containers'
docker container prune

# Remove all <None> images (dangling)
docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
