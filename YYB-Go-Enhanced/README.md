# YYB-Go-Enhanced Docker 部署说明

- **上游源码**：[525815266/YYB-Go-Enhanced](https://github.com/525815266/YYB-Go-Enhanced)
- **DockerHub 镜像**：`crosscc/yyb-go-enhanced:latest`

应用宝协议服务增强版，提供微信扫码登录、账号与 OpenID 管理、`wx.login` code 获取、凭据自动续期保活、Web 控制台，以及与青龙面板/呆呆面板联动。

---

## 核心特性

- 支持本机微信授权与手机扫码登录
- 账号与 OpenID 管理及状态监控
- 提供 `/wx/*` 与 `/wxapp/*` 兼容接口（小程序 code、用户信息、加密 Key 等）
- 凭据自动定时轮询续期保活（默认轮询间隔 `1m`）
- SQLite 数据库持久化存储（存放在 `resource/db/auth.db` 与 `yyb.db`）
- Web 控制台支持配置面板对接（支持 **青龙面板** 与 **呆呆面板**），一键推送合并环境变量

---

## 部署教程

### 方式一：Docker 一键运行

```bash
docker run -d \
  --name yyb-go \
  --restart=unless-stopped \
  -p 8000:8000 \
  -e YYB_ADMIN_USER=admin \
  -e YYB_ADMIN_PASSWORD=修改为你的强密码 \
  -v $PWD/data:/app/resource/db \
  crosscc/yyb-go-enhanced:latest
```

---

### 方式二：Docker Compose 部署（推荐）

#### 1. 创建共享 Docker 网络（按使用的面板二选一）

* **青龙面板**：
  ```bash
  docker network create qinglong_default
  ```
* **呆呆面板**：
  ```bash
  docker network create daidai-panel_default
  ```

#### 2. 准备配置文件

```bash
cp .env.example .env
```

编辑 `.env` 文件，根据使用的面板类型进行设置：

* **如果使用青龙面板**：
  ```dotenv
  PANEL_TYPE=qinglong
  PANEL_NETWORK=qinglong_default
  QL_URL=http://qinglong:5700
  ```

* **如果使用呆呆面板**：
  ```dotenv
  PANEL_TYPE=daidai
  PANEL_NETWORK=daidai-panel_default
  DAIDAI_URL=http://daidai:5700
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
| **控制台认证配置** | | |
| `YYB_AUTH_DRIVER` | `sqlite` | 认证存储驱动，默认 sqlite（支持 MySQL） |
| `YYB_AUTH_DSN` | - | 自定义 DSN 数据库连接串 |
| `YYB_ADMIN_USER` | `admin` | Web 控制台管理员账号（留空时首次注册自动成为管理员） |
| `YYB_ADMIN_PASSWORD` | - | Web 控制台管理员密码 |
| `YYB_COOKIE_SECURE` | `false` | 使用 HTTPS 反代时建议改为 `true` |
| **网络与保活设置** | | |
| `YYB_PORT` | `8000` | Web 控制台对外映射与 API 监听端口 |
| `YYB_BIND_ADDRESS` | `0.0.0.0` | 绑定监听地址（局域网安全限定可填具体 IP，如 `192.168.1.x`） |
| `YYB_KEEPALIVE_INTERVAL` | `1m` | 账号凭据后台保活检查轮询间隔（默认 1 分钟；设为 0 关闭） |
| `YYB_KEEPALIVE_AHEAD` | `45m` | 凭据提前续期时间阈值 |
| **面板与 Docker 网络配置** | | |
| `PANEL_TYPE` | `qinglong` | 面板类型，可选 `qinglong`（青龙面板）或 `daidai`（呆呆面板） |
| `PANEL_NETWORK` | `qinglong_default` | 共享外部 Docker 网络名（青龙填 `qinglong_default`，呆呆填 `daidai-panel_default`） |
| `QL_URL` | `http://qinglong:5700` | 青龙面板地址（容器同网络下填写容器名） |
| `QL_CLIENT_ID` | - | 青龙 OpenAPI 应用 Client ID |
| `QL_CLIENT_SECRET` | - | 青龙 OpenAPI 应用 Client Secret |
| `YYB_QINGLONG_SERVER` | `yyb-go:8000` | 青龙面板环境变量中注入的 YYB 服务回调地址 |
| `DAIDAI_URL` | - | 呆呆面板地址 |
| `DAIDAI_APP_KEY` | - | 呆呆面板 App Key |
| `DAIDAI_APP_SECRET` | - | 呆呆面板 App Secret |

---

## 文件结构说明

- `Dockerfile`: 多阶段构建文件，静态编译并打包为极简 Alpine 镜像，内置 `ENTRYPOINT` 与 `CMD` 参数。
- `docker-compose.yml` / `compose.yaml`: Docker Compose 一键部署脚本（网络名动态读取 `PANEL_NETWORK`）。
- `.env.example`: 完整环境变量模板文件（包含控制台认证与多面板/网络配置）。
- `.gitignore`: 忽略敏感配置文件 `.env` 与数据库文件 `data/`。
- `data/`: 持久化挂载目录（保存 SQLite 数据库）。
