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

# deploy by type
case "$TYPE" of
    (kind) SETUP_ARGS="--devcluster" ;;
    (mk8s) SETUP_ARGS="" ;;
esac

# hello world testh
nuv setup $SETUP_ARGS
nuv -wsk action create hello actions/hello.js
nuv -wsk action invoke hello -p name Nuvolaris -r | tee output.txt
if grep Nuvolaris output.txt
then echo SUCCESS ; exit 0
else echo FAIL ; exit 1
fi
