#!/bin/sh
### BEGIN INIT INFO
# Provides:          jenkins_slave
# Required-Start:    $ALL
# Should-Start:      $time ypbind smtp
# Required-Stop:     
# Should-Stop:       
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 2 6
# Short-Description: jenkinslave daemon logs machine in as a Jenkins Slave
# Description:       Start running the Java slave.jar process
#                    to log this machine to the specified jenkins master
### END INIT INFO
#
# --README--
# The information in INIT INFO is used to configure the service.
# It ensures the service does not start until the network is ready.
# It also defines which runlevel start and stop the service.
#
# This script assumes there is a local user called build. It is hardcoded
# as services load with no environmental variable value for $USER.
# If this script needs to start as another user update the LOCAL_USER variable.
#
# This script assumes the machines hostname is the same as the Jenkins node name.
# If this is not the case please update the JENKINS_SLAVE_NAME variable.
#
# This script logs its output into tmp/jenkins_service_<stage>.log.
# e.g. jenkins_service_start.log.
# If you need to debug the script please examine these logs.
# 
# Modified from /etc/init.d/skeleton

LOCAL_USER=build
JENKINS_SLAVE_NAME=$(hostname)

JENKINS_URL=http://mydemo.jenkins.com:8080
SLAVE_JAR=jnlpJars/slave.jar
SLAVE_FILE=/tmp/jenkins_slave.jar
PID_FILE_NAME=/tmp/jenkins_slave.pid
LOG="/tmp/jenkins_service_$1.log"

# Ububtu status file
. /lib/lsb/init-functions

# Flush the log
date > $LOG 2>&1

# Stop the Jenkins Service
stop() {
	if [ -f $PID_FILE_NAME ]
	then
		PID=$(cat $PID_FILE_NAME)
		echo Shutting down jenkins slave with PID $PID >> $LOG 2>&1
		kill $PID >> $LOG 2>&1
		# Wait until the process has been killed
		# When the process is killed it informs Jenkins that the slave is offline.
		# But a machine restart/shutdown can occur so fast the process does not
		# get a chance to contact Jenkins.
		# This means Jenkins thinks the node is online and can attempt to run
		# jobs on the node.
		# If the machine itself tries to re-connect while Jenkins thinks it is
		# already registered the connection will be rejected.
		# 
		# So wait for the process to finish before continuing.
		# This will hold up a machine restart/shutdown. But enables the desired
		# behaviour.  
		while kill -0 $PID > /dev/null 2>&1
		do
			sleep 1
		done
		echo Removing $PID_FILE_NAME >> $LOG 2>&1
		rm $PID_FILE_NAME >> $LOG 2>&1
	else
		echo Jenkins Service is not running >> $LOG 2>&1
	fi
}

JENKINS_CMD="nohup java -jar ${SLAVE_FILE} -jnlpUrl ${JENKINS_URL}/computer/${JENKINS_SLAVE_NAME}/slave-agent.jnlp"

# Start the Jenkins Service
start() {
	# Whenever start is called be sure to stop any existing service
	stop
	echo "Starting Jenkins Slave " >> $LOG 2>&1
	echo curl ${JENKINS_URL}/${SLAVE_JAR} --output ${SLAVE_FILE} >> $LOG 2>&1
	curl ${JENKINS_URL}/${SLAVE_JAR} --output ${SLAVE_FILE} >> $LOG 2>&1
	echo $JENKINS_CMD >> $LOG 2>&1
	sudo -u $LOCAL_USER $JENKINS_CMD >> $LOG 2>&1 &

	# Save the Jenkins process id so stop can retrieve it and kill the process
	echo $! > $PID_FILE_NAME
	echo Saved process id $! to $PID_FILE_NAME >> $LOG 2>&1
}

case "$1" in
    start)
	start
	;;
    stop)
	stop
	;;
    try-restart|condrestart)
	## Do a restart only if the service was active before.
	## Note: try-restart is now part of LSB (as of 1.9).
	## RH has a similar command named condrestart.
	if test "$1" = "condrestart"; then
		echo "${attn} Use try-restart ${done}(LSB)${attn} rather than condrestart ${warn}(RH)${norm}" >> $LOG 2>&1
	fi
	$0 status
	if test $? = 0; then
		$0 restart
	fi
	# Remember status and be quiet
	;;
    restart)
	## Stop the service and regardless of whether it was
	## running or not, start it again.
	stop
	start

	;;
    force-reload)
	## Signal the daemon to reload its config. Most daemons
	## do this on signal 1 (SIGHUP).

	echo "Reload service JENKINS SLAVE " >> $LOG 2>&1
	$0 try-restart
	;;
    reload)
	## Like force-reload, but if daemon does not support
	## signaling, do nothing (!)

	;;
    status)
	echo "Checking for service JENKINS SLAVE " >> $LOG 2>&1
	## Check status with checkproc(8), if process is running
	## checkproc will return with exit status 0.

	# Return value is slightly different for the status command:
	# 0 - service up and running
	# 1 - service dead, but /var/run/  pid  file exists
	# 2 - service dead, but /var/lock/ lock file exists
	# 3 - service not running (unused)
	# 4 - service status unknown :-(
	# 5--199 reserved (5--99 LSB, 100--149 distro, 150--199 appl.)
	
	
	# NOTE: checkproc returns LSB compliant status values.
	if [ -e $PID_FILE_NAME ]
	then
		echo "Running" >> $LOG 2>&1
	else
		echo "Not Running" >> $LOG 2>&1
	fi
	
	# "status" option and adapts its messages accordingly.
	[ -e $PID_FILE_NAME ]
	;;
    probe)
	## Optional: Probe for the necessity of a reload, print out the
	## argument to this init script which is required for a reload.
	## Note: probe is not (yet) part of LSB (as of 1.9)

	test /etc/FOO/FOO.conf -nt /var/run/FOO.pid && echo reload
	;;
    *)
	echo "Usage: $0 {start|stop|status|try-restart|restart|force-reload|reload|probe}"
	exit 1
	;;
esac
