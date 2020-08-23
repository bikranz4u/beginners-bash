#!/bin/bash

echo "========= Moving to relative directoryfor application start and stop ========="

cd /var/lib/jenkins/workspace/natserver

echo "========== Stop node if running & Start =============="
status=$(pidof node >/dev/null && echo "ServiceIsRunning" || echo "ServiceIsNOTRunning")

if [ "$status" = "ServiceIsRunning"]
then
	kill -9 $(pidof node)
	echo "Node service is stopped , we are updating npm modules & will start node"
	sleep 3
	/opt/node-v10.16.0-linux-x64/bin/npm install && sleep 2
	/opt/node-v10.16.0-linux-x64/bin/forever start index.js
	echo " Node service started"
else
	/opt/node-v10.16.0-linux-x64/bin/npm install
	sleep 5
	/opt/node-v10.16.0-linux-x64/bin/forever start index.js
	echo " Node service started"
fi
