#!/bin/sh


echo "000 $0"
ROOT="$(dirname "$(realpath "$0")")"

echo "$ROOT"

docker build -t optware-agent .
[[ $? -ne 0 ]] && exit 1
docker run -it -v $ROOT:/mnt optware-agent /bin/bash 
