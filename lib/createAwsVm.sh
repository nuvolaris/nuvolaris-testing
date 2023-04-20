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
HOST=$TYPE-nuv-test
DNS=$HOST.duckdns.org

aws cloudformation create-stack --stack-name  $STACK --template-body file://conf/$CONF
echo waiting the creation is complete
aws cloudformation wait stack-create-complete --stack-name $STACK
aws ec2 describe-instances  --output json >instance.json \
    --filters Name=tag:Name,Values=$STACK Name=instance-state-name,Values=running

# get ip
IP=$(cat instance.json | jq -r '.Reservations[].Instances[].PublicIpAddress')
echo $IP > ip.txt

# assign dyndns
echo Assigning $DNS=$IP
curl "https://www.duckdns.org/update?domains=$HOST&token=$DUCKDNS_TOKEN&ip=$IP"
echo ""
while true
do  if host -a $DNS | grep $IP
    then break
    else echo waiting DNS ; sleep 5 
    fi
done

echo IP: $IP, DNS: $DNS
