# k8s部署流程

## 基础环境配置

### 主机名规划

### 内核调整

### 禁用交换分区

## 容器镜像准备

### 安装 docker（基于阿里云镜像源）
### harbor

## k8s集群初始化

### 更换软件源（阿里云镜像源）

### 安装软件(kubeadm,kubelet,kubectl)
- kubeadm: 集群管理
- kubelet：采集节点数据汇报给master
- kubectl：管理集群资源对象环境，master 节点专用，认证

### 镜像获取
```bash
#查看当前版本依赖哪些镜像
kris@master1:~/kubelet$ kubeadm config images list
I0913 06:42:37.041171  365605 version.go:261] remote version is much newer: v1.34.1; falling back to: stable-1.32
registry.k8s.io/kube-apiserver:v1.32.9
registry.k8s.io/kube-controller-manager:v1.32.9
registry.k8s.io/kube-scheduler:v1.32.9
registry.k8s.io/kube-proxy:v1.32.9
registry.k8s.io/coredns/coredns:v1.11.3
registry.k8s.io/pause:3.10
registry.k8s.io/etcd:3.5.16-0
```

### 主节点初始化

### 工作节点加入集群