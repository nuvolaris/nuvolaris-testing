FROM ubuntu:22.04
RUN apt-get update && apt-get install -y git jq wget curl
WORKDIR /tmp
RUN git clone https://github.com/bats-core/bats-core.git ;\
    cd bats-core ; ./install.sh /usr/local
RUN curl -fsSL https://get.docker.com | bash
WORKDIR /root
RUN mkdir test_helper ;\
    cd test_helper ;\
    git clone https://github.com/bats-core/bats-support ;\
    git clone https://github.com/bats-core/bats-file ;\
    git clone https://github.com/bats-core/bats-assert ;\
    git clone https://github.com/bats-core/bats-detik
ENV NUV_BRANCH=3.0.0-testing
RUN VER="$(curl https://raw.githubusercontent.com/nuvolaris/olaris/3.0.0-testing/nuvroot.json | jq .version -r)" ;\
    ARCH="$(dpkg --print-architecture)";\
    URL="https://github.com/nuvolaris/nuv/releases/download/$VER/nuv_${VER}_${ARCH}.deb" ;\
    wget --no-verbose $URL -O nuv.deb ;\
    dpkg -i nuv.deb ;\
    nuv -update ;\
    nuv -info
