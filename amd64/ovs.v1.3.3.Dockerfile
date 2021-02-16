FROM debian:9.11

RUN echo "deb http://snapshot.debian.org/archive/debian/20190801T025637Z stretch main non-free contrib" >> /etc/apt/sources.list

ENV ARCH=amd64
ENV KVERS="4.9.0-9-$ARCH"
ENV MAGMA_ROOT=/magma

RUN apt update && \
    apt install -y git python-minimal aptitude sudo linux-image-$KVERS linux-headers-$KVERS

RUN git clone https://github.com/magma/magma.git && \
    cd magma && \
    git checkout v1.3.3

COPY resources/ovs_v1.3_build.patch /ovs_v1.3_build.patch
COPY resources/ovs_v1.3_gtp_rules.patch /ovs_v1.3_gtp_rules.patch
COPY resources/ovs_v1.3_gtp_make.patch /ovs_v1.3_gtp_make.patch
 
RUN cd magma && \
    git apply /ovs_v1.3_gtp_make.patch && \
    git apply /ovs_v1.3_gtp_rules.patch && \
    git apply /ovs_v1.3_build.patch && \
    cd lte/gateway/release/ && \
    bash build-ovs.sh

# Move packages to collection folder
RUN mkdir -p /packages && \
    mv /magma/lte/gateway/release/*.deb /packages
