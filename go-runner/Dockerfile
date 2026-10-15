FROM alpine:3.21

LABEL maintainer="docker-images" \
      description="A lightweight and robust Docker runtime environment for pre-compiled Go applications."

ENV TZ=Asia/Shanghai \
    APP_DIR=/app

# 核心运行时依赖:
# - ca-certificates: Go 程序发起 HTTPS 请求时校验根证书必备
# - tzdata: 提供时区定义，解决 Go time.LoadLocation("Asia/Shanghai") 等时区加载报错
# - gcompat: musl 下提供 glibc 兼容层，解决跨系统编译未禁用 CGO 时的动态链接报错
# - tini: 作为 PID 1 处理信号转发 (SIGTERM/SIGINT) 与回收僵尸孤儿进程
RUN apk add --no-cache \
        ca-certificates \
        tzdata \
        gcompat \
        tini \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && mkdir -p /app

WORKDIR /app

COPY launcher.sh /launcher.sh
RUN chmod +x /launcher.sh

VOLUME ["/app"]

# 通过 tini 托管启动器，确保优雅关机与进程管理
ENTRYPOINT ["/sbin/tini", "--", "/launcher.sh"]
