#!/bin/bash
#Create a user called Ansible
echo "creating a user called ansible"
useradd ansible
#Make directory under for the ansible user
#mkdir ~ansible
cd /home/ansible
#Make .ssh directory under /home/ansible/
mkdir .ssh
#Set the directory permissions to be 700
chmod 700 /home/ansible/.ssh
#Create the file ~ansible/.ssh/authorized_keys
cd .ssh/
touch authorized_keys
#Insert the following contents into ~ansible/.ssh/authorized_keys
cat > /home/ansible/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3vAqxlMjE4RM0M9VC8EPiWG2DB5LF8fUylzko5qQo6hg5wzZn/+3O+mC4L4ei+xz+P RandomKey
EOF
#Change permissions stuff
chmod 600 /home/ansible/.ssh/authorized_keys
chown -R ansible:ansible /home/ansible/

#Add to sudoers
echo "ansible ALL= NOPASSWD: ALL" >> /etc/sudoers
#######################################################################
echo 'completed successfully for ansible'
