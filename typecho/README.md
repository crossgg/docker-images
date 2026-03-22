# typecho docker image for amd64/arm64 machine

## both MySQL and SQLite are supported

use [s6](https://skarnet.org/software/s6/why.html) as supervision instead of runit

update: typecho code has been updated to [v1.3.0](https://github.com/typecho/typecho/releases/tag/v1.3.0)

latest image: docker.io/crosscc/typecho:latest

```
docker.io/crosscc/typecho:latest
```

typecho is a PHP based lightweight blog system

### container volume map

you need to map container path /data to your host machine for persistent data storage.

```
/data
```

## example

AMD64 or arm64:

```
docker run -d \
  --name=typecho \
  --restart always \
  --mount type=tmpfs,destination=/tmp \
  -v /srv/http/typecho:/data \
  -e PHP_TZ=Asia/Shanghai \
  -e PHP_MAX_EXECUTION_TIME=600 \
  -p 90:80 \
  crosscc/typecho:latest
```

## Build

1. Run `init.sh` to download typecho v1.3.0 release
2. Run `docker build -f ./docker/Dockerfile -t typecho:v1.3.0 .`

请重新构建镜像并启动。如果你的旧数据还需要数据库升级，启动后请访问 http://你的域名/install/upgrade.php 完成数据库结构升级。

## About

docker-typecho-alpine-s6

[hub.docker.com/r/80x86/typecho](https://hub.docker.com/r/80x86/typecho)
