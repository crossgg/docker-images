FROM node:alpine

ENV TZ=Asia/Shanghai
ENV BILI-PCHEARTBEAT_VERSION=2022.7.7
ENV BILI-PCHEARTBEAT_URL="https://github.com/lkeme/bilibili-pcheartbeat.git"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV PORT 3000
EXPOSE $PORT/tcp

ADD ./app/src
WORKDIR /app/src

RUN apk add update && \
    apk add vim git && \
	git clone ${BILI-PCHEARTBEAT_URL} /app/src && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# COPY /app/src/* ./
RUN npm install

CMD ["node", "/app/src/app.js"]