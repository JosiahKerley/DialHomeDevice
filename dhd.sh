#!/bin/bash
if [ "$1" == "port" ]
then
  free=0
  while [ ! "$free" == "1" ]
  do
    port=`shuf -i2222-65535 -n1`
    netstat -tulpn | grep $port
    free=$?
  done
  echo $port
elif [ "$1" == "list" ]
then
  rm -f /var/run/dhd/sessions/* > /dev/null 2>&1
  echo ""
  echo "Waiting for hosts..."
  sleep 2
  echo ""
  ls "/var/run/dhd/sessions" | nl
  echo ""
elif [ "$1" == "connect" ]
then
  if [ "$2" == "" ]
  then
    echo "Format: dhd connect clientsessionname"
  else
    if [ -f "/var/run/dhd/sessions/$2" ]
    then
      ssh localhost -p `cat /var/run/dhd/sessions/$2`
    fi
    rm -f "/var/run/dhd/sessions/$2"
  fi
elif [ "$1" == "dial" ]
then
  if [ "$2" == "" ]
  then
    echo "Format: dhd connect servernameorip"
  else
    reverseport=`ssh $2 dhd port`
    sleep 1
    ssh -R $reverseport:localhost:22 $2 dhd heartbeat $reverseport `hostname`
  fi
elif [ "$1" == "heartbeat" ]
then
  if [ "$2" == "" ]
  then
    echo "Format:  dhd heartbeat reverseport clienthostnameorip"
  else
    echo "Connected to `hostname`"
    dir=/var/run/dhd/sessions
    mkdir -p "$dir" > /dev/null 2>&1
    while [ 1 == 1 ]
    do
      echo "Connected as $2 with port $3"
      echo $2 > "$dir/$3"
      sleep 10
    done
  fi
else
  cat << EOF

Usage:

  Server side:
    List current sessions-
      dhd list

    List current sessions-
      dhd connect <session name>


  Client side:
    List current sessions-
      dhd dial <hostname or ip of server>


EOF
fi
