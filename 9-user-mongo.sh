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

if nuv config status | grep NUVOLARIS_REDIS=true 
then echo "REDIS ENABLED"
else echo "REDIS DISABLED - SKIPPING" ; exit 0
fi

user="demo-mongo-user"
password=$(nuv -random --str 12)

if nuv admin adduser $user $user@email.com $password --mongodb | grep "whiskuser.nuvolaris.org/$user created"
then echo SUCCESS CREATING $user
else echo FAIL CREATING $user; exit 1 
fi

nuv debug kube ctl CMD="wait --for=condition=ready --timeout=60s -n nuvolaris wsku/$user"

case "$TYPE" in
    (kind) 
        if NUV_LOGIN=$user NUV_PASSWORD=$password nuv -login http://localhost:3233 | grep "Successfully logged in as $user."
        then echo SUCCESS LOGIN
        else echo FAIL LOGIN ; exit 1 
        fi
    ;;
    *)
        APIURL=$(nuv debug apihost | awk '/whisk API host/{print $4}')
        echo $APIURL
        if NUV_LOGIN=$user NUV_PASSWORD=$password nuv -login $APIURL | grep "Successfully logged in as $user."
        then echo SUCCESS LOGIN
        else echo FAIL LOGIN ; exit 1 
        fi
    ;;    
esac

if nuv setup nuvolaris mongodb | grep hello
then echo SUCCESS
else echo FAIL ; exit 1 
fi

if nuv -wsk action list | grep "/$user/hello/mongodb"
then echo SUCCESS ; exit 0
else echo FAIL ; exit 1 
fi


MONGODB_URL=$(nuv -config MONGODB_URL)
if nuv -wsk action invoke /$user/hello/mongodb -p mongodb_url "$MONGODB_URL"| grep "/$user/hello/mongodb"
then echo SUCCESS ; exit 0
else echo FAIL ; exit 1 
fi