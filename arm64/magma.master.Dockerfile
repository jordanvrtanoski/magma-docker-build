FROM arm64v8/debian:9.11

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

ENV ARCH=arm64
ENV MAGMA_ROOT=/magma

COPY resources/magma_v1.4_asn1c.patch /magma_v1.4_asn1c.patch
COPY resources/magma_v1.4_freediameter.patch /magma_v1.4_freediameter.patch

RUN cd / && \
    git clone https://github.com/magma/magma.git && \
    cd magma && \
    git checkout master && \
    git apply /magma_v1.4_asn1c.patch

RUN cd /magma/third_party/build/bin/ && \
    ./nettle_build.sh && \
    dpkg -i oai-nettle_2.5-1_arm64.deb

RUN cd /magma/third_party/build/bin/ && \
    ./asn1c_build.sh && \
    dpkg -i /magma/third_party/build/bin/oai-asn1c_0~20190423+c0~rf12568d6-0_arm64.deb

RUN cd /magma/third_party/build/bin/ && \
    ./folly_build.sh && \
    dpkg -i libfolly-dev_2018.02.26.00-6_arm64.deb

RUN cd /magma/third_party/build/bin/ && \
    ./magma-libtacopie_build.sh && \
    dpkg -i magma-libtacopie_3.2.0.1-1_arm64.deb

RUN cd /magma/third_party/build/bin/ && \
    ./magma-cpp-redis_build.sh && \
    dpkg -i magma-cpp-redis_4.3.1.1-2_arm64.deb

RUN cd /magma/third_party/build/bin/ && \
    ./liblfds_build.sh && \
    dpkg -i liblfds710_7.1.0-0_arm64.deb

RUN cd /magma/third_party/build/bin/ && \
    ./libfluid_build.sh && \
    dpkg -i magma-libfluid_0.1.0.5-1_arm64.deb

RUN cd /magma/third_party/build/bin/ && \
    ./grpc_build.sh && \
    dpkg -i grpc-dev_1.15.0-3_arm64.deb

RUN cd /magma/third_party/build/bin/ && \
    ./gnutls_build.sh && \
    dpkg -i oai-gnutls_3.1.23-1_arm64.deb

RUN cd /magma/third_party/build/bin/ && \
    ./prometheus-cpp_build.sh && \
    dpkg -i prometheus-cpp-dev_1.0.2-d8326b2_arm64.deb

RUN apt install -y libgcrypt-dev libbison-dev flex bison libidn11-dev libtins-dev libmnl-dev libpcap-dev

RUN cd /magma/third_party/build/bin/ && \
    git apply /magma_v1.4_freediameter.patch && \
    ./freediameter_build.sh && \
    dpkg -i oai-freediameter_1.2.0-1_arm64.deb

## Move libraries to the package collection area
RUN mkdir -p /packages && \
    mv /magma/third_party/build/bin/*.deb /packages

# Prepare working folders
RUN mkdir /tmp/go && \
    mkdir /tmp/go/root && \
    mkdir /tmp/go/work && \
    mkdir /tmp/java

# Go Lang dependancies
RUN wget https://golang.org/dl/go1.15.8.linux-arm64.tar.gz -O /tmp/go/go1.15.8.linux-arm64.tar.gz && \
    tar -C /usr/local -xzf /tmp/go/go1.15.8.linux-arm64.tar.gz

# Python dependancies
RUN python3 -m pip install -U pip setuptools && \
    apt install -y python3-aioeventlet python3-aiodns

# Java Dependancies
RUN echo 'deb http://ftp.debian.org/debian stretch-backports main' | tee /etc/apt/sources.list.d/stretch-backports.list && \
    apt update && \
    apt install -y openjdk-11-jdk
RUN wget https://oss.sonatype.org/content/repositories/releases/io/swagger/swagger-codegen-cli/2.4.18/swagger-codegen-cli-2.4.18.jar -O /tmp/java/swagger-codegen-cli-2.4.18.jar

# Build environment  
ENV SWAGGER_CODEGEN_JAR=/tmp/java/swagger-codegen-cli-2.4.18.jar
ENV GOPATH=/tmp/go/work
ENV GOPROXY=https://proxy.golang.org
ENV PATH=/usr/local/go/bin:$PATH:$GOROOT/bin:$GOPATH/bin

ENV GO_BUILD=/tmp/go/work/bin/
ENV PYTHON_BUILD=/tmp/python-build/build
ENV PIP_CACHE_HOME=/tmp/python-build/cache
ENV SERVICE_DIR=/magma/lte/gateway/deploy/roles/magma/files/systemd/

COPY resources/rootCA.pem /rootCA.pem
COPY resources/magma_v1.4_build.patch /magma_v1.4_build.patch
COPY resources/magma_v1.4_pydep.patch /magma_v1.4_pydep.patch

RUN cd /magma && \
    git apply /magma_v1.4_build.patch && \
    git apply /magma_v1.4_pydep.patch

## Move the missing service files in packaging area. TODO: Remove this once the files are part of the master
RUN cp $MAGMA_ROOT/orc8r/tools/ansible/roles/gateway_services/files/magma.service $SERVICE_DIR/magma.service && \
    cp $MAGMA_ROOT/orc8r/tools/ansible/roles/fluent_bit/files/magma_td-agent-bit.service $SERVICE_DIR/magma_td-agent-bit.service && \
    cp $MAGMA_ROOT/orc8r/tools/ansible/roles/gateway_services/files/magma_control_proxy.service $SERVICE_DIR/magma_control_proxy.service

RUN apt-get install -y python3-aioeventlet python3-aiodns python3-aiohttp python3-jsonpickle

RUN cd /magma/lte/gateway/release/ && \
    ./build-magma.sh -c /rootCA.pem -h `git rev-parse --short HEAD`

RUN cd /magma/lte/gateway/release/ && \
    make debian.python3

RUN mv /magma/lte/gateway/release/*.deb /packages

