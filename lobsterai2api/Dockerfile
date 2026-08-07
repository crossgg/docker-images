# 阶段一：Go 源码编译阶段
FROM golang:alpine AS builder
WORKDIR /app
RUN apk add --no-cache git
RUN git clone https://github.com/xinxinshuhao-create/lobsterai2api.git .
RUN CGO_ENABLED=0 go build -ldflags="-w -s" -o lobsterai2api ./cmd/server && \
    CGO_ENABLED=0 go build -ldflags="-w -s" -o login ./cmd/login && \
    CGO_ENABLED=0 go build -ldflags="-w -s" -o credit ./cmd/credit

# 阶段二：轻量级运行时镜像
FROM alpine:latest
WORKDIR /app
RUN apk add --no-cache ca-certificates tzdata bash curl
ENV TZ=Asia/Shanghai

COPY --from=builder /app/lobsterai2api /app/
COPY --from=builder /app/login /app/
COPY --from=builder /app/credit /app/
COPY --from=builder /app/config.example.json /app/config.example.json

# 复制启动脚本并配置执行权限
COPY lobsterai2api/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# 挂载数据卷
VOLUME ["/data"]

EXPOSE 8367
ENTRYPOINT ["/app/entrypoint.sh"]
