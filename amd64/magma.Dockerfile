FROM debian:9.11

RUN apt update && \
    apt upgrade -y && \
    apt install -y git cmake gcc lsb ca-certificates build-essential autoconf libtool \
               pkg-config libc++-dev clang protobuf-c-compiler protobuf-compiler \
               libprotobuf-dev libcurl4-openssl-dev libxml2-dev libxml2-utils \
               libconfig-dev libconfig++-dev texinfo texlive ghostscript  libyaml-dev \
               libyaml-cpp-dev nlohmann-json-dev libgoogle-glog-dev libprotobuf-dev \
               protobuf-compiler libevent-dev libgoogle-perftools4 libtspi1 \
               libboost-all-dev libghc-double-conversion-dev libjemalloc1 libsnappy1v5 \
               ruby-full wget libssl-dev sudo dialog libcap-ng-dev ninja-build \
               libczmq-dev libsctp-dev libsystemd-dev kmod  
RUN gem install fpm 
RUN apt install -y  python3-apt python3-pkg-resources python3-requests python3-pip virtualenvwrapper
RUN /bin/bash -c "source /usr/share/virtualenvwrapper/virtualenvwrapper.sh && mkvirtualenv -p /usr/bin/python3 pydep && deactivate"

RUN cd / && \
    git clone https://github.com/magma/magma.git && \
    cd magma && \
    git checkout v1.3

RUN cd /magma/third_party/build/bin/ && \
    ./nettle_build.sh && \
    dpkg -i oai-nettle_2.5-1_amd64.deb

RUN cd /magma/third_party/build/bin/ && \
    ./asn1c_build.sh && \
    dpkg -i oai-asn1c_0~20170324+c0~r224dc1f9-0_amd64.deb

RUN cd /magma/third_party/build/bin/ && \
    ./folly_build.sh && \
    dpkg -i libfolly-dev_2018.02.26.00-6_amd64.deb

RUN cd /magma/third_party/build/bin/ && \
    ./magma-libtacopie_build.sh && \
    dpkg -i magma-libtacopie_3.2.0.1-1_amd64.deb

RUN cd /magma/third_party/build/bin/ && \
    ./magma-cpp-redis_build.sh && \
    dpkg -i magma-cpp-redis_4.3.1.1-2_amd64.deb

RUN cd /magma/third_party/build/bin/ && \
    ./liblfds_build.sh && \
    dpkg -i liblfds710_7.1.0-0_amd64.deb

RUN cd /magma/third_party/build/bin/ && \
    ./libfluid_build.sh && \
    dpkg -i magma-libfluid_0.1.0.5-1_amd64.deb

RUN cd /magma/third_party/build/bin/ && \
    ./grpc_build.sh && \
    dpkg -i grpc-dev_1.15.0-3_amd64.deb

RUN cd /magma/third_party/build/bin/ && \
    ./gnutls_build.sh && \
    dpkg -i oai-gnutls_3.1.23-1_amd64.deb

RUN cd /magma/third_party/build/bin/ && \
    ./prometheus-cpp_build.sh && \
    dpkg -i prometheus-cpp-dev_1.0.2-d8326b2_amd64.deb

RUN apt install -y apt-utils
RUN apt install -y mercurial cmake make gcc g++ bison flex libsctp-dev libgcrypt20-dev libidn11-dev ssl-cert debhelper fakeroot libpq-dev libxml2-dev swig python-dev default-libmysqlclient-dev libgnutls28-dev || echo "There was error in the apt install"
RUN cd ~ && hg clone http://www.freediameter.net/hg/freeDiameter && cd freeDiameter && hg update 1.5.0

RUN cd /tmp && mkdir build-freeDiameter && cd build-freeDiameter && \
    cmake ~/freeDiameter -DFD_PROJECT_VENDOR_ID=1234 && \
    make && \
    make install

COPY resources/magma_docker_v1.0.1.patch /magma_docker_v1.0.1.patch
COPY resources/rootCA.pem /rootCA.pem

RUN mkdir /tmp/python-build && \
    cd /magma/lte/gateway/release/ && \
    git checkout v1.0.1 && \
    git apply /magma_docker_v1.0.1.patch

RUN cd /magma/lte/gateway/release/ && PYTHON_BUILD=/tmp/python-build/build PIP_CACHE_HOME=/tmp/python-build/cache MAGMA_ROOT=/magma ./build-magma.sh -a amd64 -c /rootCA.pem -h `git rev-parse --short HEAD`

