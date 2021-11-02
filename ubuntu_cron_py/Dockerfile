FROM ubuntu:20.04
RUN mkdir -p /app
WORKDIR /app
COPY ubuntu_cron/extra.sample.sh /app/extra.sh
RUN chmod 777 /app/extra.sh
RUN apt-get update && apt-get install cron -y && apt-get install curl -y && apt-get install python3 -y && apt-get install python3-pip -y
CMD  service cron start && bash /app/extra.sh