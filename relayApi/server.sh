#!/bin/bash

# 启动第一个服务
./psyduck &
PID1=$!

# 启动第二个服务
frpc
PID2=$!

# 等待任一服务退出
wait -n

# 如果任一服务退出，终止另一个
kill $PID1 $PID2 2>/dev/null
wait
