# Setup of Continuos Integration

Those notes are a remindinder of the steps executed to build our CI environment.

## Overview

We have a stable test environment on AWS/GCloud/Azure  with:

- in AWS, a domain (nuvtest.net) with subzones. A subzone (oshgcp.nuvest.test) is on GCP, others in AWS
- in AWS, an EKS cluster
- in Gcloud, a GKE cluster
- in Gcloud, an OpenShift cluster 
- in Gcloud, a virtual machine k3s-test and mk8s-test
- in Azure, an AKS cluster

# Setup

## Permissions in AWS

Generated an user with admin power and extacted the Access and Secret Key 

## Permissions on google

- Enabled the services required:

```
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable dns.googleapis.com
gcloud services enable iamcredentials.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable servicemanagement.googleapis.com
gcloud services enable serviceusage.googleapis.com
gcloud services enable storage-api.googleapis.com
gcloud services enable storage-component.googleapis.com
gcloud services enable deploymentmanager.googleapis.com
gcloud services enable resourcemanager.projects.delete
```

Also manually Kubernetes cluster creaiton, IAM management

-  Generated a service account for Gcloud with administrative power. 
   Service account email available in: https://console.cloud.google.com/iam-admin/serviceaccounts
   Assigned the role "Owner" to the service account

- Extracted the json for the service account:

```
gcloud iam service-accounts keys create ~/.ssh/gcloud.json --iam-account=<account-email>
```


## SSH 

- Generate a id_rsa and and id_rsa.key,
stored in ~/.ssh/id_rsa and ~/.id_rsa.pub

# DNS

- Created the zone oshgcp.nuvtest.net in Gcloud

- Created the zones in AWS Route53
  - k3stest.nuvtest.net
  - mk8stest.nuvtest.net
  - ekstest.nuvtest.net
  - akstest.nuvtest.net 
  - gketest.nuvtest.net 

- Registered a domain in AWS (nuvtest.net) and delegated all the subzones.

# OpenShift

- Created conf/gcp-install-config.yaml and conf/aws-install-config.yaml
  First running the openshift-install and then manually twaked the configuration.

# Configured variables

- Configure env.dist copying it to env and filling it with all the required secrets.


# Build the cluster


- task osh:create


Note that a number of cloud parameters are wired in the taskfiles: look for the `*:config` tasks in `Taskfile*.yml`.



## TODO: Setup a GKE Clusters in GCloud

```
task gc:gke:create
```

## TODO: Setup an AKS Clusters in Azure

## TODO: Setup an OpenShift Cluster in GCloud

## TODO: Setup an EKS cluster in Amazon


## Cleanup

task gc:gke:delete
