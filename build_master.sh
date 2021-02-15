# Build Magma for aarch64
docker build -t arm64v8/debian_magma:master -f arm64/magma.master.Dockerfile .
docker create --name magma arm64v8/debian_magma:master
docker cp magma:/packages packages/arm64
docker rm magma

# Build OpenVSwitch for aarch64
docker build -t arm64v8/debian_ovs:master -f arm64/ovs.master.Dockerfile .
docker create --name ovs arm64v8/debian_ovs:master
docker cp ovs:/packages packages/arm64
docker rm ovs


# Build Magma for amd64
docker build -t debian_magma:master -f amd64/magma.master.Dockerfile .
docker create --name magma debian_magma:master
docker cp magma:/packages packages/amd64
docker rm magma

# Build OpenVSwitch for amd64
docker build -t debian_ovs:master -f amd64/ovs.master.Dockerfile .
docker create --name ovs debian_ovs:master
docker cp ovs:/packages packages/amd64
docker rm ovs




