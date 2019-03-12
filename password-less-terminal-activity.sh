#Make Sure to install sshpass , if alredy not 

# Provide the password from termial 
read -p "Password: " -s SSHPASS
export SSHPASS
sshpass -e ssh <Username>@<SERVER IP/DNS>


# Copy the new file from local system to server
sshpass -e scp /Users/<NAME>/Downloads/web.zip   <NAME>@1.1.1.1:/tmp

# Login to the server 

sshpass -e ssh <Username>@<SERVER IP/DNS>

# Change the file ownership

chown jenkins:jenkins /tmp/web.zip

# Switch to jenkins user to stop / start tomcat 
sshpass -e sudo su jenkins

# Remove existing Deployables 
rm -rf /opt/apache-tomcat-8.5.37/webapps/web*

# Copy the new deployable to webapps
cp /tmp/web.zip /opt/apache-tomcat-8.5.37/webapps/

# Stop Tomcat Server 

tomcatdown

# Sleep for 20 seconds

sleep 20

# Start the tomcat 

tomcatup
