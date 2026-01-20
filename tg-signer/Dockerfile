# --- 阶段 1: 编译阶段 ---
FROM python:3.12-slim-bookworm AS builder

WORKDIR /build

# 安装编译环境
RUN apt-get update && apt-get install -y --no-install-recommends gcc python3-dev && \
    pip wheel --wheel-dir=./wheels tgcrypto

# --- 阶段 2: 运行阶段 ---
FROM python:3.12-slim-bookworm

ARG TZ=Asia/Shanghai
ENV TZ=${TZ} \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 

# 从编译阶段拷贝 wheel 包
COPY --from=builder /build/wheels /tmp/wheels

# 安装系统依赖、配置时区并清理缓存
RUN apt-get update && \
    apt-get install -y --no-install-recommends tzdata && \
    ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 先安装本地编译好的 wheel，再安装主程序
RUN pip install --no-cache-dir /tmp/wheels/*.whl && \
    pip install --no-cache-dir "tg-signer[tgcrypto]" && \
    rm -rf /tmp/wheels

WORKDIR /opt/tg-signer

# 拷贝脚本并确保执行权限
COPY tg-signer/start.sh .
RUN chmod +x start.sh

ENV PORT 8080
EXPOSE $PORT/tcp

# 使用 Exec 格式启动
CMD ["/bin/bash", "start.sh"]