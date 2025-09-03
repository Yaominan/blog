# nginx部署、负载均衡、反向代理、高可用

## 1.nginx部署方式
1. 源码安装
```
# 编译前准备
Nginx是高度自由化的Web服务器，它的功能是由许多模块来支持。如果使用了某个模块，这个模块使用了一些类似zlib或OpenSSL等的第三方库，那么就必须先安装这些软件。centOS中使用yum直接在线安装，可以使用以下方法。

（1）PCRE库

PCRE库支持正则表达式。如果我们在配置文件nginx.conf中使用了正则表达式，那么在编译Nginx时就必须把PCRE库编译进Nginx，因为Nginx的HTTP模块需要靠它来解析正则表达式。另外，pcre-devel是使用PCRE做二次开发时所需要的开发库，包括头文件等，这也是编译Nginx所必须使用的。

(2）zlib库  
zlib库用于对HTTP包的内容做gzip格式的压缩，如果我们在nginx.conf中配置了gzip on，并指定对于某些类型（content-type）的HTTP响应使用gzip来进行压缩以减少网络传输量，则在编译时就必须把zlib编译进Nginx。zlib-devel是二次开发所需要的库。

（3）OpenSSL库  
如果服务器不只是要支持HTTP，还需要在更安全的SSL协议上传输HTTP，那么需要拥有OpenSSL。另外，如果我们想使用MD5、SHA1等散列函数，那么也需要安装它。
```
> 官方文档:https://nginx.org/en/docs/configure.html
```bash
# 安装nginx软件常见必要依赖
yum install -y pcre pcre-devel openssl openssl-devel zlib zlib-devel gcc gcc-c++

# 创建nginx用户，用来运行nginx软件
groupadd -g 666 nginx
useradd -u 666 -g nginx -s /bin/false -M nginx
# 根据需求，需要开哪些模块，编译时就选哪些模块

```
1. 官方yum源安装
```bash
[root@slave2 yum.repos.d]# cat nginx.repo 
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
```

## 2.nginx配置多虚拟主机（updating。。。）
1. 基于多IP的虚拟主机配置
2. 基于多端口的虚拟主机配置
3. 基于多域名的虚拟主机配置

## 3.nginx日志配置
1. 全局日志配置
2. 单站点日志配置独立的访问日志，按业务分类
3. 错误日志配置
4. 日志添加nginx内置变量

> [nginx官方文档: https://nginx.org/en/docs/](https://nginx.org/en/docs/)
> 
> [nginx七层负载均衡方案参考：https://cloud.tencent.com/developer/article/2122754](https://cloud.tencent.com/developer/article/2122754)

## 4.nginx配置反向代理
```bash
# 以下是一个示例配置，用于将请求反向代理到本地的 8080 端口：
http {
    server {
        listen 80;
        server_name localhost; # 你的域名
        location / {
            proxy_pass http://127.0.0.1:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}


# location /：表示匹配所有 URI 的 location 块。就是说，这个 location 块会处理所有发送到 Nginx 服务器的请求，不管 URI 是什么。

# location 是 Nginx 配置中的一个关键指令，用于根据请求的 URI 来进行相应的处理请求。

# 以下是一些常见的 location 使用示例：
#1. location /: 匹配所有请求，包括根路径（例如 http://yourserver.com/）。
#2. location /api/: 匹配以 /api/ 开头的所有请求，包括/api/（例如 http://yourserver.com/api/users）。
#3. location /static/: 匹配以 /static/ 开头的所有请求（例如 http://yourserver.com/static/css/style.css）。
#4. location ~* \.(jpg|jpeg|png)$: 匹配所有以 .jpg, .jpeg, 或 .png 结尾的请求，无论它们位于哪个路径下。
#5. location = /path 精准匹配，只匹配/path这个请求路径

```

```bash
http {
    server {
        listen 80;

        location /api/ {
            proxy_pass http://127.0.0.1:8000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        location /static/ {
            proxy_pass http://127.0.0.1:8001;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        location / {
            proxy_pass http://127.0.0.1:8002;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}

#注意：Nginx 会按照配置文件中 location 块的顺序进行匹配，一旦找到匹配的 location，就会停止查找。因此，你应该将最特殊的 location（例如，以特定前缀开始的路径）放在最上面，将最通用的 location（例如，用于匹配所有其他请求的路径）放在最下面。
```


## 5.nginx配置负载均衡(upstream)
1. 热备backup
```bash
# 热备：如果你有2台服务器，当一台服务器发生事故时，才启用第二台服务器给提供服务。服务器处理请求的顺序：AAAAAA突然A挂啦，BBBBBBBBBBBBBB.....

upstream mysvr { 
    server 127.0.0.1:7878; 
    server 192.168.10.121:3333 backup;  #热备     
}
```
2. 轮询
```bash
# 轮询：nginx默认就是轮询其权重都默认为1，服务器处理请求的顺序：ABABABABAB....

upstream mysvr { 
    server 127.0.0.1:7878;
    server 192.168.10.121:3333;       
}
```
3. 加权轮询
```bash
# 加权轮询：跟据配置的权重的大小而分发给不同服务器不同数量的请求。如果不设置，则默认为1。下面服务器的请求顺序为：ABBABBABBABBABB....

upstream mysvr { 
    server 127.0.0.1:7878 weight=1;
    server 192.168.10.121:3333 weight=2;
}
```
4. ip_hash
```bash
# ip_hash:nginx会让相同的客户端ip请求相同的服务器。

upstream mysvr { 
    server 127.0.0.1:7878; 
    server 192.168.10.121:3333;
    ip_hash;
}
```

```bash
# 以下是基于容器的测试
[root@slave2 html]# docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS         PORTS                                   NAMES
5fc8360b894c   nginx:latest   "/docker-entrypoint.…"   5 minutes ago    Up 5 minutes   0.0.0.0:8083->80/tcp, :::8083->80/tcp   nginx3
cfd27f5fd247   nginx:latest   "/docker-entrypoint.…"   26 minutes ago   Up 6 seconds   0.0.0.0:8081->80/tcp, :::8081->80/tcp   nginx1
95b734505a19   nginx:latest   "/docker-entrypoint.…"   26 minutes ago   Up 6 seconds   0.0.0.0:8082->80/tcp, :::8082->80/tcp   nginx2

[root@slave2 html]# cat /etc/nginx/conf.d/prox.conf 
# 开启负载均衡
upstream my_server {
    server 127.0.0.1:8081 weight=1;
    server 127.0.0.1:8082 weight=3;
    server 127.0.0.1:8083 backup;
}

server {
    listen 80;
    server_name my_server;

    location / {
	root /usr/share/nginx/html;
	index index.html;
	proxy_pass http://my_server; 
        proxy_set_header   Host             $host;
        proxy_set_header   X-Real-IP        $remote_addr;
        proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
}
}

```
> 当访问该站点时(局域网IP是192.168.10.100),刷新页面4次，先出现82页面，共出现3次，然后出现一次81页面，然后依次循环!
> 82：
> ![Screenshot](image/Pasted image 20250325111110.png)
> 81：
> ![Screenshot](image/Pasted image 20250325110813.png)
> 当将容器nginx1停掉时，刷新页面，只有82，nginx1和nginx2都停掉时，才会显示 83：
```bash
[root@slave2 html]# docker stop nginx1 nginx2
nginx1
nginx2
[root@slave2 html]# docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                                   NAMES
5fc8360b894c   nginx:latest   "/docker-entrypoint.…"   16 minutes ago   Up 16 minutes   0.0.0.0:8083->80/tcp, :::8083->80/tcp   nginx3
```
> ![Screenshot](image/Pasted image 20250325111421.png)
当开启了ip_hash和权重时，浏览器指挥访问权重最高的那台服务器;如果只设置了ip_hash,没有设置权重，则默认访问最开始访问的那台服务器
```bash
[root@slave2 html]# cat /etc/nginx/conf.d/prox.conf 
# 开启负载均衡
upstream my_server {
    server 127.0.0.1:8081 weight=1;
    server 127.0.0.1:8082 weight=3;
    server 127.0.0.1:8083;
    ip_hash;  
}

server {
    listen 80;
    server_name my_server;

    location / {
		root /usr/share/nginx/html;
		index index.html;
		proxy_pass http://my_server; 
		proxy_set_header   Host             $host;
		proxy_set_header   X-Real-IP        $remote_addr;
		proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
}
}
```

```
关于nginx负载均衡配置的几个状态参数讲解。

- down，表示当前的server暂时不参与负载均衡。
    
- backup，预留的备份机器。当其他所有的非backup机器出现故障或者忙的时候，才会请求backup机器，因此这台机器的压力最轻。
    
- max_fails，允许请求失败的次数，默认为1。当超过最大次数时，返回proxy_next_upstream 模块定义的错误。
    
- fail_timeout，在经历了max_fails次失败后，暂停服务的时间。max_fails可以和fail_timeout一起使用。
	
- least_conn, 该策略会将请求分配到连接数最少的服务上。
```
5. 第三方策略
```
Nginx支持集成第三方的策略插件。

比如：

fair：此种算法可以依据页面大小和加载时间长短智能地进行负载均衡，即响应时间短的优先分配。比上面更加智能的负载均衡算法。下载安装 Nginx的upstream_fair模块。
url_hash：按访问 url的 hash结果来分配请求，使每个url定向到同一个后端服务器，可以进一步提高后端缓存服务器的效率。下载安装 Nginx 的hash软件包。
```


```

高可用keepalive



# Tengine
> 淘宝基于nginx开发的高性能web服务器，能抗更高并发
> https://tengine.taobao.org/document/install.html

```

## 6.nginx + keepalived
### keepalived
keepalived 相关配置查看：[keepalived](./keepalived.md)

### keepalived配置nginx重启
1. 增加nginx重启脚本
```bash
vim /etc/keepalived/check_nginx_alive_or_not.sh

#!/bin/bash

A=`ps -C nginx --no-header |wc -l`
# 判断nginx是否宕机，如果宕机了，尝试重启
if [ $A -eq 0 ];then
    /usr/local/nginx/sbin/nginx
    # 等待一小会再次检查nginx，如果没有启动成功，则停止keepalived，使其启动备用机
    sleep 3
    if [ `ps -C nginx --no-header |wc -l` -eq 0 ];then
		killall keepalived
    fi
fi

# 增加执行权限
chmod +x /etc/keepalived/check_nginx_alive_or_not.sh

```

2. 在 keepalived.conf 配置定时监听 nginx 状态脚本
```bash
vrrp_script check_nginx_alive {
    script "/etc/keepalived/check_nginx_alive_or_not.sh"
    interval 2 # 每隔两秒运行上一行脚本
    weight 10 # 如果脚本运行成功，则升级权重+10
    # weight -10 # 如果脚本运行失败，则升级权重-10
}

```

3. 在vrrp_instance中新增监控的脚本
```bash
    track_script {
        check_nginx_alive   # 追踪 nginx 脚本
    }

```