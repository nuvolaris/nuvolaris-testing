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

if "%TYPE%"=="k3s" (
    set "K3S=true"
) else (
    set "K3S=false"
)

if "%TYPE%"=="kind" (
    set "KIND=true"
) else (
    set "KIND=false"
)

if "%TYPE%"=="mk8s" (
    set "MK8S=true"
) else (
    set "MK8S=false"
)

if "%TYPE%"=="gke" (
    set "GKE=true"
) else (
    set "GKE=false"
)

if "%TYPE%"=="aks" (
    set "AKS=true"
) else (
    set "AKS=false"
)

if "%TYPE%"=="eks" (
    set "EKS=true"
) else (
    set "EKS=false"
)

if not "%K3S%"=="true" (
    if not "%KIND%"=="true" (
        if not "%MK8S%"=="true" (
            if not "%GKE%"=="true" (
                if not "%AKS%"=="true" (
                    if not "%EKS%"=="true" (
                        echo "Error: input must be one of 'kind', 'k3s', 'mk8s', 'gke', 'aks', or 'eks'."
                        exit /b 1
                    )
                )
            )
        )
    )
)

echo "##############################################"
echo "#                                            #"
echo "#             DEPLOYING %TYPE%                #"
echo "#                                            #"
echo "##############################################"
call 1-deploy.cmd %TYPE%

echo "##############################################"
echo "#                                            #"
echo "#             TESTING SSL %TYPE%              #"
echo "#                                            #"
echo "##############################################"
call 2-ssl.cmd %TYPE%

echo "##############################################"
echo "#                                            #"
echo "#            TESTING REDIS %TYPE%             #"
echo "#                                            #"
echo "##############################################"
call 3-sys-redis.cmd

echo "##############################################"
echo "#                                            #"
echo "#    TESTING FERRETDB (MONGO) %TYPE%          #"
echo "#                                            #"
echo "##############################################"
call 4a-sys-ferretdb.cmd

echo "##############################################"
echo "#                                            #"
echo "#            TESTING POSTGRES %TYPE%          #"
echo "#                                            #"
echo "##############################################"
call 4b-sys-postgres.cmd

echo "##############################################"
echo "#                                            #"
echo "#            TESTING MINIO %TYPE%             #"
echo "#                                            #"
echo "##############################################"
call 5-sys-minio.cmd

echo "##############################################"
echo "#                                            #"
echo "#            TESTING LOGIN %TYPE%             #"
echo "#                                            #"
echo "##############################################"
call 6-login.cmd %TYPE%

echo "##############################################"
echo "#                                            #"
echo "#            TESTING USER REDIS %TYPE%        #"
echo "#                                            #"
echo "##############################################"
call 8-user-redis.cmd %TYPE%

echo "##############################################"
echo "#                                            #"
echo "#   TESTING USER FERRETDB (MONGO) %TYPE%      #"
echo "#                                            #"
echo "##############################################"
call 9a-user-ferretdb.cmd %TYPE%

echo "##############################################"
echo "#                                            #"
echo "#            TESTING USER POSTGRES %TYPE%     #"
echo "#                                            #"
echo "##############################################"
call 9b-user-postgres.cmd %TYPE%

echo "##############################################"
echo "#                                            #"
echo "#            TESTING USER MINIO %TYPE%        #"
echo "#                                            #"
echo "##############################################"
call 10-user-minio.cmd %TYPE%