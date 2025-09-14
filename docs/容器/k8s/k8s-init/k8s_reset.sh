#!/bin/bash
echo "⚠️  正在删除 Kubernetes 集群..."

sudo kubeadm reset -f
sudo systemctl stop kubelet containerd
sudo systemctl disable kubelet containerd

sudo rm -rf /etc/kubernetes/ \
           /var/lib/kubelet/ \
           /var/lib/etcd/ \
           /var/lib/cni/ \
           /etc/cni/net.d/ \
           ~/.kube/

sudo ip link delete cni0 2>/dev/null || true
sudo ip link delete flannel.1 2>/dev/null || true

echo "✅ Kubernetes 集群已删除。建议重启系统。"