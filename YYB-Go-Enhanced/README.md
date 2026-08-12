# YYB-Go-Enhanced Docker 部署说明

- **上游源码**：[525815266/YYB-Go-Enhanced](https://github.com/525815266/YYB-Go-Enhanced)
- **DockerHub 镜像**：`crosscc/yyb-go-enhanced:latest`

应用宝协议服务增强版，提供微信扫码登录、账号与 OpenID 管理、`wx.login` code 获取、凭据自动续期保活、Web 控制台，以及与青龙面板联动。

---

## 核心特性

- 支持本机微信授权与手机扫码登录
- 账号与 OpenID 管理及状态监控
- 提供 `/wx/*` 与 `/wxapp/*` 兼容接口（小程序 code、用户信息、加密 Key 等）
- 凭据自动定时轮询续期保活
- SQLite 数据库持久化存储
- Web 控制台支持配置青龙 OpenAPI，一键推送合并环境变量

---

## 部署教程

### 方式一：Docker 一键运行

```bash
docker run -d \
  --name yyb-go-enhanced \
  --restart=unless-stopped \
  -p 8000:8000 \
  -e YYB_WEB_USER=admin \
  -e YYB_WEB_PASSWORD=修改为你的强密码 \
  -v $PWD/data:/app/resource/db \
  crosscc/yyb-go-enhanced:latest
```

---

### 方式二：Docker Compose 部署（推荐）

#### 1. 创建青龙共享网络（可选）

如需与青龙容器运行在同一个 Docker 网络，请先建立网络：

```bash
docker network create qinglong_default
```

#### 2. 准备配置文件

```bash
cp .env.example .env
```

编辑 `.env` 文件，修改 `YYB_WEB_PASSWORD` 为自定义登录密码：

```dotenv
YYB_PORT=8000
YYB_WEB_USER=admin
YYB_WEB_PASSWORD=YourSecurePassword
```

#### 3. 启动服务

* **使用预构建 DockerHub 镜像启动**：
  ```bash
  docker compose up -d
  ```

* **如需从源码本地重新构建镜像**：
  ```bash
  docker compose up -d --build
  ```

启动成功后，浏览器访问 `http://服务器IP:8000` 即可进入 Web 管理控制台。

---

## 完整环境变量说明（.env）

| 环境变量 | 默认值 | 说明 |
| :--- | :--- | :--- |
| `YYB_PORT` | `8000` | Web 控制台对外映射与 API 监听端口 |
| `YYB_BIND_ADDRESS` | `0.0.0.0` | 绑定监听地址（局域网安全限定可填具体 IP，如 `192.168.1.x`） |
| `YYB_WEB_USER` | `admin` | Web 控制台 Basic Auth 登录用户名 |
| `YYB_WEB_PASSWORD` | - | Web 控制台 Basic Auth 登录密码（强烈建议修改） |
| `YYB_KEEPALIVE_INTERVAL` | `30m` | 账号凭据后台保活检查轮询间隔（设为 `0` 可关闭后台保活） |
| `YYB_KEEPALIVE_AHEAD` | `45m` | 凭据提前续期时间阈值 |
| `QL_URL` | `http://qinglong:5700` | 青龙面板地址（容器同网络下填写容器名） |
| `QL_CLIENT_ID` | - | 青龙 OpenAPI 应用 Client ID |
| `QL_CLIENT_SECRET` | - | 青龙 OpenAPI 应用 Client Secret |
| `YYB_QINGLONG_SERVER` | `yyb:8000` | 青龙面板环境变量中注入的 YYB 服务回调地址 |

---

## 文件结构说明

- `Dockerfile`: 多阶段构建文件，静态编译并打包为极简 Alpine 镜像，内置 `ENTRYPOINT` 与 `CMD` 参数。
- `docker-compose.yml`: Docker Compose 一键部署脚本（映射挂载数据库至 `./data`）。
- `.env.example`: 完整环境变量模板文件（包含青龙配置）。
- `.gitignore`: 忽略 `.env` 和 `data/` 目录，防止敏感信息与数据库提交至 Git 仓库。
- `data/`: 持久化挂载目录（保存 SQLite 数据库 `yyb.db`）。
