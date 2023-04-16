#!/bin/bash
VER=0.3.0-morpheus.23041217
URL="https://github.com/nuvolaris/nuv/releases/download/$VER/nuv_${VER}_amd64.deb"
wget --no-verbose $URL -O nuv.deb
sudo dpkg -i nuv.deb
sudo ln -sf /usr/nuvolaris/nuv /usr/local/bin/nuv
nuv -update
nuv -info
nuv setup --devcluster
nuv -wsk action create hello hello.js
nuv -wsk action invoke hello -p name Nuvolaris -r | tee output.txt
if grep Nuvolaris output.txt
then echo SUCCESS ; exit 0
else echo FAIL ; exit 1
fi
