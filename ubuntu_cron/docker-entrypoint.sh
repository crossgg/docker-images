#!/bin/bash

# echo -e "======================1. 启动xxx========================\n"
# if [[ $ENABLE_WEB_PM2 == true ]]; then
#        cd /app
#        pm2 start xxx
#        echo -e "xxx启动成功...\n"
# elif [[ $ENABLE_WEB_PM2 == false ]]; then
#        echo -e "\n默认首次不启动 xxx，请编辑好配置文件后，修改环境变量为true启动面板"
# fi

echo -e "############################################################\n"
echo -e "容器启动成功..."

crond -f >/dev/null

exec "$@"