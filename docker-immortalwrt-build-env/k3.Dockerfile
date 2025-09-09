FROM debian:buster
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

RUN apt-get update &&\
    apt-get full-upgrade -y &&\
    apt-get install -y \
        sudo make \
        ack antlr3 asciidoc autoconf automake autopoint bash binutils bison build-essential bzip2 \
        ccache clang cmake cpio curl device-tree-compiler ecj fastjar flex g++ g++-multilib \
        gawk gcc-multilib gettext git gnutls-dev gperf haveged help2man intltool lib32gcc-s1 \
        libc6-dev-i386 libelf-dev libglib2.0-dev libfuse-dev libgmp3-dev libltdl-dev liblzma-dev libmpc-dev libmpfr-dev libncurses-dev libpam0g-dev \
        libpython3-dev libreadline-dev libsnmp-dev libssl-dev libtool libyaml-dev lld llvm lrzsz make \
        mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python3 python3-distutils-extra python3-docutils python3-pip \
        python3-ply python3-pyelftools python3-setuptools python-is-python3 \
        qemu-utils re2c rsync scons squashfs-tools subversion sudo swig texinfo time uglifyjs unzip upx-ucl vim wget xmlto xxd xz-utils zlib1g-dev zstd && \
    apt-get clean && \
    useradd -m user && \
    echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user  && \
    export FORCE_UNSAFE_CONFIGURE=1

# set system wide dummy git config
RUN git config --system user.name "user" && git config --system user.email "user@example.com"

USER user
WORKDIR /home/user

# 下载源码
# RUN git clone -b openwrt-24.10 --single-branch --filter=blob:none https://github.com/immortalwrt/immortalwrt && \
#    cd immortalwrt && \

RUN git clone https://github.com/coolsnowwolf/lede && \
    cd lede && \
    ./scripts/feeds update -a && \
    ./scripts/feeds install -a && \
    curl https://raw.githubusercontent.com/xiangfeidexiaohuo/AE86Wrt/refs/heads/main/configs/ARM/other/k3.config –o .config && \
    make defconfig
    make download -j8 && \
    make -j1 V=s
    
    
