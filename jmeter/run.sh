#!/bin/bash
NAME="jmetertest"
IMAGE="justb4/jmeter:latest"
ROOTPATH=$1

echo "$ROOTPATH"

docker stop $NAME > /dev/null 2>&1
docker rm $NAME > /dev/null 2>&1
docker run --name $NAME -i -v $ROOTPATH:/test -w /test $IMAGE ${@:2}
