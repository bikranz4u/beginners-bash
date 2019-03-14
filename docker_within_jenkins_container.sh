# Running docker within jenkins container

FROM jenkins/jenkins
USER root

RUN mkdir -p /tmp/download && \
 curl -L https://download.docker.com/linux/static/stable/x86_64/docker-18.03.1-ce.tgz | tar -xz -C /tmp/download && \
 rm -rf /tmp/download/docker/dockerd && \
 mv /tmp/download/docker/docker* /usr/local/bin/ && \
 rm -rf /tmp/download && \
 groupadd -g 999 docker && \
 usermod -aG docker jenkins

user jenkins




# docker run -d -p 8081:8080 -p 50000:50000 -v /var/run/docker.sock:/var/run/docker.sock -v /Users/bikrdas/Desktop/DevOps/Jenkins/jenkins_home:/var/jenkins_home dockerwithinjenkins
