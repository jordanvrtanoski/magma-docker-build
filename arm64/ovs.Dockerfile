FROM arm64v8/debian:9.11

RUN echo "deb http://snapshot.debian.org/archive/debian/20190801T025637Z stretch main non-free contrib" >> /etc/apt/sources.list

RUN apt update && \
    apt install -y git python-minimal aptitude sudo linux-image-4.9.0-9-arm64 linux-headers-4.9.0-9-arm64

RUN git clone https://github.com/magma/magma.git && \
    cd magma && \
    git checkout v1.0.1

COPY resources/ovs-build-v1.0.1.patch /ovs-build-v1.0.1.patch 
 
RUN cd magma && \
    git checkout v1.0.1 && \
    git apply /ovs-build-v1.0.1.patch && \
    cd lte/gateway/release/ && \
    MAGMA_ROOT=/magma KVERS="4.9.0-9-arm64" ARCH="arm64" bash build-ovs.sh


