#!/bin/bash

REMOTE_HOST=${1:-192.168.205.41}
LOCAL_PATH=/home/dev/build/optware/sources/optware-bootstrap/usbrepo
REMOTE_PATH=usbdev

# Copy files to remote host
scp -r "$LOCAL_PATH"/* "calnex@$REMOTE_HOST:$REMOTE_PATH"