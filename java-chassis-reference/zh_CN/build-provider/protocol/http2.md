## 场景描述

用户通过简单的配置即可启用Http2进行通信，提高性能。

## 外部服务通信配置

与外部服务通信相关的配置写在microservice.yaml文件中。

* 启用h2\(Http2 + TLS\)进行通信  
  服务端在配置服务监听地址时，可以通过在地址后面追加`?sslEnabled=true`开启TLS通信，具体介绍见[使用TLS通信](../../security/tls.md)章节。然后再追加`&protocol=http2`启用h2通信。示例如下：

  ```yaml
  servicecomb:
    rest:
      address: 0.0.0.0:8080?sslEnabled=true&protocol=http2
    highway:
      address: 0.0.0.0:7070?sslEnabled=true&protocol=http2
  ```

* 启用h2c\(Http2 without TLS\)进行通信  
  服务端在配置服务监听地址时，可以通过在地址后面追加`?protocol=http2`启用h2c通信。示例如下：

  ```yaml
  servicecomb:
    rest:
      address: 0.0.0.0:8080?protocol=http2
    highway:
      address: 0.0.0.0:7070?protocol=http2
  ```

* 客户端会通过从服务中心读取服务端地址中的配置来使用http2进行通信。 

具体实例可以参考 [http2-it-tests](https://github.com/apache/incubator-servicecomb-java-chassis/blob/master/integration-tests/it-consumer/src/main/java/org/apache/servicecomb/it/ConsumerMain.java)

## http2 provider 端配置项

| 配置项 | 默认值 |   是否必选 | 含义 | 注意| 
|------|---------|-----------|-----|---------|
|servicecomb.rest.server.http2.useAlpnEnabled| true| 否| 是否启用 ALPN| 无|
|servicecomb.rest.server.http2.concurrentStreams| 100 | 否| http2 Server 端同时支持的最大的 stream 并发量| 可以结合实际情况调整, 如果server 端和client 端同时设置了 stream 并发量限制, 实际较小的生效|

## http2 client 端配置项

| 配置项 | 默认值 |   是否必选 | 含义 | 注意| 
|------|---------|-----------|-----|---------|
|servicecomb.rest.client.http2.useAlpnEnabled|true| 否| 是否启用 ALPN| 无|
|servicecomb.rest.client.http2.multiplexingLimit| -1 | 否|http2 client 端同时支持的最大的 stream 并发量| -1 代表不限制. 如果server 端和client 端同时设置了 stream 并发量限制, 实际较小的生效 |
|servicecomb.rest.client.http2.maxPoolSize| 1 | 否| client 端 http2 连接池的最大数量| 无|
|servicecomb.rest.client.http2.idleTimeoutInSeconds | 0 |否| htttp2　连接空闲断开的最长时间 | 建议结合实际情况适当配置|

