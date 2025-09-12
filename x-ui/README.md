## [FranzKafkaYu/x-ui 的docker镜像](https://github.com/FranzKafkaYu/x-ui)

使用说明请查看：[FranzKafkaYu/x-ui ](https://github.com/FranzKafkaYu/x-ui)

### 部署教程1：
```yaml
mkdir x-ui && cd x-ui
docker run -itd --network=host \
    -v $PWD/db/:/etc/x-ui/ \
    -v $PWD/cert/:/root/cert/ \
    --name x-ui --restart=unless-stopped \
    crosscc/x-ui
```

`db`是存放数据的配置的目录，`cert`是存放证书的目录

### 部署教程2（docker-compose）：

```bash
mkdir x-ui && cd x-ui
wget https://raw.githubusercontent.com/crossgg/docker-images/refs/heads/master/x-ui/docker-compose.yml
docker compose up -d
```







-------------------------------
