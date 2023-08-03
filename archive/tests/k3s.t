  $ export EXTRA=D=1
Status
  $ nuv setup k3s status 
  No Cluster Installed
  $ mkdir -p ~/.nuv/tmp ; touch ~/.nuv/tmp/kubeconfig 
  $ nuv setup k3s status 
  RUN: kubectl get nodes
  $ rm  ~/.nuv/tmp/kubeconfig
Install
  $ nuv setup k3s install SERVER=demo USERNAME= | sed -e "s|$HOME|HOME|"
  RUN: k3sup install --host=demo --user=root --local-path=HOME/.nuv/tmp/kubeconfig
  $ nuv setup k3s install SERVER=demo | sed -e "s|$HOME|HOME|"
  RUN: k3sup install --host=demo --user=root --local-path=HOME/.nuv/tmp/kubeconfig
Create
  $ nuv setup k3s create SERVER=demo USERNAME=demo | sed -e "s|$HOME|HOME|"
  RUN: k3sup install --host=demo --user=demo --local-path=HOME/.nuv/tmp/kubeconfig
  RUN: kubectl --kubeconfig HOME/.nuv/tmp/kubeconfig apply -f cert-manager.yaml
  $ nuv -config -d | grep NUVOLARIS_APIHOST
  NUVOLARIS_APIHOST=http://demo
Delete
  $ nuv setup k3s delete SERVER=demo
  RUN: ssh -o StrictHostKeyChecking=no root@demo sudo /usr/local/bin/k3s-uninstall.sh
  $ nuv setup k3s delete SERVER=demo USERNAME=
  RUN: ssh -o StrictHostKeyChecking=no root@demo sudo /usr/local/bin/k3s-uninstall.sh
  $ nuv setup k3s delete SERVER=demo USERNAME=demo
  RUN: ssh -o StrictHostKeyChecking=no demo@demo sudo /usr/local/bin/k3s-uninstall.sh
  $ nuv -config -d | grep NUVOLARIS_APIHOST
  NUVOLARIS_APIHOST=auto