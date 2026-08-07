#!/bin/bash
set -e

DATA_DIR="/data"
CONFIG_FILE="${DATA_DIR}/config.json"
AUTHS_DIR="${DATA_DIR}/auths"

# 确保数据目录与授权文件目录存在
mkdir -p "$DATA_DIR" "$AUTHS_DIR"

# 建立软链接：若 /app/auths 是普通目录，先将其中的账号文件迁移至挂载卷 /data/auths
if [ -d "/app/auths" ] && [ ! -L "/app/auths" ]; then
    cp -rn /app/auths/* "$AUTHS_DIR"/ 2>/dev/null || true
    rm -rf /app/auths
fi
ln -sfn "$AUTHS_DIR" /app/auths

# 如果 /data/config.json 不存在，自动使用默认配置进行初始化
if [ ! -f "$CONFIG_FILE" ]; then
    echo "[Init] 未检测到 config.json，正在自动初始化配置文件至 ${CONFIG_FILE}..."
    cat << 'EOF' > "$CONFIG_FILE"
{
  "listen": ":8367",
  "api_key": "",
  "auth_dir": "/data/auths",
  "state_file": "/data/state.json",
  "cooldown": {
    "hard_credit": "12h",
    "soft_rate": "60s",
    "err_threshold": 3,
    "err_cooldown": "10m"
  }
}
EOF
fi

# 启动主程序并传入配置文件参数
exec /app/lobsterai2api -config "$CONFIG_FILE" "$@"
