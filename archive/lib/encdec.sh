#!/bin/bash

if test -z "$ID_RSA_B64"
then echo "Please set ID_RSA_B64 i use it as a key"
     exit 1
fi
case "$1" in 

    (encode)
        echo encode 
        TYPE="${2:?type}"
        FILE="${3:?kubeconfig}"
       
        if  grep server: $FILE
        then openssl aes-256-cbc -e -pbkdf2 -a -in $FILE -out "conf/$TYPE.kubeconfig" -pass env:ID_RSA_B64
             echo encoded "conf/$TYPE.kubeconfig"
        else echo $FILE is not a kubeconfig
        fi
    ;;
    (decode)
        echo decode
        TYPE="${2:?type}"
        mkdir -p ~/.kube
        openssl aes-256-cbc -d -pbkdf2 -a -out ~/.kube/config -in "conf/$TYPE.kubeconfig" -pass env:ID_RSA_B64
        grep server: ~/.kube/config
        kubectl get nodes
    ;;
    (*)
        "use: encode <type> <file> | decode <type>"
    ;;
esac