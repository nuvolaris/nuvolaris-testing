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

if nuv config status | grep NUVOLARIS_MINIO=true; then
    echo "MINIO ENABLED"
else
    echo "MINIO DISABLED - SKIPPING"
    exit 0
fi

user="demominiouser"
password=$(nuv -random --str 12)

if nuv admin adduser $user $user@email.com $password --minio | grep "whiskuser.nuvolaris.org/$user created"; then
    echo SUCCESS CREATING $user
else
    echo FAIL CREATING $user
    exit 1
fi

nuv util kube waitfor FOR=condition=ready OBJ="wsku/$user" TIMEOUT=120

case "$TYPE" in
kind)
    if NUV_LOGIN=$user NUV_PASSWORD=$password nuv -login http://localhost:3233 | grep "Successfully logged in as $user."; then
        echo SUCCESS LOGIN
    else
        echo FAIL LOGIN
        exit 1
    fi
    ;;
*)
    APIURL=$(nuv debug apihost | awk '/whisk API host/{print $4}')
    if NUV_LOGIN=$user NUV_PASSWORD=$password nuv -login $APIURL | grep "Successfully logged in as $user."; then
        echo SUCCESS LOGIN
    else
        echo FAIL LOGIN
        exit 1
    fi
    ;;
esac

if nuv setup nuvolaris minio | grep hello; then
    echo SUCCESS SETUP MINIO ACTION
else
    echo FAIL
    exit 1
fi

if nuv -wsk action list | grep "/$user/hello/minio"; then
    echo SUCCESS USER MINIO ACTION LIST
else
    echo FAIL
    exit 1
fi

MINIO_ACCESS_KEY=$(nuv -config MINIO_ACCESS_KEY)
MINIO_SECRET_KEY=$(nuv -config MINIO_SECRET_KEY)
MINIO_HOST=$(nuv -config MINIO_HOST)
MINIO_PORT=$(nuv -config MINIO_PORT)
MINIO_DATA_BUCKET=$(nuv -config MINIO_DATA_BUCKET)
MINIO_STATIC_BUCKET=$(nuv -config MINIO_STATIC_BUCKET)

if [[ -z "$MINIO_ACCESS_KEY" ]]; then
    echo FAIL USER MINIO_ACCESS_KEY
    exit 1
else
    echo SUCCESS USER MINIO_ACCESS_KEY
fi

if nuv -wsk action invoke hello/minio -p minio_access "$MINIO_ACCESS_KEY" \
    -p minio_secret "$MINIO_SECRET_KEY" \
    -p minio_host "$MINIO_HOST" \
    -p minio_port "$MINIO_PORT" \
    -p minio_data "$MINIO_DATA_BUCKET" -r | grep "$user-data"; then
    echo SUCCESS
    exit 0
else
    echo FAIL
    exit 1
fi
