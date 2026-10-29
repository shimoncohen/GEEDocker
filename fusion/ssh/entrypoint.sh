#!/bin/bash

ASSET_ROOT="/gevol/fusion/assets"
SOURCE_VOLUME="/gevol/fusion/src"
AUTHORIZED_KEYS_FILE="${AUTHORIZED_KEYS_FILE:-/run/secrets/authorized_keys}"

if [ ! -s "$AUTHORIZED_KEYS_FILE" ]; then
    echo "Authorized keys file $AUTHORIZED_KEYS_FILE is missing or empty" >&2
    exit 1
fi
# Copied, not mounted in place: sshd rejects a key file root does not own.
install -d -m 700 /root/.ssh
install -m 600 "$AUTHORIZED_KEYS_FILE" /root/.ssh/authorized_keys

##### handle termination signal #####
function cleanup() {
    echo 'Stopping fusion service'
    # Stop fusion service
    /etc/init.d/gefusion stop
}

trap 'cleanup' SIGTERM

#####

if [ ! -f "$ASSET_ROOT/.config/volumes.xml" ]; then
    # Create asset root
    /opt/google/bin/geconfigureassetroot --new --noprompt --assetroot $ASSET_ROOT --srcvol $SOURCE_VOLUME
else
    # Configure asset root
    /opt/google/bin/geconfigureassetroot --fixmasterhost --noprompt --assetroot $ASSET_ROOT
fi

# Select asset root
/opt/google/bin/geselectassetroot --noprompt --assetroot $ASSET_ROOT

# Start fusion service
/etc/init.d/gefusion start

# Activate SSH
/usr/sbin/sshd -D
