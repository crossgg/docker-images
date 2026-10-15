#!/bin/sh
set -e

WORKDIR="${APP_DIR:-/app}"
if [ -d "$WORKDIR" ]; then
    cd "$WORKDIR"
fi

# 1. 执行可选的前置命令 (如检查/生成配置、执行迁移等)
if [ -n "$PRE_RUN_CMD" ]; then
    echo "[Launcher] Executing PRE_RUN_CMD: $PRE_RUN_CMD"
    eval "$PRE_RUN_CMD"
fi

# 2. 方式 A: 如果启动容器时直接传了参数 (例如: docker run ... myimage ./myapp -arg1)
if [ "$#" -gt 0 ]; then
    if [ -f "$1" ]; then
        chmod +x "$1" 2>/dev/null || true
    fi
    echo "[Launcher] Starting via CLI arguments: $@"
    exec "$@"
fi

# 3. 方式 B: 通过环境变量 APP_NAME 或 APP_BIN 指定
TARGET_BIN="${APP_NAME:-$APP_BIN}"

# 4. 方式 C: 若未指定，尝试在 /app 下进行智能探测
if [ -z "$TARGET_BIN" ]; then
    # 优先探测具有执行权限的文件（排除脚本自身）
    CANDIDATES=$(find . -maxdepth 1 -type f -perm /111 ! -name "*.sh" ! -name "launcher" 2>/dev/null)
    COUNT=$(echo "$CANDIDATES" | grep -v '^$' | wc -l)

    if [ "$COUNT" -eq 1 ]; then
        TARGET_BIN=$(echo "$CANDIDATES" | tr -d '[:space:]')
        echo "[Launcher] Auto-detected single executable: $TARGET_BIN"
    else
        # 针对 Windows 挂载丢失 +x 权限的情况：排除常见非二进制后缀后检测是否仅有 1 个主程序文件
        FALLBACK=$(find . -maxdepth 1 -type f \
            ! -name "*.sh" \
            ! -name "*.yml" \
            ! -name "*.yaml" \
            ! -name "*.json" \
            ! -name "*.toml" \
            ! -name "*.ini" \
            ! -name "*.conf" \
            ! -name "*.md" \
            ! -name "*.txt" \
            ! -name "*.log" \
            ! -name ".*" 2>/dev/null)
        FB_COUNT=$(echo "$FALLBACK" | grep -v '^$' | wc -l)
        if [ "$FB_COUNT" -eq 1 ]; then
            TARGET_BIN=$(echo "$FALLBACK" | tr -d '[:space:]')
            echo "[Launcher] Auto-detected single candidate file: $TARGET_BIN"
        fi
    fi
fi

# 5. 若仍无法确定程序，输出友好提示并列出文件
if [ -z "$TARGET_BIN" ]; then
    echo "================================================================="
    echo "[Launcher] [ERROR] 未找到要启动的 Go 程序！"
    echo "请通过环境变量 APP_NAME 或 APP_BIN 指定要运行的程序文件名。"
    echo "示例: -e APP_NAME=myapp"
    echo "-----------------------------------------------------------------"
    echo "当前工作目录 ($WORKDIR) 文件列表:"
    ls -lah "$WORKDIR"
    echo "================================================================="
    exit 1
fi

# 补充相对路径 ./ 前缀
case "$TARGET_BIN" in
    /*|./*) ;;
    *) TARGET_BIN="./$TARGET_BIN" ;;
esac

# 检查目标文件是否存在
if [ ! -f "$TARGET_BIN" ]; then
    echo "================================================================="
    echo "[Launcher] [ERROR] 指定的程序不存在: $TARGET_BIN"
    echo "请确认文件名是否正确，以及是否已将程序挂载到 $WORKDIR 目录下。"
    echo "-----------------------------------------------------------------"
    echo "当前工作目录 ($WORKDIR) 文件列表:"
    ls -lah "$WORKDIR"
    echo "================================================================="
    exit 1
fi

# 自动补全可执行权限（避免宿主机挂载丢失执行权限问题）
chmod +x "$TARGET_BIN" 2>/dev/null || true

echo "[Launcher] Working directory : $(pwd)"
echo "[Launcher] Target executable : $TARGET_BIN"
if [ -n "$APP_ARGS" ]; then
    echo "[Launcher] Startup arguments : $APP_ARGS"
    eval exec "\"$TARGET_BIN\"" $APP_ARGS
else
    echo "[Launcher] Startup arguments : (None)"
    exec "$TARGET_BIN"
fi
