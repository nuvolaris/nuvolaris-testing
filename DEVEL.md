# How to run tests

## Prereq

You need a few tools:
- [`task`](taskfile.dev)
- `aws` cli
- `azure` cli 
- `gcloud` cli 

All of them are available in the nuvolers developer image or virtual machine. Check the [nuvolaris main repo](https://github.com/nuvolaris/nuvolaris) for info about the Dockerfile or the cloud-init to build a suitable vm with all the tools.

## Config 

Copy `env.dist` in `env` and fill the keys for the various cloud providers

The `env` is used by the `task` command executor for configuration.

## Setup Kubernetes Environments

You can setup the various enviroments with

- task kind:create
  creates a kind cluster
- task k3s:create
  creates a vm and deploys k3s in it
- task mk8s:create
  setup a vm with micro k8s and extract a kubeconfig
- task eks:create
  initializes an Amason EKS cluster
- task aks:create
  initializes an Azure AKS cluster
- task gke:create
  initializes a Google GKE cluster

For each xxx:create there is also xxx:delete to remove, xxx:status to show what is happening and xxx:config to setup the configuration from the environment variables

## Switch deployment

Note that each task will create a different kubernetes environment.
There is always one active but you can switch to the others.

Use:

- `nuv config use` lists the available kubeconfigs.
- `nuv config use <n>` to select one kubeconfig.

## Test execution

Once you have setup the environment you can run the tests:

- ./2-ssl.sh
- ./3-sys-redis.sh
- ./4-shs-mongo.sh
- ./5-sys-minio.sh
- ./6-login.sh
- ./7-static.sh
- ./8-user-redis.sh
- ./9-user-mongo.sh
- ./10-user-minio.sh

## Deployment

The first task automate deployment (for continuous integration):

```
./1-deploy.sh <type>
```

where `<type>` is one of:

- kind
- k3s  
- mk8s
- eks
- aks
- gke
- osh

this task is to be executed by GitHub, once you have provided enough informations as secrets.

###

# future multi environment
The following tests are plannedo to  ensure everything works in different environments:

On windows: ./11-nuv-win.sh
On mac: ./12-nuv-mac.sh
