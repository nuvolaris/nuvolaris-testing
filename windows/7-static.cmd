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

nuv config enable --minio --static
nuv update apply
nuv debug kube ctl CMD="wait --for=condition=ready --timeout=60s -n nuvolaris pod/nuvolaris-static-0"

set "user=demostaticuser"
set "password="
for /f "delims=" %%a in ('nuv -random --str 12') do set "password=%%a"

set "ENABLE_MINIO="
nuv config status | findstr /C:"NUVOLARIS_MINIO=true" >nul && set "ENABLE_MINIO=--minio"

nuv admin adduser %user% %user%@email.com %password% %ENABLE_MINIO% | findstr /C:"whiskuser.nuvolaris.org/%user% created" >nul
if %errorlevel% equ 0 (
    echo SUCCESS CREATING %user%
) else (
    echo FAIL CREATING %user%
    exit /b 1 
)

nuv debug kube ctl CMD="wait --for=condition=ready --timeout=60s -n nuvolaris wsku/%user%"

set "API_PROTOCOL=http"
set "API_DOMAIN=localhost"
:: if type is not kind, get the API_PROTOCOL and API_DOMAIN from nuv debug apihost
if "%TYPE%" neq "kind" (
    for /f "tokens=4,8 delims=/: " %%a in ('nuv debug apihost ^| findstr /C:"whisk API host"') do (
        set "API_PROTOCOL=%%a"
        set "API_DOMAIN=%%b"
    )
)

if "%API_PROTOCOL%"=="https" (
    nuv debug kube wait OBJECT=ingress/%user%-static-ingress JSONPATH="{.status.loadBalancer.ingress[0]}"
)

set "STATIC_URL=%API_PROTOCOL%://%user%.%API_DOMAIN%"
curl --insecure %STATIC_URL% | findstr /C:"Welcome to Nuvolaris static content distributor landing page!!!" >nul
if %errorlevel% equ 0 (
    echo SUCCESS STATIC
) else (
    echo FAIL STATIC
    exit /b 1 
)