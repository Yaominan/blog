# 部署k8s

## k8s 安装

### 准备条件

```bash
# 禁用交换分区
swapoff -a
# 永久禁用，打开/etc/fstab注释掉swap那一行。  
sudo vim /etc/fstab
# 修改内核参数(首先确认你的系统已经加载了 br_netfilter 模块，默认是没有该模块的，需要你先安装 bridge-utils)
apt-get install -y bridge-utils
modprobe br_netfilter
lsmod | grep br_netfilter
# 如果报错找不到包，需要先更新 apt-get update -y
            
```

### 安装k8s
```bash
> [官方文档:https://kubernetes.io/zh-cn/docs/tasks/tools/install-kubectl-linux/](https://kubernetes.io/zh-cn/docs/tasks/tools/install-kubectl-linux/)

#下载
curl -LO https://dl.k8s.io/release/v1.32.0/bin/linux/arm64/kubectl
#验证
curl -LO "https://dl.k8s.io/release/v1.32.0/bin/linux/arm64/kubectl.sha256"

echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

#安装 kubectl：
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

执行测试，以保障你安装的版本是最新的：

kubectl version --client
或者使用如下命令来查看版本的详细信息：

kubectl version --client --output=yaml


# 配置 kubectl 命令行补全
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
sudo chmod a+r /etc/bash_completion.d/kubectl
source ~/.bashrc
```

#### 安装 containerd

```bash
 for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

- 关于如何安装 docker，另一篇文章有详细的教程：
[***如何安装docker及部署私有仓库***](../docker/harbor.md/#安装docker)

- 加载内核模块，配置内核参数

```bash
# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
# 配置 systemd cgroup 驱动 
containerd config default > config.toml
sudo mv config.toml /etc/containerd/config.toml 

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# 启用集群负载
sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg_bak
sudo vim /etc/haproxy/haproxy.cfg


sudo systemctl enable --now haproxy
sudo systemctl start haproxy

# 启用并启动 keepalived
sudo systemctl enable --now keepalived
sudo systemctl start keepalived

```

#### 安装外部 etcd 集群

1. 安装 etcd
    ```bash
    ETCD_VER=v3.5.13
    ARCH=arm64
    sudo apt install golang-cfssl

    # 下载 ARM64 版本
    wget https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-${ARCH}.tar.gz

    # 解压并安装
    tar -xzf etcd-${ETCD_VER}-linux-${ARCH}.tar.gz
    cd etcd-${ETCD_VER}-linux-${ARCH}

    # 复制二进制文件到系统路径
    sudo cp etcd etcdctl /usr/local/bin/

    ```


2. 生成证书
    1. 创建证书目录
    ```bash
    mkdir -p ~/etcd-certs && cd ~/etcd-certs
    ```

    2. 生成 CA 配置
    ```bash
    cat > ca-config.json <<EOF
    {
    "signing": {
        "default": {
        "expiry": "87600h"
        },
        "profiles": {
        "etcd": {
            "usages": ["signing", "key encipherment", "server auth", "client auth"],
            "expiry": "87600h"
        }
        }
    }
    }
    EOF
    ```

    2. 生成 CA 证书请求
    ```bash
    cat > ca-csr.json <<EOF
    {
    "CN": "etcd",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
        "C": "CN",
        "L": "Beijing",
        "O": "etcd",
        "OU": "cluster"
        }
    ]
    }
    EOF
    ```

    3. 生成 CA 证书和私钥
    ```bash
    cfssl gencert -initca ca-csr.json | cfssljson -bare ca
    ```

    4. 生成 Server 证书（支持所有节点和 VIP）
    ```bash
    cat > server-csr.json <<EOF
    {
    "CN": "etcd",
    "hosts": [
        "127.0.0.1",
        "192.168.10.80",
        "192.168.10.90",
        "192.168.10.100",
        "192.168.10.200",  # VIP
        "master1",
        "master2",
        "master3"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
        "C": "CN",
        "L": "Beijing",
        "O": "etcd",
        "OU": "cluster"
        }
    ]
    }
    EOF
    ```

    5. 生成 Server 证书和私钥
    ```bash
    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=etcd server-csr.json | cfssljson -bare server
    ```

    6. 生成客户端证书（用于 etcdctl）
    ```bash
    cat > client-csr.json <<EOF
    {
    "CN": "etcd-client",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
        "C": "CN",
        "L": "Beijing",
        "O": "etcd",
        "OU": "cluster"
        }
    ]
    }
    EOF

    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=etcd client-csr.json | cfssljson -bare client
    ```

3. 分发证书到所有节点
```bash
# 从 master1 分发证书到其他节点
# 打包并发送到所有节点
for NODE in master1 master2 master3; do
    echo "Deploying certs to $NODE..."
    tar -cf - ca.pem server.pem server-key.pem client.pem client-key.pem | \
    ssh $NODE "sudo mkdir -p /etc/etcd/ssl && sudo tar -C /etc/etcd/ssl -xf -"
done

#设置权限
for NODE in master1 master2 master3; do
    ssh $NODE "sudo chown -R root:root /etc/etcd && sudo chmod -R 600 /etc/etcd/ssl/*"
done
```

4. 在每个节点上创建配置文件
```bash
# master1
sudo mkdir -p /etc/etcd /var/lib/etcd

cat << EOF | sudo tee /etc/etcd/etcd.conf
ETCD_NAME=etcd1
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_LISTEN_PEER_URLS="https://192.168.10.80:2380"
ETCD_LISTEN_CLIENT_URLS="https://192.168.10.80:2379,http://127.0.0.1:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.10.80:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.10.80:2379"
ETCD_INITIAL_CLUSTER="etcd1=https://192.168.10.80:2380,etcd2=https://192.168.10.90:2380,etcd3=https://192.168.10.100:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_CERT_FILE="/etc/etcd/ssl/server.pem"
ETCD_KEY_FILE="/etc/etcd/ssl/server-key.pem"
ETCD_CLIENT_CERT_AUTH="true"
ETCD_TRUSTED_CA_FILE="/etc/etcd/ssl/ca.pem"
ETCD_PEER_CERT_FILE="/etc/etcd/ssl/server.pem"
ETCD_PEER_KEY_FILE="/etc/etcd/ssl/server-key.pem"
ETCD_PEER_CLIENT_CERT_AUTH="true"
ETCD_PEER_TRUSTED_CA_FILE="/etc/etcd/ssl/ca.pem"
EOF

#master2

cat << EOF | sudo tee /etc/etcd/etcd.conf
ETCD_NAME=etcd2
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_LISTEN_PEER_URLS="https://192.168.10.90:2380"
ETCD_LISTEN_CLIENT_URLS="https://192.168.10.90:2379,http://127.0.0.1:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.10.90:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.10.90:2379"
ETCD_INITIAL_CLUSTER="etcd1=https://192.168.10.80:2380,etcd2=https://192.168.10.90:2380,etcd3=https://192.168.10.100:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_CERT_FILE="/etc/etcd/ssl/server.pem"
ETCD_KEY_FILE="/etc/etcd/ssl/server-key.pem"
ETCD_CLIENT_CERT_AUTH="true"
ETCD_TRUSTED_CA_FILE="/etc/etcd/ssl/ca.pem"
ETCD_PEER_CERT_FILE="/etc/etcd/ssl/server.pem"
ETCD_PEER_KEY_FILE="/etc/etcd/ssl/server-key.pem"
ETCD_PEER_CLIENT_CERT_AUTH="true"
ETCD_PEER_TRUSTED_CA_FILE="/etc/etcd/ssl/ca.pem"
EOF


#master3
cat << EOF | sudo tee /etc/etcd/etcd.conf
ETCD_NAME=etcd3
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_LISTEN_PEER_URLS="https://192.168.10.100:2380"
ETCD_LISTEN_CLIENT_URLS="https://192.168.10.100:2379,http://127.0.0.1:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.10.100:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.10.100:2379"
ETCD_INITIAL_CLUSTER="etcd1=https://192.168.10.80:2380,etcd2=https://192.168.10.90:2380,etcd3=https://192.168.10.100:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_CERT_FILE="/etc/etcd/ssl/server.pem"
ETCD_KEY_FILE="/etc/etcd/ssl/server-key.pem"
ETCD_CLIENT_CERT_AUTH="true"
ETCD_TRUSTED_CA_FILE="/etc/etcd/ssl/ca.pem"
ETCD_PEER_CERT_FILE="/etc/etcd/ssl/server.pem"
ETCD_PEER_KEY_FILE="/etc/etcd/ssl/server-key.pem"
ETCD_PEER_CLIENT_CERT_AUTH="true"
ETCD_PEER_TRUSTED_CA_FILE="/etc/etcd/ssl/ca.pem"
EOF
```

5. 创建 systemd 服务（所有节点）
```bash

sudo tee /etc/systemd/system/etcd.service << 'EOF'
[Unit]
Description=etcd
Documentation=https://github.com/etcd-io/etcd
After=network.target

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd --config-file=/etc/etcd/etcd.conf
Restart=always
RestartSec=10s
LimitNOFILE=65536
Environment=ETCD_UNSUPPORTED_ARCH=arm64

[Install]
WantedBy=multi-user.target
EOF
```

6. 启动 etcd 集群
```bash
#1. 启用所有节点的 etcd
# 所有节点执行
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd

#2. 查看日志
sudo journalctl -u etcd -f

#3. 验证集群状态
#在任意节点执行：
ETCDCTL_API=3 etcdctl \
  --endpoints=https://192.168.10.80:2379,https://192.168.10.90:2379,https://192.168.10.100:2379 \
  --cacert=/etc/etcd/ssl/ca.pem \
  --cert=/etc/etcd/ssl/client.pem \
  --key=/etc/etcd/ssl/client-key.pem \
  endpoint status --write-out=table

```

7. 解决报错，3.4 之后的版本要用 yaml 配置文件

```bash
###报错
===========================
kris@master1:~/etcd-certs$ sudo journalctl -u etcd -f
Sep 07 09:20:37 master1 systemd[1]: etcd.service: Main process exited, code=exited, status=1/FAILURE
Sep 07 09:20:37 master1 systemd[1]: etcd.service: Failed with result 'exit-code'.
Sep 07 09:20:37 master1 systemd[1]: Failed to start etcd.
Sep 07 09:20:47 master1 systemd[1]: etcd.service: Scheduled restart job, restart counter is at 3.
Sep 07 09:20:47 master1 systemd[1]: Stopped etcd.
Sep 07 09:20:47 master1 systemd[1]: Starting etcd...
Sep 07 09:20:47 master1 etcd[34123]: {"level":"info","ts":"2025-09-07T09:20:47.348675Z","caller":"etcdmain/etcd.go:73","msg":"Running: ","args":["/usr/local/bin/etcd","--config-file=/etc/etcd/etcd.conf"]}
Sep 07 09:20:47 master1 etcd[34123]: {"level":"warn","ts":"2025-09-07T09:20:47.349635Z","caller":"etcdmain/etcd.go:75","msg":"failed to verify flags","error":"error unmarshaling JSON: while decoding JSON: json: cannot unmarshal string into Go value of type embed.configYAML"}

==============================



=======================================
=======================================
# yaml配置文件
#master1
sudo tee /etc/etcd/etcd.conf.yml << 'EOF'
name: etcd1
data-dir: /var/lib/etcd
listen-peer-urls: https://192.168.10.80:2380
listen-client-urls: https://192.168.10.80:2379,http://127.0.0.1:2379
advertise-client-urls: https://192.168.10.80:2379
initial-advertise-peer-urls: https://192.168.10.80:2380
initial-cluster: etcd1=https://192.168.10.80:2380,etcd2=https://192.168.10.90:2380,etcd3=https://192.168.10.100:2380
initial-cluster-token: etcd-cluster
initial-cluster-state: new

# TLS 配置
cert-file: /etc/etcd/ssl/server.pem
key-file: /etc/etcd/ssl/server-key.pem
client-cert-auth: true
trusted-ca-file: /etc/etcd/ssl/ca.pem

peer-cert-file: /etc/etcd/ssl/server.pem
peer-key-file: /etc/etcd/ssl/server-key.pem
peer-client-cert-auth: true
peer-trusted-ca-file: /etc/etcd/ssl/ca.pem

# 快照
snapshot-count: 10000
EOF

#master2
sudo tee /etc/etcd/etcd.conf.yml << 'EOF'
name: etcd2
data-dir: /var/lib/etcd
listen-peer-urls: https://192.168.10.90:2380
listen-client-urls: https://192.168.10.90:2379,http://127.0.0.1:2379
advertise-client-urls: https://192.168.10.90:2379
initial-advertise-peer-urls: https://192.168.10.90:2380
initial-cluster: etcd1=https://192.168.10.80:2380,etcd2=https://192.168.10.90:2380,etcd3=https://192.168.10.100:2380
initial-cluster-token: etcd-cluster
initial-cluster-state: new

# TLS 配置
cert-file: /etc/etcd/ssl/server.pem
key-file: /etc/etcd/ssl/server-key.pem
client-cert-auth: true
trusted-ca-file: /etc/etcd/ssl/ca.pem

peer-cert-file: /etc/etcd/ssl/server.pem
peer-key-file: /etc/etcd/ssl/server-key.pem
peer-client-cert-auth: true
peer-trusted-ca-file: /etc/etcd/ssl/ca.pem

# 快照
snapshot-count: 10000
EOF

#master3
sudo tee /etc/etcd/etcd.conf.yml << 'EOF'
name: etcd3
data-dir: /var/lib/etcd
listen-peer-urls: https://192.168.10.100:2380
listen-client-urls: https://192.168.10.100:2379,http://127.0.0.1:2379
advertise-client-urls: https://192.168.10.100:2379
initial-advertise-peer-urls: https://192.168.10.100:2380
initial-cluster: etcd1=https://192.168.10.80:2380,etcd2=https://192.168.10.90:2380,etcd3=https://192.168.10.100:2380
initial-cluster-token: etcd-cluster
initial-cluster-state: new

# TLS 配置
cert-file: /etc/etcd/ssl/server.pem
key-file: /etc/etcd/ssl/server-key.pem
client-cert-auth: true
trusted-ca-file: /etc/etcd/ssl/ca.pem

peer-cert-file: /etc/etcd/ssl/server.pem
peer-key-file: /etc/etcd/ssl/server-key.pem
peer-client-cert-auth: true
peer-trusted-ca-file: /etc/etcd/ssl/ca.pem

# 快照
snapshot-count: 10000
EOF


# 创建 systemd 服务（所有节点）


sudo tee /etc/systemd/system/etcd.service << 'EOF'
[Unit]
Description=etcd
Documentation=https://github.com/etcd-io/etcd
After=network.target

[Service]
Type=notify
User=root
Group=root
ExecStart=/usr/local/bin/etcd --config-file=/etc/etcd/etcd.conf.yml
Restart=always
RestartSec=10s
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# 重启并验证
# 所有节点执行
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd

#2. 查看日志
sudo journalctl -u etcd -f
```

#### 
sudo kubeadm init --config kubeadm-config.yaml --ignore-preflight-errors=Port-6443

registry.aliyuncs.com/google_containers


```
# etcd 进程用到的 key（server-key.pem）
sudo chown etcd:etcd /etc/etcd/ssl/server-key.pem
sudo chmod 600 /etc/etcd/ssl/server-key.pem

# 客户端工具用到的 key（client-key.pem）
sudo chown root:root /etc/etcd/ssl/client-key.pem
sudo chmod 600 /etc/etcd/ssl/client-key.pem



# 1. 停止服务
sudo systemctl stop etcd

# 2. 删除 etcd 数据（关键！）
sudo rm -rf /var/lib/etcd/*

# 3. 确保目录存在
sudo mkdir -p /var/lib/etcd
sudo chown etcd:etcd /var/lib/etcd


# 使用 etcdctl 检查健康
sudo ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ssl/ca.pem \
  --cert=/etc/etcd/ssl/server.pem \
  --key=/etc/etcd/ssl/server-key.pem \
  endpoint health