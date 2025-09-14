#!/bin/bash
# push-k8s-arm64-images.sh

REGISTRY="registry.aliyuncs.com/google_containers"
harbor=harbor.kris.local
NAMESPACE="k8s"
calico_namespace="calico"

k8sv=`kubelet --version | awk -F"v" '{print $NF}'`
k8s_version=${k8s_version:-$k8sv}

# k8s_images=(`kubeadm config images list --kubernetes-version=$k8s_version` | awk '{sub(/[^\/]+\//, "");print}')
mapfile -t k8s_images < <(kubeadm config images list --kubernetes-version="$k8s_version" | awk '{sub(/[^/]+\//, ""); print}')


calico_images=(
  "cni:v3.27.3"
  "node:v3.27.3"
  "kube-controllers:v3.27.3"
)

echo "正在拉取并推送 Kubernetes ARM64 镜像..."
for img in "${k8s_images[@]}"; do
  docker pull ${REGISTRY}/${img}
  docker tag ${REGISTRY}/${img} ${harbor}/${NAMESPACE}/${img}
  docker push ${harbor}/${NAMESPACE}/${img}
  echo "已推送: ${harbor}/${NAMESPACE}/${img}"
done

echo "正在拉取并推送 Calico ARM64 镜像..."

# 拉取Calico镜像
for img in "${calico_images[@]}"; do
  docker pull ${calico_namespace}/${img}
  docker tag ${calico_namespace}/${img} ${harbor}/${calico_namespace}/${img}
  docker push ${harbor}/${calico_namespace}/${img}
  echo "已推送: ${harbor}/${calico_namespace}/${img}"
done

echo "所有镜像已成功推送到 Harbor 仓库！"
echo "推送的镜像列表:"

# 列出所有推送的Kubernetes镜像
echo "Kubernetes 镜像:"
for img in "${k8s_images[@]}"; do
  echo "- ${harbor}/${NAMESPACE}/${img}"
done

echo "Calico 镜像:"

for img in "${calico_images[@]}"; do
  echo "- ${harbor}/${calico_namespace}/${img}"
done


echo "ARM64 镜像推送完成！"