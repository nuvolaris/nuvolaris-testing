# Setup of Continuos Integration

Those notes are to remind the steps executed to build our CI environment.

## Overview

We have a stable test environment on AWS/GCloud/Azure  with:

- in AWS, a domain (nuvtest.net) with subzones
- in Gcloud, a virtual machine k3s-test and mk8s-test
- in Gcloud, an OpenShift cluster and an 
- in Gcloud, a GKE cluster
- in AWS, an EKS server
- in Azure, an AKS cluster

## Setup

## TODO: configure 

Configure env.dist copying it to env and filling it with all the required secrets.

Note that a number of cloud parameters are wired in the taskfiles: look for the `*:config` tasks in `Taskfile*.yml`.

## TODO: Register Zones

Register manually a domain in AWS (nuvtest.net) and setup the following subzones. 

- k3stest.nuvtest.net
- mk8stest.nuvtest.net
- ekstest.nuvtest.net
- akstest.nuvtest.net 
- gketest.nuvtest.net 
- oshtest.nuvtest.net 

## TODO: Setup a GKE Clusters in GCloud

```
task gc:gke:create
```

## TODO: Setup an AKS Clusters in Azure

## TODO: Setup an OpenShift Cluster in GCloud

## TODO: Setup an EKS cluster in Amazon


## Cleanup

task gc:gke:delete
