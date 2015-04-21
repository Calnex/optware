#! /bin/sh

set -x

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 TARGETHOST REFERENCEHOST"
    exit 1
fi

TARGETHOST=$1
REFERENCEHOST=$2

# Make sure the host is there, bomb out if it's not
#
ping -c 1 ${TARGETHOST}
if [ $? -ne 0 ] ; then
    echo "Cannot ping ${TARGETHOST} - is it up?"
    exit 1
fi

# Ask the remote machine to stop its existing services
# Relies on SSH keys being correctly set up
#
echo "Stopping services on $1"
ssh ${TARGETHOST} "/opt/etc/init.d/S99endor-webapp stop"
ssh ${TARGETHOST} "/opt/etc/init.d/S98cat-remotingserver stop"
ssh ${TARGETHOST} "/opt/etc/init.d/S97endor-instrumentcontroller stop"
ssh ${TARGETHOST} "/opt/etc/init.d/S96endor-virtualinstrument stop"
ssh ${TARGETHOST} "/opt/etc/init.d/S95postgresql stop"

# Delete the entire old application folder
#
echo "Removing old build on $1"
ssh ${TARGETHOST} "~/test_helpers/remove_old_endor_folder.sh"

# And copy the new folder to the target machine
#

if [ -d "/tmp/endor_staging" ]; then
	rm -rf /tmp/endor_staging
fi

echo "Copying files from ${REFERENCE_HOST} to localhost"
scp -r ${REFERENCEHOST}:/opt/lib/endor /tmp/endor_staging

echo "Copying files to ${TARGETHOST} from localhost"
scp -r /tmp/endor_staging ${TARGETHOST}:/opt/lib/endor

# Restart operations on test machine
echo "Restarting services"
ssh ${TARGETHOST} "/opt/etc/init.d/S95postgresql start"
ssh ${TARGETHOST} "cd /opt/lib/endor/schema/Baseline; python3 RebuildDb.py --superuser=calnex"

ssh ${TARGETHOST} "/opt/etc/init.d/S96endor-virtualinstrument start"
ssh ${TARGETHOST} "/opt/etc/init.d/S97endor-instrumentcontroller start"
ssh ${TARGETHOST} "/opt/etc/init.d/S98cat-remotingserver start"
ssh ${TARGETHOST} "/opt/etc/init.d/S99endor-webapp start"

sleep 5

echo "Ready to run tests!"
