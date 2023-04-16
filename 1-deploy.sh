#!/bin/bash
VER=0.3.0-morpheus.23041217
URL="https://github.com/nuvolaris/nuv/releases/download/$VER/nuv_${VER}_amd64.deb"
wget $URL -O nuv.deb
dpkg -i nuv.deb
nuv -update
nuv -info
