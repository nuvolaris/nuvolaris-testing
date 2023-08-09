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

if nuv config status | findstr /C:"NUVOLARIS_REDIS=true" (
    echo REDIS ENABLED
) else (
    echo REDIS DISABLED - SKIPPING
    exit /b 0
)

set "user=demoredisuser"
set "password="
for /f "delims=" %%a in ('nuv -random --str 12') do set "password=%%a"

nuv admin adduser %user% %user%@email.com %password% --redis | findstr /C:"whiskuser.nuvolaris.org/%user% created" >nul
if %errorlevel% equ 0 (
    echo SUCCESS CREATING %user%
) else (
    echo FAIL CREATING %user%
    exit /b 1 
)

nuv debug kube ctl CMD="wait --for=condition=ready --timeout=60s -n nuvolaris wsku/%user%"

if "%TYPE%"=="kind" (
    set "NUV_LOGIN=%user%"
    set "NUV_PASSWORD=%password%"
    nuv -login http://localhost:3233 | findstr /C:"Successfully logged in as %user%." >nul
) else (
    for /f "tokens=4,8 delims=/: " %%a in ('nuv debug apihost ^| findstr /C:"whisk API host"') do (
        set "APIURL=%%a://%%b"
    )
    set "NUV_LOGIN=%user%"
    set "NUV_PASSWORD=%password%"
    nuv -login %APIURL% | findstr /C:"Successfully logged in as %user%." >nul
)
if %errorlevel% equ 0 (
    echo SUCCESS LOGIN
) else (
    echo FAIL LOGIN
    exit /b 1 
)

if nuv setup nuvolaris redis | findstr /C:"hello" >nul
then echo SUCCESS SETUP REDIS ACTION
else echo FAIL SETUP REDIS ACTION; exit /b 1 
fi

if nuv -wsk action list | findstr /C:"/%user%/hello/redis" >nul
then echo SUCCESS USER REDIS ACTION LIST
else echo FAIL USER REDIS ACTION LIST; exit /b 1 
fi

for /f "delims=" %%a in ('nuv -config REDIS_URL') do set "REDIS_URL=%%a"
for /f "delims=" %%a in ('nuv -config REDIS_PREFIX') do set "REDIS_PREFIX=%%a"

if "%REDIS_URL%"=="" (
    echo FAIL REDIS_URL
    exit /b 1
) else (
    echo SUCCESS REDIS_URL
)

if "%REDIS_PREFIX%"=="" (
    echo FAIL REDIS_PREFIX
    exit /b 1
) else (
    echo SUCCESS REDIS_PREFIX
)

nuv -wsk action invoke /%user%/hello/redis -p redis_url "%REDIS_URL%" -p redis_prefix "%REDIS_PREFIX%" -r | findstr /C:"hello" >nul
if %errorlevel% equ 0 (
    echo SUCCESS
    exit /b 0
) else (
    echo FAIL
    exit /b 1 
)