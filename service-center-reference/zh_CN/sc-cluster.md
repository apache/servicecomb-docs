###在群集模式下部署Service-Center

由于服务中心是无状态应用程序，因此可以在群集模式下无缝部署以实现HA。
SC依赖于etcd来存储微服务信息，因此您可以选择独立运行etcd或在[cluster]中运行（https://github.com/coreos/etcd/blob/master/Documentation/op-guide/container.md ）模式。
完成以群集或独立模式安装etcd后，您可以按照以下步骤运行服务中心。

假设您要在VM上安装2个Service-Center实例，并提供以下详细信息

| Name    | Address     |  
| :-----: | :---------: |  
| VM1     | 10.12.0.1   |   
| VM2     | 10.12.0.2   |  

这里我们假设您的etcd在http://10.12.0.4:2379上运行（您可以关注[this]（https://github.com/coreos/etcd/blob/master/Documentation/op-guide/container.md ）指导在集群模式下安装etcd。）

##### Step 1

从所有VM上的[here]（https://github.com/apache/incubator-servicecomb-service-center/releases）下载SC版本。

```
# Untar the release
# tar -xvf service-center-X.X.X-linux-amd64.tar.gz

```

注意：请不要运行start.sh，因为它也会启动etcd。

##### Step 2
编辑ip/port(SC运行需要)和etcd ip的配置

###### VM1
```
# vi conf/app.conf
#Replace the below values
httpaddr = 10.12.0.1
manager_cluster = "10.12.0.4:2379"

# Start the Service-center
./service-center
```

###### VM2
```
# vi conf/app.conf
#Replace the below values
httpaddr = 10.12.0.2
manager_cluster = "10.12.0.4:2379"

# Start the Service-center
./service-center
```

注意：在`manger_cluster`中，你可以将etcd的多个实例放在集群中

```
manager_cluster= "10.12.0.4:2379,10.12.0.X:2379,10.12.0.X:2379"
```

#### Step 4
Verify your instances
```
# curl http://10.12.0.1:30101/v4/default/registry/health
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

我们在这里可以看到Service-Center可以自动发现在集群中运行的Service-Center的所有实例，[Java-Chassis SDK]使用此自动发现功能（https://github.com/apache / incubator-servicecomb-java-chassis）通过了解集群中运行的服务中心的至少1个IP来自动发现服务中心的所有实例。

在您的microservice.yaml中，您可以提供实例或任何一个实例的SC IP，sdk可以自动发现其他实例，并使用其他实例在第一个实例失败的情况下获取微服务详细信息。
```
cse:
  service:
    registry:
      address: "http://10.12.0.1:30100,http://10.12.0.2:30100"
      autodiscovery: true
```
在这种情况下，sdk将能够发现集群中SC的所有实例。

