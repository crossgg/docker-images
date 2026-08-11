# --- 阶段 1: 编译阶段 ---
FROM golang:1.23-alpine AS build

ARG REPO_URL="https://github.com/525815266/YYB-Go-Enhanced.git"
ARG BRANCH="main"

RUN apk add --no-cache git ca-certificates tzdata

WORKDIR /src

# 克隆 upstream 源码
RUN git clone -b ${BRANCH} --single-branch ${REPO_URL} .

ENV GOPROXY=https://goproxy.cn,direct
RUN go mod download

# 编译
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/yyb-go ./cmd/yyb-go

# --- 阶段 2: 运行阶段 ---
FROM alpine:3.21

ENV TZ=Asia/Shanghai
RUN apk add --no-cache ca-certificates wget tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && addgroup -S yyb \
    && adduser -S -G yyb -h /app yyb

WORKDIR /app

# 拷贝二进制程序与静态资源
COPY --from=build /out/yyb-go /app/yyb-go
COPY --from=build /src/resource /app/resource

RUN mkdir -p /app/data && chown -R yyb:yyb /app

USER yyb

EXPOSE 8000

CMD ["/app/yyb-go"]
