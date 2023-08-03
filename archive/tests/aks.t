AKS Config
  $ export EXTRA=D=1
  $ nuv se config reset >/dev/null
  $ nuv setup aks create 2>&1
  Please, first configure AKS with "nuv setup config aks"
  error: task: Failed to run task "create": task: Failed to run task "prereq": exit status 1
  [1]
  $ nuv setup config aks --name=nuv --region=eastus --count=3  --vm=Standard_B4ms --disk=30 | sort
  AKS_COUNT=3
  AKS_DISK=30
  AKS_NAME=nuv
  AKS_REGION=eastus
  AKS_VM=Standard_B4ms
AKS Create
  $ nuv setup aks create
  RUN: az version
  DATA: az account show --query id -o tsv
  RUN: az account set --subscription $DATA
  RUN: az group create --name nuv --location eastus
  RUN: az aks create -g nuv -n nuv --enable-managed-identity --node-count 3 --node-osdisk-size=30 --node-vm-size=Standard_B4ms
  RUN: az aks get-credentials --name nuv --resource-group nuv --overwrite-existing -f $NUV_TMP/kubeconfig
AKS Delete  
  $ nuv setup aks delete
  *** Deleting the nuv cluster
  DATA: az account show --query id -o tsv
  RUN: az account set --subscription $DATA
  RUN: az aks delete --name nuv --resource-group nuv
  RUN: rm $NUV_TMP/kubeconfig
