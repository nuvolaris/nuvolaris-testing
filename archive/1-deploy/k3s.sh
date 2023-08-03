#!/bin/bash
set -e

# config
nuv config reset
task config:aws

# reset
if nuv aws vm-getip k3s-test
then nuv aws vm-delete k3s-test
fi

# deploy
nuv aws vm-create k3s-test
nuv aws k3s-test vm-getip --vm=k3s-test | tee ip.txt
nuv setup server k3s-test ubuntu



