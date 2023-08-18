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

rem Generate a random password for the user "demo"
for /f "usebackq tokens=* delims=" %%a in (`nuv -random --str 12`) do set "password=%%a"
set "user=demouser"

set "ENABLE_REDIS="
nuv config status | find "NUVOLARIS_REDIS=true" > nul
if not errorlevel 1 set "ENABLE_REDIS=--redis"

set "ENABLE_MONGODB="
nuv config status | find "NUVOLARIS_MONGODB=true" > nul
if not errorlevel 1 set "ENABLE_MONGODB=--mongodb"

set "ENABLE_MINIO="
nuv config status | find "NUVOLARIS_MINIO=true" > nul
if not errorlevel 1 set "ENABLE_MINIO=--minio"

set "ENABLE_POSTGRES="
nuv config status | find "NUVOLARIS_POSTGRES=true" > nul
if not errorlevel 1 set "ENABLE_POSTGRES=--postgres"

rem Create a new user "demo-user" with nuv admin adduser with previous services enabled
nuv admin adduser %user% demo@email.com %password% %ENABLE_REDIS% %ENABLE_MONGODB% %ENABLE_MINIO% %ENABLE_POSTGRES% | find "whiskuser.nuvolaris.org/%user% created" > nul
if not errorlevel 1 (
    echo SUCCESS CREATING %user%
) else (
    echo FAIL CREATING %user%
    exit /b 1
)

set "APIURL=http://localhost:3233"
rem if type is not kind, get the APIURL from nuv debug apihost
if not "%TYPE%"=="kind" (
    for /f "tokens=4" %%a in ('nuv debug apihost ^| find "whisk API host"') do set "APIURL=%%a"
)

echo %APIURL%
set "NUV_LOGIN=%user%"
set "NUV_PASSWORD=%password%"
nuv -login %APIURL% | find "Successfully logged in as %user%." > nul
if not errorlevel 1 (
    echo SUCCESS LOGIN
) else (
    echo FAIL LOGIN
    exit /b 1
)

nuv setup nuvolaris hello | find "hello" > nul
if not errorlevel 1 (
    echo SUCCESS
) else (
    echo FAIL
    exit /b 1
)

nuv -wsk action list | find "/%user%/hello/hello" > nul
if not errorlevel 1 (
    echo SUCCESS
    exit /b 0
) else (
    echo FAIL
    exit /b 1
)
