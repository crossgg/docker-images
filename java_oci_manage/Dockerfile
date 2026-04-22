FROM openjdk:20-ea-11-jdk-slim-bullseye
LABEL maintainer="crossgg <[EMAIL_ADDRESS]>"

ENV VERSION 9.5.0

RUN apt-get update && apt-get install -y wget procps

WORKDIR /app
RUN wget -O sh_client_bot.sh https://github.com/semicons/java_oci_manage/releases/latest/download/sh_client_bot.sh \
    && chmod +x sh_client_bot.sh \
    && bash sh_client_bot.sh

