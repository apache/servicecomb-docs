### 在集群模式下部署服务中心（Service-Center）

服务中心是无状态应用，其使用 etcd 作为对象存储保存微服务的元数据。

搭建单机版服务中心，服务中心发布版本默认内置一个 etcd，开箱即用；用户亦可以通过简单配置方式外接指定的 etcd 环境。

搭建服务中心集群，首先需要部署 etcd 集群，其次对服务中心做简单配置即可实现集群管理，如下举例简单说明，

准备工作：
1. 两个VM（虚拟机），分别安装一个服务中心实例

| Name    | Address     |  
| :-----: | :---------: |  
| VM1     | 10.12.0.1   |   
| VM2     | 10.12.0.2   |  

2. [etcd集群](https://github.com/etcd-io/etcd/blob/master/Documentation/op-guide/container.md) 已安装部署就绪，服务开放端口为 http://10.12.0.4:2379

3. 运行环境为 Linux

##### Step 1

下载 [服务中心版本](http://servicecomb.apache.org/release/) ，如：[ServiceComb Service-Center 1.1.0](https://apache.org/dyn/closer.cgi/servicecomb/servicecomb-service-center/1.1.0/)

``` shell
# Untar the release
tar -xvf service-center-X.X.X-linux-amd64.tar.gz
```

注意：请勿运行 start.sh 脚本，因为该脚本会启动版本默认内置的 etcd。

##### Step 2
配置服务中心运行参数，配置文件默认为发布包的 /conf/app.conf，打开文件编辑如下字段

###### VM1
``` shell
#Replace the below values
httpaddr = 10.12.0.1
manager_cluster = "10.12.0.4:2379"
```

###### VM2
``` shell
#Replace the below values
httpaddr = 10.12.0.2
manager_cluster = "10.12.0.4:2379"
```

注意：在 `manger_cluster` 中，可以将 etcd 的多个实例放在集群中

``` shell
manager_cluster= "10.12.0.4:2379,10.12.0.X:2379,10.12.0.X:2379"
```

#### Step 4
验证实例是否已成功运行,调用API：curl http://10.12.0.1:30101/v4/default/registry/health
``` json
{
    "instances": [
        {
            "instanceId": "d6e9e976f9df11e7a72b286ed488ff9f",
            "serviceId": "d6e99f4cf9df11e7a72b286ed488ff9f",
            "endpoints": [
                "rest://10.12.0.1:30100"
            ],
            "hostName": "service_center_10_12_0_1",
            "status": "UP",
            "healthCheck": {
                "mode": "push",
                "interval": 30,
                "times": 3
            },
            "timestamp": "1516012543",
            "modTimestamp": "1516012543"
        },
        {
            "instanceId": "16d4cb35f9e011e7a58a286ed488ff9f",
            "serviceId": "d6e99f4cf9df11e7a72b286ed488ff9f",
            "endpoints": [
                "rest://10.12.0.2:30100"
            ],
            "hostName": "service_center_10_12_0_2",
            "status": "UP",
            "healthCheck": {
                "mode": "push",
                "interval": 30,
                "times": 3
            },
            "timestamp": "1516012650",
            "modTimestamp": "1516012650"
        }
    ]
}
```

可以看到服务中心可以自动发现在集群中运行的所有实例。

#### Step 5
在基于ServiceComb微服务SDK [servicecomb-java-chassis](https://github.com/apache/servicecomb-java-chassis) 构建的微服务工程中，通过配置 `microservice.yaml` 文件中的 `servicecomb.service.registry.address` 参数，使微服务自动发现集群中所有的实例。

``` yaml
servicecomb:
  service:
    registry:
      address: "http://10.12.0.1:30100,http://10.12.0.2:30100"
      autodiscovery: true
```

注：允许配置一个或多个服务中心的实例地址，配置多个服务中心实例的场景可以起到单点故障备份的作用
