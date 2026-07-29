#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 显示欢迎信息
echo -e "${GREEN}批量 Psyduck 容器部署脚本${NC}"
echo "=========================="

# 获取初始端口
while true; do
    read -p "请输入初始端口: " initial_port
    if [[ "$initial_port" =~ ^[0-9]+$ ]] && [ "$initial_port" -ge 1 ] && [ "$initial_port" -le 65535 ]; then
        break
    else
        echo -e "${RED}错误: 请输入有效的端口号 (1-65535)!${NC}"
    fi
done

# 获取容器数量
while true; do
    read -p "请输入要创建的容器数量 (最大20): " container_count
    if [[ "$container_count" =~ ^[0-9]+$ ]] && [ "$container_count" -ge 1 ]; then
        if [ "$container_count" -gt 20 ]; then
            echo -e "${YELLOW}数量超过20，将使用默认值20${NC}"
            container_count=20
        fi
        break
    else
        echo -e "${RED}错误: 请输入有效的数字!${NC}"
    fi
done

# 获取网关地址
while true; do
    read -p "请输入网关地址 (GATEWAY): " gateway_addr
    if [ -n "$gateway_addr" ]; then
        break
    else
        echo -e "${RED}错误: 网关地址不能为空!${NC}"
    fi
done

# 获取FRPS服务器地址
while true; do
    read -p "请输入FRPS服务器地址 (server_addr): " server_addr
    if [ -n "$server_addr" ]; then
        break
    else
        echo -e "${RED}错误: FRPS服务器地址不能为空!${NC}"
    fi
done

# 获取FRPS token
while true; do
    read -p "请输入FRPS token: " token
    if [ -n "$token" ]; then
        break
    else
        echo -e "${RED}错误: FRPS token不能为空!${NC}"
    fi
done

# 获取FRPS端口（带默认值）
read -p "请输入FRPS端口 [默认: 7000]: " server_port
if [ -z "$server_port" ]; then
    server_port=7000
fi

# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker 未安装，请先安装 Docker${NC}"
    exit 1
fi

# 创建容器和配置文件
echo -e "${BLUE}开始创建容器和配置文件...${NC}"

for ((i=0; i<container_count; i++)); do
    current_port=$((initial_port + i))
    container_name="psyduck${current_port}"

    echo -e "${YELLOW}正在处理端口 ${current_port}...${NC}"

    # 生成配置文件内容
    config_content="[common]
server_addr = $server_addr
token = $token
server_port = $server_port

[psyduck${current_port}]
type = tcp
local_ip = 127.0.0.1
local_port = 24678
remote_port = $current_port"

    # 写入临时配置文件
    temp_config="frpc_${current_port}.ini"
    echo "$config_content" > "$temp_config"

    # 创建并启动 Docker 容器
    docker_command="docker run -d --name $container_name --restart=always --privileged --network psyduck -e GATEWAY=${gateway_addr} psyduck"
    echo -e "${BLUE}正在创建容器 ${container_name}...${NC}"
    eval $docker_command

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}容器 ${container_name} 已成功创建!${NC}"

        # 等待容器完全启动
        sleep 2

        # 复制配置文件到容器
        echo -e "${BLUE}正在复制配置文件到容器 ${container_name}...${NC}"
        docker cp $temp_config $container_name:/root/frpc.ini

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}配置文件已成功复制到容器 ${container_name}${NC}"

            # 重启容器
            echo -e "${BLUE}正在重启容器 ${container_name}...${NC}"
            docker restart $container_name

            if [ $? -eq 0 ]; then
                echo -e "${GREEN}容器 ${container_name} 已成功重启!${NC}"
            else
                echo -e "${RED}容器 ${container_name} 重启失败!${NC}"
            fi
        else
            echo -e "${RED}配置文件复制到容器 ${container_name} 失败!${NC}"
        fi

        # 删除临时配置文件
        rm -f $temp_config
    else
        echo -e "${RED}容器 ${container_name} 创建失败!${NC}"
    fi

    echo "--------------------------"
done

echo -e "${GREEN}批量部署完成!${NC}"
echo -e "${YELLOW}共创建了 ${container_count} 个容器，从端口 ${initial_port} 到 $((initial_port + container_count - 1))${NC}"
