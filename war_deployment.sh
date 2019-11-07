#!/bin/bash

################ VARIABLES #############
NOW=$(date +"%v:%H")
path="/usr/tomcat/apache-tomcat-8.5.37/webapps"
backup_path="/root/war_backup"
bundle_version="i0.8"                      ## Update when new build comes
########################################


# Kill the running application
echo "-----------------------Terminating running application----------------------"
kill $(pidof java) || true

# Move the war file to backup
get_name=$(find $path -name "*.war" | awk -F'/' '{print $NF}')
echo "----------------------Proceeding with Backup of .war-------------------------"
mv $path/$get_name $backup_path/$get_name-$NOW

# Check if backup successful
FILE="$backup_path/$get_name-$NOW"

if [ -f "$FILE" ]; then
    echo "Backup $FILE exist......We are cleaning up webapps for clean deployment"
    rm -rf $path/$get_name*
else
        echo "Could not find the backup file.....exiting now"
        exit 1
fi

# Unzip the new Bundle
unzip /root/${bundle_version}.zip

#Copy the war file to extracted folder
cp /root/$bundle_version/Bundle/*.war $path
