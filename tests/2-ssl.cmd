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

@ECHO OFF
SET "TYPE=%~1"
SET "EMAIL=msciabarra@apache.org"

IF "%TYPE%"=="" (
    ECHO test type parameter is missing.
    EXIT /B 1
)

IF "%TYPE%"=="kind" (
    ECHO SKIPPING
    EXIT /B 1
)

FOR /F %%A IN ('nuv -random --str 5') DO SET "rn=%%A"

IF "%TYPE%"=="osh" (
    REM configure
    nuv config apihost api.apps.nuvolaris.osh.nuvtest.net --tls %EMAIL%
    nuv update apply
) ELSE (
    nuv config reset
    REM task aws:config

    REM configure
    nuv config apihost nuvolaris.%rn%.%TYPE%.nuvtest.net --tls %EMAIL%
    nuv update apply
)

REM check we have https
FOR /F "tokens=* USEBACKQ" %%L IN (`nuv debug status ^| FIND "apihost: https://"`) DO (
    ECHO SUCCESS
    EXIT /B 0
)

ECHO FAIL
EXIT /B 1