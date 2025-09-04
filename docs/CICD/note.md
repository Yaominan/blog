# note


### ubuntu server中启用 networkmanager 管理网络服务

```bash
#做以下操作时需要网络是通的,以下命令检测网络连通性，最好先开交换机的 dhcp服务，让机器使用 dhcp 分配的 IP 上网，把我们的网络先配置成静态 IP 后再关掉 dhcp
kris@source:~$ ip a s
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:df:1c:79 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.130/24 brd 192.168.10.255 scope global dynamic ens160
       valid_lft 1715sec preferred_lft 1715sec
kris@source:~$ ping www.baidu.com
PING www.a.shifen.com (153.3.238.28) 56(84) bytes of data.
64 bytes from 153.3.238.28 (153.3.238.28): icmp_seq=1 ttl=128 time=12.6 ms
64 bytes from 153.3.238.28 (153.3.238.28): icmp_seq=2 ttl=128 time=12.1 ms
64 bytes from 153.3.238.28 (153.3.238.28): icmp_seq=3 ttl=128 time=12.2 ms
```

```bash
#更新apt包索引：
 sudo apt-get update
kris@source:~$ sudo apt install network-manager
kris@source:~$ systemctl is-active network-manager.service
active
kris@source:~$ sudo -i
root@source:~# vim /etc/netplan/00-installer-config.yaml
root@source:~# cat /etc/netplan/00-installer-config.yaml
# This is the network config written by 'subiquity'
network:
  renderer: NetworkManager
  ethernets:
    ens160:
      dhcp4: true
  version: 2
#这个时候可能会卡住，把虚拟机网卡的 dhcp 关掉就行，然后重新执行这一步
root@source:~# netplan apply
#现在就能用 networkmanager 管理网络了，个人觉得这个工具比其他的方便很多，还有图形化界面 nmtui
kris@source:~$ nmcli device status
DEVICE  TYPE      STATE      CONNECTION
ens160  ethernet  connected  netplan-ens160
lo      loopback  unmanaged  --
kris@source:~$ nmcli connection modify netplan-ens160 ipv4.addresses 192.168.10.5/24 ipv4.dns 192.168.10.2 ipv4.gateway 192.168.10.2 autoconnect yes
kris@source:~$ nmcli connection up netplan-ens160
kris@source:~$ ip a s
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:df:1c:79 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.5/24 brd 192.168.10.255 scope global noprefixroute ens160
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fedf:1c79/64 scope link
       valid_lft forever preferred_lft forever

#至此网络配置完成
#修改特权用户sudo免密执行命令
#ubuntu 特权用户免密：
sudo -i
#临时修改visudo 编辑器 nano 个人感觉不好用（主要是不会用，没有vim 舒服）
export EDITOR=/usr/bin/vim
visudo
#加上这一行
kris ALL=(ALL) NOPASSWD: ALL
```

## ubuntu 20.04 安装docker

```bash




更新apt包索引：
 sudo apt-get update
 安装必备的软件包以允许apt通过 HTTPS 使用存储库（repository）：
sudo apt-get install ca-certificates curl gnupg lsb-release

添加Docker官方版本库的GPG密钥：
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
使用以下命令设置存储库：
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 更新apt索引
sudo apt-get update
# 安装docker
kris@gitlab:~$ sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

Unpacking slirp4netns (0.4.3-1) ...
。。。。。。。。。。。。。。。。。。。。。。。。。。
Setting up docker-ce (5:28.1.1-1~ubuntu.20.04~focal) ...
Created symlink /etc/systemd/system/multi-user.target.wants/docker.service → /lib/systemd/system/docker.service.
Created symlink /etc/systemd/system/sockets.target.wants/docker.socket → /lib/systemd/system/docker.socket.
Processing triggers for man-db (2.9.1-1) ...
Processing triggers for systemd (245.4-4ubuntu3.20) ...
#查看docker信息或版本证明已经安装成功
kris@gitlab:~$ sudo docker info
Client: Docker Engine - Community
 Version:    28.1.1
 Context:    default

#这里最好修改一下docker的register，docker官方的地址没有科学上网的话几乎不能用了






```