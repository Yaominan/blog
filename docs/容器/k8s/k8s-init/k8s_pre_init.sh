#!/bin/bash
#================================================================================================
#   简介: Kubernetes 集群节点前期准备脚本
#   功能: 关闭防火墙、安装工具、配置 containerd、安装 kubeadm/kubelet/kubectl、配置时间同步等
#   说明: 适用于 Ubuntu 20.04+ 和 CentOS 7（ubuntu 测试成功，centos 还没测）
#   作者: Kris
#   日期: 2025-09-06
#================================================================================================

set -e  # 遇错退出

# 定义颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO] $1${NC}"  | tee -a $deploy_log
}

log_warn() {
    echo -e "${YELLOW}[WARN] $1${NC}" | tee -a $deploy_log
}

log_error() {
    echo -e "${RED}[ERROR] $1${NC}"  | tee -a $deploy_log
}


#=======================================
# 0. 检测操作系统
#=======================================
log_info "检测操作系统..."
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
else
    echo "无法识别操作系统！"
    exit 1
fi

log_info "检测到系统: $OS $VER"



#=======================================
# 1. 关闭防火墙、SELinux、Swap
#=======================================
log_info "关闭防火墙、SELinux 和 Swap..."

# 关闭防火墙（CentOS/RHEL）
if [[ "$OS" == "centos" || "$OS" == "rhel" ]]; then
    log_info "正在关闭 firewalld 防火墙..."
    sudo systemctl disable firewalld --now 2>/dev/null || true
    sudo systemctl stop firewalld 2>/dev/null || true
fi

# 关闭 UFW（Ubuntu）
if [[ "$OS" == "ubuntu" ]]; then
    log_info "正在关闭 UFW 防火墙..."
    sudo systemctl disable ufw --now 2>/dev/null || true
    sudo ufw disable 2>/dev/null || true
fi

# 关闭 SELinux
if command -v getenforce &> /dev/null; then
    log_info "正在设置 SELinux 为宽松模式..."
    sudo setenforce 0 2>/dev/null || true
    sudo sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config 2>/dev/null || true
fi

# 关闭 Swap
log_info "正在关闭 Swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

log_info "防火墙、SELinux、Swap 已关闭"


#=======================================
# 2. 安装基础依赖工具
#=======================================
log_info "安装基础工具..."

case $OS in
    "centos"|"rhel")
        yum update -y
        yum install -y epel-release
        yum install -y curl wget vim net-tools lsof telnet iproute-tc \
                      ca-certificates curl gnupg lsb-release
        ;;
    "ubuntu")
        sudo apt update
        sudo apt upgrade -y
        sudo apt install -y curl wget vim net-tools lsof telnet iproute2 ca-certificates gnupg lsb-release
        ;;
    *)
        log_error "不支持的操作系统: $OS"
        exit 1
        ;;
esac

log_info "基础工具安装完成"


#=======================================
# 3. 加载内核模块并配置内核参数
#=======================================
log_info "配置内核模块和 sysctl 参数..."

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf > /dev/null
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Sysctl 参数
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf > /dev/null
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system
log_info "内核参数配置完成"




#=======================================
# 5. 添加 Kubernetes 官方源并安装 kubeadm/kubelet/kubectl
#=======================================
log_info "添加 Kubernetes 源并安装 kubeadm、kubelet、kubectl..."

# 添加 GPG 密钥
# sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# 添加 APT/YUM 源
case $OS in
    "centos"|"rhel")
        cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo > /dev/null
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-key.gpg
exclude=kube*
EOF

        # 安装 kubelet、kubeadm、kubectl
        yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
        ;;

    "ubuntu")
        sudo mkdir -p /etc/apt/keyrings && sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
        sudo apt-get update
        sudo apt-get install -y kubelet=1.32.8-1.1 kubeadm=1.32.8-1.1 kubectl=1.32.8-1.1
        sudo apt-mark hold kubelet kubeadm kubectl
        ;;
esac

# 启用并启动 kubelet
sudo systemctl enable kubelet --now

log_info "kubeadm、kubelet、kubectl 安装完成"


#=======================================
# 4. 安装 Containerd（推荐容器运行时）
#=======================================
log_info "安装 Containerd..."

# 安装最新版本的 docker-ce 和 containerd


# k8sv=`kubelet --version | awk -F"v" '{print $NF}'`
# k8s_version=${k8s_version:-$k8sv}

# k8s_images=(`kubeadm config images list --kubernetes-version=$k8s_version` | awk '{sub(/[^\/]+\//, "");print}')
# mapfile -t k8s_images < <(sudo kubeadm config images list --kubernetes-version="$k8s_version" | awk '{sub(/[^/]+\//, ""); print}')

case $OS in
    "centos"|"rhel")
        yum install -y yum-utils
        yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
        sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
        sudo systemctl start containerd 
        sudo systemctl enable containerd --now

        ;;
    "ubuntu")
        sudo curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        # Step 3: 写入软件源信息
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
          "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
        ;;
esac

# 创建目录
sudo mkdir -p /etc/containerd

# # 使用官方脚本安装 containerd
# curl -fsSL https://get.containerd.io | sh

# 生成默认配置
# containerd config default > /etc/containerd/config.toml

# 修改配置：使用 systemd cgroup、镜像加速（可选）
sed -i "s/SystemdCgroup = false/SystemdCgroup = true/" config.toml
# 加载变量
. ./images
# 替换基础镜像
sed -i "s|^\\s*\(sandbox_image\\s*=\\s*\\).*|\1\"${sandbox_image}\"|" config.toml

# 配置镜像加速
sed -i "s|registry.k8s.io|${registry}|g" config.toml
sudo cp config.toml /etc/containerd/config.toml

# 启动 containerd
sudo systemctl enable containerd --now
sudo systemctl restart containerd


log_info "Containerd 安装并启动成功"


#=======================================
# 6. 配置 crictl（可选，用于调试 containerd）
#=======================================
log_info "配置 crictl 工具..."

cat <<EOF | sudo tee /etc/crictl.yaml > /dev/null
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF

log_info "crictl 配置完成"


#=======================================
# 7. 时间同步（NTP）
#=======================================
log_info "配置时间同步..."

case $OS in
    "centos"|"rhel")
        sudo yum install -y chrony
        sudo systemctl enable chronyd --now
        ;;
    "ubuntu")
        sudo apt install -y chrony
        sudo systemctl enable chrony --now
        ;;
esac
log_info "启用时间同步..."
sudo timedatectl set-ntp true
log_info "时间同步已启用"


#=======================================
# 8. 完成提示
#=======================================
log_info "Kubernetes 前期准备已完成！"
log_info "请在所有节点执行此脚本。"
log_info "接下来可在主节点执行：kubeadm init ..."
log_info "Worker 节点加入命令将在主节点初始化后生成。"

echo
log_info "✅ 准备工作全部完成！${NC}"
echo