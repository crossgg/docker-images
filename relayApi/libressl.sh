#!/bin/bash

CURL_VERSION=8.0.1
LIBRESSL_VERSION=3.3.6

# 系统检测
if grep -q "Alpine" /etc/os-release; then
    SYSTEM="alpine"
elif grep -q "Debian" /etc/os-release || grep -q "Ubuntu" /etc/os-release; then
    SYSTEM="debian"
else
    echo "未知系统类型，请手动选择编译方式。"
    SYSTEM="unknown"
fi

if [ "$SYSTEM" = "unknown" ]; then
    echo "请选择编译方式："
    echo "1. Alpine"
    echo "2. Debian/Ubuntu"
    read -p "请输入序号 (1 或 2，直接回车默认选择 1): " CHOICE
    if [ -z "$CHOICE" ]; then
        CHOICE="1"
    fi
    if [ "$CHOICE" = "1" ]; then
        SYSTEM="alpine"
    elif [ "$CHOICE" = "2" ]; then
        SYSTEM="debian"
    else
        echo "无效选择，退出脚本。"
        exit 1
    fi
fi

# 安装依赖
if [ "$SYSTEM" = "alpine" ]; then
    echo "检测到 Alpine 系统，安装 Alpine 依赖..."
    sed -i 's#https\?://dl-cdn.alpinelinux.org#https://mirrors.tuna.tsinghua.edu.cn#g' /etc/apk/repositories
    apk add --no-cache build-base bash libtool curl automake pkgconfig \
        zlib-dev libssh2-dev nghttp2-dev openssl-dev libpsl-dev openldap-dev brotli-dev \
        nghttp2-static ca-certificates libunistring-dev heimdal-dev \
        linux-headers libc-dev

elif [ "$SYSTEM" = "debian" ]; then
    echo "检测到 Debian/Ubuntu 系统，安装 Debian 依赖..."
    apt-get update
    apt-get install -y build-essential wget libtool automake vim pkg-config \
        zlib1g-dev libssh2-1-dev libnghttp2-dev libssl-dev libpsl-dev libldap2-dev libbrotli-dev \
        libunistring-dev libidn2-dev libgsasl7-dev libkrb5-dev libgssapi-krb5-2 \
        libc6-dev
fi

# 编译 LibreSSL - 确保启用 TLS-SRP
cd /root && \
    tar -xzf libressl-$LIBRESSL_VERSION.tar.gz && \
    cd libressl-$LIBRESSL_VERSION && \
    chmod +x configure config.* && \

    # 关键修复：显式启用 TLS-SRP
    ./configure --prefix=/opt/psyduck/libressl \
        --enable-tls-srp \
        --enable-srp && \

    make -j$(nproc) && \
    make install && \
    rm -rf ../libressl-*

# 验证 LibreSSL 的 TLS-SRP 支持
echo "验证 LibreSSL 的 TLS-SRP 支持:"
/opt/psyduck/libressl/bin/openssl ciphers -v | grep -i srp
echo ""

# 编译 curl
cd /root && \
    tar -xzf curl-$CURL_VERSION.tar.gz && \
    cd curl-$CURL_VERSION && \
    chmod +x configure config.* && \

    # 添加环境变量强制启用 TLS-SRP
    export CPPFLAGS="-I/opt/psyduck/libressl/include"
    export LDFLAGS="-L/opt/psyduck/libressl/lib"

    ./configure \
        --with-ssl=/opt/psyduck/libressl \
        --disable-shared \
        --enable-static \
        --enable-ldap \
        --enable-ldaps \
        --with-brotli \
        --enable-alt-svc \
        --enable-hsts \
        --enable-proxy \
        --enable-http \
        --enable-https \
        --with-gssapi \
        --with-ntlm \
        --enable-ntlm-wb \
        --enable-tls-srp \
        --enable-unix-sockets \
        --enable-ipv6 \
        --with-libidn2 \
        --with-libgsasl \
        --with-nghttp2 \
        --program-prefix=psyduck- \
        --prefix=/opt/psyduck/curl && \

    make -j$(nproc) && \
    make install && \
    rm -rf ../curl-*

# 验证所有支持的特性
echo "最终支持的特性列表："
/opt/psyduck/curl/bin/psyduck-curl --version
