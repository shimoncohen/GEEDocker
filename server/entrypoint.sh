#!/bin/bash

PUBLISH_ROOT="/gevol/server/published_dbs"

##### handle termination signal #####
function cleanup() {
	echo 'Stopping gee server service'
	# Stop gee server service
	/etc/init.d/geserver stop
}

trap 'cleanup' SIGTERM

#####

if [ ! -f /var/opt/google/pgsql/data/postgresql.conf ]; then
	chown -R gepguser:gegroup /var/opt/google/pgsql/data
	printf 'C\nn' | /opt/myapp/earthenterprise/earth_enterprise/src/installer/install_server.sh
fi

# Configure publish root
/opt/google/bin/geconfigurepublishroot --noprompt --path=$PUBLISH_ROOT

# Select publish root
/opt/google/bin/geselectpublishroot $PUBLISH_ROOT

# Change ownership of pg data folder if needed
PG_DATA_PATH="/var/opt/google/pgsql/data"
USER=$(stat -c '%U' $PG_DATA_PATH)
GROUP=$(stat -c '%G' $PG_DATA_PATH)
if [[ $USER != "gepguser" || $GROUP != "gegroup" ]]; then
	chown -R gepguser:gegroup $PG_DATA_PATH
fi

# Run server
/etc/init.d/geserver start

# Stay alive
while true; do sleep 3; done
