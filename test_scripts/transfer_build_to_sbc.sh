#! /bin/sh

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 USERNAME TARGETHOST REFERENCEHOST"
    exit 1
fi

USERNAME=$1
TARGETHOST=$2
REFERENCEHOST=$3

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
ssh ${USERNAME}@${TARGETHOST} "/opt/etc/init.d/S99endor-webapp stop"
ssh ${USERNAME}@${TARGETHOST} "/opt/etc/init.d/S98cat-remotingserver stop"
ssh ${USERNAME}@${TARGETHOST} "/opt/etc/init.d/S97endor-instrumentcontroller stop"
ssh ${USERNAME}@${TARGETHOST} "/opt/etc/init.d/S96endor-virtualinstrument stop"
ssh ${USERNAME}@${TARGETHOST} "/opt/etc/init.d/S95postgresql stop"

# Delete the entire old application folder
#
echo "Removing old build on $1"
ssh ${USERNAME}@${TARGETHOST} "~/test_helpers/remove_old_endor_folder.sh"

# And copy the new folder to the target machine
#
echo "Copying files from reference machine to $1"
ssh ${USERNAME}@${TARGETHOST} "scp -r ${USERNAME}@${REFERENCEHOST}:/opt/lib/endor /opt/lib/endor"

# Restart operations on test machine
echo "Restarting services"
ssh ${USERNAME}@${TARGETHOST} "/opt/etc/init.d/S95postgresql start"
ssh ${USERNAME}@${TARGETHOST} "cd /opt/lib/endor; python3 RebuildDb_Paragon.py"

ssh ${USERNAME}@${TARGETHOST} "/opt/etc/init.d/S96endor-virtualinstrument start"
ssh ${USERNAME}@${TARGETHOST} "/opt/etc/init.d/S97endor-instrumentcontroller start"
ssh ${USERNAME}@${TARGETHOST} "/opt/etc/init.d/S98cat-remotingserver start"
ssh ${USERNAME}@${TARGETHOST} "/opt/etc/init.d/S99endor-webapp start"

sleep 5

echo "Ready to run tests!"
