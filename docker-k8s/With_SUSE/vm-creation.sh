#!/bin/bash
#######################
##$1/2/3/4 needed to be passed as argument while running the script
#######################
master_vm="TEMPLATE"
file_path='/var/lib/libvirt/images'
password='Testuser123'

printf '********VM Cloning is in Progress*********'
# Clone the VM from origional
virt-clone --original $master_vm --name $1 --auto-clone

printf '*********VM customization with new IP & Hostname is in Progress***********'
# UPdate the hostname and IP for the new VM
virt-customize -a $file_path/$1.qcow2 --run-command "sed -i -e 's/10.0.6.01/$2/g' /etc/sysconfig/network/ifcfg-eth0"

# Update the hostname
virt-customize -a  $file_path/$1.qcow2 --hostname $3

# Start the VM using Virsh, passed from command line or passed from jenkins vars
virsh start $1

# Wait for 20 secs to get the VM boot properly
sleep 20

ping_status=`ping -c 2 $2`
if [ $? -eq 0 ]; then
        sshpass -e ssh -o StrictHostKeyChecking=no root@$2 \
                "useradd -m $4; \
                 echo $4:$password |chpasswd; \
                 chage -d0 $4; \
                 echo '$4 user created Successfully.'"
else
        echo '**********VM creation failed*************'

fi

