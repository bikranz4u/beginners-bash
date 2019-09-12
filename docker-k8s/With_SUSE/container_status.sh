#!/bin/bash

# Check if registry container Is Running 
STATUS=`docker inspect -f '{{.State.Status}}' registry`
#STATIC="Error\:\ No\ such\ object\:\ registry"
STATIC='Error: No such object: registry'

if [ "$STATUS" == "$STATIC"]; then
    echo "Container is not available, need to pull and Start"
    /usr/bin/docker run -p 5000:5000 --restart=always --name registry registry:latest

    # Recheck  the STATUS Value
    STATUS=`docker inspect -f '{{.State.Status}}' registry`
    elif [ "$STATUS" == "running" ]; then
    echo "Container is already running .....Nothing to do"

    elif [ "$STATUS" == "exited" ]; then
    echo "Container is Stopped, need to restart"
    docker restart registry

    elif [ "$STATUS" == "paused" ]; then
    echo "Container is Paused, need to Unpause"
    docker unpause registry

    else 
    echo "Container is not available, need to pull and Start"
    /usr/bin/docker run -p 5000:5000 --restart=always --name registry registry:latest
fi
