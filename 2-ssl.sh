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

# TYPE="$(nuv debug detect)"
TYPE="${1:?test type}"
EMAIL=msciabarra@apache.org

case "$TYPE" in
    (kind) 
        echo SKIPPING 
        exit 0
    ;;
    (k3s)
        lib/updateZone.sh k3s $(cat _ip)
        DNS=
        nuv config apihost $api.k3s.n9s.cc --tls $EMAIL
        nuv update apply
    ;;
esac


if nuv debug apihost | grep "https://"
then echo SUCCESS ; exit 0
else echo FAIL ; exit 1
fi



