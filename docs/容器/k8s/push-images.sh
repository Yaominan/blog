#!/bin/bash
# save-k8s-arm64-images.sh

REGISTRY="registry.aliyuncs.com/google_containers"

k8s_version=`kubelet --version | awk -F"v" '{print $NF}'`

k8s_images=(kubeadm config images list --kubernetes-version=$k8s_version | awk -F'/' '{print $NF}')

echo "正在拉取 ARM64 镜像..."
for img in "${k8s_images[@]}"; do
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