#!/bin/bash

echo -e "======================7. 启动JDC========================\n"
if [[ $ENABLE_WEB_XDD == true ]]; then
        cd /xdd
        pm2 start XDD
        echo -e "XDD面板启动成功...\n"
elif [[ $ENABLE_WEB_XDD == false ]]; then
        echo -e "\n默认首次不启动 XDD 面板，请编辑好配置文件后，修改环境变量为true启动面板"
        echo -e "\n配置文件为 `\xdd\conf\config.yaml`..."
fi

echo -e "############################################################\n"
echo -e "容器启动成功..."

crond -f >/dev/null

exec "$@"