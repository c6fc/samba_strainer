#! /bin/bash

NAME="samba_strainer"
CONTAINERDATA="/samba"
HOSTDATA="/storage/test"
EXTIFACE="vlan10"

if [ $# != 1 ]; then
   echo "Syntax: $0 <build | del | run>\n"
   exit 1
fi

function build {
   docker build -t $NAME .
}

function del {
   docker ps -a | grep $NAME | awk ' { system("docker stop " $1 "; docker rm " $1) } '
   docker images | grep $NAME | awk ' { system("docker rmi " $3) } '
}

function run {
   docker ps -a | grep $NAME | awk ' { system("docker stop " $1 "; docker rm " $1) } '
   CID=`docker run -dit --net $EXTIFACE -p 139:139 -p 445:445 -v $HOSTDATA:$CONTAINERDATA --name $NAME $NAME /root/start.sh`
#   sudo pipework $EXTIFACE $CID dhclient-f U:$NAME
}

function connect {
   docker ps -a | grep $NAME | awk ' { print("docker exec -it " $1 " /bin/bash") } '
}

case $1 in
connect)
   connect
   ;;
build)
   del
   build
   ;;
del)
   del
   ;;
run)
   run
   ;;
*)
   echo "$1 is not a valid verb"
   echo "Syntax: $0 <build | del | run>\n"
   exit 1
   ;;
esac
