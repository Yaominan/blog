#!/bin/bash
# save-k8s-arm64-images.sh

REGISTRY="registry.aliyuncs.com/google_containers"

images=(
  "kube-apiserver:v1.30.4"
  "kube-controller-manager:v1.30.4"
  "kube-scheduler:v1.30.4"
  "kube-proxy:v1.30.4"
  "etcd:3.5.12-0"
  "coredns:v1.10.1"
  "pause:3.9"
)

echo "正在拉取 ARM64 镜像..."
for img in "${images[@]}"; do
  docker pull ${REGISTRY}/${img}
  docker tag ${REGISTRY}/${img} registry.k8s.io/${img}
done

echo "正在拉取 Calico ARM64 镜像..."
docker pull calico/cni:v3.27.3
docker pull calico/node:v3.27.3
docker pull calico/kube-controllers:v3.27.3

echo "导出镜像为 tar 包..."
docker save -o k8s-arm64-images.tar \
  $(echo "${images[@]}" | xargs -I {} echo "registry.k8s.io/{}") \
  calico/cni:v3.27.3 \
  calico/node:v3.27.3 \
  calico/kube-controllers:v3.27.3

echo "ARM64 镜像准备完成！"