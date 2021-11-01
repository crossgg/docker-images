FROM node:lts-alpine
LABEL maintainer="DDD"
# ARG XDD_URL=https://github.com/XXX/XXXX.git
# ARG XDD_BRANCH=main
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
	ENABLE_EXTRA=false
	

WORKDIR ${WORKDIR}
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
    && npm install -g pnpm \
    && pnpm install -g pm2 \
    && pnpm install -g png-js crypto-js download got http-server request tough-cookie tunnel ws \
    && rm -rf /root/.npm \
    && pnpm install --prod \
    && rm -rf /root/.pnpm-store \
    && rm -rf /var/cache/apk/* \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && touch ~/.bashrc \
    ## 安装go环境 ##
    && cd /usr/local \
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

## Add files . ##
RUN mkdir -p /shell
    && mkdir -p /app/log

COPY xdd-plus/docker-entrypoint.sh /shell/docker-entrypoint.sh
COPY xdd-plus/extra.sample.sh /app/extra.sh
RUN chmod 777 /shell/docker-entrypoint.sh
RUN chmod 777 /app/extra.sh

ENTRYPOINT ["/shell/docker-entrypoint.sh"]
