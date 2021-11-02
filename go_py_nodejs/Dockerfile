FROM node:lts-alpine
LABEL maintainer="DDD"
# ARG XDD_URL=https://github.com/XXX/XXXX.git
# ARG XDD_BRANCH=main
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
	ENABLE_EXTRA=false
    GOLANG_VERSION=1.17.1
	

WORKDIR \app
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
							 go \
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
    ## 编译安装go环境 ##
    && cd /usr/local \
	&& wget -O go.tgz https://dl.google.com/go/go1.17.1.src.tar.gz \
	&& tar -C /usr/local -xzf go.tgz \
	&& rm go.tgz \
	&& cd /usr/local/go/src/ \
	&& ./make.bash  \
	&& del .build-deps \
    && export GO111MODULE=on  \
    && export GOPROXY=https://goproxy.cn \
    && export PATH="/usr/local/go/bin:$PATH" \
    && go version

https://github.com/docker-library/golang/blob/69f2d2a132565bf60afc91813801a3bdcc981526/1.10/alpine3.8/Dockerfile
参考

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"	
## Add files . ##
RUN mkdir -p /shell
RUN mkdir -p /app/log

COPY go_py_nodejs/docker-entrypoint.sh /shell/docker-entrypoint.sh
COPY go_py_nodejs/extra.sample.sh /app/extra.sh
RUN chmod 777 /shell/docker-entrypoint.sh
RUN chmod 777 /app/extra.sh

ENTRYPOINT ["/shell/docker-entrypoint.sh"]
