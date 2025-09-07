# K8S面经

##  1. 什么是K8S？你如何理解它？
Kubernetes，简称K8S，是一个开源的容器编排平台，旨在自动化容器化应用的部署、扩展以及管理。它不仅让应用程序的部署变得简单和高效，还能自动处理许多繁琐的运维任务。K8S通过提供统一的机制，帮助开发者和运维人员更好地管理复杂的微服务架构。
通俗来说，K8S就像是一个智能化的“调度员”，它可以高效地管理应用从启动、扩展、更新到故障恢复的整个生命周期。

##  2. Kubernetes的组件及其作用是什么？
Kubernetes 由多个核心组件构成，主要分为 Master 节点和 Node 节点：

Master 节点：负责集群管理。
Kube-API-Server：集群的访问接口，负责处理 REST API 请求。
Kube-Controller-Manager：资源控制器，管理集群状态和自动化控制。
Kube-Scheduler：负责资源调度，将 Pod 分配到合适的 Node 节点上。
Etcd：分布式键值存储，用于保存集群的所有状态数据。
Node 节点：负责实际运行容器。
Kubelet：管理每个节点上的 Pod 生命周期，保证容器按要求运行。
Kube-Proxy：负责网络通信，提供 Service 的负载均衡和网络代理功能。
容器运行时：例如 Docker，用于实际运行容器。
##  3. Kubernetes中的基础概念有哪些？

Master：集群的控制节点，负责管理所有工作节点的调度和资源分配。
Node（Worker）：运行实际容器的节点，是 Kubernetes 中 Pod 的宿主机。
Pod：Kubernetes 中最小的部署单位，可以包含一个或多个容器。
Label：给对象贴标签，用于资源的筛选和调度。
Service：定义了 Pod 的逻辑组以及访问策略，是服务的抽象。
Namespace：用于实现资源隔离，帮助管理集群中的多租户环境。
##  4. Kubernetes与Docker的关系是什么？
Docker 是一种容器引擎，负责创建和运行容器，而 Kubernetes 则是容器编排工具，用来管理这些容器。可以说，Kubernetes 是对 Docker 的增强，它解决了单独使用 Docker 时在大规模容器集群中遇到的资源调度、自动扩展、容器健康检查等问题。

##  5. Kubernetes的集群管理是如何实现的？
Kubernetes 采用 Master-Node 架构。Master 负责管理整个集群，调度资源并监控集群健康状态。Node 则是工作节点，负责实际运行应用容器。在 Master 节点上运行的核心组件（如 Kube-API-Server、Kube-Scheduler、Kube-Controller-Manager）通过相互协作，自动化管理集群资源、调度 Pod、执行容器的自动化操作。

##  6. Kubernetes的优势和适用场景
优势：

支持多云环境和混合云部署。
提供自动化运维，如自动扩缩容和自我修复功能。
轻量化、弹性强，能够高效利用硬件资源。
适用场景：

大规模微服务架构。
高并发、动态扩展的应用程序。
容器化应用程序的持续集成和部署。
##  7. Kubernetes的不足之处是什么？

复杂性：初期学习曲线较高，安装配置过程复杂。
管理繁琐：大规模集群的运维管理需要较高的技术水平。
性能：在一些简单应用场景下，使用 Kubernetes 可能导致不必要的资源消耗。
##  8. 什么是 Minikube、Kubectl 和 Kubelet？

Minikube：在本地运行单节点 Kubernetes 集群的工具，适用于学习和开发测试。
Kubectl：Kubernetes 的命令行工具，用于管理和控制集群的资源和组件。
Kubelet：运行在每个 Node 节点上的服务，负责管理容器生命周期并与 Master 节点通信。
##  9. kubelet的核心功能是什么？
kubelet 是 Kubernetes 集群中的核心组件之一，负责执行以下关键任务：

节点管理：kubelet 定期向 Master 节点汇报资源使用情况，保障集群的资源调度。
Pod 管理：kubelet 通过调用容器运行时接口，负责在节点上创建、更新、删除 Pod。
健康检查：kubelet 定期检查容器的健康状态，通过探针决定是否重启容器。
资源监控：通过 Metrics Server 监控 Node 和 Pod 的资源使用情况，如 CPU、内存等。
##  10. kube-api-server的端口是什么？Pod如何访问它？
Kubernetes 的 API Server 通常使用以下端口：

8080：用于 HTTP 的 API 请求。
6443：用于 HTTPS 的 API 请求。
Pod 通过集群内部的 ClusterIP 服务访问 API Server，确保集群内的所有节点和 Pod 都可以通过安全的 HTTPS 端口与 API Server 交互。

## 11. kube-api-server的端口是什么？Pod如何访问它？

Kube-api-server默认监听在6443端口，Pod通过kube-proxy组件访问API server，kube-proxy负责在Pod内部为API server提供反向代理服务。

## 12. Pod的原理是什么？

在微服务架构中，通常每个容器只运行一个进程。为了将多个容器绑定在一起，并将它们作为一个单元进行管理，Kubernetes引入了Pod这一更高级的结构。Pod允许多个容器共享资源并协同工作，但不能跨多个节点运行。

## 13. Pod有什么特点？

每个Pod分配唯一的IP地址，并像独立的逻辑机器一样运行；
Pod可以包含1个或多个容器，通常每个容器运行一个进程；
一个Pod只能运行在单个节点上，其生命周期短暂；
每个Pod有一个“根容器” (pause容器) 负责管理其他业务容器；
Pod中的容器共享网络命名空间和IP；
端口冲突在同一个Pod内可能发生，不同Pod间不会；
Pod是Kubernetes中扩缩容的基本单位。
## 14. Pod的重启策略有哪些？

Pod的重启策略可以通过restartPolicy字段配置，主要有以下三种：

Always: 容器退出后总是重启，默认策略；
OnFailure: 容器异常退出时才重启；
Never: 容器终止后不重启。
## 15. Pod的镜像拉取策略有哪几种？

Pod的镜像拉取策略通过imagePullPolicy字段配置，有三种：

IfNotPresent: 仅在本地不存在镜像时才拉取，默认策略；
Always: 每次创建Pod时都从镜像仓库拉取镜像；
Never: 仅使用本地镜像，不会主动拉取。
## 16. Kubernetes针对Pod资源对象的健康监测机制？

Kubernetes通过三类探针来监测Pod健康：

livenessProbe（存活探针）：检测容器是否正常运行，不健康时会重启容器；
readinessProbe（就绪探针）：判断容器是否可以接收流量，不健康时Pod会被移出Service；
startupProbe（启动探针）：用于避免业务启动缓慢导致的探针失败。
## 17. 就绪探针与存活探针的区别是什么？

livenessProbe检查失败时，会重启容器，确保Pod持续运行；
readinessProbe检查失败时，不会重启容器，只是将Pod从Service中移除，确保流量只发送到健康的Pod。
## 18. 存活探针的属性参数有哪些？

initialDelaySeconds: 容器启动后延迟多少秒开始探测；
periodSeconds: 探测频率，默认10秒；
timeoutSeconds: 探测超时时间，默认1秒；
successThreshold: 连续探测成功的次数，默认1次；
failureThreshold: 连续探测失败的次数，默认3次。
## 19. Pod的就绪探针有哪几种？

Kubernetes提供三种探测容器就绪的方式：

httpGet: 通过HTTP请求探测健康状态；
exec: 在容器内部执行命令，返回状态码判断健康；
TCPSocket: 通过TCP Socket连接容器，判断探测成功与否。
## 20. Pod的就绪探针属性参数有哪些？

initialDelaySeconds: 容器启动后延迟多少秒开始探测；
periodSeconds: 探测的频率，默认10秒；
timeoutSeconds: 探测超时时间，默认1秒；
failureThreshold: 探测失败的连续次数；
successThreshold: 探测成功的连续次数。
##  21. 简单讲一下 pod创建过程
情况一、使用 kubectl run 命令创建的 pod：

注意：
kubectl run 在旧版本中创建的是 deployment，但在新的版本中创建的是 pod，其创建过程不涉及 deployment。如果是单独创建一个 pod，过程如下：

用户通过 kubectl 或其他 API 客户端工具提交需要创建的 pod 信息给 apiserver；
apiserver 验证用户权限信息，生成 pod 对象信息并存入 etcd，然后返回确认信息给客户端；
apiserver 将 etcd 中的 pod 对象变化反馈给其他组件，其他组件使用 watch 机制跟踪变动；
调度器 scheduler 发现有新的 pod 对象，调用算法为 pod 分配最佳主机，并将结果更新至 apiserver；
kubelet 通过 watch 机制跟踪到分配给本节点的 pod，调用 Docker 启动容器，并反馈结果给 apiserver；
apiserver 将 pod 状态信息存入 etcd，至此 pod 创建完毕。
情况二、使用 deployment 创建 pod：

用户通过 kubectl create 或 kubectl apply 提交创建 deployment 请求；
apiserver 处理请求，进行身份验证，并将 deployment 信息存入 etcd，返回确认信息给客户端；
apiserver 反馈 etcd 中对象的变化，其他组件使用 watch 机制跟踪变动；
controller-manager 监听到 deployment 的创建，生成 ReplicaSet，并由 ReplicaSet Controller 处理；
调度器 scheduler 通过内部算法为未调度的 pod 分配节点，并反馈结果给 apiserver；
kubelet 监听到本节点分配的 pod，创建 pod 并启动容器，最终将状态反馈至 apiserver；
Pod 创建成功后，ReplicaSet Controller 持续监控 pod 状态，确保副本数量与期望值一致。
##  22. Kubernetes创建pod的详细流程
客户端提交创建请求，可以通过 API Server 提供的 RESTful 接口，或使用 kubectl 命令；
API Server 处理请求，将 pod 信息存储至 etcd；
scheduler 监控到未绑定的 pod，执行节点分配（预选、优选两个阶段）；
将分配结果进行 pod 绑定操作，存储到 etcd；
kubelet 从 etcd 获取 pod 清单，下载镜像并启动容器。
##  23. 简单描述一下 pod 的终止过程
用户向 apiserver 发送删除 pod 命令；
pod 对象信息更新，在宽限期内（默认 30 秒），pod 被视为 dead；
将 pod 标记为 terminating 状态；
kubectl 监控到 terminating 状态，启动 pod 关闭过程；
endpoint 控制器监控到 pod 关闭，将其从 endpoint 列表中删除；
若定义了 preStop 钩子，执行相关操作；
容器进程收到停止信息；
宽限期结束后，若 pod 仍运行，kubelet 请求 apiserver 设置宽限期为 0 完成删除操作。
##  24. pod 的生命周期状态
Kubernetes 的 pod 具有以下几种生命周期状态：

Pending：API server 已创建 pod，但尚有一个或多个容器镜像未创建或正在下载；
Running：pod 内的所有容器已经创建，至少有一个容器处于运行状态或正在重启；
Succeeded：pod 内所有容器已退出且不会再重启；
Failed：pod 内所有容器已退出，且至少有一个容器退出失败；
Unknown：apiserver 无法获取 pod 状态，可能由于网络问题导致。
##  25. pod 一直处于 pending 状态的原因及排查方法
Pod 处于 pending 状态可能的原因及解决方法：

调度器调度失败：
调度器无法为 pod 分配合适的 node 节点。可能的原因包括：

Node 节点 CPU、内存不足；
Pod 的资源请求超出节点可用资源；
Node 节点存在污点，pod 没有定义容忍；
Pod 定义了亲和性或反亲和性，无法匹配合适的节点。
PVC 或 PV 无法动态创建：
当 pod 使用 StatefulSet 但未正确配置存储时，pod 可能一直处于 pending 状态。可能的原因包括：

StorageClassName 配置错误；
PVC 动态创建失败；
存储供应异常，PV 无法创建。
##  26. DaemonSet资源对象的特性？

DaemonSet 这个资源对象的特点是，它会在集群中的每一个节点上都跑一个 Pod，而且每个节点上只能有一个 Pod。这跟 Deployment 不一样，Deployment 可以定义多个副本。而 DaemonSet 只会保证每个节点上有一个 Pod。

所以，DaemonSet 的配置文件里是没有 replicas 这个字段的。
除此之外，DaemonSet 的写法和 Deployment、ReplicaSet 这些资源对象基本一致。
常见的使用场景：

比如做每个节点的日志收集。
监控每个节点的状态。
##  27. 删除一个 Pod 会发生什么事情？

当你删除一个 Pod 时，Kubernetes 的 kube-apiserver 会接收到删除指令。默认情况下，Pod 会有 30 秒的优雅退出时间，超过 30 秒后，Pod 会被标记为“Terminating”状态。具体流程是这样的：

Pod 会从 Service 的 endpoint 列表中被移除。
如果 Pod 有定义停止前的钩子（preStop hook），它会在容器内被调用，主要是为了优雅停止进程。
然后进程会接收到 SIGTERM 信号（相当于 kill -15）。
如果超过了优雅退出时间，Pod 内的所有进程会收到 SIGKILL 信号（相当于 kill -9），强制结束。
##  28. Pod 的共享资源？

Pod 里的多个容器可以共享一些系统资源，这样它们可以更好地协同工作。常见的共享资源有：

PID 命名空间：Pod 里的容器可以看到彼此的进程 ID。
网络命名空间：Pod 中的容器共享同一个 IP 地址和端口范围。
IPC 命名空间：Pod 中的容器可以通过 SystemV IPC 或 POSIX 消息队列进行进程间通信。
UTS 命名空间：Pod 里的容器共享同一个主机名。
Volumes（共享存储卷）：Pod 中的所有容器可以访问在 Pod 级别定义的存储卷。
##  29. Pod 的初始化容器是干什么的？

初始化容器（Init Containers）是为了在应用容器启动前，完成一些前置条件任务。它们本质上和普通容器差不多，但只会运行一次，完成任务后就结束了。

初始化容器的两个主要特点：

初始化容器必须完成，才会开始启动应用容器。如果某个初始化容器失败，Kubernetes 会一直重启它，直到成功为止。
初始化容器是按顺序执行的，当前一个容器成功了，才会运行下一个。
##  30. Pod 的资源请求、限制如何定义？

Pod 的资源请求和限制可以直接在它的定义文件里设置，主要包括两部分：

limits：限制 Pod 能使用的最大 CPU 和内存。
requests：Pod 启动时申请的最小 CPU 和内存。
示例：

resources:
  limits:
    cpu: 2         # 限制最大 CPU 为 2 核
    memory: 2Gi    # 限制最大内存为 2 GiB
  requests:
    cpu: 1         # 请求 1 核 CPU
    memory: 500Mi  # 请求 500 MiB 内存
##  31. Pod 的定义中有个 command 和 args 参数，这两个参数不会和 Docker 镜像的 ENTRYPOINT 冲突吗？

不会冲突。

Kubernetes 中的 command 和 args 参数可以覆盖 Docker 镜像中的 ENTRYPOINT 和 CMD。具体的行为是：

如果 command 和 args 都没写，使用 Dockerfile 里的 ENTRYPOINT 和 CMD。
如果只写了 command，会覆盖 ENTRYPOINT，但仍会使用 Dockerfile 里的 CMD。
如果只写了 args，会覆盖 Dockerfile 里的 CMD，但还是会用 ENTRYPOINT。
如果 command 和 args 都写了，Dockerfile 里的 ENTRYPOINT 和 CMD 都会被覆盖。
这意味着，Kubernetes 允许你灵活控制容器启动时的命令和参数。

##  32. K8s中镜像的下载策略是什么？

在 Kubernetes 中，镜像的下载策略由 imagePullPolicy 字段控制。这个策略决定了 Pod 运行时 Kubernetes 是该拉取最新镜像，还是使用已经存在的镜像。主要有三种策略：

Always：每次创建 Pod 时，Kubernetes 都会去拉取最新的镜像。
IfNotPresent：只有当本地没有该镜像时，才会拉取新镜像（默认值）。
Never：Kubernetes 不会尝试去拉取镜像，只会使用本地已有的镜像。
默认情况下，如果镜像的标签是 latest，策略会自动设置为 Always，其他情况则是 IfNotPresent。

##  33. 标签与标签选择器的作用是什么？

标签（Label）是 K8s 中的一个键值对，作用是给对象（比如 Pod、Service）打上标识，以便进行管理和查询。

标签选择器：通过指定某些标签，可以筛选出匹配这些标签的资源对象。
举个例子，假设你有很多 Pod 运行在集群中，你可以通过标签选择器找到一组带有相同标签的 Pod，比如所有负责处理用户请求的 Pod。标签选择器是 Kubernetes 中进行资源管理、调度和服务发现的一个重要工具。

##  34. K8s的负载均衡器？

Kubernetes 的负载均衡机制通过 Service 来实现。每个 Service 会自动创建一个 Cluster IP，并对这个 IP 的流量进行负载均衡。内部使用 iptables 或者 IPVS 来把流量分发到对应的 Pod。

此外，Kubernetes 还支持 外部负载均衡。对于类型为 LoadBalancer 的 Service，Kubernetes 可以和云服务商的负载均衡服务对接（比如 AWS 的 ELB、GCP 的 Load Balancer），将外部请求直接转发到集群内的 Pod。

##  35. kubelet 监控 Node 节点资源使用是通过什么组件来实现的？

Kubelet 主要通过 cAdvisor（Container Advisor）来监控 Node 节点的资源使用情况。cAdvisor 能够收集和报告容器的 CPU、内存、网络、文件系统等资源的使用数据。

这些数据不仅可以用于实时监控，还可以为调度决策提供依据，帮助 Kubernetes 更好地分配和管理资源。

##  36. Pod的状态？

Pod 的状态可以通过 kubectl get pods 命令来查看，常见的状态有：

Pending：Pod 已创建，但没有足够资源或其他原因导致无法启动。
Running：Pod 已经成功分配到了节点上，并且至少有一个容器正在运行。
Succeeded：Pod 中所有容器都已经正常结束，并且不会再重新启动。
Failed：Pod 中的一个或多个容器非正常终止。
CrashLoopBackOff：Pod 中的容器启动失败，并且 Kubernetes 会进行重启。
这些状态能帮助我们快速了解 Pod 的运行情况，便于问题排查和处理。

##  37. Deployment 和 ReplicaSet 有什么区别？

Deployment 是一个更高层次的资源对象，用于管理 Pod 和 ReplicaSet 的部署和更新。ReplicaSet（RS） 则是确保集群中有指定数量的 Pod 运行。

主要区别在于：

Deployment：除了管理 Pod 的副本数之外，还支持滚动更新、回滚等高级功能，适合持续集成和更新场景。
ReplicaSet：仅负责维持固定数量的 Pod 运行，但不具备更新和回滚的能力。通常情况下，ReplicaSet 是由 Deployment 自动创建的，用户不直接操作它。
##  38. RC/RS 的实现原理？

RC（ReplicationController）和 RS（ReplicaSet）的实现原理非常相似，它们的核心功能都是确保集群中始终有指定数量的 Pod 在运行。

它们通过一个循环检查机制，不断监控 Pod 的数量，确保集群中总是有指定数量的副本。如果某个 Pod 挂了，它们会自动启动新的 Pod 来代替。
当有多余的 Pod 运行时，它们会删除超出的 Pod，保持集群资源的合理分配。
##  39. Kubernetes 服务发现？

Kubernetes 提供了两种服务发现的方式：

环境变量：每当新 Pod 创建时，Kubernetes 会自动注入服务的相关环境变量。
DNS 服务发现：Kubernetes 集成了 DNS 解析系统，Service 会被分配一个 DNS 名称，其他 Pod 可以通过这个 DNS 名称进行访问。
通常情况下，使用 DNS 进行服务发现更加灵活和高效。

##  40. k8s 发布（暴露）服务的类型有哪些？

在 Kubernetes 中，Service 主要有以下几种类型，用于暴露应用服务：

ClusterIP：集群内部的虚拟 IP，只能在集群内部访问，默认类型。
NodePort：将 Service 暴露为集群每个节点的一个静态端口，外部流量可以通过节点的 IP 和端口访问服务。
LoadBalancer：与云提供商的负载均衡器集成，将流量直接分发到集群内的 Pod。
ExternalName：将 Service 映射到一个外部的 DNS 名称，用于非集群内的服务发现。
##  41. 简述 ETCD 及其特点？

ETCD 是一个分布式键值存储系统，主要用于存储 Kubernetes 的所有集群数据和状态。它是 Kubernetes 集群的“数据库”。

ETCD 的特点：

强一致性：ETCD 使用 Raft 算法来保证数据的强一致性。
高可用性：支持集群模式运行，确保即使部分节点故障，数据依然可用。
高性能：即使在大规模集群中，ETCD 也能提供快速的读写性能。
##  42. 简述 ETCD 适用的场景？

ETCD 适用于需要存储集群状态、配置和元数据的场景，特别是需要一致性保证的分布式系统。典型的应用场景包括：

Kubernetes：存储集群的所有状态信息，包括 Pod、Service 等对象的配置。
分布式锁：ETCD 可以用来实现分布式系统中的锁机制。
配置管理：可以用来集中管理分布式系统的配置，并且保证配置的更新是一致的。
##  43. 简述 kube-proxy 作用？

kube-proxy 是 Kubernetes 集群中的一个网络代理，它的主要作用是为每个节点提供网络路由和负载均衡。它根据 Service 的配置，为流量在集群内部做转发和分发。

具体功能包括：

维护网络规则：通过 iptables 或 IPVS 设置网络规则，将流量正确地转发到目标 Pod。
负载均衡：对外部或内部的服务请求进行负载均衡，将流量分配到多个 Pod 上。
## 44. 如何让一个 Node 脱离集群调度（比如要停机维护，但不影响业务）？
当你需要维护某个节点，但又不希望这个节点上的业务受到影响，可以使用 kubectl drain 命令。这个命令会将节点上的 Pod 安全地迁移到其他节点上，确保业务不中断。

具体步骤：

首先，使用 kubectl drain <node-name>，这会让 K8S 把该节点上的所有 Pod 迁移到其他节点上。
如果有些 Pod 设置了 PodDisruptionBudget，确保你理解并满足其要求。
维护完成后，可以使用 kubectl uncordon <node-name>，重新允许该节点参与调度。
## 45. K8S 生产中遇到过哪些印象深刻的问题？怎么排查和解决的？（重点）
在生产环境中遇到问题是不可避免的。以下是一个我印象特别深刻的问题，分享给大家。

问题：前端负载均衡服务器上的 Keepalived 出现脑裂现象。

脑裂指的是本应由主服务器持有的 VIP，同时被主备服务器持有，可能导致网络流量的混乱。以下是当时的处理流程：

问题表现：VIP 同时出现在主服务器和备服务器上，但奇怪的是业务并未受到明显影响。
初步排查：查看备服务器上的日志，发现有 VRRP 超时，导致备服务器接管了 VIP。查看主服务器日志和进程状态，都显示正常。
进一步排查：检查防火墙和 SELinux，确认它们都是关闭状态。
数据包分析：使用 tcpdump 抓包分析，发现备服务器确实在发送 VRRP 心跳包，导致外部流量进入备服务器。
怀疑原因：初步猜测可能是 VRRP 心跳包的时间间隔过长，检测脚本的设置也可能不合理。
调整设置：将 VRRP 心跳包间隔从 2 秒调整为 1 秒，检测脚本的失败次数检测从连续两次失败才判定为失败。
重新测试：重启主备服务器上的 Keepalived，一切恢复正常。
再次复现：第二天凌晨同样时间，又出现脑裂现象。怀疑网络问题，排查了路由器，确认没有禁用 VRRP 协议。
最终解决：根据文档，发现默认的组播模式容易冲突，改为单播模式后，问题彻底解决。
总结：这个问题的根本原因是 Keepalived 默认使用组播模式，导致多个实例发生冲突。通过改为单播模式，保证了心跳包的唯一性，彻底解决了脑裂问题。

## 46. K8S 生产中遇到的另一个问题：ETCD 集群出现两个 Leader
问题现象：搭建好的 K8S 测试集群，发现 kubectl get nodes 无法正常显示节点资源，而 kubectl get namespace 有时能显示，有时不能。

排查步骤：

怀疑网络插件问题：起初以为是 Calico 没有安装导致的，但仔细分析后认为即使没有网络插件，也不至于完全没有资源发现。
怀疑 ETCD 集群问题：因为所有的 K8S 资源都是存储在 ETCD 中，开始检查 ETCD 服务。
发现两个 Leader：查看日志发现 ETCD 集群有两个 Leader，这是不正常的，ETCD 集群应该只有一个 Leader。
重启和修改配置无效：尝试修改配置文件、重启服务、重新颁发证书，但问题依旧。
最终解决：删除整个 ETCD 集群，重新搭建，问题解决。
总结：ETCD 出现多个 Leader 的原因可能是配置问题或者环境异常。在生产环境中，遇到此类问题时，一定要先做好数据备份，然后再进行进一步操作。

## 47. 如何通过 NodePort 方式访问 Service？

通过 NodePort 访问 Service，意思就是在集群每个节点上暴露一个固定端口（比如 30000），所有请求都可以通过这个端口进入。你只需要访问任意一个节点的 IP 地址加上这个端口号，Kubernetes 会自动将流量路由到对应的 Service 上。

## 48. K8S 的资源限制 QoS 是什么？

QoS（Quality of Service，服务质量）是 Kubernetes 用来区分不同 Pod 的资源分配方式，主要分为三类：

BestEffort：Pod 中不设置任何 CPU 或内存的请求或限制。这种模式是最佛系的，只要有资源用就行，不强求。
Burstable：Pod 中至少有一个容器设置了 CPU 或内存的请求。只要你稍微给点资源要求，Pod 就会尽力分配多余的资源。
Guaranteed：Pod 中所有的容器都必须明确设置 CPU 和内存的请求和限制，而且两者必须相等。这是最高优先级的资源分配模式，保证你分到的资源一定够用。
## 49. K8S 的数据持久化方式有哪些？

Kubernetes 提供了几种常见的数据持久化方式：

EmptyDir（空目录）：这是一种临时存储方式。当 Pod 启动时，K8S 会给它分配一个空目录，Pod 里所有容器都能共享使用。数据的生命周期与 Pod 一致，Pod 被删除时，数据也就没了，主要用于临时存储或容器间的共享数据。
HostPath：这种方式允许将宿主机上的某个文件或目录挂载到 Pod 内部。相当于将宿主机的某些资源直接暴露给容器使用。
PersistentVolume（简称 PV）：这是 Kubernetes 的一种持久化存储机制。通过 NFS、GFS 等存储后端，提供了长期存储解决方案。用户通过 PersistentVolumeClaim（简称 PVC）来向集群申请存储资源。PVC 和 PV 之间需要定义相同的访问模式和存储类，以便正确关联。
## 50. K8S 的基本组成部分有哪些？

K8S 集群分为 Master 节点和 Node 节点，每个部分都有一些核心组件：

Master 节点主要有五个组件：

kubectl：客户端命令行工具，是操作 K8S 集群的入口。
api-server：提供 REST API 接口，是集群的控制入口。
controller-manager：负责处理后台任务，比如管理 Pod 的数量、处理节点状态等。
kube-scheduler：负责根据资源分配情况，将 Pod 分配到合适的节点上。
etcd：分布式键值存储，用于存储集群的配置信息和服务发现数据。
Node 节点有三个主要组件：

kubelet：运行在每个节点上，负责管理容器并报告状态。
kube-proxy：管理 Pod 的网络，确保流量能正确转发。
容器运行时：Docker 或 rkt，负责实际运行容器。
## 51. K8S 中的镜像下载策略是什么？

Kubernetes 提供了三种镜像下载策略，通过 imagePullPolicy 字段来配置：

Always：如果镜像标签是 latest，K8S 会始终从远程仓库拉取最新的镜像。
IfNotPresent：只有当本地没有相应的镜像时，才从远程仓库拉取镜像。
Never：K8S 禁止从远程仓库拉取镜像，只能使用本地已有的镜像。
可以通过命令 kubectl explain pod.spec.containers 来查看详细说明。

##  52. kube-proxy的iptables模式是怎么工作的？

kube-proxy在Kubernetes 1.2版本后默认启用了iptables模式。简单来说，在这种模式下，kube-proxy不再是个真正的代理，而是通过监听Kubernetes API Server来捕捉Service和Endpoint的变化，并动态更新iptables的规则。这样，客户端请求就可以直接通过iptables的NAT机制被路由到目标Pod，而不再需要经过kube-proxy本身。

##  53. kube-proxy的IPVS模式是如何运作的？

从Kubernetes 1.11版本开始，IPVS模式被稳定下来。IPVS是专为高性能负载均衡设计的，使用哈希表等更高效的数据结构来管理规则，比iptables模式能支持更大规模的集群。IPVS使用的是ipset，而不是iptables的线性规则链，这让它在处理大量规则时性能表现更出色。

##  54. kube-proxy的IPVS和iptables模式有什么区别和相似之处？

虽然IPVS和iptables都基于Netfilter，但它们用途不同。iptables更像是个防火墙工具，而IPVS则专门为高性能负载均衡设计。在大规模集群中，IPVS表现更好，支持多种负载均衡算法，比如最少连接和加权等。此外，IPVS还自带健康检查和连接重试功能。

##  55. Kubernetes中的静态Pod是什么？

静态Pod是由kubelet直接管理的Pod，通常只存在于特定的节点上，不受API Server的控制，也不会被其他控制器（比如Deployment）管理。这类Pod只能在kubelet所在的节点上运行，集群调度和健康检查对它们不起作用。

##  56. Kubernetes中有哪些常见的Pod调度方式？

Kubernetes支持几种常见的调度方式：

Deployment/ReplicationController：自动管理Pod的多副本，保持指定数量的副本运行。
NodeSelector：通过标签将Pod固定调度到特定节点上。
NodeAffinity：定义Pod和节点的亲和性规则，分为硬性必须满足的规则和可优先选择的软规则。
Taints和Tolerations：Taints可以让节点拒绝某些Pod，而Toleration允许Pod在标记了Taint的节点上运行。
##  57. Kubernetes的Init容器有什么作用？

初始化容器（Init Containers）是在应用容器启动前运行的特殊容器。它们按顺序执行，只有所有Init容器完成后，应用容器才会启动。它们常用于执行一些必须在应用容器启动前完成的任务，比如文件准备或依赖检查。

##  58. Kubernetes的Deployment是如何更新Pod的？ 当创建一个Deployment时，Kubernetes会生成一个ReplicaSet并启动相应数量的Pod。如果用户更新了Deployment，系统会创建一个新的ReplicaSet，逐步替换旧的Pod副本，直到所有Pod都用新版本替换完。

##  59. Kubernetes的Deployment更新有哪几种策略？

Deployment的更新主要有两种策略：

Recreate：先删除所有旧的Pod，再创建新的Pod。
RollingUpdate：逐步替换旧Pod，同时控制最多不可用的Pod数量（maxUnavailable）和最多新增的Pod数量（maxSurge）。
##  60. DaemonSet在Kubernetes中有何特点？

DaemonSet确保每个节点上都运行一个Pod，不需要手动指定副本数量。典型应用场景包括日志收集和节点监控等任务。

##  61. Kubernetes是如何实现自动扩容的？

Kubernetes通过Horizontal Pod Autoscaler（HPA）实现自动扩缩容。HPA根据Pod的CPU等使用指标，动态调整Pod的副本数量，确保系统资源的合理利用。

##  62. Kubernetes的Service是如何分发请求的？ Kubernetes的Service有几种常见的请求分发策略：

轮询（RoundRobin）：将请求均匀分配到所有后端Pod上。
会话保持（SessionAffinity）：基于客户端IP地址，将同一客户端的请求固定转发到同一个Pod。
##  63. 什么是Kubernetes的Headless Service？ Headless Service是一种特殊的Service，它不会分配ClusterIP。它的作用是直接将后端Pod的地址列表返回给客户端，让应用程序自行处理负载分发的逻辑，适用于需要了解所有实例信息的场景。

##  64. 如何从集群外访问Kubernetes内部的服务？

有几种方式可以从外部访问Kubernetes集群内的服务：

Pod的hostPort映射：将Pod内部端口映射到物理机上。
Service的nodePort映射：将Service的端口映射到物理机IP上，外部可以通过IP加端口访问服务。
LoadBalancer：在公有云环境下，可以使用LoadBalancer类型的Service，依靠云服务商的负载均衡器接入外部流量。
##  65. Kubernetes的Ingress是怎么工作的？

Ingress是一种Kubernetes资源，用于HTTP层的流量路由。它根据不同的URL路径，将流量转发到对应的Service。Ingress依赖Ingress Controller来实现负载均衡，流量通过Ingress规则直接到达Pod，绕过kube-proxy，提升了效率。

##  66. Kubernetes有哪些镜像拉取策略？

Kubernetes有三种镜像拉取策略：

Always：每次都会从远程仓库拉取镜像，适用于latest标签。
Never：只使用本地镜像，不允许拉取。
IfNotPresent：只有本地没有镜像时才会拉取，默认用于非latest标签的镜像。
##  67. Kubernetes中的负载均衡器是如何工作的？

Kubernetes有两种类型的负载均衡器：

内部负载均衡器：在集群内部分配Pod的请求流量。
外部负载均衡器：在公有云环境中，将外部流量引导至集群内的Pod。
##  68. Kubernetes各组件是如何与API Server通信的？

API Server是Kubernetes的核心，负责集群内部通信。kubelet定期向API Server报告节点状态，Controller Manager和Scheduler通过API Server监控集群资源，所有组件都通过API Server共享和存取数据。

##  69. Kubernetes的Scheduler是怎么工作的？

Scheduler负责将新建的Pod调度到合适的节点上。它先筛选出满足条件的节点，然后给这些节点打分，选择得分最高的节点作为Pod的目标节点。

##  70. Kubernetes的Scheduler如何选择节点？

Scheduler使用两种算法来选择节点：

预选算法（Predicates）：根据资源需求筛选出符合条件的节点。
优选算法（Priorities）：对通过预选的节点进行评分，选择得分最高的节点。
##  71. kubelet在Kubernetes中起什么作用？

kubelet是每个节点上运行的服务，负责管理该节点上的Pod和容器。它定期向API Server汇报节点状态，并监控容器的资源使用情况。

##  72. kubelet使用什么工具监控节点资源？

kubelet使用集成的cAdvisor工具来监控节点上Pod和容器的资源使用情况。它会收集CPU、内存等性能指标，帮助管理员了解资源消耗。

##  73. Kubernetes是如何保证集群安全的？

Kubernetes通过多种机制保障集群的安全性：

隔离机制：确保容器与宿主机的隔离。
权限控制：通过用户角色管理访问权限。
API Server认证和授权：通过HTTPS和Token对请求进行认证。
RBAC授权：通过基于角色的访问控制机制来管理权限。
##  74. Kubernetes的准入控制是什么？

准入控制是在API Server认证和授权之后的额外检查。如果请求不符合准入控制的策略，它将被拒绝。常见的准入控制策略包括允许所有请求、拒绝所有请求，以及确保资源请求在合理范围内等。

##  75. 什么是Kubernetes的RBAC？它有什么优点？

RBAC（基于角色的访问控制）通过角色分配权限。它的优点包括：

可以覆盖集群内外所有资源的权限管理。
通过API操作，可用kubectl管理权限。
支持动态调整，无需重启API Server。
## 76. Kubernetes Secret 有什么用？

Secret 对象主要用来保存一些敏感数据，比如密码、OAuth Tokens 和 SSH 密钥。相比直接把这些信息放在 Pod 或者镜像里，放到 Secret 里更安全，而且使用起来也更方便。

## 77. Kubernetes Secret 怎么用？

在创建 Pod 时，可以通过指定 Service Account 自动使用 Secret。
可以通过把 Secret 挂载到 Pod 来使用。
在拉取 Docker 镜像时，通过配置 Pod 的 ImagePullSecrets 来使用 Secret。
## 78. 什么是 Kubernetes PodSecurityPolicy？

PodSecurityPolicy 是 Kubernetes 提供的一种机制，用来更细致地控制 Pod 的资源使用和安全策略。当启用了 PodSecurityPolicy 后，系统默认不允许创建 Pod，必须先创建相应的安全策略和授权策略，Pod 才能被成功创建。

## 79. PodSecurityPolicy 能实现哪些安全策略？

特权模式：是否允许 Pod 以特权模式运行。
宿主机资源控制：比如 hostPID，决定 Pod 是否可以共享宿主机的进程空间。
用户和组的设置：指定容器运行时的用户 ID 或组 ID。
权限提升：是否允许容器内的子进程提升权限。
SELinux 配置：为容器设置 SELinux 策略。
## 80. Kubernetes 网络模型是什么样的？

在 Kubernetes 中，每个 Pod 都有自己的 IP 地址，不管它们是不是在同一个节点上，都可以通过 IP 直接互相访问。同一个 Pod 内的容器共享一个网络命名空间，也就是可以通过 localhost 互相通信。

## 81. Kubernetes CNI 模型是什么？

CNI（Container Network Interface）是 Kubernetes 用来操作和配置容器网络的规范。通过插件的形式，CNI 负责在创建和销毁容器时，分配或回收网络资源。它只关心网络分配，至于容器本身，则是通过 Docker 或其他容器工具来实现。

## 82. Kubernetes 的网络策略有什么用？

Kubernetes 的 Network Policy 允许你对 Pod 之间的网络通信进行精细化控制，可以设置哪些 Pod 能够相互访问，或者禁止某些 Pod 之间的通信，保障应用的安全。

## 83. Kubernetes 的网络策略原理是什么？

Network Policy 的核心原理是通过监听用户定义的策略，网络控制器把这些策略转换为实际的网络规则，并通过各个节点上的 Agent 配合 CNI 插件进行实际的网络限制。

## 84. Kubernetes 中 flannel 是干嘛的？

Flannel 主要负责给每个 Node 上的 Docker 容器分配 IP 地址，并且通过 Overlay Network 的方式，让不同 Node 上的容器可以互相通信。

## 85. Kubernetes 中的 Calico 网络是怎么实现的？

Calico 是基于 BGP 协议的三层网络方案。它通过在每个节点上运行 vRouter 来进行数据转发，并通过 BGP 协议广播路由信息，实现容器之间的通信。Calico 可以直接利用数据中心的网络结构，避免了封包解包的性能消耗，提升了网络效率。

## 86. Kubernetes 为什么需要共享存储？

对于一些有状态的应用或者需要持久化数据的应用，Kubernetes 需要一个可靠的存储方案来保存数据。这样，即使容器重新创建，也能继续使用之前保存的数据。

## 87. 什么是 Kubernetes 的 PV 和 PVC？

PV（Persistent Volume）是对底层共享存储的抽象，表示存储资源。
PVC（Persistent Volume Claim）是用户对存储资源的申请，类似于向 Kubernetes 要求一定的存储空间。
## 88. Kubernetes 中 PV 生命周期有哪些状态？

Available：还没被绑定，处于可用状态。
Bound：已经被绑定到某个 PVC。
Released：绑定的 PVC 被删除了，但资源还没被回收。
Failed：资源回收失败。
## 89. Kubernetes 的 CSI 是什么？

CSI（Container Storage Interface）是 Kubernetes 和存储系统对接的标准接口。通过 CSI，存储提供商可以基于标准接口开发自己的存储插件，方便 Kubernetes 对接各种存储方案。

## 90. Kubernetes Worker 节点怎么加入集群？

在节点上安装 Docker、kubelet 和 kube-proxy，然后配置它们的启动参数，指定 Kubernetes Master 的地址。启动服务后，节点会自动注册到集群，成为新的 Worker。

## 91. Kubernetes Pod 如何控制节点资源？

Kubernetes 中，节点的资源主要是 CPU 和内存。在配置 Pod 时，可以通过 CPU Request 和 Memory Request 参数为每个容器指定所需的 CPU 和内存。Kubernetes 会根据这些请求值，寻找合适的节点来调度 Pod。

## 92. Requests 和 Limits 如何影响 Pod 调度？

当一个 Pod 被创建时，调度器会根据 Pod 的 Requests 需求选择合适的节点。节点必须有足够的资源来满足 Pod 的 Requests，调度器才会将 Pod 分配到该节点。

## 93. Kubernetes Metric Service 是什么？

从 1.10 版本开始，Kubernetes 引入了 Metrics Server 来采集集群中的核心指标数据，比如节点和 Pod 的 CPU、内存使用情况。对于自定义指标，可以通过 Prometheus 等工具进行监控。

## 94. Kubernetes 中如何使用 EFK 实现日志管理？

EFK 是 Elasticsearch、Fluentd 和 Kibana 的组合。Fluentd 负责从各个节点上收集日志，Elasticsearch 负责存储，Kibana 提供 Web 界面供用户查询和分析日志。

## 95. Kubernetes 如何优雅地进行节点维护？

在进行节点关机维护前，建议先使用 kubectl drain 把节点上的 Pod 驱逐到其他节点，确保服务不中断，然后再进行关机。

## 96. 什么是 Kubernetes 集群联邦？

Kubernetes 集群联邦可以将多个集群管理成一个统一的集群，这样你可以在不同的数据中心或云平台上创建集群，并通过联邦统一管理它们。

## 97. Helm 是什么，有什么优势？

Helm 是 Kubernetes 的包管理工具。它能把一系列 Kubernetes 资源打包成一个 Chart，方便统一管理。对于应用开发者来说，Helm 可以打包、发布和管理应用；而对使用者来说，可以通过 Helm 快速安装、升级和回滚应用，而不需要手动编写复杂的部署文件。

## 98. Kubernetes 标签与选择器有什么作用？

标签 是附加在资源对象上的键值对数据，用来对资源进行分类和筛选。
标签选择器 用来表达对标签的查询条件，Kubernetes 支持基于等值和集合关系的选择器。
## 99. Google Container Engine 是什么？

Google Container Engine（GKE）是基于 Kubernetes 的集群管理平台，专门用来在 Google 公有云上运行和管理容器集群。

## 100. 镜像的状态有哪些？

Running：Pod 已经成功运行。
Pending：Pod 已经创建，但还没有调度成功，或者正在下载镜像。
Unknown：无法获取 Pod 状态，通常是因为无法与节点通信。
## 101. Service 在 Kubernetes 中是什么？

Service 是 Kubernetes 用来管理多个 Pod 的负载均衡器。它通过 Label Selector 将多个 Pod 加入到同一个服务里。Service 有几种类型：

ClusterIP：集群内部访问，分配一个内部 IP 供 Pod 使用。
NodePort：外部访问，通过节点的端口暴露服务。
LoadBalancer：外部访问，通过外部负载均衡器转发请求到节点。