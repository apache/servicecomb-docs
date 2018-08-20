## Highway RPC Protocol
### Concept Description

Highway is a high-performance proprietary protocol of ServiceComb, and you can use it in scenarios having special performance requirements.

### Configuration

To use the Highway communication channel, you need to add the following dependencies in the maven pom.xml file:

```xml
<dependency> 
  <groupId>org.apache.servicecomb</groupId>  
  <artifactId>transport-highway</artifactId> 
</dependency>
```

Configuration items that need to be set in the microservice.yaml file are described as follows:

Table 3 Configuration items of Highway

| Configuration Item                       | Default Value | Value Range | Mandatory | Description                              | Remark                                   |
| :--------------------------------------- | :------------ | :---------- | :-------- | :--------------------------------------- | :--------------------------------------- |
| servicecomb.highway.address                      | 0.0.0.0:7070  | -           | No        | Specifies the server listening IP address. | -                                        |
| servicecomb.highway.server.thread-count          | 1             | -           | No        | Specifies the number of server network threads. | -                                        |
| servicecomb.highway.client.thread-count          | 1             | -           | No        | Specifies the number of client network threads. | -                                        |
| servicecomb.highway.client.connection-pool-per-thread | 1             | -           | No        | Specifies the number of connection pools in each client thread. | -                                        |
| servicecomb.request.timeout                      | 30000         | -           | No        | Specifies the request timeout duration.  | The configuration of this parameter for Highway is the same as that for REST over Vertx. |
| servicecomb.references.\[服务名\].transport         | rest          |             | No        | Specifies the accessed transport type.   | The configuration of this parameter for Highway is the same as that for REST over Vertx. |
| servicecomb.references.\[服务名\].version-rule      | latest        | -           | No        | Specifies the version of the accessed instance. | The configuration of this parameter for Highway is the same as that for REST over Vertx. |

### 

An example of the configuration in the microservice.yaml file for Highway is as follows:

```yaml
servicecomb:
  highway:
    address: 0.0.0.0:7070
```
