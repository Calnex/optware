#!/bin/sh

ROOT="$(dirname "$(realpath "$0")")"

docker build -t optware-agent .
[[ $? -ne 0 ]] && exit 1
docker run -it -w /mnt -v $ROOT:/mnt optware-agent /bin/bash 
