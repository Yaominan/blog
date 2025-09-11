# note

## 1. mac vmware fusion 添加网络设备并配置自定义子网
- 为了使用我们熟悉的 ip，建议添加自定义的网卡，并让我们的虚拟机连上我们的自定义网卡
```bash
(base)  /Library/Preferences/VMware Fusion/vmnet2/ pwd
/Library/Preferences/VMware Fusion/vmnet2
# 修改nat.conf文件的配置
(base)  /Library/Preferences/VMware Fusion/vmnet2/ grep -Ev '^#|^$' nat.conf
[host]
useMacosVmnetVirtApi = 1
#修改这个 IP(这里是后面要用到的虚拟机的网关IP)
ip = 192.168.10.2
# 掩码根据IP修改
netmask = 255.255.255.0
device = vmnet2
activeFTP = 1
allowAnyOUI = 1
#修改这个IP（这个是虚拟交换机的主机 IP）
hostIp = 192.168.10.1
resetConnectionOnLinkDown = 1
resetConnectionOnDestLocalHost = 1
natIp6Enable = 0
natIp6Prefix = fd15:4ba5:5a2b:1002::/64
[tcp]
timeWaitTimeout = 30
[udp]
timeout = 30
[netbios]
nbnsTimeout = 2
nbnsRetries = 3
nbdsTimeout = 3
[incomingtcp]
[incomingudp]

# 保存后退出 :wq
#重启 vmware 的网络服务
sudo /Applications/VMware\ Fusion.app/Contents/Library/vmnet-cli --restart
# 重启vmware，打开网络设置
# 设置和上面配置的交换机和网关同一网段的子网 IP，这个子网决定了你的虚拟机的 IP，这里需要先启用 dhcp 功能，
# 修改完 IP 后关掉 dhcp，否则无法修改
如图：[添加vmwar-net2网卡](img/net1.png)
# 至此，vmware上的网络配置就算完成了
```

## 2. 添加免密用户（自己环境方便测试推荐，生产环境推荐不要动）
```bash
ubuntu修改特权用户sudo免密执行命令
# 提权到 root ，默认是没有密码的
sudo -i
#临时修改visudo 编辑器 nano 个人感觉不好用（主要是不会用，没有vim 舒服）
export EDITOR=/usr/bin/vim
visudo
#加上这一行,使ubuntu 指定用户 sudo 免密执行所有命令：
kris ALL=(ALL) NOPASSWD: ALL

```


## 3. ubuntu server中启用 networkmanager 管理网络服务
### 3.1. 虚拟机联网
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

### 3.2. 安装网络管理软件 network-manager
```bash
# 由于这里需要安装软件，需要先做 3.1 中的操作连上网，将我们的静态 IP 配好后再禁用 dhcp
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
```
#### 3.2.1. 填坑

> 之前的网络配好之后，第二天发现被坑了。。。。。就算装了 networkmanager，网络还是由 netplan 管理的，
> 在这里更新下第二天打开虚拟机发现天塌了，昨天晚上配好的 IP 失效了，现在虚拟机是没有联网的状态，
> 由于是在vmware 的黑框中操作的，这里贴不了记录了，反正就是我用哦 iterm2 连接虚拟机时没反应，去虚
> 拟机中 ip 看了下已经没有我配好的 ip 了

#### 3.2.2. 解决办法：
- 禁用 systemd-networkd
```bash
# 先禁用掉systemd-networkd，并关闭开机自启
kris@node01:~$ sudo systemctl stop systemd-networkd
kris@node01:~$ sudo systemctl disable --now systemd-networkd
kris@node01:~$ sudo systemctl status systemd-networkd
# systemctl mask systemd-networkd 是一个 非常强力的系统级禁用命令，它的作用远不止“停止并禁止开机启动”，
# 而是彻底阻止该服务被任何方式激活。它会创建一个符号链接（symlink），将 /etc/systemd/system/systemd-networkd.service 指向 /dev/null
# 否则重启之后还会用systemd-networkd管理网络，或者和 systemd-networkd 冲突
kris@node01:~$ sudo systemctl mask systemd-networkd

kris@node01:~$ sudo systemctl status systemd-networkd
● systemd-networkd.service
     Loaded: masked (Reason: Unit systemd-networkd.service is masked.)
     Active: inactive (dead)

```

- 添加静态 IP
```bash
# 修改文件 /etc/netplan/00-installer-config.yaml ，名字可能不一样，更具实际情况来，文件中每个字段都很容易理解
kris@node01:~$ sudo cat /etc/netplan/00-installer-config.yaml
# This is the network config written by 'subiquity'
network:
# 使用NetworkManager渲染
  renderer: NetworkManager
  ethernets:
    ens160:
      dhcp4: no
      addresses:
        - 192.168.10.101/24
      gateway4: 192.168.10.2
      nameservers:
        addresses: [192.168.10.2]
  version: 2
# 让配置文件生效
kris@node01:~$ sudo netplan apply
# 重启机器验证
kris@node01:~$ sudo init 6
# 正常了
kris@node01:~$ ip a s
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:58:ec:a0 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.101/24 brd 192.168.10.255 scope global noprefixroute ens160
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe58:eca0/64 scope link
       valid_lft forever preferred_lft forever

```


