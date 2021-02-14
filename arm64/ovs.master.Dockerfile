FROM arm64v8/debian:9.11

RUN echo "deb http://snapshot.debian.org/archive/debian/20190801T025637Z stretch main non-free contrib" >> /etc/apt/sources.list

RUN apt update && \
    apt install -y git python-minimal aptitude sudo linux-image-4.9.0-9-arm64 linux-headers-4.9.0-9-arm64

RUN git clone https://github.com/magma/magma.git 

COPY resources/ovs_v1.4_build.patch /ovs_v1.4_build.patch
COPY resources/ovs_v1.4_gtp_rules.patch /ovs_v1.4_gtp_rules.patch
COPY resources/ovs_v1.4_gtp_make.patch /ovs_v1.4_gtp_make.patch
 
RUN cd magma && \
    git apply /ovs_v1.4_gtp_make.patch && \
    git apply /ovs_v1.4_gtp_rules.patch && \
    git apply /ovs_v1.4_build.patch && \
    cd lte/gateway/release/ && \
    MAGMA_ROOT=/magma KVERS="4.9.0-9-arm64" ARCH="arm64" bash build-ovs.sh

# Move packages to collection folder
RUN mkdir -p /packages && \
    mv /magma/lte/gateway/release/*.deb /packages
