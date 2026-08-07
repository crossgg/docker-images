# lobsterai2api Docker 镜像

本项目为 [xinxinshuhao-create/lobsterai2api](https://github.com/xinxinshuhao-create/lobsterai2api) 的 Docker 镜像打包方案，支持 `linux/amd64` 和 `linux/arm64` 双架构。

## 特性

- **单目录挂载**：只需映射 `/data` 一个数据卷目录，所有的配置文件（`config.json`）、状态记录（`state.json`）及授权文件（`auths/`）统一存放在该目录下。
- **自动初始化**：如果挂载的目录下不存在 `config.json`，容器会在启动时自动根据模板生成并完成路径配置。

## 快速开始

```bash
docker run -d \
  --name lobsterai2api \
  --restart always \
  -p 8367:8367 \
  -v /your/local/path/data:/data \
  crosscc/lobsterai2api:latest
```

## Docker Compose 方式启动

推荐使用 Docker Compose 进行快速部署，新建 `docker-compose.yml` 文件：

```yaml
services:
  lobsterai2api:
    image: crosscc/lobsterai2api:latest
    container_name: lobsterai2api
    restart: always
    ports:
      - "8367:8367"
    volumes:
      - ./data:/data
```

启动命令：
```bash
docker compose up -d
```


## 账号登录授权（添加新账号）

容器内已集成编译好的登录授权工具 `/app/login`，支持通过 `docker exec` 直接操作添加新账号：

### 第一步：生成登录链接
```bash
docker exec -it lobsterai2api /app/login url
```
> 执行后终端会启动本地回调服务器并打印出授权 URL 链接。

### 第二步：浏览器扫码/登录
复制终端中打印出来的 URL 链接，在电脑浏览器中打开，完成手机号或微信登录。

### 第三步：获取 Token 并保存凭证
```bash
docker exec -it lobsterai2api /app/login poll
```
> 登录完成后执行此命令，等待回调换取 Token，账号凭证会自动保存为 `/data/auths/lobsterai-<uid>.json`。

### 附加功能：查询账号额度
```bash
docker exec -it lobsterai2api /app/credit
```
> 输出当前已保存账号的剩余额度与健康状态（JSON 格式）。


## 目录映射说明

| 容器内路径 | 对应功能 | 说明 |
| :--- | :--- | :--- |
| `/data` | 统一数据卷 | 包含 `config.json`、`state.json` 以及 `auths/` 文件夹 |
| `/data/config.json` | 配置文件 | 启动时如不存在会自动新建 |
| `/data/auths/` | 账号 Token 目录 | 存放所有登录成功的账号凭证 (`lobsterai-*.json`) |
| `/data/state.json` | 运行状态文件 | 记录账号冷却与运行状态 |

