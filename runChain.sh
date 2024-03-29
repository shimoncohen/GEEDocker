function runIfImageDoesNotExists {

    local IMAGE_NAME=$1
    # Check if image does not exists
    if [[ "$(docker images -q $IMAGE_NAME 2>/dev/null)" == "" ]]; then
        # Run given command
        "${@:2}"
    fi
}

# Default values of arguments
BUILD_TAG=""
BUILD_TAG_STRING=""
SHOULD_TEST=0
INSTALL_TUTORIAL=0
ADMIN_PASSWORD=""
ADMIN_PASSWORD_STRING=""

# Loop through arguments and process them
# Taken from: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"; do
    case $arg in
    --tag=*)
        BUILD_TAG="${arg#*=}"
        shift # Remove
        ;;
    --tag)
        BUILD_TAG="$2"
        shift # Remove
        shift
        ;;
    --test)
        SHOULD_TEST=1
        shift # Remove --test from processing
        ;;
    --tutorial)
        INSTALL_TUTORIAL=1
        shift # Remove --tutorial from processing
        ;;
    --admin_password=*)
        ADMIN_PASSWORD="${arg#*=}"
        shift # Remove
        ;;
    --admin_password)
        ADMIN_PASSWORD="$2"
        shift # Remove
        shift
        ;;
    esac
done

# Check if a build tag was given
if [ -n "$BUILD_TAG" ]; then
    BUILD_TAG_STRING="--tag $BUILD_TAG"
fi

# Build google earth enterprise
cd geeBuild && runIfImageDoesNotExists geebuild:v1 bash build.sh $BUILD_TAG_STRING

# Run tests
if [ "$SHOULD_TEST" -eq 1 ]; then
    cd ../geeTest && bash run.sh
fi

# Check if a password was given
if [ -n "$ADMIN_PASSWORD" ]; then
    ADMIN_PASSWORD_STRING="--admin_password $ADMIN_PASSWORD"
fi

# Install server
cd ../server && runIfImageDoesNotExists geeserver:v1 bash install.sh $ADMIN_PASSWORD_STRING

# Install fusion
cd ../fusion && runIfImageDoesNotExists geefusion:v1 bash install.sh

# Check if should install tutorial files
if [ "$INSTALL_TUTORIAL" -eq 1 ]; then
    # Download tutorial files to fusion
    cd tutorial && runIfImageDoesNotExists fusiontutorial:v1 bash install.sh
fi
