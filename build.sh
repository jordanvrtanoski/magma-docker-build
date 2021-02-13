# Build Magma for aarch64
docker build -t arm64v8/debian_magma -f arm64/magma.v1.0.1.Dockerfile .
docker run -d --rm --name build_env arm64v8/debian_magma /bin/bash -c "mkdir -p /agw && find / -type f -not -path \"/agw/*\" -name *\.deb -exec cp {} /agw/ \; && sleep 600"
sleep 60
docker cp build_env:/agw packages/arm64/
docker stop build_env

# Build OpenVSwitch for aarch64
docker build -t arm64v8/debian_ovs -f arm64/ovs.Dockerfile .
docker run -d --rm --name build_env arm64v8/debian_ovs /bin/bash -c "mkdir -p /ovs && find / -type f -not -path \"/ovs/*\" -name *\.deb -exec cp {} /ovs/ \; && sleep 600"
sleep 60
docker cp build_env:/ovs packages/arm64/
docker stop build_env

# Build Magma for amd86
docker build -t debian_magma -f amd64/magma.Dockerfile .
docker run -d --rm --name build_env debian_magma /bin/bash -c "mkdir -p /agw && find / -type f -not -path \"/agw/*\" -name *\.deb -exec cp {} /agw/ \; && sleep 600"
sleep 60
docker cp build_env:/agw packages/amd64/
docker stop build_env

# Build OpenVSwitch for amd64
docker build -t debian_ovs -f amd64/ovs.Dockerfile .
docker run -d --rm --name build_env debian_ovs /bin/bash -c "mkdir -p /ovs && find / -type f -not -path \"/ovs/*\" -name *\.deb -exec cp {} /ovs/ \; && sleep 600"
sleep 60
docker cp build_env:/ovs packages/amd64/
docker stop build_env

