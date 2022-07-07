FROM node:alpine

ENV TZ=Asia/Shanghai
ENV BILI-PCHEARTBEAT_VERSION=2022.7.7
ENV BILI-PCHEARTBEAT_URL="https://github.com/lkeme/bilibili-pcheartbeat.git"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

EXPOSE 3000
WORKDIR /app/src

RUN apt-get update && \
    apt-get install -y --no-install-recommends vim git && \
	git clone ${BILI-PCHEARTBEAT_URL} /app/src && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# COPY /app/src/* ./
RUN npm install

CMD ["node", "app.js"]