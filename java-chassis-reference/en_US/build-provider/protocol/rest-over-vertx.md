## REST over Vertx
### Configuration

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


| Configuration Item | Default Value | Range | Required | Description | Remark |
| :--- | :--- | :--- | :--- | :--- | :--- |
| servicecomb.rest.address | 0.0.0.0:8080 | - | No | Service listening address | Only for providers |
| servicecomb.rest.server.thread-count | 1 | - | No | Server's thread number | Only for providers |
| servicecomb.rest.server.connection-limit | Integer.MAX_VALUE | - | No | Max allowed client connections | Only for providers |
| servicecomb.rest.server.connection.idleTimeoutInSeconds | 60 | - | No | Timeout for server's idle connection | The idle connections will be recycled |
| servicecomb.rest.client.thread-count | 1 | - | No | Client's thread number | Only for consumers |
| servicecomb.rest.client.connection.maxPoolSize | 5 | - | No | Max connection number of each pool | connection number = thread number \* pool number \* pool connection number |
| servicecomb.rest.client.connection.idleTimeoutInSeconds | 30 | - | No | The timeout of client idle connection| The idle connections will be recycled  |
| servicecomb.rest.client.connection.keepAlive | true | - | No | Use long lived connection or not |  |
| servicecomb.request.timeout | 30000 | - | No | Request timeout |  |
| servicecomb.references.\[ServiceName\].transport | rest |  | No | The transport type to access | Only for consumers |
| servicecomb.references.\[ServiceName\].version-rule | latest | - | No | The version of instance to access | Only for consumers. The supported rules including latest，1.0.0+，1.0.0-2.0.2，or accurate version. For details, please refer to the service center interface description |

### Sample Code

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

