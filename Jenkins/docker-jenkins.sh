# PRE-REQUISITE ---> INSTALL DOCKER 


#CHECK THE JENKINS INSTAALTION DOC 

# https://jenkins.io/doc/book/installing/

sudo mkdir -p /var/jenkins_home
sudo chown -R 1000:1000 /var/jenkins_home/

# This will pull the latest Jenlins LTS image
docker run -p 8080:8080 -p 50000:50000 -v /var/jenkins_home:/var/jenkins_home --name jenkins -d jenkins/jenkins:lts

# This will pull Jenkins BlueOcean Image
docker run -d -p 8080:8080 -p 50000:50000  -v /var/jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkinsci/blueocean

# GEtting the Initial password for Jenkins
echo 'Jenkins installed'
echo 'You should access jenkins at : http://'$(curl -s ifconfig.co)':8080'

#docker exec -it jenkins-blueocean bash
#cat /var/jenkins_home/secrets/initialAdminPassword

# In Case you ran docker in attached mode run 

docker logs jenkins-blueocean | grep 


# 
# FOR MAC
# brew install jenkins-lts

# sudo usermod -aG docker jenkins
