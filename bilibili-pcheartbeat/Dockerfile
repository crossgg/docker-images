FROM node:alpine

ENV TZ=Asia/Shanghai
ENV BILI-PCHEARTBEAT_VERSION=2022.7.7
ENV BILI-PCHEARTBEAT_URL="https://github.com/lkeme/bilibili-pcheartbeat.git"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV PORT 3000
EXPOSE $PORT/tcp

WORKDIR /app/src

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && \
    apk add --update && \
    apk add --no-cache vim git && \
    git clone https://github.com/lkeme/bilibili-pcheartbeat.git /app/src && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/* && \
    cd /app/src && \
    npm install 

CMD ["node", "/app/src/app.js"]
