# --- 阶段 1: 编译阶段 ---
FROM golang:1.23-alpine AS build

ARG REPO_URL="https://github.com/crossgg/YYB-Go-Enhanced.git"
ARG BRANCH="main"

RUN apk add --no-cache git ca-certificates tzdata

WORKDIR /src

# 克隆 upstream 源码
RUN git clone -b ${BRANCH} --single-branch ${REPO_URL} .

ENV GOPROXY=https://goproxy.cn,direct
RUN go mod download

# 编译生成二进制文件
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/yyb-go ./cmd/yyb-go

# --- 阶段 2: 运行阶段 ---
FROM alpine:3.21

ENV TZ=Asia/Shanghai
RUN apk add --no-cache ca-certificates wget tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && addgroup -S yyb \
    && adduser -S -G yyb -h /app yyb

WORKDIR /app

# 拷贝二进制程序与静态资源模板
COPY --from=build /out/yyb-go /app/yyb-go
COPY --from=build /src/resource /tmp/resource-src

RUN mkdir -p /app/resource/db /app/data \
    && cp -rn /tmp/resource-src/* /app/resource/ 2>/dev/null || true \
    && rm -rf /tmp/resource-src \
    && chown -R yyb:yyb /app

USER yyb

EXPOSE 8000

ENTRYPOINT ["/app/yyb-go"]
CMD ["-host", "0.0.0.0", "-port", "8000", "-resource-root", "/app/resource"]
