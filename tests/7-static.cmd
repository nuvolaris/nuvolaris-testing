:: Licensed to the Apache Software Foundation (ASF) under one
:: or more contributor license agreements.  See the NOTICE file
:: distributed with this work for additional information
:: regarding copyright ownership.  The ASF licenses this file
:: to you under the Apache License, Version 2.0 (the
:: "License"); you may not use this file except in compliance
:: with the License.  You may obtain a copy of the License at
::
::   http://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing,
:: software distributed under the License is distributed on an
:: "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
:: KIND, either express or implied.  See the License for the
:: specific language governing permissions and limitations
:: under the License.
@echo off

setlocal enabledelayedexpansion

set "TYPE=%~1"
if "%TYPE%"=="" (
    echo test type parameter is missing.
    exit /b 1
)

for /f "tokens=1 delims=-" %%a in ("%TYPE%") do set "TYPE=%%a"

nuv config enable --minio --static
nuv update apply
nuv debug kube ctl CMD="wait --for=condition=ready --timeout=60s -n nuvolaris pod/nuvolaris-static-0"

set "user=demostaticuser"

for /f "usebackq tokens=* delims=" %%a in (`nuv -random --str 12`) do set "password=%%a"

nuv admin adduser %user% %user%@email.com %password% --minio | find "whiskuser.nuvolaris.org/%user% created" > nul
if not errorlevel 1 (
    echo SUCCESS CREATING %user%
) else (
    echo FAIL CREATING %user%
    exit /b 1
)

nuv debug kube ctl CMD="wait --for=condition=ready --timeout=60s -n nuvolaris wsku/%user%"

for /f "tokens=4 delims=[/:" %%a in ('nuv debug apihost ^| find "whisk API host"') do set "API_PROTOCOL=%%a"
for /f "tokens=4 delims=[/:]" %%a in ('nuv debug apihost ^| find "whisk API host"') do set "API_DOMAIN=%%a"

if "%TYPE%"=="osh" (
    for /f "usebackq tokens=* delims=" %%a in ('nuv debug kube wait OBJECT=route.route.openshift.io/%user%-static-route JSONPATH="{.status.ingress[0].host}"') do set "STATIC_URL=%%a"
) else (
    for /f "usebackq tokens=* delims=" %%a in ('nuv debug kube wait OBJECT=ingress/%user%-static-ingress JSONPATH="{.status.loadBalancer.ingress[0]}"') do set "STATIC_URL=%%a"
)

if "%TYPE%"=="kind" (
    echo SUCCESS STATIC FOR LOCALHOST IS SKIPPED
) else (
    set "STATIC_URL=!API_PROTOCOL!://!user!.!API_DOMAIN!"
    echo testing using !STATIC_URL!
    curl --insecure !STATIC_URL! | find "Welcome to Nuvolaris static content distributor landing page!!!" > nul
    if not errorlevel 1 (
        echo SUCCESS STATIC
    ) else (
        echo FAIL STATIC
        exit /b 1
    )
)
