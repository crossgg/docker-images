FROM golang:alpine
ENV ENABLE_GOPROXY=true
ENV ENABLE_GITHUBPROXY=true
ENV ENABLE_APKPROXY=true

COPY xdd-plus/docker-entrypoint.sh /bin/
RUN chmod a+x /bin/docker-entrypoint.sh

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update -f \
    && apk upgrade \
    && apk --no-cache add -f git wget python3 nodejs gcc \
    && rm -rf /var/cache/apk/* \

ENTRYPOINT ["/bin/docker-entrypoint.sh"]

WORKDIR /xdd

