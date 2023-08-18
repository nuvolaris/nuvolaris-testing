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

nuv config status | find "NUVOLARIS_REDIS=true" > nul
if not errorlevel 1 (
    echo REDIS ENABLED
) else (
    echo REDIS DISABLED - SKIPPING
    exit /b 0
)

set "user=demoredisuser"

for /f "usebackq tokens=* delims=" %%a in (`nuv -random --str 12`) do set "password=%%a"

nuv admin adduser %user% %user%@email.com %password% --redis | find "whiskuser.nuvolaris.org/%user% created" > nul
if not errorlevel 1 (
    echo SUCCESS CREATING %user%
) else (
    echo FAIL CREATING %user%
    exit /b 1
)

nuv debug kube ctl CMD="wait --for=condition=ready --timeout=60s -n nuvolaris wsku/%user%"

set "LOGIN_COMMAND="
set "APIURL=http://localhost:3233"
if "%TYPE%"=="kind" (
    set "LOGIN_COMMAND=nuv -login %APIURL% | find "Successfully logged in as %user%." > nul"
) else (
    for /f "tokens=4" %%a in ('nuv debug apihost ^| find "whisk API host"') do set "APIURL=%%a"
    set "LOGIN_COMMAND=NUV_LOGIN=%user% NUV_PASSWORD=%password% nuv -login !APIURL! | find "Successfully logged in as %user%." > nul"
)

rem Use delayed expansion for variable expansion inside the block
setlocal enabledelayedexpansion
if "%TYPE%"=="kind" (
    !LOGIN_COMMAND!
    if not errorlevel 1 (
        echo SUCCESS LOGIN
    ) else (
        echo FAIL LOGIN
        exit /b 1
    )
) else (
    !LOGIN_COMMAND!
    if not errorlevel 1 (
        echo SUCCESS LOGIN
    ) else (
        echo FAIL LOGIN
        exit /b 1
    )
)
endlocal

nuv setup nuvolaris redis | find "hello" > nul
if not errorlevel 1 (
    echo SUCCESS SETUP REDIS ACTION
) else (
    echo FAIL SETUP REDIS ACTION
    exit /b 1
)

nuv -wsk action list | find "/%user%/hello/redis" > nul
if not errorlevel 1 (
    echo SUCCESS USER REDIS ACTION LIST
) else (
    echo FAIL USER REDIS ACTION LIST
    exit /b 1
)

for /f "tokens=* delims=" %%a in ('nuv -config REDIS_URL') do set "REDIS_URL=%%a"
for /f "tokens=* delims=" %%a in ('nuv -config REDIS_PREFIX') do set "REDIS_PREFIX=%%a"

if not defined REDIS_URL (
    echo FAIL REDIS_URL
    exit /b 1
) else (
    echo SUCCESS REDIS_URL
)

if not defined REDIS_PREFIX (
    echo FAIL REDIS_PREFIX
    exit /b 1
) else (
    echo SUCCESS REDIS_PREFIX
)

nuv -wsk action invoke hello/redis -p redis_url "%REDIS_URL%" -p redis_prefix "%REDIS_PREFIX%" -r | find "hello" > nul
if not errorlevel 1 (
    echo SUCCESS
    exit /b 0
) else (
    echo FAIL
    exit /b 1
)
