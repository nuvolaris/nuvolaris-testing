#!/bin/bash
set -e

# config
nuv config reset
task config:aws

# reset
if nuv aws vm-getip mk8s-test
then nuv aws vm-delete mk8s-test
fi

# deploy
nuv aws vm-create mk8s-test --microk8s


