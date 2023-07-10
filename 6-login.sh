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

# Create a new user "demo-user" with nuv admin adduser with previous services enabled
if nuv admin adduser demo-user demo@email.com $password --redis --mongodb --minio | grep "whiskuser.nuvolaris.org/demo-user created"
then echo SUCCESS CREATING demo-user
else echo FAIL CREATING demo-user ; exit 1 
fi

sleep 10

case "$TYPE" in
    (kind) 
        if NUV_LOGIN="demo-user" NUV_PASSWORD=$password nuv -login http://localhost:3233 | grep "Successfully logged in as demo-user."
        then echo SUCCESS LOGIN
        else echo FAIL LOGIN ; exit 1 
        fi
    ;;
esac

if nuv setup nuvolaris hello | grep hello
then echo SUCCESS ; exit 0
else echo FAIL ; exit 1 
fi

if nuv -wsk action list | grep /demo-user/hello/hello
then echo SUCCESS ; exit 0
else echo FAIL ; exit 1 
fi