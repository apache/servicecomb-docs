# REST Transport Client 配置项

|配置项名称|版本|缺省值|功能描述|
|---|---|---|---|
|servicecomb.rest.client.verticle-count||备注1|备注2|
|servicecomb.rest.client.thread-count|废弃||同verticle-count|
|servicecomb.rest.client.maxWaitQueueSize||-1|HTTP HTTP2 等待队列大小|
|servicecomb.rest.client.connection.compression||false|HTTP HTTP2是否启用压缩|
|servicecomb.rest.client.http2.maxPoolSize||1|HTTP2 客户端连接池大小|
|servicecomb.rest.client.http2.multiplexingLimit||1||
|servicecomb.rest.client.http2.idleTimeoutInSeconds|2.0.1|0|HTTP2 连接闲置超时时间|
|servicecomb.rest.client.http2.useAlpnEnabled||true||
|servicecomb.rest.client.connection.maxPoolSize||5|HTTP 客户端连接池大小|
|servicecomb.rest.client.connection.idleTimeoutInSeconds||30|HTTP 连接闲置超时时间|
|servicecomb.rest.client.connection.keepAlive||true|HTTP 连接是否保活|
|servicecomb.rest.client.maxHeaderSize||8192|HTTP 最大头部限制|

**备注**:

1. 如果没有配置，或者配置的值小于8，为CPU的核数。 如果CPU核数小于8， 取8。
2. java-chassis 默认采用 vert.x 的 HTTP Client 功能，这个配置项对应的是 verticle instances 数量。 verticle instances 数量
   会影响并发资源分配。比如： 如果 verticle instances 为 2， maxPoolSize 为 5， 那么实际创建的连接数为 2*5=10。

