## 一、快速开始 🚀
1. 网络必须开启IPV6,没有IPV6就别浪费时间了

2. 容器不能创建在主路由/旁路由系统内

3. N1盒子总有吧,刷armbian 

4. 飞牛Nas总有吧,直接用

5. 玩客云总有吧,也能刷armbian

6. 都没有? 买个玩客云吧,30块钱,转发流量够用了

7. 虚拟机安装容器,或多或少有点问题,不通过请自行解决 (需要开启)

    如果 `主机` 是运行在 **Hyper-V、PVE (Proxmox)、VMware 或 ESXi** 上的虚拟机，必须在**虚拟化平台侧**允许 MAC 伪造/混杂模式，否则虚拟机外部的网络依然通不了：

   1. **Hyper-V**：
      - 找到 `主机` 虚拟机设置 -> 展开网卡 (Network Adapter) -> **高级功能 (Advanced Features)** -> 勾选 **启用 MAC 地址伪造 (Enable MAC Address Spoofing)**。
   2. **PVE (Proxmox VE)**：
      - 在 PVE 界面中找到 `主机` 虚拟机 -> 网卡 (Hardware -> Network Device) -> 取消勾选 `MAC Filter`（MAC 过滤）。
   3. **VMware Workstation / ESXi**：
      - 虚拟网络编辑器 / vSwitch 设置 -> 找到对应的虚拟网卡 -> **混杂模式 (Promiscuous Mode)** 设为 **接受 (Accept)**。
## 二、配置详解(IP模式)
### ~~0. 创建镜像~~ 

   >~~docker build -t psyduck .~~

   >~~ 先确认你机器cpu架构,找到cpu架构对应的可执行文件psyduck-xxx重命名psyduck,x86机器将psyduck-amd64改名psyduck,n1盒子将psyduck-arm改名psyduck~~ 


### 1、拉取镜像
```
docker pull crosscc/psyduck
```

### 2. 创建网络
```
docker network create -d macvlan   --subnet=10.0.0.0/24   --gateway=10.0.0.2   --ipv6   --subnet=fdfa:5a35:6fce::/64 -o parent=eth0 psyduck
```


   > 网关: 192.168.100.1 按照自己网关实际填写(192.168.2.1, 10.0.0.1, 192.168.3.0)
   >
   > 网段: 192.168.100.0 按照自己网段实际填写(192.168.2.0, 10.0.0.0, 192.168.3.0)
   >
   > eth0: 以太网卡,一般都是eth0,飞牛nas一般为enp4s0 可以通过ip -6 a 命令查看


### 3. 创建容器(ip模式)
```
docker run -d --name psyduck201 --restart=unless-stopped --ip=10.0.0.201 --privileged --network psyduck --dns=10.0.0.2 -e GATEWAY=10.0.0.2  docker.1ms.run/crosscc/relayapi
```


   > ip: 192.168.100.31  需要分配内网一个ip给容器,注意别ip冲突了(192.168.2.22, 10.0.0.33, 192.168.3.44)
   >
   > GATEWAY: 192.168.100.1 按照自己网关实际填写(192.168.2.0, 10.0.0.0, 192.168.3.0)
   >
   > 不需要设置端口,固定24678

```
# 如果想更快的创建容器,可以执行:

chmod +x x.sh && ./x.sh
```
   >请输入网关地址 (GATEWAY): 

   >请输入起始主机号 (如 37): 

   >请输入要创建的容器数量 (最大20): 
 ### 4. 创建容器(Frp内网穿透模式) 
 ```
chmod +x y.sh && ./y.sh
 ```
   >请输入初始端口:

   >请输入要创建的容器数量 (最大20):

   >请输入网关地址 (GATEWAY): 

   >请输入FRPS服务器地址 (server_addr): 

   >请输入FRPS token:

   >请输入FRPS端口 [默认: 7000]: 


 ### 5. 多容器并发
   > 可以多创建几个容器,注意分配不同ip,一般创建个三四个容器就可以满足日常需求,如果你用户比较多可以多创建
   >
   > openwrt或者一般路由器都可以分配网络地址的起始分配基址(ip段从第几开始分配),可以很好解决ip问题
 ### 6. 使用方式
   >  在iniPath目录(默认是框架的config目录,如果iniPath设置了在/ql/data/config就在/ql/data/config)创建proxy.ini,如果之前有可以忽略,复制如下内容,

```
[jdRelay]
http://ip1:24678
http://ip2:24678
http://ip3:24678

....

http://ip:port1 
http://ip:port2 
http://ip:port3 
```
   >  当然,脚本也支持使用不同Relay分组,自行创建relay分组节点(以testRelay演示),然后在脚本节点处添加: relayGroup=testRelay
```
[testRelay]
http://ip4:24678
http://ip5:24678
http://ip6:24678
```
### 7. 验证可用
> ip模式访问: http://ip:24678/ipv6
> 内网穿透模式访问: http://ip:port/ipv6
> 
> 出现ipv6地址,一般可正常使用
> 
> 如果在脚本处出现验证不通过,一般因虚拟机安装引起的问题,请自行解决! 或者使用独立小主机安装,毕竟一个玩客云也才几块钱,没精力探讨那么多

 
