# 使用轻量级运行时镜像
FROM alpine:latest

# 设置清华源以加快下载速度
RUN sed -i 's#https\?://dl-cdn.alpinelinux.org/alpine#https://mirrors.tuna.tsinghua.edu.cn/alpine#g' /etc/apk/repositories

# 安装运行时依赖
RUN apk add --no-cache \
        bash \
        iproute2 \
        iputils \
        openssl \
        curl \
        frp

# 设置工作目录
WORKDIR /root/

# 复制必要的文件
COPY . .
RUN chmod +x libressl.sh
RUN ./libressl.sh
# 根据 Target Architecture (TARGETARCH) 自动识别并复制对应的 psyduck 二进制文件
ARG TARGETARCH
RUN case "${TARGETARCH}" in \
      "amd64") cp psyduck-amd64 psyduck ;; \
      "arm64") cp psyduck-arm64 psyduck ;; \
      "arm")   cp psyduck-armv7 psyduck || cp psyduck-arm psyduck ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    chmod +x ./psyduck && \
    rm -f psyduck-amd64 psyduck-arm64 psyduck-armv7 psyduck-arm

RUN chmod +x ./server.sh
# 设置容器以NET_ADMIN权限运行
# 注意：实际运行时需要添加 --cap-add=NET_ADMIN 参数

# 启动应用
CMD ["./server.sh"]
