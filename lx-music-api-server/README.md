
https://github.com/MeoProject/lx-music-api-server 的docker构建

使用：
```
docker run  --name lx-music-api-server-python -p 9763:9763 -v /映射文件夹:/app/config -d crosscc/lx-music-api-server:latest
```