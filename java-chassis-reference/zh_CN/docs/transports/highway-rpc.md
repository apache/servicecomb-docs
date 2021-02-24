# Highway

## 概念阐述

Highway是ServiceComb的高性能私有协议，用户可根据实际需求选择使用。

## 配置说明

使用Highway网络通道需要在maven pom文件中添加如下依赖：

```xml
 <dependency>
     <groupId>org.apache.servicecomb</groupId>
     <artifactId>transport-highway</artifactId>
 </dependency>
```

Highway通道在microservice.yaml文件中的配置项如下表所示：

表1-1Highway配置项说明

| 配置项                                         | 默认值                                          | 含义                                      |
| :--------------------------------------------- | :---------------------------------------------- | :---------------------------------------- |
| servicecomb.highway.address                    |                                                 | 服务监听地址，不配置表示不监听            |
| servicecomb.highway.server.connection-limit    | Integer.MAX_VALUE                               | 允许客户端最大连接数                      |
| servicecomb.highway.server.thread-count        | [verticle-count](verticle-count.md) | highway server verticle实例数(Deprecated) |
| servicecomb.highway.server.verticle-count      | [verticle-count](verticle-count.md) | highway server verticle实例数             |
| servicecomb.highway.client.thread-count        | [verticle-count](verticle-count.md) | highway client verticle实例数(Deprecated) |
| servicecomb.highway.client.verticle-count      | [verticle-count](verticle-count.md) | highway client verticle实例数             |
| servicecomb.Provider.requestWaitInPoolTimeout${op-priority}| 30000 |在同步线程中排队等待执行的超时时间，单位为毫秒 |
| servicecomb.highway.server.requestWaitInPoolTimeout | 30000       |同servicecomb.Provider.requestWaitInPoolTimeout${op-priority}, 该配置项优先级更高。       |

## 示例代码

microservice.yaml文件中的配置示例：

```yaml
servicecomb:
  highway:
    address: 0.0.0.0:7070
```



