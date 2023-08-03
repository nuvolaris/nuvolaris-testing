#!/bin/bash
set -e

# config
nuv config reset
task config:eks

# reset
if nuv cloud aws vm-getip k3s-test
then nuv cloud aws vm-delete k3s-test
fi

# deploy
nuv cloud aws vm-create k3s-test
nuv cloud aws k3s-test vm-getip --vm=k3s-test | tee ip.txt
nuv setup server k3s-test ubuntu


