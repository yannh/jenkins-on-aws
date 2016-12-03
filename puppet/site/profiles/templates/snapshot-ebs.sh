#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CONFIGFILE=/etc/ebs-snapshot.cfg
EXITCODE=0

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Will configure $VOLUMEID
if [ -f $CONFIGFILE ]; then
  if [ -r $CONFIGFILE ]; then
    source $CONFIGFILE
  else
    echo "Failed to read $CONFIGFILE on $SERVER (permission denied) - Snapshot will NOT be run!" 1>&2
    exit 1
  fi
else
  echo "$CONFIGFILE not existing on $SERVER - Snapshot will NOT be run!" 1>&2
  exit
fi

if [ -z $VOLUMEID ] ; then
  echo "$CONFIGFILE does not initialise $VOLUMEID on $SERVER - Snapshot will NOT be run!" 1>&2
  exit 1
fi

JENKINSFS=/var/lib/jenkins
SERVER=$(uname -n)

if ! fsfreeze -f /var/lib/jenkins ; then
  echo "Failed to lock $JENKINSFS on $SERVER - Snapshot will NOT be run!" 1>&2
  exit 1
fi

DATE=$(date --rfc-3339=date)
SNAPSHOTID=$(aws ec2 create-snapshot --region eu-central-1 --output=text --description "Jenkins EBS for $SERVER - $DATE" --volume-id $VOLUMEID --query SnapshotId 2>/dev/null)
if [ $? -ne 0 ] ; then
  echo "Failed to snapshot $JENKINSFS on $SERVER" 1>&2
  EXITCODE=1
else
  aws ec2 create-tags --region eu-central-1 --resource $SNAPSHOTID --tags Key=Name,Value=$CLUSTER-$DATE Key=cluster,Value=$CLUSTER
  if [ $? -ne 0 ] ; then
    echo "Failed to add tags to $SNAPSHOTID" 1>&2
    EXITCODE=1
  fi
fi

if ! fsfreeze -u /var/lib/jenkins  ; then
  echo "Failed to unlock $JENKINSFS on $SERVER" 1>&2
  EXITCODE=1
fi

exit $EXITCODE
