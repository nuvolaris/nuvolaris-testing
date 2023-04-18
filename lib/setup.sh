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

## install task
sudo sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

## install nuv
VER=0.3.0-morpheus.23041622
URL="https://github.com/nuvolaris/nuv/releases/download/$VER/nuv_${VER}_amd64.deb"
wget --no-verbose $URL -O nuv.deb
sudo dpkg -i nuv.deb
nuv -update 2>/dev/null
nuv -info

# deploy by type
case "$TYPE" of
    (mk8s) 
        lib/createAwsVm.sh mk8s
        lib/getKubeConfig.sh "$(cat ip.txt)"
    ;;
esac
