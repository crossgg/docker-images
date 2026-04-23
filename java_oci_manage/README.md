

## 简介
基于 [semicons/java_oci_manage](https://github.com/semicons/java_oci_manage) 项目的 docker 镜像.  
本项目仅为方便 docker 容器化部署,相关使用教程及问题请参考官方项目.


## docker 部署
### 准备配置文件

1、给 tgbot（@radiance_helper_bot）发送`/raninfo`  生成随机账号密码

2、首次运行的时候会在你映射出来的路径生成配置默认配置文件`client_config` 

主要是修改里面的账号密码,修改好后重启容器就可以运行了。
其他配置可以在 https://yourip:9527 可视化面板修改

### 启动 docker 容器
```bash
docker run -itd --name Rbot --restart unless-stopped \
  -v /yourpatch/app:/app \
  -p 9527:9527 \
  crosscc/java_oci_manage
```

### 进入 docker 容器
```bash
docker exec -it Rbot bash
```

### 启动服务
```bash
bash sh_client_bot.sh
```
启动服务,日志提示成功后即可 ctrl + c 退出终端,服务将在容器内后台执行.

```bash
tail -f log_r_client.log 
# 查看日志
ps -ef | grep r_client.jar | grep -v grep | awk '{print $2}' | xargs kill -9
# 停止服务进程
```

## docker compose 部署
参考完成上述配置后,下载 docker-compose.yml执行以下命令启动:
```shell
docker-compose up -d
```

## 链接
- [semicons/java_oci_manage](https://github.com/semicons/java_oci_manage)
