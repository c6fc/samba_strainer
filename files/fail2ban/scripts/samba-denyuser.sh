#! /bin/bash

if [ "${3}" = "" ]; then
   echo "Syntax: use ${0} <ip> <logpath> <(ban | unban)\n"
   exit 1
fi

IP=${1}
LOGPATH=${2}
ACTION=${3}

if [ "$ACTION" = "ban" ]; then
   echo "Attempting ban..."
   NOW=`date +"%b %e %H:%M"`
   LOGLINES=`grep "$NOW" ${LOGPATH} | grep ${IP} | awk ' { print $6 } '`
   ACCOUNTS=`echo ${LOGLINES} | awk -F"|" ' { print $1 } ' | sort | uniq`
   echo "Found users $ACCOUNTS"
   SHARES=`echo ${LOGLINES} | awk -F"|" ' { print $4 } ' | sort | uniq`

   for i in ${ACCOUNTS}; do
      php /etc/fail2ban/scripts/samba-denyuser.php ban ${i} ${IP} >> $LOGPATH
      service samba reload

      PIDS=`smbstatus | grep ${IP} | grep -v \( | awk ' { print $2 } ' | sort | uniq`
      for j in ${PIDS}; do
         kill -9 ${j}
      done
   done

   exit 0
fi

if [ "$ACTION" = "unban" ]; then
   echo "Attempting unban..."
   php /etc/fail2ban/scripts/samba-denyuser.php unban ${IP} >> $LOGPATH
   service samba reload

   exit 0
fi

echo "Verb must be one of (ban | unban)"
exit 1
