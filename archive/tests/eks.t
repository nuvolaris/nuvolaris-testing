EKS config
  $ export EXTRA=D=1
  $ nuv se config reset >/dev/null
  $ nuv setup eks create 2>&1
  Please, first configure EKS with "nuv setup config eks"
  error: task: Failed to run task "create": task: Failed to run task "prereq": exit status 1
  [1]
  $ nuv setup config eks --name=nuv --region=us-east-1 --count=3 --vm=m5.xlarge --disk=100 --key=nuvolaris-key --kubever=1.25 | sort
  EKS_COUNT=3
  EKS_DISK=100
  EKS_KUBERNETES_VERSION=1.25
  EKS_NAME=nuv
  EKS_REGION=us-east-1
  EKS_SSHKEY=nuvolaris-key
  EKS_VM=m5.xlarge
EKS Create
  $ nuv setup eks create 
  RUN: aws --version
  RUN: aws ec2 describe-key-pairs --key-names nuvolaris-key --query KeyPairs[*].{KeyName: KeyName} --output table
  RUN: envsubst -i eks-cluster.yml -o _eks-cluster.yml
  RUN: eksctl create cluster -f _eks-cluster.yml --kubeconfig $NUV_TMP/kubeconfig
  Waiting for nodes
  RUN: kubectl get nodes
  0 Waiting for nodes ready
  RUN: kubectl get nodes
  RUN: kubectl apply -f cert-manager.yaml
  RUN: kubectl apply -f ingress-deploy.yaml
EKS Delete
  $ nuv setup eks delete
  *** Deleting the Cluster
  RUN: kubectl delete -f cert-manager.yaml
  RUN: kubectl delete -f ingress-deploy.yaml
  RUN: eksctl delete cluster -f _eks-cluster.yml --disable-nodegroup-eviction
  RUN: rm /home/ubuntu/.nuv/tmp/kubeconfig
