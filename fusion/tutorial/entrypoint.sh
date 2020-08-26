#!/bin/bash

ASSET_ROOT="/opt/google/share/tutorials/fusion/assets"
TUTORIAL_SOURCE_VOLUME="/opt/google/share/tutorials/fusion/src"

mkdir -p $ASSET_ROOT
mkdir -p $TUTORIAL_SOURCE_VOLUME

# Configure asset root
/opt/google/bin/geconfigureassetroot --new --noprompt --assetroot $ASSET_ROOT --srcvol $TUTORIAL_SOURCE_VOLUME

# Select asset root
/opt/google/bin/geselectassetroot --noprompt --assetroot $ASSET_ROOT

# Copy tutorial script to wanted destination
cp /download_tutorial.sh $TUTORIAL_SOURCE_VOLUME/download_tutorial.sh

# Download tutorial files if not already installed
bash $TUTORIAL_SOURCE_VOLUME/download_tutorial.sh

# Start fusion service
/etc/init.d/gefusion start

# Run fusion
/opt/google/bin/fusion
