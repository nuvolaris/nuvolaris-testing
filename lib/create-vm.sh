#!/bin/bash

NAME=${1:?test name}

STACK=nuvolaris-test-$NAME

echo $ID_RSA_B64 | base64 -d - >id_rsa
echo $ID_RSA_PUB >id_rsa.pub

