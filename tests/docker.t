  $ export EXTRA=D=1
StStatus 
  $ nuv setup docker status
  Cluster Nuvolaris not found
Create
  $ nuv setup docker create | grep "RUN:" | sed -e "s|$HOME|home|g"
  RUN: kind create cluster --wait=1m --name=nuvolaris --config=_kind.yaml --kubeconfig=home/.nuv/tmp/kubeconfig
  RUN: kubectl apply -f ingress-deploy.yaml
Delete:
  $ nuv setup docker delete
  RUN: kind delete clusters nuvolaris
