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

容器内已集成编译好的登录授权工具 `/app/login`，推荐使用 **2 个终端窗口** 进行操作：

### 第一步：启动登录监听服务（终端窗口 1）
```bash
docker exec -it lobsterai2api /app/login url
```
> **注意**：执行后终端会启动一个临时的 HTTP 回调服务器并输出授权 URL。**必须保持该窗口打开，切勿按下 Ctrl+C 终止进程！**

### 第二步：浏览器登录并复制跳转地址
复制终端窗口 1 打印出来的 `https://lobsterai.youdao.com/...` 链接在电脑浏览器中打开，完成手机号或微信登录。登录成功后，浏览器地址栏会跳转至一个无法打开的 `http://127.0.0.1:端口/auth/callback?code=...&state=...` 地址，**完整复制此跳转 URL**。

### 第三步：发送回调给容器（终端窗口 2）
打开**第二个终端窗口**，运行 `curl` 将回调触发给容器（**注意：必须使用英文双引号 `"..."` 包裹 URL，且端口号需与窗口 1 一致**）：
```bash
docker exec -it lobsterai2api curl "http://127.0.0.1:端口/auth/callback?code=你的code&state=你的state"
```

### 第四步：获取 Token 并落盘保存凭证（终端窗口 2）
在**第二个终端窗口**中执行：
```bash
docker exec -it lobsterai2api /app/login poll
```
> 触发回调后执行此命令，换取 Token 并自动将账号凭证保存至 `/data/auths/lobsterai-<uid>.json`。

---

> 💡 **单终端窗口操作技巧**：
> 如果只有一个终端窗口，可以在第一步加上 `&` 放到后台运行：
> `docker exec -it lobsterai2api sh -c "/app/login url &"`，之后直接在当前窗口顺序执行第三步 `curl` 和第四步 `poll` 命令。

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

