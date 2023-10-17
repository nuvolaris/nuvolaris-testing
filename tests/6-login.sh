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

# Generate a random password for the user "demo"
password=$(nuv -random --str 12)
user="demouser"

ENABLE_REDIS=""
if nuv config status | grep NUVOLARIS_REDIS=true; then
    ENABLE_REDIS="--redis"
fi

ENABLE_MONGODB=""
if nuv config status | grep NUVOLARIS_MONGODB=true; then
    ENABLE_MONGODB="--mongodb"
fi

ENABLE_MINIO=""
if nuv config status | grep NUVOLARIS_MINIO=true; then
    ENABLE_MINIO="--minio"
fi

ENABLE_POSTGRES=""
if nuv config status | grep NUVOLARIS_POSTGRES=true; then
    ENABLE_POSTGRES="--postgres"
fi

# Create a new user "demo-user" with nuv admin adduser with previous services enabled
if nuv admin adduser $user demo@email.com $password $ENABLE_REDIS $ENABLE_MONGODB $ENABLE_MINIO $ENABLE_POSTGRES | grep "whiskuser.nuvolaris.org/$user created"; then
    echo SUCCESS CREATING $user
else
    echo FAIL CREATING $user
    exit 1
fi

nuv util kube waitfor FOR=condition=ready OBJ="wsku/$user" TIMEOUT=120

APIURL="http://localhost:3233"
# if type is not kind, get the APIURL from nuv debug apihost
if [ "$TYPE" != "kind" ]; then
    APIURL=$(nuv debug apihost | awk '/whisk API host/{print $4}')
fi

echo $APIURL
if NUV_LOGIN=$user NUV_PASSWORD=$password nuv -login $APIURL | grep "Successfully logged in as $user."; then
    echo SUCCESS LOGIN
else
    echo FAIL LOGIN
    exit 1
fi

if nuv setup nuvolaris hello | grep hello; then
    echo SUCCESS
else
    echo FAIL
    exit 1
fi

if nuv -wsk action list | grep /$user/hello/hello; then
    echo SUCCESS
    exit 0
else
    echo FAIL
    exit 1
fi
