FROM ubuntu:20.04
RUN mkdir -p /app
WORKDIR /app
COPY ubuntu_cron_node_go/extra.sample.sh /app/extra.sh
RUN chmod 777 /app/extra.sh
RUN apt-get update && apt-get install cron -y && apt-get install curl -y && apt-get install python3 -y && apt-get install python3-pip -y \
    && apt-get install vim git wget gcc -y
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

## 安装go环境
RUN cd /usr/local \
    && wget https://golang.google.cn/dl/go1.17.1.linux-amd64.tar.gz \
	&& rm -rf /usr/local/go \
	&& tar -C /usr/local -xzf go1.17.1.linux-amd64.tar.gz \
	&& rm go1.17.1.linux-amd64.tar.gz \
	&& echo "export GO111MODULE=on" > \etc\profile  \
	&& echo "export GOPROXY=https://goproxy.cn" > \etc\profile \
	&& echo "export GOROOT=/usr/local/go" > \etc\profile \
	&& echo "export GOPATH=/usr/local/go/path" > \etc\profile \
	&& echo "export PATH=$PATH:$GOROOT/bin:$GOPATH/bin" > \etc\profile \
	&& source /etc/profile \
	&& echo "source /etc/profile" > ~/.bashrc \
	&& go env
## 安装nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash - \
	&& apt-get install -y nodejs
RUN npm config set registry http://registry.npm.taobao.org/



## RUN npm install -g png-js crypto-js download got http-server request tough-cookie tunnel ws pm2


CMD  service cron start && bash /app/extra.sh