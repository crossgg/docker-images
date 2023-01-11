#!/bin/bash

if [[ $EnableExtraShell == true ]]; then
  echo -e "======================8. 执行自定义脚本========================\n"
  nohup bash /app/extra.sh &
  echo -e "自定义脚本后台执行中...\n"
fi

echo -e "############################################################\n"
echo -e "容器启动成功..."

crond -f >/dev/null

exec "$@"
