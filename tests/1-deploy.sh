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

cd "$(dirname $0)"

if test -e ../.secrets
then source ../.secrets
else echo "missing .secrets - you should generate it"
     echo "to generate it, set .env variables from .env.dist then execute task secrets"
     echo "otherwise, just touch .secrets but be aware it will try to rebuild all the clusters (good luck)"
fi

# recode the id_rsa if setup
mkdir -p ~/.ssh
if test -n "$ID_RSA_B64"
then echo $ID_RSA_B64 | base64 -d >~/.ssh/id_rsa
     chmod 0600 ~/.ssh/id_rsa
fi

# disable preflight memory and cpu check
export PREFL_NO_CPU_CHECK=true
export PREFL_NO_MEM_CHECK=true

# actual setup
case "$TYPE" in
kind)
    # create vm with docker
    nuv config reset
    nuv setup devcluster --uninstall
    nuv setup devcluster
    ;;
k3s)
    # create vm and install in the server
    nuv config reset
    # create vm without k3s
    if test -n "$K3S_IP"
    then 
        echo $K3S_IP>_ip
        nuv config apihost api.k3s.nuvtest.net
    else
        task aws:vm:config
        nuv cloud aws vm-create k3s-test
        nuv cloud aws zone-update k3s.nuvtest.net --wildcard --vm=k3s-test
        nuv cloud aws vm-getip k3s-test >_ip
    fi
    # install nuvolaris
    nuv setup server $(cat _ip) ubuntu --uninstall
    nuv setup server $(cat _ip) ubuntu
    ;;
mk8s)
    nuv config reset
    # create vm with mk8s
    if test -n "$MK8S_IP"
    then 
          nuv config apihost api.mk8s.nuvtest.net
          nuv cloud mk8s kubeconfig SERVER=$MK8S_IP USERNAME=ubuntu
    else
        task aws:vm:config
        nuv cloud aws vm-create mk8s-test
        nuv cloud aws zone-update mk8s.nuvtest.net --wildcard --vm=mk8s-test
        nuv cloud aws vm-getip mk8s-test >_ip
        nuv cloud mk8s create SERVER=$(cat _ip) USERNAME=ubuntu
        nuv cloud mk8s kubeconfig SERVER=$(cat _ip) USERNAME=ubuntu
    fi
    # install cluster
    nuv setup cluster --uninstall
    nuv setup cluster
    ;;
eks)
    nuv config reset
    # create cluster
    if test -n "$EKS_KUBECONFIG_B64"
    then
        mkdir -p ~/.kube
        echo $EKS_KUBECONFIG_B64 | base64 -d >~/.kube/config
        nuv config apihost api.eks.nuvtest.net
        nuv config use 0
    else
        task aws:config
        task eks:config
        nuv cloud eks create
        nuv cloud eks kubeconfig
        nuv cloud eks lb >_cname
        nuv cloud aws zone-update eks.nuvtest.net --wildcard --cname=$(cat _cname)
        # on eks we need to setup an initial apihost resolving the NLB hostname
        nuv config apihost api.eks.nuvtest.net
    fi
    # install cluster
    nuv debug defin
    nuv setup cluster --uninstall
    nuv setup cluster
    ;;
aks)
    nuv config reset
    # create cluster
    if test -n "$AKS_KUBECONFIG_B64"
    then
        mkdir -p ~/.kube
        echo $AKS_KUBECONFIG_B64 | base64 -d >~/.kube/config
        nuv config use 0
        nuv config apihost api.aks.nuvtest.net
    else
        task aks:config
        nuv cloud aks create
        nuv cloud aks kubeconfig
        task aws:config
        IP=$(nuv cloud aks lb)
        nuv cloud aws zone-update aks.nuvtest.net --wildcard --ip $IP
    fi
    # install cluster
    nuv debug defin
    nuv setup cluster --uninstall
    nuv setup cluster
    ;;
gke)
    nuv config reset
    # create cluster
    if test -n "$GCLOUD_SERVICE_ACCOUNT_B64"
    then     
        mkdir -p ~/.kube
        echo "$GCLOUD_SERVICE_ACCOUNT_B64" | base64 -d  >~/.kube/gcloud.json
        gcloud auth activate-service-account --key-file ~/.kube/gcloud.json
        gcloud container clusters get-credentials nuvolaris-testing --project nuvolaris-testing --region=us-east1
        
        nuv config use 0
        nuv config apihost api.gke.nuvtest.net
    else
        task gcp:vm:config
        task aws:vm:config
        nuv cloud gke create
        nuv cloud gke kubeconfig
        nuv cloud aws zone-update gke.nuvtest.net --wildcard --ip $(nuv cloud gke lb)
    fi
    # install cluster
    nuv debug defin
    nuv setup cluster --uninstall
    nuv setup cluster
    ;;

osh)
    nuv config reset
    # create cluster
    if test -n "$OPENSHIFT_KUBECONFIG_B64"
    then
        mkdir -p ~/.kube
        echo $OPENSHIFT_KUBECONFIG_B64 | base64 -d >~/.kube/config
        nuv config use 0
        nuv config apihost api.apps.nuvolaris-testing.oshgcp.nuvtest.net
    else
        task osh:create
        nuv cloud osh import conf/gcp/auth/kubeconfig
    fi
    # install cluster
    nuv debug defin
    nuv setup cluster --uninstall
    nuv setup cluster
    ;;

esac
