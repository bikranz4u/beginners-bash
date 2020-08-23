#!/bin/bash
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
#echo "${red}red text ${green}green text${reset}"
#--------------   updating and installing requirequired packages --------------  #
architecture=`arch`

yum update -y
yum install gcc wget curl firewalld glibc-devel.${architecture} -y

#-------------- If the Open JDK needs to be removed ----------#
echo "${red} ######## Removing openjdk ############${reset}"

sudo yum remove java-1.*-openjdk* -y #It will remove all version of openjdk Ver 1.0 >

#--------------   Installing Java 1.8 --------------  #
echo "${green} ######## Installing Oracle JAVA 1.8 ############ ${reset}"
cd /opt/
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jdk-8u201-linux-x64.tar.gz"
tar xzf jdk-8u201-linux-x64.tar.gz
sleep 5
cd jdk1.8.0_201/
alternatives --install /usr/bin/java java /opt/jdk1.8.0_201/bin/java 200000
alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_201/bin/javac 200000
alternatives --install /usr/bin/jar jar /opt/jdk1.8.0_201/bin/jar 200000
alternatives --set jar /opt/jdk1.8.0_201/bin/jar
alternatives --set javac /opt/jdk1.8.0_201/bin/javac


#--------------   Setting up Java Path --------------  #
echo "${green} ######## Setting up Java Path ############ ${reset}"
cat <<EOT >> /etc/profile.d/java.sh
#!/bin/bash
export JAVA_HOME=/opt/jdk1.8.0_201
export JRE_HOME=/opt/jdk1.8.0_201/jre
export PATH=$PATH:/opt/jdk1.8.0_201/bin:/opt/jdk1.8.0_191/jre/bin
EOT

# Reload the java.sh , so that the path will available for all user in the system
source /etc/profile.d/java.sh

chmod +x /etc/profile.d/java.sh


# --------------  Install Tomcat 8.5 --------------------------#
echo "${green} ######## Install Tomcat 8.5 ############ ${reset}"
cd /opt
version=8.5.39
wget https://www-eu.apache.org/dist/tomcat/tomcat-8/v${version}/bin/apache-tomcat-${version}.tar.gz
tar xvf apache-tomcat-8*tar.gz -C /opt
sleep 5

#--------------   Setting up Tomcat Path --------------  #

echo "${green} ######## Setting up Tomcat Path ############ ${reset}"
cat <<EOT >> /etc/profile.d/tomcat.sh
#!/bin/bash
CATALINA_HOME=/opt/apache-tomcat-${version}
export PATH=$PATH:$CATALINA_HOME/bin
EOT
# Reload the tomcat.sh , so that the path will available for all user in the system
source  /etc/profile.d/tomcat.sh

chmod +x /etc/profile.d/tomcat.sh
chmod +x $CATALINA_HOME/bin/startup.sh
chmod +x $CATALINA_HOME/bin/shutdown.sh
chmod +x $CATALINA_HOME/bin/catalina.sh


# --------------  Create a dedicated user for Apache Tomcat -------------- # 

sudo groupadd tomcat
#sudo mkdir /opt/tomcat
sudo useradd -s /bin/nologin -g tomcat -d /opt/apache-tomcat-${version} tomcat

# -------------- Install Systemd Unit File -------------- ------------------#
echo "${green} ######## Install Systemd Unit File ############ ${reset}"
cat <<EOT >> /etc/systemd/system/tomcat.service
# Systemd unit file for tomcat
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

Environment=JAVA_HOME=/opt/jdk1.8.0_201
Environment=CATALINA_PID=/opt/apache-tomcat-${version}/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/apache-tomcat-${version}
Environment=CATALINA_BASE=/opt/apache-tomcat-${version}
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/apache-tomcat-${version}/bin/startup.sh
ExecStop=/bin/kill -15 $MAINPID

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOT
sleep 5
#------------------------ Setup proper permissions for tomcat ------------------#
echo "${green} ######## Setting Up tomcat user file access permissions ############ ${reset}"
cd /opt/apache-tomcat*/
chgrp -R tomcat conf
chmod g+rwx conf
chmod g+r conf/*
chown -R tomcat logs/ temp/ webapps/ work/
chgrp -R tomcat bin
chgrp -R tomcat lib
chmod g+rwx bin
chmod g+r bin/*


# -----------------------Tomocat Start / Stop short Link ----------------------- #


#ln -s /opt/apache-tomcat-${version}/bin/startup.sh /usr/bin/tomcatup
#ln -s /opt/apache-tomcat-${version}/bin/shutdown.sh /usr/bin/tomcatdown


#-------------- Install haveged, a security-related program ---------------#
echo "${green} ######## Installing haveged from source ############ ${reset}"
#http://www.issihosts.com/haveged/downloads.html
cd /opt
version=1.9.2

wget http://www.issihosts.com/haveged/haveged-${version}.tar.gz
tar zxvf haveged*tar.gz -C /opt
sleep 5
cd haveged*
./configure
make
make install
# Autostart haveged"
#yum install haveged
systemctl enable haveged.service
systemctl start haveged.service


# ----------------------- Open Firewall for desired ports ----------------------#
# Inorder to test Apache Tomcat in a web browser, you need to modify the firewall rules

# --------- Enable & Start Firewalld Service ------------#
echo "${green} ######## Enable & Start Firewalld Service ############ ${reset}"
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --zone=public --permanent --add-port=8080/tcp
firewall-cmd --reload

#---------------- Clean up the tar.gz files ----------------#
echo "${red} ######## Removing tar.gz files ############ ${reset}"
cd /opt
rm -rf *tar.gz

# ---------------------- Start and Test Apache Tomcat -------------------------#
echo "${green} ####### Enable and Start Tomcat ######### ${reset}"
systemctl enable tomcat.service
systemctl start tomcat.service
