# Service Center Client 配置项

* 基本配置

  |配置项名称|版本|缺省值|功能描述|
  |---|---|---|---|
  |servicecomb.service.registry.client.eventLoopPoolSize||4|event loop 线程数|
  |servicecomb.service.registry.client.instances||1|verticle instances 数量|
  |servicecomb.service.registry.client.httpVersion||1.1|HTTP协议版本|
  |servicecomb.service.registry.client.timeout.connection||1000|连接超时时间|
  |servicecomb.service.registry.client.timeout.idle||60|HTTP 连接闲置超时时间|
  |servicecomb.service.registry.client.workerPoolSize||4|work线程池大小，仅供 web socket 使用|

* 请求超时配置

  `servicecomb.service.registry.client.timeout.heartbeat` 设置心跳请求超时时间，默认为 3, 000 毫秒；
  `servicecomb.service.registry.client.timeout.request` 设置其他请求超时时间，默认为 30, 000 毫秒。

* SSL 配置

  参考 [使用TLS通信](../security/tls.md)。 tag 为 `sc.consumer`。

* Proxy 配置

  参考 [代理设置](../general-development/proxy.md)
