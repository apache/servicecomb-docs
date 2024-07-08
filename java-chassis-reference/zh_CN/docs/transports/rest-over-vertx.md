# REST over HTTP（Vert.x)

## 开发介绍

参考 [Spring Boot集成Java Chassis介绍](../spring-boot/introduction.md) ，高性能模式使用 REST over HTTP（Vert.x）。 

application.yaml 文件中的配置示例：

```yaml
servicecomb:
  rest:
    address: 0.0.0.0:8080
    server:
      verticle-count: 8
```

其中 `0.0.0.0:8080` 代表使用HTTP协议，并且监听8080端口。可以通过在地址后面追加`sslEnabled=true`使用HTTPS通信，具体介绍见[使用TLS通信](../security/tls.md)章节。

## 配置参考

REST over HTTP（Vert.x)有以下配置项：

| 配置项                                                         | 默认值                                 | 含义                                                                       |
|:------------------------------------------------------------|:------------------------------------|:-------------------------------------------------------------------------|
| servicecomb.rest.address                                    |                                     | 服务监听地址，不配置表示不监听                                                          |
| servicecomb.rest.server.thread-count                        | [verticle-count](verticle-count.md) | rest server verticle实例数（Deprecated）                                      |
| servicecomb.rest.server.verticle-count                      | [verticle-count](verticle-count.md) | rest server verticle实例数                                                  |
| servicecomb.rest.server.connection-limit                    | Integer.MAX_VALUE                   | 允许客户端最大连接数                                                               |
| servicecomb.rest.server.connection.idleTimeoutInSeconds     | 60                                  | 服务端连接闲置超时时间，超时连接会被释放                                                     |
| servicecomb.rest.server.compression                         | false                               | 服务端是否支持启用压缩                                                              |
| servicecomb.rest.server.maxInitialLineLength                | 4096                                | 服务端接收请求的最大 initial line 长度，单位字节                                          |
| servicecomb.rest.server.maxHeaderSize                       | 32768                               | 服务端接收请求的最大header长度，单位字节                                                  |
| servicecomb.rest.server.maxFormAttributeSize                | 8192                                | 服务端接收请求的最大 form 长度，单位为字节                                                 |
| servicecomb.rest.server.compressionLevel                    | 6                                   | 服务端gzip/deflate压缩级别                                                      |
| servicecomb.rest.server.maxChunkSize                        | 8192                                | 最大http chunk大小，单位为字节                                                     |
| servicecomb.rest.server.decoderInitialBufferSize            | 128                                 | HttpObjectDecoder的最大初始缓冲区大小                                              |
| servicecomb.rest.server.http2ConnectionWindowSize           | -1                                  | 允许HTTP/2连接数大小，无限制                                                        |    
| servicecomb.rest.server.decompressionSupported              | false                               | 是否支持解压缩                                                                  |
| servicecomb.Provider.requestWaitInPoolTimeout${op-priority} | 30000                               | 在同步线程中排队等待执行的超时时间，单位为毫秒                                                  |
| servicecomb.rest.server.requestWaitInPoolTimeout            | 30000                               | 同servicecomb.Provider.requestWaitInPoolTimeout${op-priority}, 该配置项优先级更高。 |                                     | 客户端接收响应的最大header长度，单位字节      |
| servicecomb.uploads.maxSize                                 | 无限制                                 | 最大 body 大小，这个配置项对文件上传，REST请求都生效                                          |

## 补充说明

* 极限连接数计算 
 
假设在微服务A调用B的情况下，微服务A和B各有10个实例，微服务A的配置为：

  * servicecomb.rest.client.verticle-count配置为8
  * servicecomb.rest.client.connection.maxPoolSize配置为5
  * 微服务B有10个实例  

站在A的角度，在极限情况下：
  * 一个实例最多会建立400条连接。（`8 * 5 * 10 = 400`）  
  * 假设该A还需要调用微服务C，微服务C也有10个实例，则最多再建立400条连接，共800条连接

站在B的角度，在极限情况下：
  * 一个A的实例最多建立40条连接。(`8 * 5 = 40`)  
  * 10个A的实例最多会向一个B建立`40 * 10 = 400`条连接

为了提高性能，需要尽量使用更大的连接池，但是更大的连接池又可能会导致连接数暴涨，当微服务实例规模达到百级别时，有的进程可能需要管理
几万条连接，业务需要根据实际业务规模进行合理的规划。在实例规模比较小的情况下，HTTP仍然是所有应用程序的最佳选择，它具备更好的兼容性
和可靠性。当单个实例的连接数管理规模超过1万的时候，可以考虑切换为[http2](http2.md)。

## 客户端配置

参考 [REST Transport Client 配置项](../config-reference/rest-transport-client.md) 
