#!/bin/bash

set -euxo pipefail

apt-get -qq update

apt-get -qq install --no-install-recommends -y \
    apt-transport-https \
    gnupg \
    wget \
    procps vainfo \
    unzip locales tzdata libxml2 xz-utils \
    python3-pip \
    curl \
    jq \
    nethogs

mkdir -p -m 600 /root/.gnupg

# armNN_GPU -> arm64
# Khadas VIM4 specific at this point!
if [[ "${TARGETARCH}" == "arm64" ]]; then
   wget -c "https://github.com/ARM-software/armnn/releases/download/v23.02/ArmNN-linux-aarch64.tar.gz"
   mkdir /lib/armnn
   tar -xf ArmNN*.tar.gz -C /lib/armnn
   mkdir /etc
   mkdir /etc/ld.so.con.d
   echo "/lib/armnn" > /etc/ld.so.conf.d/armnn.conf
   wget "https://dl.khadas.com/repos/vim4/pool/main/l/linux-gpu-mali-wayland/linux-gpu-mali-wayland_1.1-r37p0-202208_arm64.deb"
   dpkg -i linux-gpu-mali-wayland_1.1-r37p0-202208_arm64.deb
fi