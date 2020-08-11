#!/bin/bash

ASSET_ROOT="/gevol/fusion/assets"
SOURCE_VOLUME="/gevol/fusion/src"

# Configure asset root
/opt/google/bin/geconfigureassetroot --new --noprompt --assetroot $ASSET_ROOT --srcvol $SOURCE_VOLUME

# Select asset root
/opt/google/bin/geselectassetroot --noprompt --assetroot $ASSET_ROOT

# Start fusion service
/etc/init.d/gefusion start

# Activate SSH
/usr/sbin/sshd -D