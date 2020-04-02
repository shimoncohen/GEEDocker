# check for invalid asset names
ASSET_ROOT="/gevol/assets"
SOURCE_VOLUME="/gevol/src"
TUTORIAL_SOURCE_VOLUME="/opt/google/share/tutorials/fusion"

#INVALID_ASSETROOT_NAMES=$(find $ASSET_ROOT -type d -name "*[\\\&\%\'\"\*\=\+\~\`\?\<\>\:\; ]*" 2> /dev/null)

#if [ ! -z "$INVALID_ASSETROOT_NAMES" ]; then
#	echo "yes1"
#	cd ../
#	ls

# Configure asset root
/opt/google/bin/geconfigureassetroot --new --noprompt --assetroot $ASSET_ROOT --srcvol $SOURCE_VOLUME

# Configure tutorial asset root
if [ "$#" -gt 0 ] && [[ "$1" == "tutorial" ]]; then
	/opt/google/bin/geconfigureassetroot --new --noprompt --assetroot $ASSET_ROOT --srcvol $TUTORIAL_SOURCE_VOLUME
fi

/etc/init.d/gefusion start

/opt/google/bin/fusion
