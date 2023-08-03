  $ export EXTRA=D=1
Context:
  $ nuv setup kubernetes context
  Using current context
  RUN: kubectl config get-contexts
  $ nuv setup kubernetes context CONTEXT=
  Using current context
  RUN: kubectl config get-contexts
  $ nuv setup kubernetes context CONTEXT=test
  RUN: kubectl config use-context test
  RUN: kubectl config get-contexts
Info
  $ nuv setup kubernetes info | grep RUN:
  RUN: kubectl config get-contexts
  RUN: kubectl -n nuvolaris get no
  RUN: kubectl version --short
  $ nuv setup kubernetes status | grep RUN:
  RUN: kubectl -n nuvolaris get sts,po,svc
Create
  $ nuv setup kubernetes create | grep RUN:
  RUN: kubectl config get-contexts
  RUN: kubectl apply -f common -f roles -f crds
  RUN: kubectl apply -f _operator.yaml
  RUN: kubectl -n nuvolaris get pod/nuvolaris-operator
  RUN: kubectl -n nuvolaris wait --for=condition=ready pod/nuvolaris-operator --timeout=10s
  RUN: kubectl apply -f _whisk.yaml
  RUN: kubectl -n nuvolaris get pod/couchdb-0
  RUN: kubectl -n nuvolaris wait --for=condition=ready pod/couchdb-0 --timeout=10s
  RUN: kubectl -n nuvolaris get pod/controller-0
  RUN: kubectl -n nuvolaris wait --for=condition=ready pod/controller-0 --timeout=10s
  $ nuv setup kubernetes create CONTEXT= | grep "kubectl config"
  RUN: kubectl config get-contexts
  $ nuv setup kubernetes create CONTEXT=demo | grep "kubectl config"
  RUN: kubectl config use-context demo
  RUN: kubectl config get-contexts
Delete
  $ nuv setup kubernetes delete
  RUN: kubectl -n nuvolaris delete wsk/controller
  RUN: kubectl -n nuvolaris delete all --all
  RUN: kubectl -n nuvolaris delete pvc --all
  RUN: kubectl delete ns nuvolaris
