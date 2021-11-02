FROM golang:alpine
ENV ENABLE_GOPROXY=true
    ENABLE_GITHUBPROXY=true
	ENABLE_APKPROXY=true

COPY SillyGirlDockerDeploy/docker-entrypoint.sh /bin/

RUN chmod a+x /bin/docker-entrypoint.sh

ENTRYPOINT ["/bin/docker-entrypoint.sh"]

WORKDIR /sillyGirl

