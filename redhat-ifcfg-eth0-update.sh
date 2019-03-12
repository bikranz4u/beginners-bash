#!/bin/bash

# This file is used to customizeing the network file present in redhat system 
# This script will look for existing values of some parameters , if those are present it will update as per requirement , if not those parameters will be added
# We will search for below parameters in default ethernet file and modify accordingly.
# HWADDR:
# IPADDR:
# PREFIX:
# GATEWAY:
# DNS1:
# DNS2:


# Lets take a backup before proceed
cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0.backup

#Lets define what are going to be updated as variable
new_hardware_address='00:ac:90:4r:30:1q:32:tw'
new_ip_address='111.222.333.444'
new_prefix='123addr'
new_gateway='192.168.56.1'
new_dns1='test.example.com'
new_dns2='test1.example.com'

# Modifying MAC address
existing_hardware_address=`cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep HWADDR | cut -d '=' -f2`

if [ $new_hardware_address == $existing_hardware_address ]
then
	echo "MAC address is Old"
	sed  's/\$existing_hardware_address/\$new_hardware_address/' /etc/sysconfig/network-scripts/ifcfg-eth0
else 
	echo "HWADDR=$new_hardware_address" >> /etc/sysconfig/network-scripts/ifcfg-eth0
	
fi


#Check If IPADDR is present , if not add it.

existing_ip_address=`cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep IPADDR | cut -d '=' -f2`

if [ echo $? != 0]
then
	echo "IPADDR=$new_ip_address" >> /etc/sysconfig/network-scripts/ifcfg-eth0

elif [ $existing_ip_address == $new_ip_address ] 
then
	echo "IPADDR address is old  "
	sed  's/\$existing_ip_address/\$new_ip_address/' /etc/sysconfig/network-scripts/ifcfg-eth0
fi


#Check If PREFIX is present , if not add it.

existing_prefix=`cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep PREFIX | cut -d '=' -f2`

if [ echo $? != 0]
then
	echo "PREFIX=$new_prefix" >> /etc/sysconfig/network-scripts/ifcfg-eth0
	
elif [ $existing_prefix == $new_prefix ] 
then
	echo "PREFIX is old  "
	sed  's/\$existing_prefix/\$new_prefix/' /etc/sysconfig/network-scripts/ifcfg-eth0
fi



#Check If GATEWAY is present , if not add it.

existing_gateway=`cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep GATEWAY | cut -d '=' -f2`

if [ echo $? != 0]
then
	echo "GATEWAY=$new_gateway" >> /etc/sysconfig/network-scripts/ifcfg-eth0
	
elif [ $existing_gateway == $new_gateway ] 
then
	echo "GATEWAY is old  "
	sed  's/\$existing_gateway/\$new_gateway/' /etc/sysconfig/network-scripts/ifcfg-eth0
	
fi

#Check If DNS1 is present , if not add it.

existing_dns1=`cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep DNS1 | cut -d '=' -f2`

if [ echo $? != 0]
then
	echo "DNS1=$new_dns1" >> /etc/sysconfig/network-scripts/ifcfg-eth0
	
elif [ $existing_dns1 == $new_dns1 ] 
then
	echo "DNS1 is old  "
	sed  's/\$existing_DNS1/\$new_DNS1/' /etc/sysconfig/network-scripts/ifcfg-eth0
fi



#Check If DNS2 is present , if not add it.

existing_dns2=`cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep DNS2 | cut -d '=' -f2`

if [ echo $? != 0]
then
	echo "DNS2=$new_dns2" >> /etc/sysconfig/network-scripts/ifcfg-eth0
	
elif [ $existing_dns2 == $new_dns2 ] 
then
	echo "DNS2 is old  "
	sed  's/\$existing_dns2/\$new_dns2/' /etc/sysconfig/network-scripts/ifcfg-eth0
fi
