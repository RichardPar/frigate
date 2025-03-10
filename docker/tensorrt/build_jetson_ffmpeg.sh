#!/bin/bash

# For jetson platforms, build ffmpeg with custom patches. NVIDIA supplies a deb
# with accelerated decoding, but it doesn't have accelerated scaling or encoding

set -euxo pipefail

INSTALL_PREFIX=/rootfs/usr/lib/ffmpeg/jetson

apt-get -qq update
apt-get -qq install -y --no-install-recommends build-essential ccache clang cmake pkg-config
apt-get -qq install -y --no-install-recommends libx264-dev libx265-dev

pushd /tmp

# Install libnvmpi to enable nvmpi decoders (h264_nvmpi, hevc_nvmpi)
if [ -e /usr/local/cuda-12 ]; then
    # assume Jetpack 6.2
    apt-key adv --fetch-key https://repo.download.nvidia.com/jetson/jetson-ota-public.asc
    echo "deb https://repo.download.nvidia.com/jetson/common r36.4 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list
    echo "deb https://repo.download.nvidia.com/jetson/t234 r36.4 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list
    echo "deb https://repo.download.nvidia.com/jetson/ffmpeg r36.4 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list

    mkdir -p /opt/nvidia/l4t-packages/
    touch /opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall

    apt-get update
    apt-get -qq install -y --no-install-recommends -o Dpkg::Options::="--force-confold" nvidia-l4t-jetson-multimedia-api
elif [ -e /usr/local/cuda-10.2 ]; then
    # assume Jetpack 4.X
    wget -q https://developer.nvidia.com/embedded/L4T/r32_Release_v5.0/T186/Jetson_Multimedia_API_R32.5.0_aarch64.tbz2 -O jetson_multimedia_api.tbz2
    tar xaf jetson_multimedia_api.tbz2 -C / && rm jetson_multimedia_api.tbz2
else
    # assume Jetpack 5.X
    wget -q https://developer.nvidia.com/downloads/embedded/l4t/r35_release_v3.1/release/jetson_multimedia_api_r35.3.1_aarch64.tbz2 -O jetson_multimedia_api.tbz2
    tar xaf jetson_multimedia_api.tbz2 -C / && rm jetson_multimedia_api.tbz2
fi

wget -q https://github.com/AndBobsYourUncle/jetson-ffmpeg/archive/9c17b09.zip -O jetson-ffmpeg.zip
unzip jetson-ffmpeg.zip && rm jetson-ffmpeg.zip && mv jetson-ffmpeg-* jetson-ffmpeg && cd jetson-ffmpeg
LD_LIBRARY_PATH=$(pwd)/stubs:$LD_LIBRARY_PATH   # tegra multimedia libs aren't available in image, so use stubs for ffmpeg build
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX
make -j$(nproc)
make install
cd ../../

# Install nv-codec-headers to enable ffnvcodec filters (scale_cuda)
wget -q https://github.com/FFmpeg/nv-codec-headers/archive/refs/heads/master.zip
unzip master.zip && rm master.zip && cd nv-codec-headers-master
make PREFIX=$INSTALL_PREFIX install
cd ../ && rm -rf nv-codec-headers-master

# Build ffmpeg with nvmpi patch
wget -q https://ffmpeg.org/releases/ffmpeg-6.0.tar.xz
tar xaf ffmpeg-*.tar.xz && rm ffmpeg-*.tar.xz && cd ffmpeg-*
patch -p1 < ../jetson-ffmpeg/ffmpeg_patches/ffmpeg6.0_nvmpi.patch
export PKG_CONFIG_PATH=$INSTALL_PREFIX/lib/pkgconfig
# enable Jetson codecs but disable dGPU codecs
./configure --cc='ccache gcc' --cxx='ccache g++' \
            --enable-shared --disable-static --prefix=$INSTALL_PREFIX \
            --enable-gpl --enable-libx264  --enable-libx265 \
            --enable-nvmpi --enable-ffnvcodec --enable-cuda-llvm \
            --disable-cuvid --disable-nvenc --disable-nvdec \
    || { cat ffbuild/config.log && false; }
make -j$(nproc)
make install
cd ../

rm -rf /var/lib/apt/lists/*
popd
