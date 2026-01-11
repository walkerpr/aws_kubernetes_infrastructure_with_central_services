#!/bin/bash
originInstanceType=$1
newInstanceType=$2

for INSTANCE in $(aws ec2 describe-instances --filters Name=instance-type,Values=$originInstanceType Name=instance-state-name,Values=stopped --query Reservations[*].Instances[*].InstanceId --output text); do
  aws ec2 modify-instance-attribute --instance-id $INSTANCE --instance-type "{\"Value\": \"$newInstanceType\"}"
  aws ec2 start-instances --instance-ids $INSTANCE >/dev/null 2>&1
done