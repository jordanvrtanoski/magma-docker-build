# Build Magma for aarch64
docker build -t arm64v8/debian_magma:v1.3.3 -f arm64/magma.v1.3.3.Dockerfile .
docker create --name magma arm64v8/debian_magma:v1.3.3
docker cp magma:/packages packages/arm64
docker rm magma

# Build OpenVSwitch for aarch64
docker build -t arm64v8/debian_ovs:v1.3.3 -f arm64/ovs.v1.3.3.Dockerfile .
docker create --name ovs arm64v8/debian_ovs:v1.3.3
docker cp ovs:/packages packages/arm64
docker rm ovs


