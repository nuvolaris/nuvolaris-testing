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

nuv config status | findstr /C:"NUVOLARIS_POSTGRES=true" > nul
if %ERRORLEVEL% EQU 0 (
    echo POSTGRES ENABLED
) else (
    echo POSTGRES DISABLED - SKIPPING
    exit /b 0
)

set "user=demopostgresuser"
set "password="
for /f "delims=" %%a in ('nuv -random --str 12') do set "password=%%a"

nuv admin adduser %user% %user%@email.com %password% --postgres | findstr /C:"whiskuser.nuvolaris.org/%user% created" >nul
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

nuv setup nuvolaris postgres | findstr /C:"Nuvolaris Postgres is up and running!" >nul
if %ERRORLEVEL% EQU 0 (
    echo SUCCESS SETUP POSTGRES ACTION
) else (
    echo FAIL SETUP POSTGRES ACTION
    exit /b 1
)

nuv -wsk action list | findstr /C:"/%user%/hello/postgres" >nul
if %ERRORLEVEL% EQU 0 (
    echo SUCCESS USER POSTGRES ACTION LIST
) else (
    echo FAIL USER POSTGRES ACTION LIST
    exit /b 1
)

for /f "delims=" %%a in ('nuv -config POSTGRES_URL') do set "POSTGRES_URL=%%a"

if "%POSTGRES_URL%"=="" (
    echo FAIL USER POSTGRES_URL
    exit /b 1
) else (
    echo SUCCESS USER POSTGRES_URL
)

nuv -wsk action invoke /%user%/hello/postgres -p dburi "%POSTGRES_URL%" -r | findstr /C:"Nuvolaris Postgres is up and running!" >nul
if %errorlevel% equ 0 (
    echo SUCCESS
    exit /b 0
) else (
    echo FAIL
    exit /b 1 
)