FROM ubuntu:jammy

ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive

RUN  apt-get -qq update && \
     apt-get -qq install -y --no-install-recommends tzdata ca-certificates cron curl python3 python3-pip nodejs vim git wget gcc sudo && \
	 apt-get -qq install -y --no-install-recommends npm && \
	 ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && \
	 echo ${TZ} > /etc/timezone && \
	 dpkg-reconfigure --frontend noninteractive tzdata
	 
RUN  mkdir /app/ && \
	 mkdir /shell/

#COPY ./docker-entrypoint.sh /shell/docker-entrypoint.sh

#RUN  chmod 777 /shell/docker-entrypoint.sh

COPY --from=nevinee/s6-overlay:bin-is-softlink / /


EXPOSE 8080

VOLUME /app

## 安装pm2

RUN npm config set registry https://registry.npmmirror.com/
RUN npm install -g pm2


## 安装go环境
RUN apt-get -qq install golang-go -y
RUN cd /usr/local \
    && wget https://golang.google.cn/dl/go1.18.linux-amd64.tar.gz \
	&& rm -rf /usr/local/go \
	&& tar -C /usr/local -xzf go1.18.linux-amd64.tar.gz \
	&& rm go1.18.linux-amd64.tar.gz \
	&& echo "export GO111MODULE=on" > \etc\profile  \
	&& echo "export GOPROXY=https://goproxy.cn" > /etc/profile \
	&& echo "export GOROOT=/usr/local/go" > /etc/profile \
	&& echo "export GOPATH=/usr/local/go/path" > /etc/profile \
	&& echo "export PATH=$PATH:$GOROOT/bin:$GOPATH/bin" > /etc/profile \
	&& echo "source /etc/profile" > ~/.bashrc

RUN rm -rf /var/lib/apt/lists/*
WORKDIR /app

## 替换清华源
RUN  sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list && \
     sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
	 
## 开机启动cron
RUN echo "service cron start" > ~/.bashrc

ENTRYPOINT ["/init"]