## 基础ubuntu:jammy 集成s6-overlay的镜像
### 自用，预装了cron python3 nodejs golang18 等。

### amd部署教程1：
`docker run -itd -v /path/to/your/confFileName:/app crosscc/ubuntu_s6_cron:latest`
### arm64部署教程：
`docker run -itd -v /path/to/your/confFileName:/app crosscc/ubuntu_s6_cron:latest`




## 项目相关

* [evine / dockerfiles](https://gitee.com/evine/dockerfiles/tree/master/s6-overlay)


### 因为不知道怎么设置开启启动，把`cron`的启动加入到了 ~/.bashrc

### 开机启动设置 参考 https://blog.csdn.net/qq_35720307/article/details/87108831
1：`cd /etc/init.d/`
2：新建一个 `xx.sh`文件
3：`chmod +x xx.sh`
4：`update-rc.d xx.sh defaults 90`   ##90表明一个优先级，越高表示执行的越晚



##移除Ubuntu开机脚本
`update-rc.d -f xx.sh remove`