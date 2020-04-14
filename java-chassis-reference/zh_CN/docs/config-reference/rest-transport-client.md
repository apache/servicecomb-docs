# REST Transport Client 配置项

* 基本配置

  REST Trasnport Client 分为 HTTP 和 HTTP 2, 它们共享很多配置项。包含 `http2` 的配置项， 是 HTTP 2 独有的。

  |配置项名称|版本|缺省值|功能描述|
  |---|---|---|---|
  |servicecomb.rest.client.enabled|2.0.2|true|是否启用Rest Transport Client, HTTP 1|
  |servicecomb.rest.client.verticle-count||[备注1](#note1)|[备注2](#note2)|
  |servicecomb.rest.client.thread-count|废弃||同verticle-count|
  |servicecomb.rest.client.connection.timeoutInMillis|2.0.2|1000|连接超时时间|
  |servicecomb.rest.client.connection.idleTimeoutInSeconds||60|HTTP 连接闲置超时时间|
  |servicecomb.rest.client.connection.compression||false|是否启用压缩|
  |servicecomb.rest.client.maxWaitQueueSize||-1|HTTP HTTP2 等待队列大小|
  |servicecomb.rest.client.connection.maxPoolSize||5|HTTP 客户端连接池大小|
  |servicecomb.rest.client.connection.keepAlive||true|HTTP 连接是否保活|
  |servicecomb.rest.client.maxHeaderSize||8192|HTTP 最大头部限制|
  |servicecomb.rest.client.http2.enabled|2.0.2|true|是否启用Rest Transport Client，HTTP 2|
  |servicecomb.rest.client.http2.useAlpnEnabled||true||
  |servicecomb.rest.client.http2.multiplexingLimit||1||
  |servicecomb.rest.client.http2.maxPoolSize||1|HTTP2 客户端连接池大小|
  |servicecomb.rest.client.http2.idleTimeoutInSeconds|2.0.1|0|HTTP2 连接闲置超时时间|

* 请求超时配置

  可以针对每个具体的接口设置超时，配置项 `request.${op-any-priority}.timeout` ， 单位是毫秒，默认 30000。 举例：

        servicecomb.request.timeout=30000
        servicecomb.request.MyService.timeout=40000
        servicecomb.request.MyService.MySchema.MyOperation.timeout=50000


* SSL 配置

  参考 [使用TLS通信](../security/tls.md)。 tag 为 `rest.consumer`。

* Proxy 配置

  不支持。

**备注**:

1.  <a name="note1"></a> 如果CPU数小于8，则取CPU数。如果CPU数大于等于8，则为8。

2.  <a name="note2"></a> java-chassis 默认采用 vert.x 的 HTTP Client 功能，这个配置项对应的是 verticle instances 数量。 verticle instances 数量
   会影响并发资源分配。比如： 如果 verticle instances 为 2， maxPoolSize 为 5， 那么实际创建的连接数为 2*5=10。

