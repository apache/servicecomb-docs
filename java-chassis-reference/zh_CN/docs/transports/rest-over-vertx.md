# REST over Vertx

## 配置说明

REST over Vertx通信通道对应使用standalone部署运行模式，可直接通过main函数拉起。main函数中需要初始化日志和加载服务配置，代码如下：

```java
public class MainServer {
    public static void main(String[] args) throws Exception {
        Log4jUtils.init();//日志初始化
        BeanUtils.init(); // Spring bean初始化
    }
}
```

使用REST over Vertx网络通道需要在maven pom文件中添加如下依赖：

```xml
<dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>transport-rest-vertx</artifactId>
</dependency>
```

REST over Vertx通道在microservice.yaml文件中有以下配置项：

表1-1 REST over Vertx配置项说明

| 配置项                                                  | 默认值                                          | 含义                                          |
| :------------------------------------------------------ | :---------------------------------------------- | :-------------------------------------------- |
| servicecomb.rest.address                                |                                                 | 服务监听地址，不配置表示不监听                |
| servicecomb.rest.server.thread-count                    | [verticle-count](verticle-count.md) | rest server verticle实例数（Deprecated）      |
| servicecomb.rest.server.verticle-count                  | [verticle-count](verticle-count.md) | rest server verticle实例数                    |
| servicecomb.rest.server.connection-limit                | Integer.MAX_VALUE                               | 允许客户端最大连接数                          |
| servicecomb.rest.server.connection.idleTimeoutInSeconds | 60                                              | 服务端连接闲置超时时间，超时连接会被释放      |
| servicecomb.rest.server.compression                     | false                                           | 服务端是否支持启用压缩                        |
| servicecomb.rest.server.maxInitialLineLength            | 4096                                            | 服务端接收请求的最大 initial line 长度，单位字节 |
| servicecomb.rest.server.maxHeaderSize                   | 32768                                           | 服务端接收请求的最大header长度，单位字节      |
| servicecomb.rest.server.maxFormAttributeSize            | 8192                                            | 服务端接收请求的最大 form 长度，单位为字节   |
| servicecomb.rest.server.compressionLevel                | 6                                               | 服务端gzip/deflate压缩级别
| servicecomb.rest.server.maxChunkSize                    | 8192                                            | 最大http chunk大小，单位为字节         |
| servicecomb.rest.server.decoderInitialBufferSize        | 128                                             | HttpObjectDecoder的最大初始缓冲区大小   |
| servicecomb.rest.server.http2ConnectionWindowSize       | -1                                              | 允许HTTP/2连接数大小，无限制 |    
| servicecomb.rest.server.decompressionSupported          | false                                           | 是否支持解压缩  |
| servicecomb.Provider.requestWaitInPoolTimeout${op-priority}| 30000  |在同步线程中排队等待执行的超时时间，单位为毫秒 |
| servicecomb.rest.server.requestWaitInPoolTimeout | 30000        |同servicecomb.Provider.requestWaitInPoolTimeout${op-priority}, 该配置项优先级更高。       |                                     | 客户端接收响应的最大header长度，单位字节      |
| servicecomb.uploads.maxSize                             | 无限制                                           | 最大 body 大小，这个配置项对文件上传，REST请求都生效|

### 补充说明
* 极限连接数计算 
 
假设:  
  * servicecomb.rest.client.verticle-count配置为8
  * servicecomb.rest.client.connection.maxPoolSize配置为5
  * 微服务A有10个实例  

站在client的角度，在极限情况下：
  * 一个client调用微服务A，最多会建立400条连接。（`8 * 5 * 10 = 400`）  
  * 假设该client还需要调用微服务B，微服务B，也有10个实例，则最多再建立400条连接，共800条连接

站在server的角度，在极限情况下：
  * 一个client最多向一个server建立40条连接。(`8 * 5 = 40`)  
  * `n`个client最多会向一个server建立`40 * n`条连接

为了提高性能，需要尽量使用更大的连接池，但是更大的连接池又可能会导致连接数暴涨，当微服务实例规模达到百级别时，有的进程可能需要管理
几万条连接，业务需要根据实际业务规模进行合理的规划。在实例规模比较小的情况下，HTTP仍然是所有应用程序的最佳选择，它具备更好的兼容性
和可靠性。当单个实例的连接数管理规模超过1万的时候，可以考虑切换为[http2](http2.md)。

## 示例代码

microservice.yaml文件中的配置示例：

```yaml
servicecomb:
  rest:
    address: 0.0.0.0:8080
    server:
      verticle-count: 8
  references:
    hello:
      transport: rest
      version-rule: 0.0.1
```
