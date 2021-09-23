# REST Transport Client 配置项

* 基本配置

  REST Trasnport Client 分为 HTTP 和 HTTP2, 它们共享很多配置项。下表中配置项名称包含 `http2` 的配置项， 是 HTTP2 独有的。
  HTTP2协议依赖于HTTP协议，HTTP和HTTP2的连接池是共享的，在使用HTTP2的情况下，同样需要配置HTTP的连接池参数。比如：

    servicecomb:
      rest:
        client:
          connection:
            maxPoolSize: 50
          http2:
            maxPoolSize: 5

  连接池在计算是否超过大小的时候，会同时检查这两个配置项。假设访问的服务器为H，那么上述配置，和H建立的最大连接可能性为
  HTTP:HTTP2=50:0, HTTP:HTTP2=0:5, HTTP:HTTP2=20:3等。一个客户端和H建立的总的连接数还和servicecomb.rest.client.verticle-count
  有关。可以理解为每个vertical会针对H创建一个连接池，连接池个数为vertical-count。

  由于HTTP和HTTP2协议之间这种紧密的关系，在使用HTTP2的情况下，其他相关的HTTP参数建议一并需要合理设置，比如连接闲置超时时间等。

  |配置项名称|版本|缺省值|功能描述|
  |---|---|---|---|
  |servicecomb.rest.client.enabled|2.0.2|true|是否启用Rest Transport Client, HTTP 1|
  |servicecomb.rest.client.verticle-count||[备注1](#note1)|[备注2](#note2)|
  |servicecomb.rest.client.thread-count|废弃||同verticle-count|
  |servicecomb.rest.client.connection.timeoutInMillis|2.0.2|1000|连接超时时间|
  |servicecomb.rest.client.connection.idleTimeoutInSeconds||30|HTTP 连接闲置超时时间|
  |servicecomb.rest.client.connection.compression||false|是否启用压缩|
  |servicecomb.rest.client.maxWaitQueueSize||-1|HTTP HTTP2 等待队列大小|
  |servicecomb.rest.client.connection.maxPoolSize||5|HTTP 客户端连接池大小|
  |servicecomb.rest.client.connection.keepAlive||true|HTTP 连接是否保活|
  |servicecomb.rest.client.maxHeaderSize||8192|HTTP 最大头部限制|
  |servicecomb.rest.client.http2.enabled|2.0.2|true|是否启用Rest Transport Client，HTTP 2|
  |servicecomb.rest.client.http2.useAlpnEnabled||true||
  |servicecomb.rest.client.http2.multiplexingLimit||-1|一条连接中，同时支持的最大的stream并发量，-1表示不限制。最终以服务端的concurrentStreams和客户端的multiplexingLimit较小值为准。|
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

