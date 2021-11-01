FROM node:lts-alpine
LABEL maintainer="DDD"
ARG XDD_URL=https://github.com/764763903a/xdd-plus.git
ARG XDD_BRANCH=main
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
    XDD_DIR=/xdd \
	ENABLE_WEB_XDD=false

WORKDIR ${XDD_DIR}
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update -f \
    && apk upgrade \
    && apk --no-cache add -f bash \
                             coreutils \
                             moreutils \
                             git \
                             curl \
                             wget \
                             tzdata \
                             perl \
                             openssl \
                             nginx \
                             python3 \
                             jq \
                             openssh \
                             build-base \
							 gcc \
                             g++ \
                             cairo-dev \
                             pango-dev \
                             giflib-dev \
    && rm -rf /var/cache/apk/* \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && touch ~/.bashrc 

## 安装go环境
RUN cd /usr/local \
    && wget https://golang.google.cn/dl/go1.17.1.linux-amd64.tar.gz \
	&& rm -rf /usr/local/go \
	&& tar -C /usr/local -xzf go1.17.1.linux-amd64.tar.gz \
	&& rm go1.17.1.linux-amd64.tar.gz \
	&& export GO111MODULE=on \
	&& export GOPROXY=https://goproxy.cn \
	&& export GOROOT=/usr/local/go \
	&& export GOPATH=/usr/local/go/path \
	&& export PATH=$PATH:$GOROOT/bin:$GOPATH/bin \
    && touch ~/.bashrc 

## 编译 XDD
RUN git clone -b ${XDD_BRANCH} ${XDD_URL} ${XDD_DIR} \
    && git config --global user.email "hzoo@vip.qq.com" \
    && git config --global user.name "q123458384" \
    && git config --global pull.rebase true \
    && cd ${XDD_DIR} \
	&& go build -o xdd

RUN npm install -g pnpm \
    && pnpm install -g pm2 \
    && pnpm install -g png-js crypto-js download got http-server request tough-cookie tunnel ws \
    && rm -rf /root/.npm \
    && rm -rf /root/.pnpm-store 

# Add files.
RUN mkdir -p /shell && mkdir -p /${XDD_DIR}/log

COPY xdd-plus/docker-entrypoint.sh ${XDD_DIR}/docker-entrypoint.sh
RUN chmod 777 /shell/docker-entrypoint.sh && chmod a+x /shell/docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
