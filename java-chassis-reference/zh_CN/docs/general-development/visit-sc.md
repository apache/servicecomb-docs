## 概念阐述

系统通过[服务中心](https://github.com/apache/servicecomb-service-center)实现服务之间的发现。服务启动过程中，会向服务中心进行注册。在调用其他服务的时候，会从服务中心查询其他服务的实例信息，比如访问地址、使用的协议以及其他参数。服务中心支持使用PULL和PUSH两种模式通知实例变化。

开发者可以配置服务中心集群地址、连接参数以及心跳管理等。

## 配置说明



### 表1-1访问配置中心常用的配置项

| 配置项 | 参考/默认值 | 取值范围 | 是否必选 | 含义 | 注意 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| servicecomb.service.registry.address | http://127.0.0.1:30100 |  | 是 | 服务中心的地址信息，可以配置多个，用逗号分隔。 |  |
| servicecomb.service.registry.instance.watch | true |  | 否 | 是否采用PUSH模式监听实例变化。为false的时候表示使用PULL模式。 |  |
| servicecomb.service.registry.autodiscovery | false |  | 否 | 是否自动发现服务中心的地址。当需要配置部分地址，其他地址由配置的服务中心实例发现的时候，开启这个配置。 |  |
| servicecomb.service.registry.instance.healthCheck.interval | 30 |  | 否 | 心跳间隔。 |  |
| servicecomb.service.registry.instance.healthCheck.times | 3 |  | 否 | 允许的心跳失败次数。当连续第times+1次心跳仍然失败时则实例被sc下线。即interval \* (times + 1)决定了实例被自动注销的时间。如果服务中心等待这么长的时间没有收取到心跳，会注销实例。 |  |
| servicecomb.service.registry.instance.empty.protection | true |  | 否 | 当从服务中心查询到的地址为空的时候，是否覆盖本地缓存。这个是一种可靠性保护机制，避免实例异常批量下线导致的请求失败。 |  |
| servicecomb.service.registry.client.timeout.connection | 30000 |  | 连接超时时间 | 单位毫秒 |  |
| servicecomb.service.registry.client.timeout.request | 30000 |  | 请求超时时间 | 单位毫秒 |  |
| servicecomb.service.registry.client.timeout.idle | 60 |  | 连接闲置超时时间 | 单位秒 |  |
| servicecomb.service.registry.client.timeout.heartbeat | 3000 |  | 心跳超时时间 | 单位毫秒 |  |
| servicecomb.service.registry.client.instances | 1 |  | 否 | Service Registry客户端Verticle部署实例的个数 |  |
| servicecomb.service.registry.client.eventLoopPoolSize | 4 |  | 否 | Service Registry客户端Event Loop线程池大小 |  |
| servicecomb.service.registry.client.workerPoolSize | 4 |  | 否 | Service Registry客户端Worker线程池大小 |  |