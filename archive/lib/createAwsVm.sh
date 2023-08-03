#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

TYPE=${1:?type}
TYPE="$(echo $TYPE | awk -F- '{print $1}')"
STACK=nuvolaris-testing-$TYPE
CONF=$TYPE.cf

# create vm
echo "*** creating the vm and waiting the cloudformation is complete"
aws cloudformation create-stack --stack-name  $STACK --template-body file://conf/$CONF
aws cloudformation wait stack-create-complete --stack-name $STACK

# assign ip to duckdns
#echo "*** extracting IP and assigning to $DNS"
aws ec2 describe-instances  --output json >instance.json \
    --filters Name=tag:Name,Values=$STACK Name=instance-state-name,Values=running
IP=$(cat instance.json | jq -r '.Reservations[].Instances[].PublicIpAddress')


# wait the is vm ready
echo "*** waiting for the vm to be usable via ssh"
mkdir -p ~/.ssh
echo $ID_RSA_B64 | base64 -d > ~/.ssh/id_rsa
chmod 0600  ~/.ssh/id_rsa
N=1
while ! ssh -o "StrictHostKeyChecking=no" ubuntu@$IP sudo cloud-init status --wait
do sleep 10 ; echo "retry $N"
   N=$((N+1))
   if [[ "$N" == 100 ]]
   then exit 1
   fi
done

echo $IP >_ip
echo IP: $IP, saved in ./_ip

