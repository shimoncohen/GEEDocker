#!/bin/bash

PUBLISH_ROOT="/gevol/server/published_dbs"

# Configure publish root
/opt/google/bin/geconfigurepublishroot --noprompt --path=$PUBLISH_ROOT

# Select publish root
/opt/google/bin/geselectpublishroot $PUBLISH_ROOT

# Run server
/etc/init.d/geserver start

# Stay alive
while true; do sleep 3; done