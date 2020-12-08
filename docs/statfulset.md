#### StatefulSet 是什么
StatefulSet是Kubernetes提供的管理有状态应用的负载管理控制器API。在Pods管理的基础上，保证Pods的顺序和一致性。与Deployment一样，StatefulSet也是使用容器的Spec来创建Pod，与之不同,StatefulSet创建的Pods在生命周期中会保持持久的标记（例如Pod Name）

StatefulSet适用于具有以下特点的应用：
* 具有固定的网络标记（主机名）
* 具有持久化存储
* 需要按顺序部署和扩展
* 需要按顺序终止及删除
* 需要按顺序滚动更新

cat web.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None   #注意这里，stateful的clusterIP一定要设置成none
  selector:
    app: nginx

---
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx"  #声明它属于哪个Headless Service.
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: k8s.gcr.io/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:   #可看作pvc的模板
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi

```
```sh
$ kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   1d
nginx        ClusterIP   None         <none>        80/TCP    21m
```
#### 顺序创建 Pod
对于一个拥有 N 个副本的 StatefulSet，Pod 被部署时是按照 {0..N-1}  升序顺序创建的

#### 检查 Pod 的顺序索引
```sh
$ kubectl get pods -l app=nginx
NAME      READY     STATUS    RESTARTS   AGE
web-0     1/1       Running   0          1m
web-1     1/1       Running   0          1m
```

#### 使用稳定的网络身份标识
每个 Pod 都拥有一个基于其顺序索引的稳定的主机名
```sh
$ for i in 0 1; do kubectl exec web-$i -- sh -c 'hostname'; done
web-0
web-1
```

```sh
$ kubectl get pvc -l app=nginx
NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
www-web-0   Bound    pvc-2ad27247-61bd-11e9-88eb-025000000001   1Gi        RWO            hostpath       11m
www-web-1   Bound    pvc-2d96ab3b-61bd-11e9-88eb-025000000001   1Gi        RWO            hostpath       11m
```

##### 为什么需要 headless service 无头服务？

* 在用Deployment时，每一个Pod名称是没有顺序的，是随机字符串，因此是Pod名称是无序的，但是在statefulset中要求必须是有序 ，每一个pod不能被随意取代，pod重建后pod名称还是一样的。而pod IP是变化的，所以是以Pod名称来识别。pod名称是pod唯一性的标识符，必须持久稳定有效。这时候要用到无头服务，它可以给每个Pod一个唯一的名称 。
##### 为什么需要volumeClaimTemplate？
* 对于有状态的副本集都会用到持久存储，对于分布式系统来讲，它的最大特点是数据是不一样的，所以各个节点不能使用同一存储卷，每个节点有自已的专用存储，但是如果在Deployment中的Pod template里定义的存储卷，是所有副本集共用一个存储卷，数据是相同的，因为是基于模板来的 ，而statefulset中每个Pod都要自已的专有存储卷，所以statefulset的存储卷就不能再用Pod模板来创建了，于是statefulSet使用volumeClaimTemplate，称为卷申请模板，它会为每个Pod生成不同的pvc，并绑定pv， 从而实现各pod有专用存储。这就是为什么要用volumeClaimTemplate的原因。

#### StatefulSet使用场景：

* 稳定的持久化存储，即Pod重新调度后还是能访问到相同的持久化数据，基于PVC来实现。
* 稳定的网络标识符，即Pod重新调度后其PodName和HostName不变。
* 有序部署，有序扩展，基于init containers来实现。
* 有序收缩。