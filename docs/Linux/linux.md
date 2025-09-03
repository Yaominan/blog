## 1.系统安装
```text
centos光盘选择

https://mirrors.aliyun.com/centos-vault/7.6.1810/isos/x86_64/?spm=a2c6h.25603864.0.0.484d289bf1kM8o

选择 CentOS-7-x86_64-DVD-1810.iso
install（参考网站：https://www.cnblogs.com/mr-xiong/p/12470034.html）
```

```bash
分区配置

boot分区一般是 200M
swap分区 一般是内存的两倍（16G）
/分区
网络配置(NAT模式)

nmcli connection modify ens33 ipv4.methord manual ipv4.address [] ipv4.dns [] ipv4.gateway [] autoconnect yes

ip a s
```
解决物理机ping不通虚拟机

物理机上修改虚拟网卡地址

ip和虚拟交换机机的IP在同一网段，网关和虚拟交换机的网关一样，如图nat

解决虚拟机ping不通网关

重置虚拟机网卡（删除添加）
### Linux系统相关
https://www.linuxcool.com/ （Linux命令大全）

查看系统版本号
```bash
[root@192 ~]# cat /etc/centos-release
```
查看内核参数
```bash
[root@192 ~]# uname -a
```
查看端口占用

netstate -luntp | grep ...
处理boot分区满了的办法
```bash
[root@localhost boot]# uname -r
[root@localhost boot]# rpm -qa | grep kernel


[root@localhost boot]# rpm -q kernel


[root@localhost boot]# rpm -e kernel-3.10.0-957.el7.x86_64   （删除较老的版本）


[root@localhost boot]# df  -lh
```
 

### 软件部署安装
#### Linux下软件安装的几种方式
Linux下常见的安装包有以下集中形式（名称-版本-修正版-类型）：

tar包：如software-1.2.3-1.tar.gz 该形式是用打包工具tar打包的
rpm包：如software-1.2.3-1.i386.rpm 这是Redhat Linux提供的一种报道额封装格式
dpkg包：如software-1.2.3-1.deb 这是Debian提供的包的封装格式
源码安装

rpm安装

yum安装

配置软件仓库
```bash
[root@192 yum.repos.d]# wget -O /etc/yum.repos.d/CentOS-Base.repo   https://mirrors.aliyun.com/repo/Centos-7.repo
[root@192 yum.repos.d]# yum clean all


[root@192 yum.repos.d]# yum makecache
```
 

#### 安装jdk
下载jdk压缩包

解压
```bash
tar -xzvf jdk-18_linux-x64_bin.tar.gz
mv jdk-18.0.2 /usr/local/tools/
```
卸载openjdk

yum remove ***

修改配置/etc/profile
```bash
export JAVA_HOME=/usr/local/tools/jdk-18.0.2 （jdk的存放路径）​ export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar​ export PATH=$PATH:$JAVA_HOME/bin

source /etc/profile

Java -version
```

#### 安装mysql
下载mysql
```bash
mysql-8.0.30-1.el7.x86_64.rpm-bundle.tar
#删除自带的mariadb
[root@localhost opt]# rpm -qa | grep mariadb
[root@localhost opt]# yum list | grep mariadb*
[root@localhost opt]# yum remove mariadb-libs.x86_64
# 解压

[root@localhost mysql]# tar -xvf mysql-8.0.30-1.el7.x86_64.rpm-bundle.tar
#安装（需要按照顺序）

[root@localhost mysql]# rpm -ivh mysql-community-common-8.0.30-1.el7.x86_64.rpm -c --nodeps --force
[root@localhost mysql]# rpm -ivh mysql-community-libs-8.0.30-1.el7.x86_64.rpm -c --nodeps --force
[root@localhost mysql]# rpm -ivh mysql-community-client-8.0.30-1.el7.x86_64.rpm -c --nodeps --force
[root@localhost mysql]# rpm -ivh mysql-community-server-8.0.30-1.el7.x86_64.rpm -c --nodeps --force
#检查
[localhost mysql]# rpm -qa | grep mysql
#初始化mysql

#初始化

[root@localhost mysql]# mysqld --initialize

#生成初始密码

root@localhost mysql]# chown mysql:mysql /var/lib/mysql -R

#开启服务查看初始密码

[root@localhost mysql]# cat /var/log/mysqld.log | grep password

#登录mysql

[root@localhost mysql]# mysql -uroot -p [enter输入复制的密码]

#重置密码（密码永久不过期）

mysql> alter user root@'localhost' identified by 'yma666' password expire never;

#开放防火墙端口

[root@localhost mysql]# firewall-cmd --list-all
[root@localhost mysql]# firewall-cmd --zone=public --add-port=3306/tcp --permanent
[root@localhost mysql]# firewall-cmd --reload
#连接数据库

#创建用户用来外部连接数据库

mysql> create user yma@'%' identified by 'yma666';

#授权

mysql> grant all on . to yma@'%';

#其他连接问题解决方案

alter user 'lzj'@'%' identified by 'zdx123zdx' password expire never;
alter user 'root'@'localhost' identified with mysql_native_password by 'password';


alter user 'lzj'@'%' identified with mysql_native_password by 'zdx123zdx';



alter user 'root'@'localhost' identified with mysql_native_password by 'password';
```
   
#### 安装tomcat
```bash
[root@localhost yum.repos.d]# yum -y install tomcat
[root@localhost mysql]# rpm -qa | grep tomcat
#启动tomcat
[root@localhost mysql]# systemctl start tomcat.service
#开放防火墙端口
[root@localhost mysql]# firewall-cmd --zone=public --add-port=8080/tcp --permanent
#重启或重新加载（--reload）防火墙
[root@localhost mysql]# systemctl restart firewalld.service
#安装网页插件
[root@localhost mysql]# yum -y install tomcat-admin-webapps.noarch tomcat-webapps.noarch
#修改文件/etc/tomcat/tomcat-users.xml

8. 登录管理所有发布的应用
http://192.168.10.11:8080/manager/html




选择war包发布


image-20220808184124941




配置SSL





cd /usr/java/jdk1.6.0_32/bin
./keytool -genkey -alias tomcat -keyalg RSA -keystore /usr/local/tomcat/conf/.keystore


```
参考：https://www.jb51.net/LINUXjishu/801011.html

##### 源码安装tomcat
下载apache-tomcat-9.0.65.tar.gz

上传到服务器

将文件解压到安装位置（/usr/local/tools/tomcat）
```bash
[root@localhost bin]# cp -p /usr/local/tools/tomcat/bin/catalina.sh /etc/init.d/tomcat
```
设置开机自启

参考：https://blog.csdn.net/cbuy888/article/details/87190065

[root@localhost bin]# vim /etc/init.d/tomcat
```bash
# chkconfig: 112（启动级别0-6） 63（启动优先级0-100） 37（停止优先级0-100，数字越大，优先级越低）
# description: tomcat server init script
# Source Function Library
. /etc/init.d/functions
JAVA_HOME=/usr/local/tools/jdk-18.0.2
CATALINA_HOME=/usr/local/tools/tomcat
[root@localhost bin]# chmod 755 /etc/init.d/tomcat
[root@localhost bin]# chkconfig --add tomcat
[root@localhost bin]# chkconfig tomcat on
```
配置tomcat

修改端口（如下代码块）
```bash
[root@localhost conf]# vim /usr/local/tools/tomcat/conf/server.xml
    <Connector port="80" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
[root@localhost conf]# firewall-cmd --zone=public --add-port=80/tcp --permanent 
#配置虚拟主机（网站）

[root@localhost conf]# vim /usr/local/tools/tomcat/conf/server.xml
<Host name="www.yma.ca"  appBase="webapps"
         unpackWARs="true" autoDeploy="true">
         <!-- SingleSignOn valve, share authentication between web applications
      Documentation at: /docs/config/valve.html -->
 <!--
 <Valve className="org.apache.catalina.authenticator.SingleSignOn" />
 -->
a

#配置SSL

[root@localhost conf]# cd /usr/local/tools/jdk-18.0.2/bin
[root@localhost bin]# ./keytool -genkey -alias tomcat -keyalg RSA -keystore /usr/local/tools/tomcat/conf/.keystore
```

## 2.Linux系统调优
### 关闭selinux
```bash
vim /etc/selinux/config
```
### 查看环境变量

```bash
env

env | grep JAVA
设置环境变量文件/etc/profile

设置账户超时时间

[root@chao ~]# echo 'export TMOUT=300' >>/etc/profile
[root@chao ~]# source /etc/profile
[root@chao ~]# env |grep -i tmout
``` 

### 开机自启服务
- 需要开机自启的服务
  - sshd,远程连接需要使用此服务
  - rsyslog,日志有关的软件
  - networ，网络相关的软件
  - crond,定时任务相关软件
  - sysstat数据分析的软件
- 查看目前开机自启的服务
```bash
systemctl list-unit-files|grep enabled
```
- 关闭开机自启
```bash
systemctl disable postfix.service 
```

### 设置ssh服务
```bash
#编辑/etc/ssh/sshd_config

#Port 22222 （默认端口22）
Linux中文设置
查看系统是否是 zh_CN.UTF-8，添加代码

cat /etc/locale.conf

LANG="zh_CN.UTF-8"
```
### 设置命令行历史记录数
```bash
[root@chao ~]# sed -i 's/^HISTSIZE=5/HISTSIZE=10/' /etc/profile
[root@chao ~]# source /etc/profile
```

### 锁定重要文件
```bash
[root@chao ~]# chattr -i /etc/passwd /etc/shoadow /etc/group /etc/gshadow /etc/inittab
```

### 隐藏系统版本
```bash
[root@chao ~]# echo redflag 5.9 >/etc/issue
[root@chao ~]# cat /etc/issue
redflag 5.9
```

### 通配符

表3-3 Linux系统中的通配符及含义

|通配符	|含义
|--|--|
|*	          |任意字符
|?	          |单个任意字符
|[a-z]	      |单个小写字母
|[A-Z]	      |单个大写字母
|[a-Z]	      |单个字母
|[0-9]	      |单个数字
|[[:alpha:]]	|任意字母
|[[:upper:]]	|任意大写字母
|[[:lower:]]	|任意小写字母
|[[:digit:]]	|所有数字
|[[:alnum:]]	|任意字母加数字
|[[:punct:]]	|标点符号
|转义符
|反斜杠（\）：使反斜杠后面的一个变量变为单纯的字符。
|
|单引号（' '）：转义其中所有的变量为单纯的字符串。
|
|双引号（" "）：保留其中的变量属性，不进行转义处理。
|
|反引号（）：把其中的命令执行后返回结果。

### top
top -p ：查看指定进程的top信息
top -H -p:查看指定进程的所有线程的top信息
### 重要的环境变量
表3-4 Linux系统中最重要的10个环境变量

变量名称	作用
HOME	用户的主目录（即家目录）
SHELL	用户在使用的Shell解释器名称
HISTSIZE	输出的历史命令记录条数
HISTFILESIZE	保存的历史命令记录条数
MAIL	邮件保存路径
LANG	系统语言、语系名称
RANDOM	生成一个随机数字
PS1	Bash解释器的提示符
PATH	定义解释器搜索用户执行命令的路径
EDITOR	用户默认的文本编辑器
### 网卡配置
 

设备类型：TYPE=Ethernet

地址分配模式：BOOTPROTO=static

网卡名称：NAME=ens160

是否启动：ONBOOT=yes

IP地址：IPADDR=192.168.10.10

子网掩码：NETMASK=255.255.255.0

网关地址：GATEWAY=192.168.10.1

DNS地址：DNS1=192.168.10.1

按照测试对象来划分，条件测试语句可以分为4种：
文件测试语句；

逻辑测试语句；

整数值比较语句；

字符串比较语句。

表4-3 文件测试所用的参数

操作符	作用
-d	测试文件是否为目录类型
-e	测试文件是否存在
-f	判断是否为一般文件
-r	测试当前用户是否有权限读取
-w	测试当前用户是否有权限写入
-x	测试当前用户是否有权限执行
表4-4 可用的整数比较运算符

操作符	作用
-eq	是否等于
-ne	是否不等于
-gt	是否大于
-lt	是否小于
-le	是否等于或小于
-ge	是否大于或等于
表4-5 常见的字符串比较运算符

操作符	作用
=	比较字符串内容是否相同
!=	比较字符串内容是否不同
-z	判断字符串内容是否为空
表5-7 SUID、SGID、SBIT特殊权限的设置参数

参数	作用
u+s	设置SUID权限
u-s	取消SUID权限
g+s	设置SGID权限
g-s	取消SGID权限
o+t	设置SBIT权限
o-t	取消SBIT权限
表5-8 chattr/lsattr命令中的参数及其作用

参数	作用
i	无法对文件进行修改；若对目录设置了该参数，则仅能修改其中的子文件内容而不能新建或删除文件
a	仅允许补充（追加）内容，无法覆盖/删除内容（Append Only）
S	文件内容在变更后立即同步到硬盘（sync）
s	彻底从硬盘中删除，不可恢复（用0填充原文件所在硬盘区域）
A	不再修改这个文件或目录的最后访问时间（atime）
b	不再修改文件或目录的存取时间
D	检查压缩文件中的错误
d	使用dump命令备份时忽略本文件/目录
c	默认将文件或目录进行压缩
u	当删除该文件后依然保留其在硬盘中的数据，方便日后恢复
t	让文件系统支持尾部合并（tail-merging）
x	可以直接访问压缩文件中的内容
partprobe 重读分区表

uquota 磁盘容量配额

xfs_quota管理设备的磁盘容量配额

xfs_quota -x -c 'limit bsoft=3M bhard=6M isoft=3 ihard=6 tom' /boot
edquota管理系统的磁盘配额

表6-6 edquota命令中可用的参数以及作用

参数	作用
-u	对某个用户进行设置
-g	对某个用户组进行设置
-p	复制原有的规则到新的用户/组
-t	限制宽限期限
### 软硬链接
表6-8 ln命令中可用的参数以及作用

参数	作用
-s	创建“符号链接”（如果不带-s参数，则默认创建硬链接）
-f	强制创建文件或目录的链接
-i	覆盖前先询问
-v	显示创建链接的过程
## 3.raid磁盘阵列与lvm逻辑卷管理
### raid
表7-3 RAID 0、1、5、10方案技术对比

RAID级别	最少硬盘	可用容量	读写性能	安全性	特点
0	2	n	n	低	追求最大容量和速度，任何一块盘损坏，数据全部异常。
1	2	n/2	n	高	追求最大安全性，只要阵列组中有一块硬盘可用，数据不受影响。
5	3	n-1	n-1	中	在控制成本的前提下，追求硬盘的最大容量、速度及安全性，允许有一块硬盘异常，数据不受影响。
10	4	n/2	n/2	高	综合RAID1和RAID0的优点，追求硬盘的速度和安全性，允许有一半硬盘异常（不可同组），数据不受影响
raid0

将至少两块的物理设备通过硬件或软件的方式串联到一起，将数据依次写入到各个物理硬盘中，容量大，读写快，安全性低
raid1

将两块以上的硬盘进行绑定，在写入数据的时候，同时写入到多块硬盘设备上（类似于镜像/备份），当一块硬盘发生故障，一般会以自动热交换的方式回复数据的使用。空间使用率低，数据安全性高，读写速度较raid0稍低
raid5

raid5是把硬盘设备的数据的奇偶校验信息保存到其他每一块硬盘上，而不是备份真实的数据信息，当发生故障时，通过奇偶校验信息尝试重建损坏的数据，兼顾速度、安全、成本。
RAID 5最少由3块硬盘组成，使用的是硬盘切割（Disk Striping）技术。相较于RAID 1级别，好处就在于保存的是奇偶校验信息而不是一模一样的文件内容，所以当重复写入某个文件时，RAID 5级别的磁盘阵列组只需要对应一个奇偶校验信息就可以，效率更高，存储成本也会随之降低。
raid10

结合了raid0 和raid1的技术，最少需要4块硬盘，先两两组成raid1阵列，然后利用raid0技术将两个阵列组合成raid0阵列
#### 部署磁盘阵列
表7-2 mdadm命令的常用参数和作用

|参数	|作用| 
|-------|---------|         
|-a	|检测设备名称    
|-n	|指定设备数量     
|-l	|指定RAID级别     
|-C	|创建             
|-v	|显示过程         
|-f	|模拟设备损坏     
|-r	|移除设备         
|-Q	|查看摘要信息     
|-D	|查看详细信息     
|-S	|停止RAID磁盘阵列 
|-x	|备份盘          

- 部署raid10
```bash
mdadm -Cv /dev/md0 -n 4 -l 10 /dev/sdb /dev/sdc /dev/sdd /dev/sde
mdadm -Q /dev/md0
mdadm -D /dev/md0
mkfs.ext4 /dev/md0
mdadm --detail --scan >> /etc/mdadm.conf
mkdir /RAID
echo "/dev/md0 /RAID ext4 defaults 0 0" >> /etc/fstab
mount -a
```
- 部署raid5
```bash
mdadm -Cv /dev/md0 -n 3 -l 5 -x 1 /dev/sdb /dev/sdc /dev/sdd /dev/sde
mdadm -D /dev/md0
mkfs.ext4 /dev/md0
mount /dev/md0 /RAID
```
#### 损坏磁盘阵列及修复
*重启后遇到进入emergency mode，进fstab把无效的挂载删掉
```bash
mdadm /dev/md0 -f /dev/sdd (模拟硬盘)
mdadm /dev/md0 -r /dev/sdd (移除硬盘)
umount /RAID
mdadm /dev/md0 -a /dev/sdf
mdadm -D /dev/md0
```
#### 解除raid
```bash
umount /RAID
mdadm /dev/md0 -r /dev/sd[b-e]
mdadm -S /dev/md0
mdadm --remove /dev/md0
mdadm --misc --zero-superblock /dev/sd[b-e]
rm -rf /etc/mdadm.conf
删除fstab挂载项
```
### LVM逻辑卷管理器
#### 部署逻辑卷
表7-3 常用的LVM部署命令

功能/命令	|物理卷管理	| 卷组管理	|  逻辑卷管理
---------------|---------------|--------------|----
扫描	        |pvscan	vgscan	|lvscan
建立	        |pvcreate	|vgcreate	|lvcreate
显示	        |pvdisplay	|vgdisplay	|lvdisplay
删除	        |pvremove	|vgremove	|lvremove
扩展	 	|                |vgextend	|lvextend
缩小	 	 |               |vgreduce	|lvreduce
```bash
pvcreate /dev/sdf /dev/sdg
vgcreate storage /dev/sdf /dev/sdg
vgdisplay
lvcreate -n vo -L 150M storage
lvdisplay
mkfs.ext4 /dev/storage/vo
mkdir /gmiao
mount /dev/storage/vo /gmiao/
echo "/dev/storage/vo /gmiao/ ext4 defaults 0 0" >> /etc/fstab
```

#### 扩容逻辑卷
```bash
umount /gmiao
lvextend -L 290M /dev/storage/vo
e2fsck -f /dev/storage/vo
resize2fs /dev/storage/vo
mount -a
df -h
```
#### 缩小逻辑卷
```bash
umount /gmiao
e2fsck -f /dev/storage/vo （检查文件系统的完整性）
resize2fs /dev/storage/vo 120M
lvreduce -L 120M /dev/storage/vo
mount -a
df -h
```
#### 逻辑卷快照
```bash
lvcreate -L 120M -s -n snap /dev/storage/vo (-s参数表示创建快照卷)
dd if=/dev/zero of=/gmiao/gm count=1 bs=100M
umount /gmiao
lvconvert --merge /dev/storage/snap
mount -a
```
#### 删除逻辑卷
```bash
umount /gmiao
删除fstab关联项
lvremove /dev/storage/vo
vgremove storage
pvremove /dev/sdf /dev/sdg
```
## 4.iptables和firewalld防火墙

### iptables
表8-1 iptables中常用的参数以及作用

|参数	       |作用
|--|--|
|-P	       |设置默认策略
|-F	       |清空规则链
|-L	       |查看规则链
|-A	       |在规则链的末尾加入新规则
|-I num	       |在规则链的头部加入新规则
|-D num	       |删除某一条规则
|-s	       |匹配来源地址IP/MASK，加叹号“!”表示除这个IP外
|-d	       |匹配目标地址
|-i 网卡名称	|匹配从这块网卡流入的数据
|-o 网卡名称	|匹配从这块网卡流出的数据
|-p	       |匹配协议，如TCP、UDP、ICMP
|--dport num	|匹配目标端口号
|--sport num	|匹配来源端口号

> 防火墙的策略规则是按照从上到下的顺序匹配的，所以一定要把允许动作放在拒绝动作前面，否则所有的流量都会被拒绝。(针对单条规则)
```bash
# 将INPUT规则链设置为只允许指定网段的主机访问本机的22端口，拒绝来自其他所有主机的流量。
iptables -I INPUT -s 192.168.10.0/24 -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j REJECT
# 向INPUT规则链中添加拒绝所有人访问本机12345端口的策略规则。

iptables -I INPUT -p tcp --dport 12345 -j REJECT
iptables -I INPUT -p udp --dport 12345 -j REJECT
# 向INPUT规则链中添加拒绝192.168.10.5主机访问本机80端口（Web服务）的策略规则。

iptables -I INPUT -s 192.168.10.5 -p tcp --dport 80 -j REJECT
# 向INPUT规则链中添加拒绝所有主机访问本机1000～1024端口的策略规则。

iptables -A INPUT -p tcp --dport 1000:1024 -j REJECT
iptables -A INPUT -p udp --dport 1000:1024 -j REJECT
iptables-save
```
### firewalld
表8-2 firewalld中常用的区域名称及策略规则

|区域	        |默认规则策略
|--|--|
|trusted        |允许所有的数据包
|home	        |拒绝流入的流量，除非与流出的流量相关；而如果流量与ssh、mdns、ipp-client、amba-client与dhcpv6-client服务相关，则允许流量
|internal	|等同于home区域
|work	        |拒绝流入的流量，除非与流出的流量相关；而如果流量与ssh、ipp-client与dhcpv6-client服务相关，则允许流量
|public	        |拒绝流入的流量，除非与流出的流量相关；而如果流量与ssh、dhcpv6-client服务相关，则允许流量
|external	|拒绝流入的流量，除非与流出的流量相关；而如果流量与ssh服务相关，则允许流量
|dmz	        |拒绝流入的流量，除非与流出的流量相关；而如果流量与ssh服务相关，则允许流量
|block	        |拒绝流入的流量，除非与流出的流量相关
|drop	        |拒绝流入的流量，除非与流出的流量相关
- 终端管理工具

- 表8-3 firewall-cmd命令中使用的参数以及作用

|参数	                        |作用
|--|--|
|--get-default-zone	        |查询默认的区域名称
|--set-default-zone=<区域名称>	|设置默认的区域，使其永久生效
|--get-zones	                |显示可用的区域
|--get-services	                |显示预先定义的服务
|--get-active-zones	        |显示当前正在使用的区域与网卡名称
|--add-source=	                |将源自此IP或子网的流量导向指定的区域
|--remove-source=	        |不再将源自此IP或子网的流量导向某个指定区域
|--add-interface=<网卡名称>	|将源自该网卡的所有流量都导向某个指定区域
|--change-interface=<网卡名称>	|将某个网卡与区域进行关联
|--list-all	                |显示当前区域的网卡配置参数、资源、端口以及服务等信息
|--list-all-zones	        |显示所有区域的网卡配置参数、资源、端口以及服务等信息
|--add-service=<服务名>	        |设置默认区域允许该服务的流量
|--add-port=<端口号/协议>	|设置默认区域允许该端口的流量
|--remove-service=<服务名>	|设置默认区域不再允许该服务的流量
|--remove-port=<端口号/协议>	|设置默认区域不再允许该端口的流量
|--reload	                |让“永久生效”的配置规则立即生效，并覆盖当前的配置规则
|--panic-on	                |开启应急状况模式
|--panic-off	                |关闭应急状况模式

- 查看firewalld服务当前所使用的区域。
```bash
firewall-cmd --get-default-zone
查询指定网卡在firewalld服务中绑定的区域

firewall-cmd --get-zone-of-interface=ens33
把网卡默认区域修改为external，并在系统重启后生效

firewall-cmd --permanent --zone=external --change-interface=ens33
firewall-cmd --get-zone-of-interface=ens33 --permanent
启动和关闭firewalld防火墙服务的应急状况模式。

firewall-cmd --panic-on
firewall-cmd --panic-off
查询SSH和HTTPS协议的流量是否允许放行。

[root@192 ~]# firewall-cmd --zone=public --query-service=ssh
yes
[root@192 ~]# firewall-cmd --zone=public --query-service=https
no
把HTTPS协议的流量设置为永久允许放行，并立即生效

[root@192 ~]# firewall-cmd --permanent --zone=public --add-service=https
success
[root@192 ~]# firewall-cmd --zone=public --query-service=https
no
[root@192 ~]# firewall-cmd --reload 
success
[root@192 ~]# firewall-cmd --zone=public --query-service=https
yes
把HTTP协议的流量设置为永久拒绝，并立即生效

[root@192 ~]# firewall-cmd --permanent --zone=public --remove-service=http
Warning: NOT_ENABLED: http
success
[root@192 ~]# firewall-cmd --zone=public --query-service=http
no
[root@192 ~]# firewall-cmd --reload 
success
[root@192 ~]# firewall-cmd --zone=public --query-service=http
no

把访问8080和8081端口的流量策略设置为允许，但仅限当前生效

[root@192 ~]# firewall-cmd --zone=public --add-port=8080-8081/tcp
success
[root@192 ~]# firewall-cmd --zone=public --query-port=8080-8081
Error: INVALID_PORT: bad port (most likely missing protocol), correct syntax is portid[-portid]/protocol
[root@192 ~]# firewall-cmd --zone=public --query-port=8080
Error: INVALID_PORT: bad port (most likely missing protocol), correct syntax is portid[-portid]/protocol
[root@192 ~]# firewall-cmd --zone=public --query-port=8080/tcp
yes
[root@192 ~]# firewall-cmd --zone=public --query-port=8080-8081/tcp
yes
把原本访问本机888端口的流量转发到22端口，要且求当前和长期均有效

[root@192 ~]# firewall-cmd --permanent --zone=public --add-forward-port=port=888:proto=tcp:toport=22:toaddr=192.168.10.10
success
[root@192 ~]# firewall-cmd --reload 
success
富规则的设置

[root@192 ~]# man firewall-cmd
man firewalld.richlanguage
[--permanent] [--zone=zone] --add-rich-rule='rule family="ipv6" source address="1:2:3:4:6::" service name="radius" log prefix="dns" level="info" limit value="3/m" reject'

[root@linuxprobe ~]# firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" source address="192.168.10.0/24" service name="ssh" reject"
success
[root@linuxprobe ~]# firewall-cmd --reload
success
```
### 图形管理工具
firewall-config
### 服务的访问控制列表

```bash
root@192 ~]# vim /etc/hosts.deny
sshd:*
[root@192 ~]# vim /etc/hosts.allow
sshd:192.168.10.
```
### Cockpit驾驶舱管理工具

```text
总共分为十三个功能模块，即：系统状态、日志信息、硬盘存储、网卡网络、账户安全、服务程序、软件仓库、报告分析、内核排错、SElinux、更新软件、订阅服务、终端界面。

System

类似web版的任务管理器
Logs

可根据时间和日志级别查询日志
Storage

可以简单的创建RAIDD、LVM、VDO、iSCSI等存储设备
Networking

动态查看网卡的输出和接受值，还可进行网卡的绑定、聚合、创建桥接网卡、添加vlan，列出网卡相关的日志信息
Accounts

可以对用户进行管理
Services

可查看服务并进行管理（包括停止启动等），点击单个服务，下面还有相关的日志信息
Applications

软件仓库
Diagnostic Report

sosreport
Kernel Dump

内核排错
SElinux

Terminal（运维常用）
```

## 5.使用ssh服务管理远程主机
### 配置网卡服务

- 配置网卡参数

```bash
nmtui

ONBOOT=yes（重启后网卡激活）
nmcli connection reload ens33
nmcli connection up ens33
```

- 创建网络会话（实现不用频繁的更改ip）
  - 
        ```bash
        [root@192 ~]# nmcli connection add con-name company ifname ens33 autoconnect no type ethernet ip4 192.168.10.10/24 gw4 192.168.10.2
        [root@192 ~]# nmcli connection show
        [root@192 ~]# nmcli connection up company (开启会话，表示当前可用的是这个会话=连接)
        [root@192 ~]# nmcli connection delete company （删除不用的会话）
        ```

- 绑定两块网卡
  - round-robin(轮循模式)
    - 根据设备的顺序依次传输数据包，一台网卡发生故障，会切换到另一台上，网络不会断
          ```bash
          ### 创建一个bond网卡
          [root@192 ~]# nmcli connection add type bond con-name bond0 ifname bond0 bond.options "mode=balance-rr"
          Connection 'bond0' (2525bc21-b229-4a94-b2a9-d2d4f47bfba1) successfully added
          #### 向bond0中添加从属网卡

          [root@192 ~]# nmcli connection add type ethernet slave-type bond con-name bond0-port1 ifname ens33 master bond0


          [root@192 ~]# nmcli connection add type ethernet slave-type bond con-name bond0-port2 ifname ens37 master bond0


          [root@192 ~]# nmcli connection up bond0
          ```

    - 提供负载均衡的效果，带宽的性能更好

 

active-backup(主备模式)

一台网卡发生损坏，另一个会自动顶上，冗余能力较强
### 远程控制服务
- 配置sshd服务,编辑（/etc/ssh/sshd_config）文件
  - sshd提供两种安全验证的方式（基于密码的验证，基于密钥的验证）

> 基于密码的验证—用账户和密码来验证登录；
> 基于密钥的验证—需要在本地生成密钥对，然后把密钥对中的公钥上传至服务器，并与服务器中的公钥进行比较；该方式相较来说更安全。

- 表9-1 sshd服务配置文件（/etc/ssh/sshd_config）中包含的参数以及作用

|参数	                               |作用
|--|--|
|Port 22	                               |默认的sshd服务端口
|ListenAddress 0.0.0.0	               |设定sshd服务器监听的IP地址
|Protocol 2	                       |SSH协议的版本号
|HostKey /tc/ssh/ssh_host_key	       |SSH协议版本为1时，DES私钥存放的位置
|HostKey /etc/ssh/ssh_host_rsa_key	|SSH协议版本为2时，RSA私钥存放的位置
|HostKey /etc/ssh/ssh_host_dsa_key	|SSH协议版本为2时，DSA私钥存放的位置
|PermitRootLogin yes	               |设定是否允许root管理员直接登录
|StrictModes yes	                       |当远程用户的私钥改变时直接拒绝连接
|MaxAuthTries 6	                       |最大密码尝试次数
|MaxSessions 10	                       |最大终端数
|PasswordAuthentication yes	       |是否允许密码验证
|PermitEmptyPasswords no	               |是否允许空密码登录（很不安全）

#### 安全密钥验证
```bash
#在客户端主机中生成密钥对
ssh-keygen
#将客户端中生成的公钥文件发送到服务器

ssh-copy-id root@192.168.10.10
ssh root@192.168.10.10
PasswordAuthentication no (禁止密码登录)
[root@server ~]# systemctl restart sshd
#windows将公钥复制到Linux，将文件内容追加到.ssh/authorized_keys文件中，重启sshd服务，就可以实现密钥远程连接
```

- 远程传输命令
  - 表9-3 scp命令中可用的参数及作用

|参数	|作用
|--|--|
|-v	|显示详细的连接进度
|-P	|指定远程主机的sshd端口号
|-r	|用于传送文件夹
|-6	|使用IPv6协议
 

### 不间断会话服务
- Tmux管理远程会话
```bash
[root@server ~]# tmux
[exited]
[root@server ~]# tmux new -s backup  （新建会话）
[detached]
[root@server ~]# tmux ls   （查看有哪些后台会话）
backup: 1 windows (created Mon Sep 26 16:13:21 2022) [60x19]


[root@server ~]# tmux attach -t backup  （返回i会话）
[exited]
[root@server ~]# tmux ls
failed to connect to server
[root@server ~]# tmux new "vim yma.a"    （直接执行命令，完成之后推出会话）
[exited]
```

- 管理多窗格
  - Tmux服务为用户提供了一系列快捷键来执行窗格的切换。方法是先同时按下Ctrl+B组合键，然后松手后再迅速按下其他后续按键，而不是一起按下。
  - 表9-5 Tmux会话窗格相关的常用快捷键

|快捷键	|作用
|--|--|
|%	|划分左右两个窗格
|"	|划分上下两个窗格
|<方向键>|	切换到上下左右相邻的一个窗格
|;	|切换至上一个窗格
|o	|切换至下一个窗格
|{	|将当前窗格与上一个窗格位置互换
|}	|将当前窗格与下一个窗格位置互换
|x	|关闭窗格
|!	|将当前窗格拆分成独立窗口
|q	|显示窗格编号
会话共享

tmux new -s share
tmux attach-session -t share
### 检索日志信息
- 在RHEL 8系统中，默认的日志服务程序是rsyslog

- 表9-7 常见的日志文件保存路径

|文件路径及命令	|作用
|--|--|
|/var/log/boot.log	|系统开机自检事件及引导过程等信息
|/var/log/lastlog	|用户登录成功时间、终端名称及IP地址等信息
|/var/log/btmp	        |记录登录失败的时间、终端名称及IP地址等信息
|/var/log/messages	|系统及各个服务的运行和报错信息
|/var/log/secure	        |系统安全相关的信息
|/var/log/wtmp	        |系统启动与关机等相关信息
- 从理论上讲，日志文件分为下面3种类型。在日常工作中，/var/log/message这个综合性的文件用得最多

> 系统日志：主要记录系统的运行情况和内核信息。
> 用户日志：主要记录用户的访问信息，包含用户名、终端名称、登入及退出时间、来源IP地址和执行过的操作等。
> 程序日志：稍微大一些的服务一般都会保存一份与其同名的日志文件，里面记录着服务运行过程中各种事件的信息；每个服务程序都有自己独立的日志文件，且格式相差较大。

- journalctl它可以根据事件、类型、服务名称等信息进行信息检索，从而大大提高了日常排错的效率。

- 表9-7 journalctl命令中常用按键以及作用

|参数	        |作用
|--|--|
|-k	        |内核日志
|-b	        |启动日志
|-u	        |指定服务
|-n	        |指定条数
|-p	        |指定类型
|-f	        |实时刷新（追踪日志）
|--since	|指定时间
|--disk-usage	|占用空间

- 表9-9 日志信息登记分类

|日志等级	|说明介绍
|--|--|
|emerg	        |系统出现严重故障，内核崩溃等情况
|alert	        |应立即修复的故障，数据库损坏等情况
|crit	        |危险较高的故障，硬盘损坏导致程序运行失败的情况
|err	        |一般危险的故障，某个服务启动或运行失败的情况
|warning	        |警告信息，某个服务参数或功能错误的情况
|notice	        |一般无危险的故障，只是需要处理的情况
|info	        |通用性消息，给用户提示一些有用信息
|debug	        |调试程序所产生的信息
|none	        |没有优先级，不做日志记录

```bash
[root@server ~]# journalctl -p crit   （按级别查询）
[root@server ~]# journalctl --since today
[root@server ~]# journalctl --since "-1 hour"   (最近一小时的日志)
[root@server ~]# journalctl --since "15:00" --until "16:00"
（指定时间段日志）
[root@server ~]# journalctl  -u sshd  （查看某个服务的日志）
```

## 6.使用apache服务部署静态网站
### 网站服务程序
Apache服务程序可以运行在Linux系统、UNIX系统甚至是Windows系统中，它支持基于IP、域名及端口号的虚拟主机功能，支持多种认证方式，集成有代理服务器模块、安全Socket层（SSL），能够实时监视服务状态与定制日志消息，并支持各类丰富的模块。

```bash
yum -y install httpd
systemctl start httpd
systemctl enable httpd
全局配置参数是一种全局性的配置参数，可作用于所有的子站点；区域配置参数 (写在中的) 则是单独针对每个独立的子站点设置的；而注释行信息一般是对服务程序的功能或某一行参数进行介绍的。
```

### 配置服务文件参数
- 表10-1 Linux系统中的httpd配置文件

|作用	        |文件名称
|--|--|
|服务目录       |/etc/httpd
|主配置文件     |/etc/httpd/conf/httpd.conf
|网站数据目录   |/var/www/html
|访问日志       |/var/log/httpd/access_log
|错误日志       |/var/log/httpd/error_log

- 表10-2 配置httpd服务程序时最常用的参数以及用途描述

|参数	        |作用
|--|--|
|ServerRoot	|服务目录
|ServerAdmin	|管理员邮箱
|User	        |运行服务的用户
|Group	        |运行服务的用户组
|ServerName	|网站服务器的域名
|DocumentRoot	|网站数据目录
|Listen  	|监听的IP地址与端口号
|DirectoryIndex	|默认的索引页页面
|ErrorLog	|错误日志文件
|CustomLog	|访问日志文件
|Timeout	        |网页超时时间，默认为300秒

- 建立网站数据的保存目录，创建首页文件
```bash
mkdir /home/wwwroot
echo "this is new web site pagemkdir /home/wwwroot" > /home/wwwroot/index.html
vim /etc/httpd/conf/httpd.conf
DocumentRoot "/home/wwwroot"
<Directory "/home/wwwroot">
AllowOverride None
# Allow open access:
Require all granted
</Directory>
# Further relax access to the default document root:
<Directory "/home/wwwroot">

[root@server wwwroot]# systemctl restart httpd
[root@server wwwroot]# semanage fcontext -a -t httpd_sys_content_t "/home/wwwroot/index.html"
[root@server wwwroot]# restorecon -R -v /home/wwwroot/index.html
[root@server wwwroot]# ll -Z
-rw-r--r--. root root unconfined_u:object_r:httpd_sys_content_t:s0 index.html
```
### SELinux安全子系统

- SELinux安全上下文确保文件资源只能被其所属的服务程序进行访问

- SELinux服务有3种配置模式，具体如下。
> enforcing：强制启用安全策略模式，将拦截服务的不合法请求。
> permissive：遇到服务越权访问时，只发出警告而不强制拦截。
> disabled：对于越权的行为不警告也不拦截。

- 表10-3 semanage命令中常用参数以及作用

|参数	|作用
|--|--|
|-l	|查询
|-a	|添加
|-m	|修改
|-d	|删除
```bash
[root@server wwwroot]# semanage fcontext -a -t httpd_sys_content_t "/home/wwwroot
[root@server wwwroot]# semanage fcontext -a -t httpd_sys_content_t "/home/wwwroot/*
[root@server wwwroot]# restorecon -R -v /home/wwwroot/index.html
```
### 个人用户主页功能
- userdir
```bash
[root@server wwwroot]# vim /etc/httpd/conf.d/userdir.conf 
    #UserDir disabled
    UserDir public_html  （网站数据在用户家目录中的保存目录名称：public_html）
[minayao@server ~]$ chmod -R 755 ./
[minayao@server ~]$ mkdir public_html
[minayao@server ~]$ echo "This is yma's site pageecho ！！！ " > public_html/index.html
[minayao@server ~]$ systemctl restart httpd
[root@server wwwroot]# firefox 
[root@server wwwroot]#  setsebool -P httpd_read_user_content=on
[root@server wwwroot]# getsebool -a | grep http
[root@server wwwroot]#  setsebool -P httpd_enable_homedirs=on
```

- 为个人主页设置密码
```bash
htpasswd -c /etc/httpd/passwd minayao

vim /etc/httpd/conf.d/userdir.conf

<Directory "/home/*/public_html">
    AllowOverride all
    authuserfile "/etc/httpd/passwd"
    authname "My paivately website"
    authtype basic
    Require user minayao
</Directory>
systemctl restart httpd
```

- 网页中输入用户名和密码

### 虚拟网站主机
- 基于IP地址（一台机器有多个IP地址）
```bash
[root@localhost yum.repos.d]# ping -c 4 192.168.10.30
（检查三个地址的连通性）
```

- 新建不同IP网站的数据目录，并写入主页
```bash
mkdir -p /home/wwwroot/10
mkdir -p /home/wwwroot/20
mkdir -p /home/wwwroot/30
echo "IP:192.168.10.10" > /home/wwwroot/10/index.html
echo "IP:192.168.10.20" > /home/wwwroot/20/index.html
echo "IP:192.168.10.30" > /home/wwwroot/30/index.html
semanage fcontext -a -t httpd_sys_content_t "/home/wwwroot/10/index.html"
（添加selinux安全上下文）
```

- 修改httpd.conf中的权限设置
```bash
#虚拟主机设置（基于IP地址）
NameVirtualHost *:80
<VirtualHost 192.168.10.10>
        DocumentRoot /home/wwwroot/10
        ServerName www.minayao10.com
        <Directory /home/wwwroot/10>
        AllowOverride None
        Require all granted
        </Directory>
</VirtualHost>
<VirtualHost 192.168.10.20>
DocumentRoot /home/wwwroot/20
ServerName www.minayao20.com
<Directory /home/wwwroot/10>
AllowOverride None
Require all granted
</Directory>
</VirtualHost>


<VirtualHost 192.168.10.30>
DocumentRoot /home/wwwroot/30
ServerName www.minayao30.com
<Directory /home/wwwroot/10>
AllowOverride None
Require all granted
</Directory>
</VirtualHost>
//权限设置
DocumentRoot "/home/wwwroot"


<Directory "/home/wwwroot">
AllowOverride None
# Allow open access:
Require all granted
</Directory>


Further relax access to the default document root:

<Directory "/home/wwwroot">
```


- 基于主机域名
  - 绑定IP和域名
```bash
#编辑/etc/hosts
92.168.10.10   www.minayao10.com
192.168.10.20   www.minayao20.com
192.168.10.30   www.minayao30.com
```
  - 创建几个目录存放数据，并创建首页文件
```bash
[root@192 wwwroot]# mkdir -p /home/wwwroot/minayao10
[root@192 wwwroot]# mkdir -p /home/wwwroot/minayao20
[root@192 wwwroot]# mkdir -p /home/wwwroot/minayao30
[root@192 wwwroot]# echo www.minayao10.com > minayao10/index.html
[root@192 wwwroot]# echo www.minayao20.com > minayao20/index.html
[root@192 wwwroot]# echo www.minayao30.com > minayao30/index.html
```


  - 修改/etc/httpd/conf/httpd.conf
```bash
NameVirtualHost *:80
<VirtualHost 192.168.10.10>
        DocumentRoot /home/wwwroot/minayao10    ⬅here
        ServerName www.minayao10.com
        <Directory /home/wwwroot/minayao10>     ⬅
        AllowOverride None
        Require all granted
        </Directory>
</VirtualHost>
<VirtualHost 192.168.10.20>
DocumentRoot /home/wwwroot/minayao20   ⬅
ServerName www.minayao20.com
<Directory /home/wwwroot/minayao10>    ⬅
AllowOverride None
Require all granted
</Directory>
</VirtualHost>


<VirtualHost 192.168.10.30>
DocumentRoot /home/wwwroot/minayao30   ⬅
ServerName www.minayao30.com
<Directory /home/wwwroot/minayao10>    ⬅
AllowOverride None
Require all granted
</Directory>
</VirtualHost>
```

  - 如果没有设置selinux上下文的话要设置

- 基于端口号
  - 创建目录
```bash
[root@192 wwwroot]# mkdir 6111
[root@192 wwwroot]# mkdir 6112
[root@192 wwwroot]# mkdir 6113
```
  - 添加首页文件
```bash
[root@192 wwwroot]# echo "port:6111" > 6111/index.html
[root@192 wwwroot]# echo "port:6112" > 6112/index.html
[root@192 wwwroot]# echo "port:6113" > 6113/index.html
```
  - 修改http.conf
```bash
Listen 6111
Listen 6112
Listen 6113
<VirtualHost 192.168.10.10:6111>    ⬅here
DocumentRoot /home/wwwroot/6111    ⬅here
ServerName www.minayao10.com
<Directory /home/wwwroot/6111>    ⬅here
AllowOverride None
Require all granted
</Directory>
</VirtualHost>


<VirtualHost 192.168.10.20:6112>
DocumentRoot /home/wwwroot/6112
ServerName www.minayao20.com
<Directory /home/wwwroot/6112>
AllowOverride None
Require all granted
</Directory>
</VirtualHost>


<VirtualHost 192.168.10.30:6113>
DocumentRoot /home/wwwroot/6113
ServerName www.minayao30.com
<Directory /home/wwwroot/6113>
AllowOverride None
Require all granted
</Directory>
</VirtualHost>
```

### apache的访问控制
1. 创建目录server，并创建首页文件

2. 编辑httpd.conf
```bash
限制浏览器登录
<Directory "/home/wwwroot/server">
        SetEnvIf User-Agent "Firefox" ff=1
        Order allow,deny
        Allow from env=ff
</Directory>
```
```bash
限制IP地址
<Directory "/home/wwwroot/server">
        Order allow,deny
        Allow from 192.168.10.10
</Directory>
```

> 想要查询并过滤http协议相关的selinux域策略有哪些？
```bash
* getsebool -a | grep http
```
使用端口号配置虚拟主机网站有什么特点

在使用端口号来配置虚拟主机网站时，必须要考虑到SELinux域对httpd服务程序所用端口号的控制策略，还要在httpd服务程序的主配置文件中使用Listen参数来开启要监听的端口号。

## 7.使用vsftpd服务传输文件
### 文件传输协议
```text
ftp是一种在互联网中进行文件传输的协议，基于C/S模式，默认使用20、21端口，20用来进行数据传输，21用于接收客户端发出的命令和参数

ftp协议有两种工作模式

主动模式：FTP服务器主动向客户端发起连接请求。

被动模式：FTP服务器等待客户端发起连接请求（默认工作模式）。
```
### vsftpd服务程序
- vsftpd的主配置文件/etc/vsftpd/vsftpd.conf

- 表11-1 vsftpd服务程序常用的参数以及作用

|参数	                                                |作用
|--|--|
|listen=[YES|NO]	                                |是否以独立运行的方式监听服务
|listen_address=IP地址	                                |设置要监听的IP地址
|listen_port=21	                                        |设置FTP服务的监听端口
|download_enable＝[YES|NO]	                        |是否允许下载文件
|userlist_enable=[YES|NO] userlist_deny=[YES|NO]	|设置用户列表为“允许”还是“禁止”操作
|max_clients=0	                                        |最大客户端连接数，0为不限制
|max_per_ip=0	                                        |同一IP地址的最大连接数，0为不限制
|anonymous_enable=[YES|NO]	                        |是否允许匿名用户访问
|anon_upload_enable=[YES|NO]	                        |是否允许匿名用户上传文件
|anon_umask=022	                                        |匿名用户上传文件的umask值
|anon_root=/var/ftp	                                |匿名用户的FTP根目录
|anon_mkdir_write_enable=[YES|NO]	                |是否允许匿名用户创建目录
|anon_other_write_enable=[YES|NO]	                |是否开放匿名用户的其他写入权限（包括重命名、删除等操作权限）
|anon_max_rate=0	                                |匿名用户的最大传输速率（字节/秒），0为不限制
|local_enable=[YES|NO]	                                |是否允许本地用户登录FTP
|local_umask=022	                                |本地用户上传文件的umask值
|local_root=/var/ftp	                                |本地用户的FTP根目录
|chroot_local_user=[YES|NO]	                        |是否将用户权限禁锢在FTP目录，以确保安全
|local_max_rate=0	                                |本地用户最大传输速率（字节/秒），0为不限制

- vsftpd的三种认证模式
        1. 匿名开放模式：是最不安全的一种认证模式，任何人都可以无须密码验证而直接登录到FTP服务器。
        2. 本地用户模式：是通过Linux系统本地的账户密码信息进行认证的模式，相较于匿名开放模式更安全，而且配置起来也很简单。但是如果黑客破解了账户的信息，就可以畅通无阻地登录FTP服务器，从而完全控制整台服务器。
        3. 虚拟用户模式：更安全的一种认证模式，它需要为FTP服务单独建立用户数据库文件，虚拟出用来进行密码验证的账户信息，而这些账户信息在服务器系统中实际上是不存在的，仅供FTP服务程序进行认证使用。这样，即使黑客破解了账户信息也无法登录服务器，从而有效降低了破坏范围和影响。
- ftp客户端

- 匿名开放模式
  - 表11-2 向匿名用户开放的权限参数以及作用

|参数	                        |作用
|--|--|
|anonymous_enable=YES	        |允许匿名访问模式
|anon_umask=022	                |匿名用户上传文件的umask值
|anon_upload_enable=YES	        |允许匿名用户上传文件
|anon_mkdir_write_enable=YES	|允许匿名用户创建目录
|anon_other_write_enable=YES	|允许匿名用户修改目录名称或删除目录

```bash
[root@linuxprobe ~]# vim /etc/vsftpd/vsftpd.conf
  1 anonymous_enable=YES
  2 anon_umask=022
  3 anon_upload_enable=YES
  4 anon_mkdir_write_enable=YES
  5 anon_other_write_enable=YES
  6 local_enable=YES
  7 write_enable=YES
  8 local_umask=022
  9 dirmessage_enable=YES
 10 xferlog_enable=YES
 11 connect_from_port_20=YES
 12 xferlog_std_format=YES
 13 listen=NO
 14 listen_ipv6=YES
 15 pam_service_name=vsftpd
 16 userlist_enable=YES
[root@linuxprobe ~]# systemctl restart vsftpd
[root@linuxprobe ~]# systemctl enable vsftpd
[root@linuxprobe ~]# setsebool -P ftpd_full_access=on
```

- 本地用户模式
  - 表11-3 本地用户模式使用的权限参数以及作用

|参数	                |作用
|--|--|
|anonymous_enable=NO	|禁止匿名访问模式
|local_enable=YES	|允许本地用户模式
|write_enable=YES	|设置可写权限
|local_umask=022	|本地用户模式创建文件的umask值
|userlist_deny=YES	|启用“禁止用户名单”，名单文件为ftpusers和user_list
|userlist_enable=YES	|开启用户作用名单文件功能
```bash
[root@linuxprobe ~]# vim /etc/vsftpd/vsftpd.conf
  1 anonymous_enable=NO
  2 local_enable=YES
  3 write_enable=YES
  4 local_umask=022
  5 dirmessage_enable=YES
  6 xferlog_enable=YES
  7 connect_from_port_20=YES
  8 xferlog_std_format=YES
  9 listen=NO
 10 listen_ipv6=YES
 11 pam_service_name=vsftpd
 12 userlist_enable=YES
[root@linuxprobe ~]# systemctl restart vsftpd
[root@linuxprobe ~]# systemctl enable vsftpd
[root@linuxprobe ~]# cat /etc/vsftpd/user_list 
#root  黑名单模式（默认userlist_deny=yes）下将要登陆的账号注释掉才能登录成功
[root@linuxprobe ~]# cat /etc/vsftpd/ftpusers 
#root
[root@linuxprobe ~]# ftp 192.168.10.10
Connected to 192.168.10.10 (192.168.10.10).
220 (vsFTPd 3.0.3)
Name (192.168.10.10:root): root
331 Please specify the password.
Password:此处输入该用户的密码
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp>
```

- 虚拟用户模式
  1. 重新安装vsftpd服务。创建用于进行FTP认证的用户数据库文件，其中奇数行为账户名，偶数行为密码。例如，分别创建zhangsan和lisi两个用户，密码均为redhat：
```bash
[root@linuxprobe ~]# cd /etc/vsftpd/
[root@linuxprobe vsftpd]# vim vuser.list
zhangsan
redhat
lisi
redhat
```
由于明文信息既不安全，也不符合让vsftpd服务程序直接加载的格式，因此需要使用db_load命令用哈希（hash）算法将原始的明文信息文件转换成数据库文件，并且降低数据库文件的权限（避免其他人看到数据库文件的内容），然后再把原始的明文信息文件删除。
```bash
[root@linuxprobe vsftpd]# db_load -T -t hash -f vuser.list vuser.db
[root@linuxprobe vsftpd]# chmod 600 vuser.db
[root@linuxprobe vsftpd]# rm -f vuser.list
```
  2. 创建vsftpd服务程序用于存储文件的根目录以及用于虚拟用户映射的系统本地用户。vsftpd服务用于存储文件的根目录指的是，当虚拟用户登录后所访问的默认位置。
```bash
[root@linuxprobe ~]# useradd -d /var/ftproot -s /sbin/nologin virtual
[root@linuxprobe ~]# ls -ld /var/ftproot/
drwx------. 3 virtual virtual 74 Jul 14 17:50 /var/ftproot/
[root@linuxprobe ~]# chmod -Rf 755 /var/ftproot/
```
  3. 建立用于支持虚拟用户的PAM文件。

新建一个用于虚拟用户认证的PAM文件vsftpd.vu，其中PAM文件内的“db=”参数为使用db_load命令生成的账户密码数据库文件的路径，但不用写数据库文件的后缀：
```bash
[root@linuxprobe ~]# vim /etc/pam.d/vsftpd.vu
auth       required     pam_userdb.so db=/etc/vsftpd/vuser
account    required     pam_userdb.so db=/etc/vsftpd/vuser
```
  4. 在vsftpd服务程序的主配置文件中通过pam_service_name参数将PAM认证文件的名称修改为vsftpd.vu。PAM作为应用程序层与鉴别模块层的连接纽带，可以让应用程序根据需求灵活地在自身插入所需的鉴别功能模块。当应用程序需要PAM认证时，则需要在应用程序中定义负责认证的PAM配置文件，实现所需的认证功能。
   例如，在vsftpd服务程序的主配置文件中默认就带有参数pam_service_name=vsftpd，表示登录FTP服务器时是根据/etc/pam.d/vsftpd文件进行安全认证的。现在我们要做的就是把vsftpd主配置文件中原有的PAM认证文件vsftpd修改为新建的vsftpd.vu文件即可。该操作中用到的参数以及作用如表11-4所示。

  - 表11-4 利用PAM文件进行认证时使用的参数以及作用

|参数	                        |作用
|--|--|
|anonymous_enable=NO	        |禁止匿名开放模式
|local_enable=YES	        |允许本地用户模式
|guest_enable=YES	        |开启虚拟用户模式
|guest_username=virtual	        |指定虚拟用户账户
|pam_service_name=vsftpd.vu	|指定PAM文件
|allow_writeable_chroot=YES	|允许对禁锢的FTP根目录执行写入操作，而且不拒绝用户的登录请求
```bash
[root@linuxprobe ~]# vim /etc/vsftpd/vsftpd.conf  
  1 anonymous_enable=NO
  2 local_enable=YES
  3 write_enable=YES
  4 guest_enable=YES
  5 guest_username=virtual
  6 allow_writeable_chroot=YES
  7 local_umask=022
  8 dirmessage_enable=YES
  9 xferlog_enable=YES
 10 connect_from_port_20=YES
 11 xferlog_std_format=YES
 12 listen=NO
 13 listen_ipv6=YES
 14 pam_service_name=vsftpd.vu
 15 userlist_enable=YES
```

  5. 为虚拟用户设置不同的权限。虽然账户zhangsan和lisi都是用于vsftpd服务程序认证的虚拟账户，但是我们依然想对这两人进行区别对待。比如，允许张三上传、创建、修改、查看、删除文件，只允许李四查看文件。这可以通过vsftpd服务程序来实现。只需新建一个目录，在里面分别创建两个以zhangsan和lisi命名的文件，其中在名为zhangsan的文件中写入允许的相关权限（使用匿名用户的参数）：
```bash
[root@linuxprobe ~]# mkdir /etc/vsftpd/vusers_dir/
[root@linuxprobe ~]# cd /etc/vsftpd/vusers_dir/
[root@linuxprobe vusers_dir]# touch lisi
[root@linuxprobe vusers_dir]# vim zhangsan
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
```

然后再次修改vsftpd主配置文件，通过添加user_config_dir参数来定义这两个虚拟用户不同权限的配置文件所存放的路径。为了让修改后的参数立即生效，需要重启vsftpd服务程序并将该服务添加到开机启动项中：

```bash
[root@linuxprobe ~]# vim /etc/vsftpd/vsftpd.conf
  1 anonymous_enable=NO
  2 local_enable=YES
  3 write_enable=YES
  4 guest_enable=YES
  5 guest_username=virtual
  6 allow_writeable_chroot=YES
  7 local_umask=022
  8 dirmessage_enable=YES
  9 xferlog_enable=YES
 10 connect_from_port_20=YES
 11 xferlog_std_format=YES
 12 listen=NO
 13 listen_ipv6=YES
 14 pam_service_name=vsftpd.vu
 15 userlist_enable=YES
 16 user_config_dir=/etc/vsftpd/vusers_dir     ⬅   here
[root@linuxprobe ~]# systemctl restart vsftpd
[root@linuxprobe ~]# systemctl enable vsftpd
Created symlink /etc/systemd/system/multi-user.target.wants/vsftpd.service → /usr/lib/systemd/system/vsftpd.service.
[root@linuxprobe ~]# setsebool -P ftpd_full_access=on
```

使用不同的方式登录文件传输服务器后，默认所在的位置，如表11-5所示。

- 表11-5 vsftpd服务程序登陆后所在目录

|登录方式	|默认目录
|--|--|
|匿名公开	|/var/ftp
|本地用户	|该用户的家目录
|虚拟用户	|对应映射用户的家目录

### TFTP简单文件传输协议
因为TFTP不需要客户端的权限认证，也就减少了无谓的系统和网络带宽消耗，因此在传输琐碎（trivial）不大的文件时，效率更高。tftp-server是服务程序，tftp是用于连接测试的客户端工具，xinetd是管理服务

```bash
[root@linuxprobe ~]# dnf install tftp-server tftp xinetd
[root@linuxprobe ~]# vim /etc/xinetd.d/tftp
service tftp
{
        socket_type             = dgram
        protocol                = udp
        wait                    = yes
        user                    = root
        server                  = /usr/sbin/in.tftpd
        server_args             = -s /var/lib/tftpboot
        disable                 = no
        per_source              = 11
        cps                     = 100 2
        flags                   = IPv4
}
[root@linuxprobe ~]# systemctl restart tftp
[root@linuxprobe ~]# systemctl enable tftp
[root@linuxprobe ~]# systemctl restart xinetd
[root@linuxprobe ~]# systemctl enable xinetd
[root@linuxprobe ~]# firewall-cmd --zone=public --permanent --add-port=69/udp
success
[root@linuxprobe ~]# firewall-cmd --reload 
success
```

- 表11-6 tftp命令中可用的参数以及作用

|参数	        |作用
|--|--|
|?	        |帮助信息
|put	        |上传文件
|get	        |下载文件
|verbose	|显示详细的处理信息
|status	        |显示当前的状态信息
|binary	        |使用二进制进行传输
|ascii	        |使用ASCII码进行传输
|timeout	|设置重传的超时时间
|quit           |退出

```bash
[root@linuxprobe ~]# echo "i love linux" > /var/lib/tftpboot/readme.txt
[root@linuxprobe ~]# tftp 192.168.10.10
tftp> get readme.txt
tftp> quit
[root@linuxprobe ~]# ls
anaconda-ks.cfg  Documents  initial-setup-ks.cfg  Pictures  readme.txt  Videos
Desktop          Downloads  Music                 Public    Templates
[root@linuxprobe ~]# cat readme.txt 
i love linux
```

## 8.使用samba/NFS实现文件共享
### samba文件共享服务
1. 安装samba服务程序
```bash
[root@www ~]# yum -y install samba samba-client
```

2. 配置文件/etc/samba/smb.conf

   - 表12-1 Samba服务程序中的参数以及作用

|行数	|参数	|作用
|--|--|--|
|1	|# See smb.conf.example for a more detailed config file or	|注释信息
|2	|# read the smb.conf manpage.	 
|3	|# Run 'testparm' to verify the config is correct after	 
|4	|# you modified it.	 
|5	|[global]	                |全局参数        
|6	|workgroup = SAMBA	        |工作组名称
|7	| 	        |
|8	|security = user	        |安全验证的方式，总共有4种
|9	| 	        |
|10	|passdb backend = tdbsam        |定义用户后台的类型，总共有3种
|11	| 	        |
|12	|printing = cups	        |打印服务协议
|13	|printcap name = cups	        |打印服务名称
|14	|load printers = yes	        |是否加载打印机
|15	|cups options = raw	        |打印机的选项
|16	| 	        |
|17	|[homes]	                |共享名称
|18	|comment = Home Directories	|描述信息
|19	|valid users = %S, %D%w%S	|可用账户
|20	|browseable = No	        |指定共享信息是否在“网上邻居”中可见
|21	|read only = No	                |是否只读
|22	|inherit acls = Yes	        |是否继承访问控制列表
|23	| 	 |
|24	|[printers]	共享名称|
|25	|comment = All Printers	        |描述信息
|26	|path = /var/tmp	        |共享路径
|27	|printable = Yes	        |是否可打印
|28	|create mask = 0600	        |文件权限
|29	|browseable = No	        |指定共享信息是否在“网上邻居”中可见
|30	| 	 |
|31	|[print$]	共享名称|
|32	|comment = Printer Drivers	|描述信息
|33	|path = /var/lib/samba/drivers	|共享路径
|34	|write list = @printadmin root	|可写入文件的用户列表
|35	|force group = @printadmin	|用户组列表
|36	|create mask = 0664	        |文件权限
|37	|directory mask = 0775	        |目录权限

在上面的代码中，security参数代表用户登录Samba服务时采用的验证方式。总共有4种可用参数。

> share：代表主机无须验证密码。这相当于vsftpd服务的匿名公开访问模式，比较方便，但安全性很差。

> user：代表登录Samba服务时需要使用账号密码进行验证，通过后才能获取到文件。这是默认的验证方式，最为常用。
> 
> domain：代表通过域控制器进行身份验证，用来限制用户的来源域。
> 
> server：代表使用独立主机验证来访用户提供的密码。这相当于集中管理账号，并不常用。 


- 配置共享

- 表12-2 用于设置Samba服务程序的参数以及作用

|参数	                                                |作用
|--|--|
|[database]	                                        |共享名称为database
|comment = Do not arbitrarily modify the database file	|警告用户不要随意修改数据库
|path = /home/database	                                |共享目录为/home/database
|public = no	                                        |关闭“所有人可见”                        
|writable = yes	                                        |允许写入操作

1. 配置
```bash
[root@www ~]# pdbedit -a -u minayao
#创建共享账户（账户需要是本地存在的用户）
[root@www ~]# mkdir /home/database
#创建共享资源的文件目录
[root@www ~]# chown -Rf minayao:minayao /home/database
#改权限
[root@www ~]# semanage fcontext -a -t samba_share_t /home/database
#改安全上下文
[root@www ~]# restorecon -Rv /home/database
#让安全上下文立即生效
[root@www ~]# setsebool -P samba_enable_home_dirs on
#更改selinux域策略放行家目录共享
[root@www ~]# vim /etc/samba/smb.conf
[global]
        workgroup = SAMBA
        security = user
        passdb backend = tdbsam
[database]
        comment = Do not arbitrarily modify the database file
        path = /home/database
        public = no
        writable = yes
#修改配置文件，最后重启服务
\\192.168.10.10   windos挂载共享
[root@www ~]# smbclient -U minayao -L 192.168.10.10
#查看当前共享了哪些文件
```
2. 挂载 
```bash
[root@www ~]# yum -y install cifs-utils
#Linux支持文件共享的软件包
[root@www ~]# mkdir /database
#创建挂载点
[root@www ~]# mount -t cifs -o username=minayao,password=aaaa //192.168.10.10/database /database
#挂载
```

3. 自动加载共享
```bash
[root@www ~]# vim auth.smb
username=minayao
password=aaaa
domain=MYGROUP
[root@www ~]# chmod 600 auth.smb


[root@www ~]# vim /etc/fstab
//192.168.10.10/database /database      cifs    credentials=/root/auth.smb 0 0
```
 

### NFS网络文件系统
1. 安装nfs
```bash
[root@www ~]# yum -y install nfs-utils.x86_64
```

2. 放行防火墙
```bash
[root@www ~]# firewall-cmd --permanent --zone=public --add-service=rpc-bind 
success
[root@www ~]# firewall-cmd --permanent --zone=public --add-service=nfs
success
[root@www ~]# firewall-cmd --permanent --zone=public --add-service=mountd 
success
[root@www ~]# firewall-cmd --reload 
success
```

3. 创建共享目录和文件
```bash
[root@www ~]# mkdir /nfsfile
[root@www ~]# chmod -R 777 /nfsfile
[root@www ~]# echo "welcome to.192.168.10.10" > /nfsfile/readme.md
```

4. 编辑nfs主配置文件/etc/exports

表12-7 用于配置NFS服务程序配置文件的参数

|参数	        |作用
|--|--|
|ro	        |只读
|rw	        |读写
|root_squash	|当NFS客户端以root管理员访问时，映射为NFS服务器的匿名用户
|no_root_squash	|当NFS客户端以root管理员访问时，映射为NFS服务器的root管理员
|all_squash	|无论NFS客户端使用什么账户访问，均映射为NFS服务器的匿名用户
|sync	        |同时将数据写入到内存与硬盘中，保证不丢失数据
|async	        |优先将数据保存到内存，然后再写入硬盘；这样效率更高，但可能会丢失数据

```bash
[root@www ~]# vim /etc/exports
/nfsfile 192.168.10.*(rw,sync,root_squash)
```
 

5. 重启服务
```bash
[root@www ~]# systemctl restart nfs-server.service 
[root@www ~]# systemctl enable --now nfs-server.service 
Created symlink from /etc/systemd/system/multi-user.target.wants/nfs-server.service to /usr/lib/systemd/system/nfs-server.service.
[root@www ~]# systemctl restart rpcbind
[root@www ~]# systemctl enable --now rpcbind  （远程过程调用）
```

6. showmount 查看NFS服务器的远程共享信息

表12-8 showmount命令中可用的参数以及作用

|参数	|作用
|--|--|
|-e	|显示NFS服务器的共享列表
|-a	|显示本机挂载的文件资源的情况NFS资源的情况
|-v	|显示版本号
```bash
[root@www ~]# showmount -e 192.168.10.10
Export list for 192.168.10.10:
/nfsfile 192.168.10.*
```

7. 在客户端创建挂载点并挂载
```bash
[root@www ~]# mkdir /nfsfile
[root@www ~]# mount -t nfs 192.168.10.10:/nfsfile /nfsfile
```


 

### autofs自动挂载
1. 安装autofs

yum -y install autofs

2. 编辑配置文件/etc/auto.master和/etc/auto.misc

/misc /etc/auto.misc

nfsfile 192.168.10.10:/nfsfile

3. 创建挂载目录

mkdir /misc/nfsfile

4. 重启autofs

5. 进入挂载目录自动挂载

## 9.使用bind提供域名解析服务
### DNS域名解析服务
DNS技术作为互联网基础设施中重要的一环，为了为网民提供不间断、稳定且快速的域名查询服务，保证互联网的正常运转，提供了下面3种类型的服务器。

> 主服务器：在特定区域内具有唯一性，负责维护该区域内的域名与IP地址之间的对应关系。
> 
> 从服务器：从主服务器中获得域名与IP地址的对应关系并进行维护，以防主服务器宕机等情况。
> 
> 缓存服务器：通过向其他域名解析服务器查询获得域名与IP地址的对应关系，并将经常查询的域名信息保存到服务器本地，以此来提高重复查询时的效率。

### 安装Bind服务程序

- [root@192 ~]# yum -y install bind-chroot.x86_64

- 在bind服务程序中有下面这3个比较关键的文件。

> 主配置文件（/etc/named.conf）：只有59行，而且在去除注释信息和空行之后，实际有效的参数仅有30行左右，这些参数用来定义bind服务程序的运行。
> 
> 区域配置文件（/etc/named.rfc1912.zones）：用来保存域名和IP地址对应关系的所在位置。类似于图书的目录，对应着每个域和相应IP地址所在的具体位置，当需要查看或修改时，可根据这个位置找到相关文件。
> 
> 数据配置文件目录（/var/named）：该目录用来保存域名和IP地址真实对应关系的数据配置文件。
> 

- 编辑主配置文件/etc/named.conf
```bash
#服务器上的所有IP地址均可提供DNS域名解析服务，以及允许所有人对本服务器发送DNS查询请求
      listen-on port 53 { any; };
      allow-query     { any; };
```

#### 正向解析（域名->IP）
- 编辑区域配置文件
```bash
zone "www.minayao10.com" IN {
        type master;
        file "www.minayao10.com.zone";
        allow-update {none;};
};
```
- 编辑数据配置文件/var/named/minayao.com.zone
```bash
$TTL 1D
@       IN SOA  minayao.com. root.minayao.com. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      ns.minayao10.com.
ns      IN A    192.168.1.10
www     IN A    192.168.1.10
        AAAA    ::1
```
```bash
$TTL 1D 	#生存周期为1天 				
@ 	IN SOA 	linuxprobe.com. 	root.linuxprobe.com. 	( 	
	#授权信息开始: 	#DNS区域的地址 	#域名管理员的邮箱(不要用@符号) 	
				0;serial 	#更新序列号
				1D;refresh 	#更新时间
				1H;retry 	#重试延时
				1W;expire 	#失效时间
				3H );minimum 	#无效解析记录的缓存时间
	NS 	ns.linuxprobe.com. 	#域名服务器记录
ns 	IN A 	192.168.10.10 	#地址记录(ns.linuxprobe.com.)
www 	IN A 	192.168.10.10 	#地址记录(www.linuxprobe.com.)
```

- 将网卡DNS地址参数改成本机IP，nmcli重启，并重启named服务

- nslookup确认服务器信息是否为“Address: 192.168.10.10#53”，即由本地服务器192.168.10.10的53端口号进行解析；若不是，则重启网络后再试一下。

#### 反向解析（IP->域名）
- 区域配置文件/etc/named.rfc1912.zones
```bash
zone "1.168.192.in-addr.arpa" IN {
        type master;
        file "192.168.1.arpa"
        allow-update {none;};
};
```

- 数据配置文件/var/named/192.168.1.arpa
```bash
$TTL 1D
@       IN SOA  minayo.com.     root.minayao.com. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      ns.minayao.com.
        A       192.168.1.10
        AAAA    ::1
10      PTR     ns.minayao.com.
10      PTR     www.minayao.com.
20      PTR     bbs.minayao.com.
注：PTR为指针记录，仅用于反向解析中，nslookup命令用于检测能否从DNS服务器中查询到域名与IP地址的解析记录
```

### 部署从服务器
通过部署从服务器不仅可以减轻主服务器的负载压力，还可以提升用户的查询效率。

1. 修改allow-update {192.168.1.20;}; IP为从服务器的IP，重启named

2. 防火墙放行dns
```bash
[root@minayao named]# iptables -F
[root@minayao named]# firewall-cmd --permanent --zone=public --add-service=dns
success
[root@minayao named]# firewall-cmd --reload 
success
[root@minayao named]# 
```

3. 在从服务器上安装bind-chroot，并修改主配置文件/etc/named.conf
```bash
listen-on port 53 { any; };
allow-query     { any; };
```

4. 在从服务器中填写主服务器的IP和抓取的区域信息，重启服务
```bash
[root@localhost ~]# vim /etc/named.rfc1912.zones 
zone "minayao.com" IN {
        type slave;
        masters { 192.168.1.10; };
        file "slaves/minayao.com.zone";
};
zone "1.168.192.in-addr.arpa" IN {
type slave;
masters { 192.168.1.10; };
file "slaves/192.168.1.arpa";
};
[root@localhost ~]# systemctl restart named
```

5. 检验，将从服务器的dns参数改成192.168.1.20（此处如果是DHCP分配的IP会出问题，可以新建连接，用nmcli手动配置连接的参数，）并up起来
```bash
[root@192 ~]# nmcli connection add con-name zidong type ethernet ifname ens32 
[root@192 ~]# nmcli connection modify zidong ipv4.method manual ipv4.addresses 192.168.1.20/24 ipv4.gateway 192.168.1.2 ipv4.dns 192.168.1.20 autoconnect yes
[root@192 ~]# nmcli connection up zidong 
[root@192 ~]# nslookup 
> www.baidu.com
Server:		192.168.1.20
Address:	192.168.1.20#53
Non-authoritative answer:
www.baidu.com	canonical name = www.a.shifen.com.
Name:	www.a.shifen.com
Address: 112.80.248.75
Name:	www.a.shifen.com
Address: 112.80.248.76
> www.minayao.com
Server:		192.168.1.20
Address:	192.168.1.20#53


Name:	www.minayao.com
Address: 192.168.1.10
```

---

### 安全的加密传输
2. 配置主服务器

- 生成DNS安全密钥
```bash
[root@localhost ~]# dnssec-keygen -a HMAC-MD5 -b 128 -n HOST master-slave
```

- 创建密钥验证文件transfer.key，写入密钥名称、加密算法、私钥字符等。更改权限、属组，设置硬链指向/etc/transfer.key
```bash
[root@localhost etc]# vim transfer.key 
key "master-slave" {
	algorithm hmac-md5;
	secret "M7E5DcFHZrOtXR+7qBpBeg==";
};
[root@localhost etc]# chown root:named transfer.key 
[root@localhost etc]# chmod 640 transfer.key 
[root@localhost etc]# ln transfer.key /etc/transfer.key 
```

- 配置主配置文件，开启bind服务的密钥验证功能
```bash
[root@localhost ~]# vim /etc/named.conf 
include "/etc/transfer.key";
option  添加      allow-transfer  { key master-slave; };
```

2. 配置从服务器

- 删除/var/named/slaves下的文件

- 创建密钥文件，并设置权限，同主服务器
```bash
[root@localhost etc]# vim transfer.key 
key "master-slave" {
	algorithm hmac-md5;
	secret "M7E5DcFHZrOtXR+7qBpBeg==";
};
[root@localhost etc]# chown root:named transfer.key 
[root@localhost etc]# chmod 640 transfer.key 
[root@localhost etc]# ln transfer.key /etc/transfer.key 
```

-  配置主配置文件/etc/named.conf
```bash
include "/etc/transfer.key";
server 192.168.1.10
{
        keys { master-slave; };
};
```

- 重启named服务，查看slaves下有数据文件了

3. 验证
```bash
[root@localhost slaves]# nslookup www.minayao.com
Server:		192.168.1.20
Address:	192.168.1.20#53
Name:	www.minayao.com
Address: 192.168.1.10


[root@localhost slaves]# nslookup 192.168.1.10
Server:		192.168.1.20
Address:	192.168.1.20#53


10.1.168.192.in-addr.arpa	name = www.minayao.com.
10.1.168.192.in-addr.arpa	name = ns.minayao.com.


[root@localhost slaves]# nslookup 192.168.1.20
Server:		192.168.1.20
Address:	192.168.1.20#53


20.1.168.192.in-addr.arpa	name = bbs.minayao.com.
```


### 部署缓存服务器
```bash
cat /etc/named.conf

forwarders	{ 114.114.114.114; };
systemctl restart named
将客户端网络dns参数设置成缓存服务器的地址
```
!!!分离解析技术
 

## 10.使用DHCP动态管理主机地址
### 部署dhcpd服务程序
- 安装
```bash
[root@www ~]# yum -y install dhcp
```
- 编辑配置文件/etc/dhcp/dhcpd.conf
  - 表14-1 dhcpd服务程序配置文件中使用的常见参数以及作用

|参数	|作用
|--|--|
|ddns-update-style 类型	                |定义DNS服务动态更新的类型，类型包括： none（不支持动态更新）、interim（互动更新模式）与ad-hoc（特殊更新模式）
|allow/ignore client-updates	        |允许/忽略客户端更新DNS记录
|default-lease-time 21600	        |默认超时时间
|max-lease-time 43200	最大超时时间|
|option domain-name-servers 8.8.8.8	|定义DNS服务器地址
|option domain-name "domain.org"	        |定义DNS域名
|range	                                |定义用于分配的IP地址池
|option subnet-mask	                |定义客户端的子网掩码
|option routers	                        |定义客户端的网关地址
|broadcast-address 广播地址	        |定义客户端的广播地址
|ntp-server IP地址	                |定义客户端的网络时间服务器（NTP）
|nis-servers IP地址	                |定义客户端的NIS域服务器的地址
|hardware 硬件类型 MAC地址	        |指定网卡接口的类型与MAC地址
|server-name 主机名	                |向DHCP客户端通知DHCP服务器的主机名
|fixed-address IP地址	                |将某个固定的IP地址分配给指定主机
|time-offset 偏移差	                |指定客户端与格林尼治时间的偏移差
 

### 自动管理IP地址
服务端
```bash
# DHCP Server Configuration file.
#   see /usr/share/doc/dhcp*/dhcpd.conf.example
#   see dhcpd.conf(5) man page
#
ddns-update-style none;
ignore client-updates;
subnet 192.168.1.0 netmask 255.255.255.0 {
range 192.168.1.50 192.168.1.150;
option subnet-mask 255.255.255.0;
option routers 192.168.1.10;
option domain-name "www.minayao10.com";
option domain-name-servers 192.168.1.10;
default-lease-time 21600;
max-lease-time 43200;
}
```

客户端
```bash
TYPE="Ethernet"
BOOTPROTO="dhcp"
ONBOOT="yes"
```

- 表14-4 dhcpd服务程序配置文件中使用的参数以及作用

|参数	|作用
|--|--|
|ddns-update-style none;	                |设置DNS服务不自动进行动态更新
|ignore client-updates;	忽略客户端更新DNS记录|
|subnet 192.168.10.0 netmask 255.255.255.0 {	|作用域为192.168.10.0/24网段
|range 192.168.10.50 192.168.10.150;	        |IP地址池为192.168.10.50-150（约100个IP地址）
|option subnet-mask 255.255.255.0;	        |定义客户端默认的子网掩码
|option routers 192.168.10.1;	                |定义客户端的网关地址
|option domain-name "linuxprobe.com";	        |定义默认的搜索域
|option domain-name-servers 192.168.10.1;	|定义客户端的DNS地址
|default-lease-time 21600;	                |定义默认租约时间（单位：秒）
|max-lease-time 43200;	                        |定义最大预约时间（单位：秒）
|}	|结束符
```bash
[root@192 ~]# systemctl restart dhcpd
[root@192 ~]# systemctl enable --now dhcpd
[root@192 ~]# firewall-cmd --permanent --zone=public --add-service=dhcp
[root@192 ~]# firewall-cmd --reload 
```

### 分配固定IP地址
```bash
# DHCP Server Configuration file.
#   see /usr/share/doc/dhcp*/dhcpd.conf.example
#   see dhcpd.conf(5) man page
#
ddns-update-style none;
ignore client-updates;
subnet 192.168.1.0 netmask 255.255.255.0 {
range 192.168.1.50 192.168.1.150;
option subnet-mask 255.255.255.0;
option routers 192.168.1.10;
option domain-name "www.minayao10.com";
option domain-name-servers 192.168.1.10;
default-lease-time 21600;
max-lease-time 43200;
host www.minayao10.com {
hardware ethernet 00:0c:29:76:8b:a0;
fixed-address 192.168.1.100;
}
}
```
 

## 11.使用Postfix与Dovecot部署邮件系统
### 电子邮件系统
电子邮件系统基于邮件协议来完成电子邮件的传输，常见的邮件协议有下面这些。

> 简单邮件传输协议（Simple Mail Transfer Protocol，SMTP）：用于发送和中转发出的电子邮件，占用服务器的TCP/25端口。
> 
> 邮局协议版本3（Post Office Protocol 3）：用于将电子邮件存储到本地主机，占用服务器的TCP/110端口。
> 
> Internet消息访问协议版本4（Internet Message Access Protocol 4）：用于在本地主机上访问邮件，占用服务器的TCP/143端口。

大家在生产环境中部署企业级的电子邮件系统时，有4个注意事项请留意。

> 添加反垃圾与反病毒模块：它能够很有效地阻止垃圾邮件或病毒邮件对企业信箱的干扰。
> 
> 对邮件加密：可有效保护邮件内容不被黑客盗取和篡改。
> 
> 添加邮件监控审核模块：可有效地监控企业全体员工的邮件中是否有敏感词，是否有透露企业资料等违规行为。
> 
> 保障稳定性：电子邮件系统的稳定性至关重要，运维人员应做到保证电子邮件系统的稳定运行，并及时做好防范分布式拒绝服务（Distributed Denial of Service，DDoS）攻击的准备。

### 部署基础的电子邮件系统
1. 配置服务器主机名，服务器主机名需要和发信域名保持一致

2. 清空防火墙，允许DNS协议

3. 为电子邮件系统提供域名解析（bind-chroot）

```bash
1.主配置文件/etc/named.conf
options {
	listen-on port 53 { any; };    ⬅here
	listen-on-v6 port 53 { ::1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	recursing-file  "/var/named/data/named.recursing";
	secroots-file   "/var/named/data/named.secroots";
	allow-query     { any; };	⬅here

2.区域配置文件/etc/named.rfc1912.zones
  zone "minayao.com" IN {
  	type master;
  	file "minayao.com.zone";
  	allow-update { none; };
  };
3.域名数据文件/var/named/minayao.com.zone
$TTL 1D
@	IN SOA	minayao.com. root.minayao.com. (
					0	; serial
					1D	; refresh
					1H	; retry
					1W	; expire
					3H )	; minimum
	NS	ns.minayao.com.
ns	IN A    192.168.10.10
@	IN MX 10	mail.minayao.com.
mail	IN A	192.168.10.10
4.重启bind（named）
5.尝试ping mail.minayao.com,若能解析地址则正确
```

#### 配置Postfix服务程序
1. 安装postfix
```bash
[root@mail ~]# yum -y install postfix.x86_64
```
2. 配置postfix服务

Postfix服务程序主配置文件中的重要参数

|参数	|作用
|--|--|
|myhostname	        |邮局系统的主机名
|mydomain	        |邮局系统的域名
|myorigin	        |从本机发出邮件的域名名称
|inet_interfaces	|监听的网卡接口
|mydestination	        |可接收邮件的主机名或域名
|mynetworks	        |设置可转发哪些主机的邮件
|relay_domains	        |设置可转发哪些网域的邮件

```bash
[root@mail ~]# vim /etc/postfix/main.cf 
myhostname = mail.minayao.com
mydomain = minayao.com
myorigin = $mydomain
inet_interfaces = all
mydestination = $myhostname, $mydomain
```

3. 创建邮件系统登录账户
```bash
[root@mail ~]# useradd gm
[root@mail ~]# echo qqqq | passwd --stdin gm
[root@mail ~]# systemctl restart postfix.service 
[root@mail ~]# systemctl enable --now postfix.service 
[root@mail ~]# systemctl status postfix.service 
```

#### 配置Dovecot服务程序
1. 安装dovecot
```bash
[root@mail ~]# yum -y install dovecot.x86_64
```

2. 配置部署Dovecot服务程序
```bash
[root@mail ~]# vim /etc/dovecot/dovecot.conf 
protocols = imap pop3 lmtp
disable_plaintext_auth = no
login_trusted_networks = 192.168.10.10/24
```
3. 配置邮件格式与存储路径
```bash
[root@mail ~]# vim /etc/dovecot/conf.d/10-mail.conf 
mail_location = mbox:~/mail:INBOX=/var/mail/%u
[root@mail ~]# su - gm
[gm@mail ~]#  mkdir -p mail/.imap/INBOX
[root@mail ~]# systemctl restart dovecot
[root@mail ~]# systemctl enable --now dovecot
```

#### 客户使用电子邮件新系统
1. 配置IP在同一网段，DNS为邮件系统的IP

2. 使用客户端(如outlook、thunderbird等)
```bash
#1.安装thunderbird
yum -y install thunderbird
```
3. 查看邮件mailx

### 设置用户别名邮箱
 

## 12.使用ISCSI服务部署网络存储
### 无人值守安装系统
1. 安装配置dhcp
```bash
[root@192 yum.repos.d]# yum -y install dhcp
[root@192 yum.repos.d]# vim /etc/dhcp/dhcpd.conf
allow booting;
allow bootp;
ddns-update-style none;
ignore client-updates;
subnet 192.168.10.0 netmask 255.255.255.0 {
        option subnet-mask                 255.255.255.0;
        option domain-name-servers         192.168.10.10;
        range dynamic-bootp 192.168.10.100 192.168.10.200;
        default-lease-time                 21600;
        max-lease-time                     43200;
        next-server                        192.168.10.10;
        filename                           "pxelinux.0";
}
```
2. 安装TFTP并配置
```bash
# 安装
[root@192 yum.repos.d]# yum -y install tftp-server xinetd
# 配置开启TFTP服务程序
[root@192 yum.repos.d]# vim /etc/xinetd.d/tftp
# default: off
# description: The tftp server serves files using the trivial file transfer \
#	protocol.  The tftp protocol is often used to boot diskless \
#	workstations, download configuration files to network-aware printers, \
#	and to start the installation process for some operating systems.
service tftp
{
	socket_type		= dgram
	protocol		= udp
	wait			= yes
	user			= root
	server			= /usr/sbin/in.tftpd
	server_args		= -s /var/lib/tftpboot
	#disable			= yes
	disable			= no
	per_source		= 11
	cps			= 100 2
	flags			= IPv4
}
```

3. 配置syslinux服务程序
```bash
# 安装
[root@192 yum.repos.d]# yum -y install syslinux
# 配置
```
updating......................