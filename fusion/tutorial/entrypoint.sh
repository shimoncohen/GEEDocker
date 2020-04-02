# check for invalid asset names
ASSET_ROOT="/opt/google/share/tutorials/fusion/assets"
TUTORIAL_SOURCE_VOLUME="/opt/google/share/tutorials/fusion/src"

#INVALID_ASSETROOT_NAMES=$(find $ASSET_ROOT -type d -name "*[\\\&\%\'\"\*\=\+\~\`\?\<\>\:\; ]*" 2> /dev/null)

#if [ ! -z "$INVALID_ASSETROOT_NAMES" ]; then
#	echo "yes1"
#	cd ../
#	ls

mkdir -p $ASSET_ROOT
mkdir -p $TUTORIAL_SOURCE_VOLUME

# Configure asset root
/opt/google/bin/geconfigureassetroot --new --noprompt --assetroot $ASSET_ROOT --srcvol $TUTORIAL_SOURCE_VOLUME

/opt/google/bin/geselectassetroot --noprompt --assetroot $ASSET_ROOT

cp /download_tutorial.sh $TUTORIAL_SOURCE_VOLUME/download_tutorial.sh

#bash $TUTORIAL_SOURCE_VOLUME/download_tutorial.sh

bash /opt/google/share/tutorials/fusion/download_tutorial.sh

/etc/init.d/gefusion start

/opt/google/bin/fusion
