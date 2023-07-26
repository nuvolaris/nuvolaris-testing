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

nuv config enable --minio --static
nuv update apply
nuv debug kube ctl CMD="wait --for=condition=ready --timeout=60s -n nuvolaris pod/nuvolaris-static-0"

user="demo-static-user"
password=$(nuv -random --str 12)

if nuv admin adduser $user $user@email.com $password --redis --minio| grep "whiskuser.nuvolaris.org/$user created"
then echo SUCCESS CREATING $user
else echo FAIL CREATING $user; exit 1 
fi

nuv debug kube ctl CMD="wait --for=condition=ready --timeout=60s -n nuvolaris wsku/$user"
nuv debug kube wait OBJECT=ingress/$user-static-ingress JSONPATH="{.status.loadBalancer.ingress[0]}"

case "$TYPE" in
    (kind)
        echo SUCCESS STATIC FOR LOCALHOST IS SKIPPED 
    ;;
    *)
        API_PROTOCOL=$(nuv debug apihost | awk '/whisk API host/{print $4}' | awk -F[/:] '{print $1}')
        API_DOMAIN=$(nuv debug apihost | awk '/whisk API host/{print $4}' | awk -F[/:] '{print $4}')
        STATIC_URL=$API_PROTOCOL://$user.$API_DOMAIN
        if curl  $STATIC_URL | grep "Welcome to Nuvolaris static content distributor landing page!!!"
        then echo SUCCESS STATIC
        else echo FAIL STATIC ; exit 1 
        fi
    ;;
esac