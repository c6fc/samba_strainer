#! /bin/bash

# The name to use for the images, container, and to calculate a unique MAC from.
NAME="samba_strainer"

# Where the host data will be mounted in the container. Don't change this.
CONTAINERDATA="/samba"

# The host folder to distrubute via Samba_Strainer.
HOSTDATA="/storage/test"

# Which interface to bridge on. You probably want to change this.
EXTIFACE="br10"


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
   CID=`docker run -dit --net none -v $HOSTDATA:$CONTAINERDATA --name $NAME $NAME /root/start.sh`

   # Use pipework by default.
   sudo pipework $EXTIFACE $CID dhclient-f U:$NAME
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
