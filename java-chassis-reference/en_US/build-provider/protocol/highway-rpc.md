## Highway RPC Protocol
### Concept Description

Highway is ServiceComb's private high-performance protocol, it's suitable for the performance sensitive scenarios.

### Configuration

To use the Highway channel, add the following dependencies in the pom.xml file:

```xml
<dependency> 
  <groupId>org.apache.servicecomb</groupId>  
  <artifactId>transport-highway</artifactId> 
</dependency>
```

The Highway configuration items in the microservice.yaml file are described below:

Table 1-1 Highway configuration items

| Configuration Item                                    | Default Value | Value Range | Required | Description                                  | Remark                                               |
| :---------------------------------------------------- | :------------ | :---------- | :------- | :------------------------------------------- | :--------------------------------------------------- |
| servicecomb.highway.address                           | 0.0.0.0:7070  | -           | No       | The address that the server listens          | -                                                    |
| servicecomb.highway.server.thread-count               | 1             | -           | No       | The number of server network threads         | -                                                    |
| servicecomb.highway.client.thread-count               | 1             | -           | No       | The max number of allowed client connections | -                                                    |
| servicecomb.highway.client.connection-pool-per-thread | 1             | -           | No       | The number of client network threads         | -                                                    |
| servicecomb.request.timeout                           | 30000         | -           | No       | The request timeout duration                 | The same with the configuration of "REST over Vertx" |
| servicecomb.references.\[servicename\].transport      | rest          |             | No       | The transport type of the request            | The same with the configuration of "REST over Vertx" |
| servicecomb.references.\[servicename\].version-rule   | latest        | -           | No       | The version of the requested instance.       | The same with the configuration of "REST over Vertx" |

### Sample code

An example of the Highway configuration in the microservice.yaml:

```yaml
servicecomb:
  highway:
    address: 0.0.0.0:7070
```
