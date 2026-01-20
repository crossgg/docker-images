## docker 安装：

```sh
docker run -d --name tg-signer-web --restart=unless-stopped -p xxxx:8080 -v $PWD/tg-signer:/opt/tg-signer docker.1ms.run/crosscc/tg-signer-web
```

`xxxx`改为你需要映射的端口



**或者采用docker-compose安装**

创建docker-compose.yaml

```yaml
services:
  tg-signer-web:
    container_name: tg-signer-web
    image: docker.1ms.run/crosscc/tg-signer-web
    restart: unless-stopped
    ports:
      - xxxx:8080
    environment:
      TZ: Asia/Shanghai
    volumes:
      - ./tg-signer:/opt/tg-signer 
```

运行：docker-compose up -d



后打开 `ip:xxxx` 就能打开webui

## 配置任务

接下来即可执行 `docker exec -it tg-signer bash` 进入容器进行登录和配置任务操作，见 https://github.com/amchii/tg-signer
