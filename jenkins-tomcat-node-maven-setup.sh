#!/bin/bash

# ------- References --------- #
# https://www.vultr.com/docs/how-to-install-apache-tomcat-8-on-centos-7 ##
# https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-8-on-centos-7


#--------------   updating and installing requirequired packages --------------  #

yum update -y
yum install wget curl git  -y

#--------------   Installing Java 1.8 --------------  #

cd /opt/
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jdk-8u201-linux-x64.tar.gz"
tar xzf jdk-8u201-linux-x64.tar.gz
cd jdk1.8.0_201/
alternatives --install /usr/bin/java java /opt/jdk1.8.0_201/bin/java 200000
alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_201/bin/javac 200000
alternatives --install /usr/bin/jar jar /opt/jdk1.8.0_201/bin/jar 200000
alternatives --set jar /opt/jdk1.8.0_201/bin/jar
alternatives --set javac /opt/jdk1.8.0_201/bin/javac


#--------------   Setting up Java Path --------------  #

cat <<EOT >> /etc/profile.d/java.sh
#!/bin/bash
export JAVA_HOME=/opt/jdk1.8.0_201
export JRE_HOME=/opt/jdk1.8.0_201/jre
export PATH=$PATH:/opt/jdk1.8.0_201/bin:/opt/jdk1.8.0_191/jre/bin
EOT

chmod +x /etc/profile.d/java.sh

# Reload the java.sh , so that the path will available for all user in the system
source /etc/profile.d/java.sh

# --------------  Create a dedicated user for Apache Tomcat -------------- # 
#For security purposes, you need to create a dedicated non-root user "tomcat" who belongs to the "tomcat" group:
sudo groupadd tomcat
sudo mkdir /opt/tomcat
sudo useradd -s /bin/nologin -g tomcat -d /opt/tomcat tomcat



# --------------  Install Tomcat 8.5 --------------------------#
cd /opt
version=8.5.39
wget https://www-eu.apache.org/dist/tomcat/tomcat-8/v${version}/bin/apache-tomcat-${version}.tar.gz
tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1

#--------------   Setting up Tomcat Path --------------  #
cat <<EOT >> /etc/profile.d/tomcat.sh
#!/bin/bash
CATALINA_HOME=/opt/tomcat-8.5.37
export PATH=$PATH:$CATALINA_HOME/bin
EOT

chmod +x /etc/profile.d/tomcat.sh
chmod +x $CATALINA_HOME/bin/startup.sh
chmod +x $CATALINA_HOME/bin/shutdown.sh
chmod +x $CATALINA_HOME/bin/catalina.sh
source  /etc/profile.d/tomcat.sh

# -----------------------Tomocat Start / Stop short Link ----------------------- #


ln -s /opt/apache-tomcat-8.5.37/bin/startup.sh /usr/bin/tomcatup
ln -s /opt/apache-tomcat-8.5.37/bin/shutdown.sh /usr/bin/tomcatdown

#--------------  Create users and add to group  
#--------------  this user will be the owner of running the application
#--------------  you need to switch to this user to start tomcat  --------------  #

usermod -s /bin/bash jenkins
chown -R jenkins:jenkins  apache-tomcat-8.5.37/
 

# -------------- Install Maven 3.6.0 --------------#
cd /opt
wget https://www-us.apache.org/dist/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz
tar xzvf apache-maven-3.6.0-bin.tar.gz
ln -s /opt/apache-maven-3.6.0/bin/mvn /usr/bin/mvn

#--------------   Setting up Maven Path --------------  #

echo "#!/bin/bash\nMAVEN_HOME=/opt/apache-maven-3.6.0\nPATH=$MAVEN_HOME/bin:$PATH\nexport PATH MAVEN_HOME\nexport CLASSPATH=." > /etc/profile.d/maven.sh
chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

# -------------- Install Node  --------------#

VERSION=v10.15.3
DISTRO=linux-x64

cd /opt
wget https://nodejs.org/dist/v10.15.3/node-$VERSION-$DISTRO.tar.xz
sudo tar -xJvf node-$VERSION-$DISTRO.tar.xz -C /opt/nodejs

#--------------   Setting up Nodejs Path --------------  #
echo "#!/bin/bash\nexport PATH=/opt/node-v10.15.3-linux-x64/bin:$PATH" > /etc/profile.d/node.sh
chmod +x /etc/profile.d/node.sh
source /etc/profile.d/node.sh
sudo ln -s /opt/node-v10.15.3-linux-x64/bin/node /usr/bin/node
sudo ln -s /opt/node-v10.15.3-linux-x64/bin/npm /usr/bin/npm
sudo ln -s /opt/node-v10.15.3-linux-x64/bin/npx /usr/bin/npx


#--------------   Install jenkins natively  -------------- VER -2.150.3 #
#--------------   Reason When we need to restart our application running in tomcat 8.5,the jenkins also be restarted if we run jenkin as a .war file in tomcat, 
#--------------   to avoid that we are running it a native application. --------------  #

#-------- If need to change port    update in vi /etc/sysconfig/jenkins -----#

wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install jenkins
systemctl enable jenkins.service
/sbin/chkconfig jenkins on
systemctl restart jenkins.service



echo "------------ Jenkins Initial Password --------------------"
cat /var/lib/jenkins/secrets/initialAdminPassword



echo "------- ALERT ALERT ALERT !!!! --------------------------" 
echo " --- For Security Practive Delete the Initial Password for Jenkins !!!! once done with a admin user----"






