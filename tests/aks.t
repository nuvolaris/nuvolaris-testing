Azure Config
  $ export EXTRA=D=1
  $ nuv se config reset >/dev/null
  $ nuv setup azure create 2>&1
  Please, first configure AKS with "nuv setup config aks"
  error: task: Failed to run task "create": exit status 1
  [1]
  $ nuv setup config aks --name=nuvolaris --region=eastus --count=1  --vm=Standard_B4ms --disk=30 | sort
  AKS_COUNT=1
  AKS_DISK=30
  AKS_NAME=nuvolaris
  AKS_REGION=eastus
  AKS_VM=Standard_B4ms
Azure Create
  $ nuv setup azure create
  RUN: az version
  RUN: az account set --subscription RUN: az account show --query id -o tsv
  RUN: az group create --name nuvolaris --location eastus
  RUN: az aks create -g nuvolaris -n nuvolaris --enable-managed-identity --node-count 1 --node-osdisk-size=30 --node-vm-size=Standard_B4ms
  RUN: az aks get-credentials --name nuvolaris --resource-group nuvolaris --overwrite-existing
  $ nuv setup azure delete
  RUN: az account set --subscription $(cat _id)
  *** Deleting the nuvolaris cluster
  RUN: az aks delete --name nuvolaris --resource-group nuvolaris
