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
IF "%TYPE%"=="" (
    ECHO test type parameter is missing.
    EXIT /B 1
)

FOR /F "tokens=1 delims=-" %%A IN ("%TYPE%") DO SET "TYPE=%%A"

:: actual setup
IF "%TYPE%"=="kind" (
    :: create vm with docker
    nuv config reset
    nuv setup devcluster --uninstall
    nuv setup devcluster
) ELSE IF "%TYPE%"=="k3s" (
    :: create vm and install in the server
    nuv config reset
    task aws:config
    :: create vm without k3s
    nuv cloud aws vm-create k3s-test
    nuv cloud aws zone-update k3s.n9s.cc --wildcard --vm=k3s-test
    nuv cloud aws vm-getip k3s-test >_ip
    :: install nuvolaris
    nuv setup server %_ip% ubuntu --uninstall
    nuv setup server %_ip% ubuntu
) ELSE IF "%TYPE%"=="mk8s" (
    nuv config reset
    task aws:config
    :: create vm with mk8s
    nuv cloud aws vm-create mk8s-test
    nuv cloud aws zone-update mk8s.n9s.cc --wildcard --vm=mk8s-test
    nuv cloud aws vm-getip mk8s-test >_ip
    nuv cloud mk8s create SERVER=%_ip% USERNAME=ubuntu
    nuv cloud mk8s kubeconfig SERVER=%_ip% USERNAME=ubuntu
    :: install cluster
    nuv setup cluster --uninstall
    nuv setup cluster
) ELSE IF "%TYPE%"=="eks" (
    nuv config reset
    :: create cluster
    task aws:config
    task eks:config
    nuv cloud eks create
    nuv cloud eks kubeconfig
    nuv cloud eks lb >_cname
    nuv cloud aws zone-update eks.n9s.cc --wildcard --cname=%_cname%
    :: on eks we need to setup an initial apihost resolving the NLB hostname
    nuv config apihost nuvolaris.eks.n9s.cc
    :: install cluster
    nuv setup cluster --uninstall
    nuv setup cluster
) ELSE IF "%TYPE%"=="aks" (
    nuv config reset
    :: create cluster
    task aks:config
    nuv cloud aks create
    SETLOCAL ENABLEDELAYEDEXPANSION
    FOR /F "usebackq tokens=*" %%A IN (`nuv cloud aks lb`) DO SET "IP=%%A"
    ENDLOCAL & SET "IP=%IP%"
    nuv cloud aws zone-update aks.n9s.cc --wildcard --ip %IP%
    :: install cluster
    nuv setup cluster --uninstall
    nuv setup cluster
) ELSE IF "%TYPE%"=="gke" (
    nuv config reset
    :: create cluster
    task gke:config
    nuv cloud gke create
    nuv cloud gke kubeconfig

    task aws:config
    SETLOCAL ENABLEDELAYEDEXPANSION
    FOR /F "usebackq tokens=*" %%A IN (`nuv cloud gke lb`) DO SET "IP=%%A"
    ENDLOCAL & SET "IP=%IP%"
    nuv cloud aws zone-update gke.n9s.cc --wildcard --ip %IP%

    :: install cluster
    nuv setup cluster --uninstall
    nuv setup cluster
) ELSE IF "%TYPE%"=="osh" (
    nuv config reset
    :: create cluster
    task osh:create
    nuv cloud osh import conf/osh/auth/kubeconfig

    :: install cluster
    nuv setup cluster --uninstall
    nuv setup cluster
)