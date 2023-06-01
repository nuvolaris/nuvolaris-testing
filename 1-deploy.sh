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
        nuv config reset
        nuv setup devcluster --uninstall
        nuv setup devcluster
    ;;
    (k3s)
        lib/createAwsVm.sh k3s
        nuv config reset
        nuv setup server $(cat _ip) ubuntu --uninstall
        nuv setup server $(cat _ip) ubuntu
    ;;
    (mk8s)
        nuv config reset
        lib/createAwsVm.sh mk8s
        lib/getKubeConfig.sh $(cat _ip)
        nuv setup cluster microk8s --uninstall
    ;;
    (eks)
        nuv config tls $EMAIL
        nuv setup cluster
    ;;

esac
