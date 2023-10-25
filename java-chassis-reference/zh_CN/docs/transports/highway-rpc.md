# Highway

## 开发说明

Highway是Java Chassis的高性能私有TCP协议, Highway协议支持proto-buffer编码。参考 [Spring Boot集成Java Chassis介绍](../spring-boot/introduction.md) ，建议在高性能模式使用Highway。

application.yaml 文件中的配置示例：

```yaml
servicecomb:
  highway:
    address: 0.0.0.0:7070
```

其中 `0.0.0.0:7070` 代表使用Highway协议，并且监听7070端口。可以通过在地址后面追加`sslEnabled=true`使用HTTPS通信，具体介绍见[使用TLS通信](../security/tls.md)章节。

## 配置说明

| 配置项                                                         | 默认值                                 | 含义                                                                       |
|:------------------------------------------------------------|:------------------------------------|:-------------------------------------------------------------------------|
| servicecomb.highway.address                                 |                                     | 服务监听地址，不配置表示不监听                                                          |
| servicecomb.highway.server.connection-limit                 | Integer.MAX_VALUE                   | 允许客户端最大连接数                                                               |
| servicecomb.highway.server.thread-count                     | [verticle-count](verticle-count.md) | highway server verticle实例数(Deprecated)                                   |
| servicecomb.highway.server.verticle-count                   | [verticle-count](verticle-count.md) | highway server verticle实例数                                               |
| servicecomb.highway.client.thread-count                     | [verticle-count](verticle-count.md) | highway client verticle实例数(Deprecated)                                   |
| servicecomb.highway.client.verticle-count                   | [verticle-count](verticle-count.md) | highway client verticle实例数                                               |
| servicecomb.Provider.requestWaitInPoolTimeout${op-priority} | 30000                               | 在同步线程中排队等待执行的超时时间，单位为毫秒                                                  |
| servicecomb.highway.server.requestWaitInPoolTimeout         | 30000                               | 同servicecomb.Provider.requestWaitInPoolTimeout${op-priority}, 该配置项优先级更高。 |

