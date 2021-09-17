# REST over Vertx

## Configuration

The REST over Vertx communication channel runs in standalone mode, it can be started in the main function. In the main function, you need to initialize logs and load service configuration. The code is as follow:

```java
import org.apache.servicecomb.foundation.common.utils.BeanUtils;
import org.apache.servicecomb.foundation.common.utils.Log4jUtils;

public class MainServer {
  public static void main(String[] args) throws Exception {
  　Log4jUtils.init();// Log initialization
  　BeanUtils.init(); // Spring bean initialization
  }
}
```

To use the REST over Vertx communication channel, add the following dependencies in the maven pom.xml file:

```xml
<dependency>
　　<groupId>org.apache.servicecomb</groupId>
　　<artifactId>transport-rest-vertx</artifactId>
</dependency>
```

The REST over Vertx related configuration items in the microservice.yaml file are described as follows:

Table 1-1 Configuration items for REST over Vertx

| Configuration Item                                     | Default Value                                  | Description                                    |
| :----------------------------------------------------- | :--------------------------------------------- | :--------------------------------------------- |
|servicecomb.rest.address                                |                                                |listening address, empty for not listen, just a rest client |
|servicecomb.rest.server.connection-limit                |Integer.MAX_VALUE                               |Max allowed client connections                  |
|servicecomb.rest.server.thread-count                    |[verticle-count](verticle-count.md) |rest server verticle instance count(Deprecated) |
|servicecomb.rest.server.verticle-count                  |[verticle-count](verticle-count.md) |rest server verticle instance count             |
|servicecomb.rest.server.connection.idleTimeoutInSeconds |60                                              |Timeout for server's idle connection, The idle connections will be closed |
| servicecomb.rest.server.compression                    | false                                          | Wether the server support compression          |
| servicecomb.rest.server.maxInitialLineLength           | 4096                                           | The max initial line length of the request the server can process, unit is Byte |
| servicecomb.rest.server.maxHeaderSize                  | 32768                                          | The max header size of the request the server can process, unit is Byte |
| servicecomb.rest.server.maxFormAttributeSize           | 2048                                           | The max form attribute size of the request the server can process, unit is Byte |
| servicecomb.rest.server.compressionLevel               | 6                                              | The gzip/deflate compression level |
| servicecomb.rest.server.maxChunkSize                   | 8192                                           | The max HTTP chunk size, unit is Byte |
| servicecomb.rest.server.decoderInitialBufferSize       | 128                                            | The max initial buffer size for HttpObjectDecoder, unit is Byte |
| servicecomb.rest.server.http2ConnectionWindowSize      | -1                                             | HTTP/2 connection window size, unlimited    |
| servicecomb.rest.server.decompressionSupported         | false                                          | whether decompression is supported  |
|servicecomb.rest.client.thread-count                    |[verticle-count](verticle-count.md) |rest client verticle instance count(Deprecated) |
|servicecomb.rest.client.verticle-count                  |[verticle-count](verticle-count.md) |rest client verticle instance count             |
|servicecomb.rest.client.connection.maxPoolSize          |5                                               |The maximum number of connections in each connection pool for an IP:port combination |
|servicecomb.rest.client.connection.idleTimeoutInSeconds |30                                              |Timeout for client's idle connection, The idle connections will be closed |
|servicecomb.rest.client.connection.keepAlive            |true                                            |Whether to use long connections                 |
| servicecomb.rest.client.connection.compression         | false                                          | Wether the client support compression          |
| servicecomb.rest.client.maxHeaderSize                  | 8192                                           | The max header size of the response the client can process, unit is Byte |

### Supplementary Explanation

* The connection amount under extreme condition
  Assumption:
  * servicecomb.rest.client.thread-count = 8
  * servicecomb.rest.client.connection.maxPoolSize = 5
  * there are 10 instances of microservice A  

  In terms of client side, under the extreme condition:
  * for a client instance invoking microservice A, there are up to 400 connections.(`8 * 5 * 10 = 400`)
  * if this client instance is also invoking another microservice B, and there are 10 instances of microservice B, then there are another 400 connections, and 800 connections in total.

  In terms of server side, under the extreme condition:
  * a client instance establishes up to 40 connections to a server instance.(`8 * 5 = 40`)
  * `n` client instances establish up to `40 * n` connections to a server instance.

  To improve performance, larger connection pools are needed. While the larger connection pools means the more connections. When the microservice instance scale reaches hundreds, some instances may handle tens of thousands of connections. Therefore, the developers need to make reasonable planning according to the actual condition.
  The planning of HTTP1.1 may be relatively complex, and sometimes there is no proper solution, in which case the [http2](http2.md) is recommended.

## Sample Code

An example of the configuration in the microservice.yaml file for REST over Vertx:

```yaml
servicecomb:
  rest:
    address: 0.0.0.0:8080
    thread-count: 1
  references:
    hello:
      transport: rest
      version-rule: 0.0.1
```
