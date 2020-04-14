# ServiceComb Kie Client 配置项

* 基本配置

  |配置项名称|版本|缺省值|功能描述|
  |---|---|---|---|
  |servicecomb.kie.client.eventLoopSize||2|event loop 线程数|
  |servicecomb.kie.client.verticalInstanceCount||1|verticle instances 数量|
  |servicecomb.kie.client.timeout.connection||1000|连接超时时间|
  |servicecomb.kie.client.idleTimeoutInSeconds||60|HTTP 连接闲置超时时间|

* 请求超时配置

  不支持。

* SSL 配置

  参考 [使用TLS通信](../security/tls.md)。 tag 为 `kie.consumer`。

* Proxy 配置

  参考 [代理设置](../general-development/proxy.md)
