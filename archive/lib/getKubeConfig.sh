#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

IP="${1:?ip}"

mkdir -p ~/.kube
ssh  -o "StrictHostKeyChecking=no" ubuntu@$IP cat /etc/kubeconfig  >~/.kube/config

echo waiting for node ready
ST=""
while [[ "$ST" != "Ready" ]]
do ST="$(kubectl get nodes | awk 'NR==2 { print $2}')"
   sleep 5
done
kubectl get nodes