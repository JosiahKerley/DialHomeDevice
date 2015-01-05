#!/bin/bash
sessions="/var/run/dhd/sessions"
outbox="/var/run/dhd/outbox"
inbox="/var/run/dhd/inbox"
mkdir -p $sessions > /dev/null 2>&1
mkdir -p $outbox > /dev/null 2>&1
mkdir -p $inbox > /dev/null 2>&1

session2hostname()
{
  id=$1  
  if [[ "$id" =~ ^[0-9]+$ ]]
  then
    n=`ls -1 "$sessions" | head -$id | tail -1`
    echo $n
    id=$n
  fi
  if [ -f "$sessions/$id" ]
  then
    echo `cat "$sessions/$id"`
  fi
}

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
  find /var/run/dhd/sessions/ -type f -not -newermt "-`cat /etc/dhd/maxage` seconds" -delete > /dev/null 2>&1
  echo ""
  ls "/var/run/dhd/sessions" | nl
  echo ""
elif [ "$1" == "exec" ]
then
  if [ "$2" == "" ]
  then
    echo "Format: dhd exec clientsessionname"
  else
    #echo "exec:"
    #echo `session2hostname $2`
    #echo "exec^"
    if [ -f "/var/run/dhd/sessions/$2" ]
    then
      ssh localhost -p `session2hostname $2` $3 $4 $5 $6 $7 $8 $9
    fi
    rm -f "/var/run/dhd/sessions/$2"
  fi
elif [ "$1" == "dial" ]
then
  if [ "$2" == "" ]
  then
    echo "Format: dhd dial servernameorip"
  else
    reverseport=`ssh $2 dhd port`
    sleep 1
    ssh -R $reverseport:localhost:`cat /etc/dhd/port` $2 dhd heartbeat $reverseport `hostname`
  fi
elif [ "$1" == "heartbeat" ]
then
  if [ "$2" == "" ]
  then
    echo "Format:  dhd heartbeat reverseport clienthostnameorip"
  else
    echo "Connected to `hostname`"
    while [ 1 == 1 ]
    do
      echo "Connected as $3 with port $2 '`date`'"
      echo $2 > "$sessions/$3"
      sleep 1
    done
  fi
else
  cat << EOF

Usage:

  Server side:
    List current sessions-
      dhd list

    List current sessions-
      dhd exec <session name>


  Client side:
    List current sessions-
      dhd dial <hostname or ip of server>


EOF
fi
