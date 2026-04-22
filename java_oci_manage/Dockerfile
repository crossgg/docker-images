FROM openjdk:20-ea-11-jdk-slim-bullseye
LABEL maintainer="Stille <stille@ioiox.com>"

ENV VERSION 5.0.1

RUN apt-get update && apt-get install -y wget procps

WORKDIR /app
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
        FILE="gz_client_bot_aarch.tar.gz"; \
    else \
        FILE="gz_client_bot_x86.tar.gz"; \
    fi && \
    wget -O gz_client_bot.tar.gz https://github.com/semicons/java_oci_manage/releases/download/v${VERSION}/${FILE} \
    && tar -zxvf gz_client_bot.tar.gz --exclude=client_config \
    && tar -zxvf gz_client_bot.tar.gz --skip-old-files client_config \
    && rm -rf gz_client_bot.tar.gz \
    && chmod +x sh_client_bot.sh
