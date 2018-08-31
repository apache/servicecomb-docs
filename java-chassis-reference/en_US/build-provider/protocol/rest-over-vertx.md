## REST over Vertx
### Configuration

The REST over Vertx communication channel uses the standalone running mode that can be started using the main function. In the main function, you need to initialize logs and load service configuration. The code is as follow:

```java
import org.apache.servicecomb.foundation.common.utils.BeanUtils;
import org.apache.servicecomb.foundation.common.utils.Log4jUtils;

public class MainServer {
  public static void main(String[] args) throws Exception {
  　Log4jUtils.init();//Log initialization
  　BeanUtils.init(); // Spring bean initialization
  }
}
```

To use the REST over Vertx communication channel, you need to add the following dependencies in the maven pom.xml file:

```xml
<dependency>
　　<groupId>org.apache.servicecomb</groupId>
　　<artifactId>transport-rest-vertx</artifactId>
</dependency>
```

Configuration items that need to be set in the microservice.yaml file are described as follows:

Table 2 Configuration items of REST over Vertx

| Configuration Item                       | Default Value | Value Range | Mandatory | Description                              | Remark                                   |
| :--------------------------------------- | :------------ | :---------- | :-------- | :--------------------------------------- | :--------------------------------------- |
| servicecomb.rest.address                         | 0.0.0.0:8080  | -           | No        | Specifies the server listening IP address. | Only service providers require this parameter. |
| servicecomb.rest.server.thread-count             | 1             | -           | No        | Specifies the number of server threads.  | Only service providers require this parameter. |
| servicecomb.rest.client.thread-count             | 1             | -           | No        | Specifies the number of client network threads. | Only service consumers require this parameter. |
| servicecomb.rest.client.connection-pool-per-thread | 1             | -           | No        | Specifies the number of connection pools in each client thread. | Only service consumers require this parameter. |
| servicecomb.request.timeout                      | 30000         | -           | No        | Specifies the request timeout duration.  |                                          |
| servicecomb.references.\[服务名\].transport         | rest          |             | No        | Specifies the accessed transport type.   | Only service consumers require this parameter. |
| servicecomb.references.\[服务名\].version-rule      | latest        | -           | No        | Specifies the version of the accessed instance. | Only service consumers require this parameter. You can set it to latest, a version range such as 1.0.0+ or 1.0.0-2.0.2, or a specific version number. For details, see the API description of the service center. |

### Sample Code

An example of the configuration in the microservice.yaml file for REST over Vertx is as follows:

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