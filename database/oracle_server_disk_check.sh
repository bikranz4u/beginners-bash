
#/bin/bash

today=`date +"%m_%d_%y"`
logx=${HOME}/'footprint_creation'${today}'.log'
echo ${today} > ${logx}

# function for file system space check
chk_spc () {
MNT=$1
TSNEED=$2
SPACE=`df -k ${MNT} | sed -n '2p'| awk '{print $2}'`
total=`expr $SPACE / 1024 / 1024`
TSPACE=`echo $total`
if [[ $TSNEED -ge $TSPACE ]]
then
        msg='ERROR: Not enough space in '${MNT}
        echo ${msg} >> ${logx}
else
        msg='INFO: passed space check. Available space is '${TSPACE}'GB in '${MNT}
        echo ${msg} >> ${logx}
fi
}

# check if all standard file systems exist and they have min size
# /orah1, /orah4, /orabin, /orabase, /cigna/oramgr, /ora_misc, /tmp
chk_spc /orah1 60
chk_spc /orabin 60
chk_spc /orabase 100
chk_spc /cigna/oramgr 20
chk_spc /orah4 10
chk_spc /ora_misc 500
chk_spc /tmp 4

# check swap space
SWP_TOTAL=`free -g | grep Swap | awk '{print $2}'`
SWP_NEED=17
if [[ $SWP_NEED -gt $SWP_TOTAL ]]
then
        msg='ERROR: Not enough space in Swap'
        echo ${msg} >> ${logx}
else
        msg='INFO: passed Swap space check. Available space is '${SWP_TOTAL}'GB'
        echo ${msg} >> ${logx}
fi

# /dev/shm 50% of physical memory
MEM_TOTAL=`free -g | grep Mem | awk '{print $2}'`
MEM_50TOTAL=`expr $MEM_TOTAL / 2`
chk_spc /dev/shm MEM_50TOTAL

# PROD SVC DB Alerting – Oracle
MON_GRP=`cat /etc/passwd|grep -i oracle|grep 'PROD SVC DB Alerting - Oracle' | wc -l`
if [[ $MON_GRP -ne 1 ]]
then
        msg='ERROR: Alerting bucket was not set up correct'
        echo ${msg} >> ${logx}
else
        msg='INFO: Passed Alerting bucket information'
        echo ${msg} >> ${logx}
fi

# check diskmon.conf to make sure it is set up accurate.

# create Standard directories under /home/oracle
msg='INFO: Starting standard directory creation under /home/oracle'
echo ${msg} >> ${logx}

mkdir /home/oracle/dbascripts

msg='INFO: completed standard directory creation under /home/oracle'
echo ${msg} >> ${logx}

# setup standard profile
msg='INFO: Starting standard profile setup'
echo ${msg} >> ${logx}

wget https://cpc-ora-swrep.sym.paas.silver.com/ENV_Files/profile -O /home/oracle/.profile --no-check-certificate

msg='INFO: Completed standard profile setup'
echo ${msg} >> ${logx}

# refresh dbascripts

# create standard directories under /cigna/oramgr
msg='INFO: Starting standard directory creation under /cigna/oramgr'
echo ${msg} >> ${logx}

mkdir /cigna/oramgr/logs
mkdir /cigna/oramgr/development
mkdir /cigna/oramgr/history

msg='INFO: completed standard directory creation under /cigna/oramgr'
echo ${msg} >> ${logx}

# create standard directories under /orabase
msg='INFO: Starting standard directory creation under /orabase'
echo ${msg} >> ${logx}

mkdir /orabase/admin
mkdir /orabase/audit

msg='INFO: completed standard directory creation under /orabase'
echo ${msg} >> ${logx}

# setup cronjobs
TEMP_CRON=/home/oracle/cron_ora.txt
crontab -l > $TEMP_CRON

if [[ `cat $TEMP_CRON | grep -v ^# | grep housekeeper | wc -l` -eq 0 ]]
then
        echo "00 06 * * 0 /home/oracle/dbascripts/housekeeper.sh 1>/dev/null 2>&1" >> $TEMP_CRON
        msg='INFO: Housekeeper job set in crontab.'
        echo ${msg} >> ${logx}
else
        msg='ERROR: please check crontab, housekeeper job already exists.'
        echo ${msg} >> ${logx}
fi

# Error Check
num_err=`cat ${logx} | grep ERROR | wc -l`

if [[ num_err -gt 0 ]]
then
        msg='ERROR: please check the logfile for errors.'
        echo ${msg} >> ${logx}
        exit 1
else
        msg=SUCCESS: no errors found, exiting the footprint creation phase.'
        echo ${msg} >> ${logx}
        exit 0
fi
