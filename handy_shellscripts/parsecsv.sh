#!/bin/bash
# This file will parse a csv file to viewable in unix style
OLDIFS=$IFS

# Define a Field Separator as ,
IFS=","   

# Read the variable (header) from the csv file

while read user job uid location

   do 
   		echo -e "\e [\e[1;33m$user \
   		#############################\e [0m\n\
   		Role : \t $job\n\
   		ID : \t $uid\n\
   		SITE: \t $location\n"
   done < $1   # By using $1 we can pass any csv file name from command line, which has same headers
IFS=$OLDIFS



# parsecsv.sh test.csv


#export GOROOT=/usr/local/bin/
#export GOPATH=/Users/bikrdas/go
#export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
