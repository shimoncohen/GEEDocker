# check for invalid asset names
ASSET_ROOT="/gevol/assets"
SOURCE_VOLUME="/gevol/src"
#INVALID_ASSETROOT_NAMES=$(find $ASSET_ROOT -type d -name "*[\\\&\%\'\"\*\=\+\~\`\?\<\>\:\; ]*" 2> /dev/null)

#if [ ! -z "$INVALID_ASSETROOT_NAMES" ]; then
#	echo "yes1"
#	cd ../
#	ls

/opt/google/bin/geconfigureassetroot --new --noprompt --assetroot $ASSET_ROOT --srcvol $SOURCE_VOLUME

/opt/google/bin/geselectassetroot --noprompt --assetroot $ASSET_ROOT

/etc/init.d/gefusion start

/opt/google/bin/fusion
