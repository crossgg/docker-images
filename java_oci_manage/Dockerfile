FROM openjdk:20-ea-11-jdk-slim-bullseye
LABEL maintainer="crossgg <[EMAIL_ADDRESS]>"

ENV VERSION 9.5.0

RUN apt-get update && apt-get install -y wget procps

# 先在无数据卷挂载影响的临时目录预装
WORKDIR /init_app
RUN wget -O sh_client_bot.sh https://github.com/semicons/java_oci_manage/releases/latest/download/sh_client_bot.sh \
    && chmod +x sh_client_bot.sh \
    && bash sh_client_bot.sh upgrade

# 切换回挂载目录
WORKDIR /app


# 去掉 NO_TAIL 和人为尾随的 tail -f，全权交由原始 sh_client_bot.sh 来处理
#CMD ["bash", "-c", "[ ! -f /app/sh_client_bot.sh ] && cp -a /init_app/. /app/; bash sh_client_bot.sh start"]
