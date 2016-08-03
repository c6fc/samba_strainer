#! /bin/bash

if [ "${3}" = "" ]; then
   echo "Syntax: use ${0} <jail> <ip> <logpath> <(disable | enable)\n"
   exit 1
fi

JAIL=${1}
IP=${2}
LOGPATH=${3}
ACTION=${4}
BANLIST=/etc/fail2ban/samba-vfs.banlist

if [ "$ACTION" = "disable" ]; then
   NOW=`date +"%b %d %H:%M"`
   LOGLINES=`grep "$NOW" ${LOGPATH} | grep ${IP} | awk ' { print $6 } '`
   ACCOUNTS=`echo ${LOGLINES} | awk -F"|" ' { print $1 } ' | sort | uniq`
   SHARES=`echo ${LOGLINES} | awk -F"|" ' { print $4 } ' | sort | uniq`

   for i in ${ACCOUNTS}; do
      smbpasswd -d ${i}
      echo "${IP} ${i}" >> $BANLIST

      PIDS=`smbstatus | grep ${IP} | grep -v \( | awk ' { print $2 } ' | sort | uniq`
      for j in ${PIDS}; do
         kill -9 ${j}
      done
   done

   exit 0
fi

if [ "$ACTION" = "enable" ]; then
   ACCOUNTS=`grep ${IP} $BANLIST | awk ' { print $2 } ' | sort | uniq`
   sed -i "/^${IP}.*\$/d" $BANLIST
   for i in ${ACCOUNTS}; do
      smbpasswd -e ${i}
   done

   exit 0
fi

echo "Verb must be one of (enable | disable)"
exit 1
