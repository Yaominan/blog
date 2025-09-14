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
[***如何安装docker及部署私有仓库***](../docker/harbor.md)

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

#安装 kubelet kubeadm kubectl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet=1.32.8-1.1 kubeadm=1.32.8-1.1 kubectl=1.32.8-1.1
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

#### 配置 crictl
```bash
sudo touch /etc/crictl.yaml
sudo 

crictl config \
  runtime-endpoint unix:///run/containerd/containerd.sock \
  image-endpoint unix:///run/containerd/containerd.sock \
  timeout 10 \
  debug false
```



#### k8s环境初始化
```bash
#使用配置文件初始化集群，初始化时需要把配置文件中的注释全部删除避免报错
sudo kubeadm init --config kubeadm-config.yaml 

# kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.10.80
  bindPort: 6443
nodeRegistration:
  criSocket: unix:///run/containerd/containerd.sock
  name: master1

---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
kubernetesVersion: v1.32.8
clusterName: kris
controlPlaneEndpoint: "192.168.10.200:6443"
networking:
#pod子网需要和你的集群的宿主机的 IP 同网段
  podSubnet: "192.168.0.0/16"
  serviceSubnet: "10.96.0.0/12"
  dnsDomain: "cluster.local"
imageRepository: harbor.kris.local/k8s
certificatesDir: /etc/kubernetes/pki

etcd:
  local:
    dataDir: /var/lib/etcd
    serverCertSANs:
      - "192.168.10.80"
      - "127.0.0.1"
      - "localhost"
    peerCertSANs:
      - "192.168.10.80"

apiServer:
  certSANs:
    - "192.168.10.200"
    - "192.168.10.80"
    - "192.168.10.90"
    - "192.168.10.100"
    - "localhost"
    - "127.0.0.1"
    - "k8s-api.internal"
    - "::1"

---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
clusterDNS:
  - 10.96.0.10
clusterDomain: cluster.local
resolvConf: "/run/systemd/resolve/resolv.conf"

---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: iptables

-------------------------------------------------------
# flannel 配置文件：kube-flannel.yml
# 下载最新的 flannel 配置文件
wget https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
# 修改网络和镜像相关配置，net-conf.json中的 Network 需要改成和 kubeadm 配置中 podSubnet一样，image 改成阿里云的镜像或者自己的私有镜像仓库
kris@master1:~/kubelet$ grep image:  kube-flannel.yml
        image: harbor.kris.local/k8s/flannel:v0.27.3
        image: harbor.kris.local/k8s/flannel-cni-plugin:v1.7.1-flannel1
        image: harbor.kris.local/k8s/flannel:v0.27.3
kris@master1:~/kubelet$ grep -A 10 net-conf  kube-flannel.yml
  net-conf.json: |
    {
      "Network": "192.168.0.0/16",
      "EnableNFTables": false,
      "Backend": {
        "Type": "vxlan"
      }
    }
kind: ConfigMap
metadata:
  labels:


#使用参数初始化集群
sudo kubeadm init --kubernetes-version=1.32.8 --apiserver-advertise-address=192.168.10.80 --image-repository=harbor.kris.local/k8s --pod-network-cidr="192.168.0.0/16" --service-cidr="10.96.0.0/12" --ignore-preflight-errors=Swap --cri-socket=unix:///run/containerd/containerd.sock


##加入新的 master 节点
sudo kubeadm join 192.168.10.200:6443 --token pxpwdu.em5s28kpqjsq7rwi \
--discovery-token-ca-cert-hash sha256:90021e60622f7ae9431dbb71248279edab995be52f91a94632487b442061cda8 \
--control-plane \
--certificate-key 8ae9065ca0c43d5ccd5882bb28017db4a0e0173b55968e5af2fe767ed655c6db

#证书过期时重新生成证书并上传,替换 certificate-key
sudo kubeadm init phase upload-certs --upload-certs

# 加入worker节点
sudo kubeadm join 192.168.10.200:6443 --token pxpwdu.em5s28kpqjsq7rwi \
--discovery-token-ca-cert-hash sha256:90021e60622f7ae9431dbb71248279edab995be52f91a94632487b442061cda8
# 如果忘了加入集群的命令，使用以下命令重新生成
kubeadm token create --print-join-command


  ```