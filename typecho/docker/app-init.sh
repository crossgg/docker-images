#!/bin/sh

ARCH=`uname -m`
CPU_NUM=`nproc --all`
MEM_TOTAL_MB=`free -m | grep Mem | awk '{ print $2 }'`
# Tweak nginx to match the workers to cpu's
#procs=$(cat /proc/cpuinfo | grep processor | wc -l)
sed -i -e "s/worker_processes 5/worker_processes $CPU_NUM/" /etc/nginx/nginx.conf

if [ "$PHP_FPM_MAX_CHILDREN" != '' ] && [ "$PHP_FPM_MAX_CHILDREN" != '0' ]; then
    sed -i "s|pm.max_children =.*|pm.max_children = ${PHP_FPM_MAX_CHILDREN}|i" /etc/php83/php-fpm.d/www.conf
fi

if [ "$PHP_TZ" != '' ]; then
    sed -i "s|;*date.timezone =.*|date.timezone = ${PHP_TZ}|i" /etc/php83/php.ini
fi
if [ "$PHP_MAX_EXECUTION_TIME" != '' ]; then
    sed -i "s|;*max_execution_time =.*|max_execution_time = ${PHP_MAX_EXECUTION_TIME}|i" /etc/php83/php.ini
    sed -i "s|;*max_input_time =.*|max_input_time = ${PHP_MAX_EXECUTION_TIME}|i" /etc/php83/php.ini
fi
if [ "$APP_DEBUG" != 'false' ]; then
    sed -i "s|;*php_flag\[display_errors\] =.*|php_flag\[display_errors\] = on|i" /etc/php83/php-fpm.d/www.conf
fi

echo "**** Make sure the /data folders exist ****"
[ ! -d /data/log/nginx ] && \
	mkdir -p /data/log/nginx

[ ! -d /data/log/php83 ] && \
	mkdir -p /data/log/php83

[ ! -L /app/usr ] && \
	cp -ra /app/usr/* /data && \
	rm -r /app/usr && \
	ln -s /data /app/usr && \
	echo "**** Create the symbolic link for the /usr folder ****"

#if app installed, link /data/config.inc.php to /app/config.inc.php
[ ! -L /app/config.inc.php ] && \
[ -e /data/config.inc.php ] && \
	ln -sf /data/config.inc.php /app/config.inc.php && \
	echo "**** Create the symbolic link for config.inc.php ****"

# Migrate v1.2 config.inc.php to v1.3 format (Typecho_Db -> \Typecho\Db, etc.)
if [ -e /data/config.inc.php ] && grep -q 'Typecho_Db' /data/config.inc.php; then
	echo "**** Detected v1.2 config.inc.php, migrating to v1.3 format ****"
	cp /data/config.inc.php /data/config.inc.php.bak.v12
	sed -i 's/Typecho_Db/\\Typecho\\Db/g' /data/config.inc.php
	sed -i 's/Typecho_Widget/\\Typecho\\Widget/g' /data/config.inc.php
	sed -i 's/Typecho_Common/\\Typecho\\Common/g' /data/config.inc.php
	sed -i 's/Typecho_Cookie/\\Typecho\\Cookie/g' /data/config.inc.php
	sed -i 's/Typecho_Router/\\Typecho\\Router/g' /data/config.inc.php
	echo "**** Config migration complete. Old config backed up as config.inc.php.bak.v12 ****"
	echo ""
	echo "=========================================="
	echo "  IMPORTANT: After the server starts,"
	echo "  please visit /install/upgrade.php"
	echo "  to complete the database upgrade!"
	echo "=========================================="
	echo ""
fi

#fixup __TYPECHO_SITE_URL__
if [ -e /data/config.inc.php ] && ! grep -q '__TYPECHO_SITE_URL__' /data/config.inc.php; then
	sed -i "s|define('__TYPECHO_ROOT_DIR__', '/app');.*|define('__TYPECHO_ROOT_DIR__', '/app'); define('__TYPECHO_SITE_URL__', '/');|i" /data/config.inc.php && \
	echo "**** fixup __TYPECHO_SITE_URL__ ****"
fi

echo "**** Set Permissions ****"
chown -R "$HTTPD_USER":"$HTTPD_USER" /data
chmod -R a+rw /data
chown -R "$HTTPD_USER":"$HTTPD_USER" /app

echo "**** Setup complete, starting the server. ****"

# Start s6-overlay
exec /init