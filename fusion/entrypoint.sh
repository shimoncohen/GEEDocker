#!/bin/bash

ASSET_ROOT="/gevol/fusion/assets"
SOURCE_VOLUME="/gevol/fusion/src"

if [ ! -f "$ASSET_ROOT/.config/volumes.xml" ]; then
    # Create asset root
    /opt/google/bin/geconfigureassetroot --new --noprompt --assetroot $ASSET_ROOT --srcvol $SOURCE_VOLUME
else
    # Configure asset root
    /opt/google/bin/geconfigureassetroot --fixmasterhost --noprompt --assetroot $ASSET_ROOT
fi;

# Select asset root
/opt/google/bin/geselectassetroot --noprompt --assetroot $ASSET_ROOT

# Start fusion service
/etc/init.d/gefusion start

# Run fusion
/opt/google/bin/fusion
