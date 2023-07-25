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
TYPE="${1:?test type}"
TYPE="$(echo $TYPE | awk -F- '{print $1}')"

# actual setup
case "$TYPE" in
    (kind)
        # create vm with docker
        nuv config reset
        nuv setup devcluster --uninstall
        nuv setup devcluster
    ;;
    (k3s)
        # create vm and install in the server
        nuv config reset
        task aws:config
        # create vm without k3s
        nuv cloud aws vm-create k3s-test
        nuv cloud aws vm-getip k3s-test >_ip
        # install nuvolaris
        nuv setup server $(cat _ip) ubuntu --uninstall
        nuv setup server $(cat _ip) ubuntu
    ;;
    (mk8s)
        nuv config reset
        task aws:config
        # create vm with mk8s
        nuv cloud aws vm-create mk8s-test
        nuv cloud aws vm-getip mk8s-test >_ip
        nuv cloud mk8s create SERVER=$(_ip) USERNAME=ubuntu
        nuv cloud mk8s kubeconfig SERVER=$(_ip) USERNAME=ubuntu
        #
        nuv setup cluster --uninstall
    ;;
    (eks)
        # create cluster
        task aws:config
        task eks:config
        nuv cloud eks create
        nuv cloud eks kubeconfig
        # install cluster
        nuv setup cluster --uninstall
        nuv setup cluster
    ;;
    (aks)
        # create cluster
        task aks:config
        nuv cloud aks create
        nuv cloud aks kubeconfig
        # install cluster
        nuv setup cluster --uninstall
        nuv setup cluster
    ;;
    (gke)
        # create cluster
        task gke:config
        nuv cloud gke create
        nuv cloud gke kubeconfig
        # install cluster
        nuv setup cluster --uninstall
        nuv setup cluster
esac
