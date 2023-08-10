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
setlocal

set "TYPE=%1"
if "%TYPE%"=="" exit /b 1
for /f "tokens=1 delims=-" %%a in ("%TYPE%") do set "TYPE=%%a"

set "user=demouser"
set "password="
for /f "delims=" %%a in ('nuv -random --str 12') do set "password=%%a"

set "ENABLE_REDIS="
nuv config status | findstr /C:"NUVOLARIS_REDIS=true" >nul && set "ENABLE_REDIS=--redis"

set "ENABLE_MONGODB="
nuv config status | findstr /C:"NUVOLARIS_MONGODB=true" >nul && set "ENABLE_MONGODB=--mongodb"

set "ENABLE_MINIO="
nuv config status | findstr /C:"NUVOLARIS_MINIO=true" >nul && set "ENABLE_MINIO=--minio"

set "ENABLE_POSTGRES="
nuv config status | findstr /C:"NUVOLARIS_POSTGRES=true" >nul && set "ENABLE_POSTGRES=--postgres"

:: Create a new user "demo-user" with nuv admin adduser with previous services enabled
nuv admin adduser %user% demo@email.com %password% %ENABLE_REDIS% %ENABLE_MONGODB% %ENABLE_MINIO% %ENABLE_POSTGRES% | findstr /C:"whiskuser.nuvolaris.org/%user% created" >nul
if %errorlevel% equ 0 (
    echo SUCCESS CREATING %user%
) else (
    echo FAIL CREATING %user%
    exit /b 1
)

nuv debug kube ctl CMD="wait --for=condition=ready --timeout=60s -n nuvolaris wsku/%user%"

set "APIURL=http://localhost:3233"
:: if type is not kind, get the APIURL from nuv debug apihost
if "%TYPE%" neq "kind" (
    for /f "tokens=4" %%a in ('nuv debug apihost ^| findstr /C:"whisk API host"') do set "APIURL=%%a"
)

echo %APIURL%
set "NUV_LOGIN=%user%"
set "NUV_PASSWORD=%password%"
nuv -login %APIURL% | findstr /C:"Successfully logged in as %user%." >nul
if %errorlevel% equ 0 (
    echo SUCCESS LOGIN
) else (
    echo FAIL LOGIN
    exit /b 1
)

nuv setup nuvolaris hello | findstr /C:"hello" >nul
if %errorlevel% equ 0 (
    echo SUCCESS
) else (
    echo FAIL
    exit /b 1
)

nuv -wsk action list | findstr /C:"/%user%/hello/hello" >nul
if %errorlevel% equ 0 (
    echo SUCCESS
    exit /b 0
) else (
    echo FAIL
    exit /b 1
)