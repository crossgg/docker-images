#!/bin/sh

if [  "$ENABLE_GOPROXY" = "true" ]; then
  export GOPROXY=https://goproxy.io,direct 
  echo "启用 goproxy 加速 ${GOPROXY}"
else
  echo "未启用 goproxy 加速"
fi

if [ "$ENABLE_GITHUBPROXY" = "true" ]; then
   GITHUBPROXY=https://ghproxy.com/
   echo "启用 github 加速 ${GITHUBPROXY}"
else
  echo "未启用 github 加速"
fi

if [ "$ENABLE_APKPROXY" = "true" ]; then
  sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
  echo "启用 alpine APK 加速 mirrors.aliyun.com"
else
  sed -i 's/mirrors.aliyun.com/dl-cdn.alpinelinux.org/g' /etc/apk/repositories
  echo "未启用 alpine APK 加速"
fi

## xdd-plus库
if [ -z $REPO_URL ]; then
  REPO_URL=${GITHUBPROXY}https://github.com/764763903a/xdd-plus.git
fi


if ! type git  >/dev/null 2>&1; then
  echo "正在安装git..."
  apk add git
else 
  echo "git已安装"
fi


if [ ! -d $WORKDIR/.git ]; then
  echo "sillyGirl 核心代码目录为空, 开始clone代码..."
  git clone $REPO_URL  $WORKDIR
else 
  echo "sillyGirl 核心代码已存在"
  echo "更新 sillyGirl 核心代码"
  cd $WORKDIR && git reset --hard && git pull
fi

echo "开始编译..."
cd $WORKDIR && go build -o xdd


echo "启动..."
 ./xdd


