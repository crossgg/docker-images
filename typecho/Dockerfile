FROM php:7.1-apache

ENV TYPECHO_VERSION=1.0
ENV TYPECHO_URL="https://github.com/typecho/typecho.git"

RUN set -x \
  && mkdir -p /usr/src/typecho \
  && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget git && rm -rf /var/lib/apt/lists/* \
  && git clone https://github.com/typecho/typecho.git /usr/src/typecho/ \
  && apt-get purge -y --auto-remove ca-certificates wget \
  && rm -rf /var/cache/apk/* \
  && rm -rf /tmp/*

WORKDIR /var/www/html

COPY typecho/entrypoint.sh /usr/local/bin/

EXPOSE 80

ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2-foreground"]
