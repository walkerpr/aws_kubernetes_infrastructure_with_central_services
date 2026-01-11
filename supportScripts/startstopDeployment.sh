#!/bin/bash

DEPLOYMENTNUMBER=$1
STATUS=start


if [ "$(echo $1)" == "" ]; then
  echo "Please include a numeric value after the script name. Example 'bash ./startDeployment.sh 1' "
  exit 1
fi

if [ "$(echo $2)" != "" ]; then
  if [ "$(echo $2)" == "stop" ]; then
  STATUS=$2
  elif [ "$(echo $2)" == "start" ]; then
  STATUS=$2
  else
  echo "Please include either 'start' or 'stop' after the deployment number. Example 'bash ./startDeployment.sh 1 stop' "
  exit 1
  fi
fi

if [ "$(echo $STATUS)" == "start" ]; then
  for INSTANCE in "$(aws ec2 describe-instances --filters "Name=tag:aaDeploymentNumber,Values=$DEPLOYMENTNUMBER" "Name=instance-state-name,Values=stopped" --query "Reservations[*].Instances[*].[InstanceId]" --output text)"; do
  aws ec2 start-instances --instance-ids $INSTANCE >/dev/null
  echo "Instances are being started."
  done
else
  for INSTANCE in "$(aws ec2 describe-instances --filters "Name=tag:aaDeploymentNumber,Values=$DEPLOYMENTNUMBER" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].[InstanceId]" --output text)"; do
  aws ec2 stop-instances --instance-ids $INSTANCE >/dev/null
    echo "Instances are being stopped."
  done
fi