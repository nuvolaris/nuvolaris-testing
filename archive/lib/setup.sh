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

## install the latest version of nuv
# cleanup, just in case
VER="$(curl https://raw.githubusercontent.com/nuvolaris/olaris/0.3.0/nuvroot.json | jq .version -r)"
URL="https://github.com/nuvolaris/nuv/releases/download/$VER/nuv_${VER}_amd64.deb"
sudo dpkg -r nuv
sudo rm -f /usr/local/bin/nuv /usr/bin/nuv
sudo rm -Rf ~/.nuv/
wget --no-verbose $URL -O nuv.deb
sudo dpkg -i nuv.deb
nuv -update
nuv -info

## install task and cram
if ! which task; then
    sudo sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
fi
if ! which cram; then
    pip install cram --user
fi

# deploy the ssh key
if test -e env.src; then
    echo "Sourcing env.src"
    source env.src
fi

mkdir -p ~/.ssh
if test -n "$ID_RSA_B64"; then
    echo $ID_RSA_B64 | base64 -d - >~/.ssh/id_rsa
    chmod 0600 ~/.ssh/id_rsa
    ssh-keygen -y -f ~/.ssh/id_rsa >~/.ssh/id_rsa.pub
else
    echo "*** Missing ID_RSA_B64 ***"
fi
mkdir -p ~/.kube

# deploy by type
case "$TYPE" in
kind)
    #  remove containers if any
    if docker ps -qa | wc -l | grep -v -x 0; then
        docker ps -qa | xargs docker rm -f
    fi
    ;;
k3s)
    lib/createAwsVm.sh k3s

    ;;
mk8s)
    lib/createAwsVm.sh mk8s
    lib/updateZone.sh mk8s "$(cat _ip)"
    lib/getKubeConfig.sh mk8s.nuvtest.net
    ;;
eks)
    lib/encdec.sh decode eks
    lib/updateZone.sh eks "$(cat conf/eks.lb)" CNAME
    ;;
esac
