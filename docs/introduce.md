## Kubernetes中的核心组件
  ![avatar](img/cd.jpg)(evernotecid://481E08E3-B0BC-4AF0-BD1D-F5A91D581CF3/appyinxiangcom/15709100/ENResource/p834)

    >Kubernetes 是 Google 基于 Borg 开源的容器编排调度，用于管理容器集群自动化部署、扩容以及运维的开源平台。作为云原生计算基金会 CNCF（Cloud Native Computing Foundation）最重要的组件之一（CNCF 另一个毕业项目 Prometheus ），它的目标不仅仅是一个编排系统，而是提供一个规范，可以让你来描述集群的架构，定义服务的最终状态，Kubernetes 可以帮你将系统自动地达到和维持在这个状态，Kubernetes 也可以对容器(Docker)进行集群管理和服务编排（Docker Swarm 类似的功能）,对于大多开发者来说，以容器的方式运行一个程序是一个最基本的需求，跟多的是 Kubernetes 能够提供路由网关、水平扩展、监控、备份、灾难恢复等一系列运维能力

  **Kubernetes主要由以下几个核心组件组成：**
    * etcd: 保存了整个集群的状态；
    * apiserver: 提供了资源操作的唯一入口，并提供认证、授权、访问控制、API注册和发现等机制；
    * controller manager: 负责维护集群的状态，比如故障检测、自动扩展、滚动更新等；
    * scheduler: 负责资源的调度，按照预定的调度策略将Pod调度到相应的机器上；
    * kubelet: 负责维护容器的生命周期，同时也负责Volume（CVI）和网络（CNI）的管理；
    * Container runtime: 负责镜像管理以及Pod和容器的真正运行（CRI）；
    * kube-proxy: 负责为Service提供cluster内部的服务发现和负载均衡；

  **除了核心组件，还有一些推荐的Add-ons：**
    * kube-dns负责为整个集群提供DNS服务
    * Ingress Controller为服务提供外网入口
    * Dashboard提供GUI
    * Federation提供跨可用区的集群
    * Fluentd-elasticsearch提供集群日志采集、存储与查询

  #### 1. Etcd 简介
    Etcd是Kubernetes的存储状态的数据库。
    Etcd的watch机制是Kubernetes工作的关键。系统允许client去执行轻量级的对于Key值变化事件的订阅。当要watch的数据发生变化时, client会立即得到通知。这可以用作分布式系统组件之间的协调机制。 一个组件一旦写入etcd，其他组件可以立即对该变化作出反应。

  #### 2. Api Server 简介
    Kubernetes的核心组件是API Server，提供了资源对象的唯一操作入口，其他所有组件都必须通过它提供的API来操作资源数据，只有API Server与存储通信，其他模块通过API Server访问集群状态。
      该进程运行在单个k8s-master节点上。默认有两个端口:

    * http默认端口: 8080
    * https默认端口: 6443

  #### 3. Controller Manager 简介
    Controller Manager作为集群内部的管理控制中心，负责执行各种控制器，负责集群内的Node、Pod副本、服务端点（Endpoint）、命名空间（Namespace）、服务账号（ServiceAccount）、资源定额（ResourceQuota）的管理，当某个Node意外宕机时，Controller Manager会及时发现并执行自动化修复流程，确保集群始终处于预期的工作状态。

  #### 4. Scheduler 简介
    Scheduler收集和分析当前Kubernetes集群中所有Minion节点的资源(内存、CPU)负载情况，然后依此分发新建的Pod到Kubernetes集群中可用的节点。

  #### 5.kubelet简介
    在kubernetes集群中，每个Node节点都会启动kubelet进程，用来处理Master节点下发到本节点的任务，管理Pod和其中的容器。kubelet会在API Server上注册节点信息，定期向Master汇报节点资源使用情况，并通过cAdvisor监控容器和节点资源。可以把kubelet理解成【Server-Agent】架构中的agent，是Node上的pod管家。

  #### 6.Kube-proxy 简介
    负责接收并转发请求。Kube-proxy的核心功能是将到Service的访问请求转发到后台的某个具体的Pod。当Kube-proxy监听到Service的访问请求后，它会找到最适合的Endpoints，然后将请求转发过去,Proxy后端使用了随机、轮循负载均衡算法，这样Proxy解决了同一主宿机相同服务端口冲突的问题。

  #### 7. pause-amd64 简介
    pause-amd64是Kubernetes基础设施的一部分，Kubernetes管理的所有pod里，pause-amd64容器是第一个启动的，用于实现Kubernetes集群里pod之间的网络通讯。
      pause容器用作于你的Pod中所有容器的“父容器”。pause容器有两个核心职责:
    1.在Pod中它作为Linux命名空间共享的基础,
    2.启用PID（进程ID）命名空间共享，它为每个Pod提供PID，并收集僵尸进程。

  #### kubernetes的其他必备组件
      DNS(例如: coredns,kube-dns等)
      网络插件(例如: flanel,calico等)
      ingress负债均衡(例如: nginx,haproxy等)
