
#! /bin/bash

set -e  # 遇错退出

deploy_log=deploy.log
kube_config_file=kubeadm-config.yaml
net_config_file=kube-flannel.yml
#sudo kubeadm init --kubernetes-version=1.32.8 --apiserver-advertise-address=192.168.10.80 --image-repository=harbor.kris.local/k8s --pod-network-cidr="10.244.0.0/16" --service-cidr="10.96.0.0/12" --ignore-preflight-errors=Swap --cri-socket=unix:///run/containerd/containerd.sock

# 定义颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
timestamp=$(date +"%Y%m%d_%H%M%S")

log_info() {
    echo -e "${GREEN}[${timestamp}] [INFO] $1${NC}" | tee -a $deploy_log
}

log_warn() {
    echo -e "${YELLOW}[${timestamp}] [WARN] $1${NC}" | tee -a $deploy_log
}

log_error() {
    echo -e "${RED}[${timestamp}] [ERROR] $1${NC}" | tee -a $deploy_log
}

# 清理旧的 Kubernetes 配置
log_info "清理旧的 Kubernetes 配置..." 
sudo kubeadm reset -f
rm -rf ~/.kube


log_info "初始化 Kubernetes 集群..." 
log_info "初始化 Kubernetes 集群..." 
sudo systemctl start kubelet containerd
sudo kubeadm init --config $kube_config_file | tee -a $deploy_log
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

log_info "部署网络插件..." 
kubectl apply -f $net_config_file | tee -a $deploy_log

sudo kubeadm init phase upload-certs --upload-certs | tee -a $deploy_log

hosts="./hosts"
while read -r host; do
    if [[ -n "$host" ]]; then
        log_info "正在同步配置到节点 $host ..."
        rsync -av --delete $HOME/.kube/config $host:$HOME/.kube/
    fi
done < "$hosts"
log_info "Kubernetes 集群初始化完成！"
log_info "集群配置文件已复制到 $HOME/.kube/config" 
log_info "网络插件已部署"
log_info "部署日志已保存到 $deploy_log" 
log_info "查看集群状态: kubectl get nodes" 
log_info "查看所有 Pod: kubectl get pods --all-namespaces" 
log_info "查看加入集群命令和证书密钥: sudo cat $deploy_log | grep 'kubeadm join' -A 2" | grep -v '^\['