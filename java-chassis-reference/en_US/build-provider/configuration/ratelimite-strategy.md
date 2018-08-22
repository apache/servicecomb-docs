
## Rate Limiting Policy
### Scenario

Users at the provider end can use the rate limiting policy to limit the maximum number of requests sent from a specified microservice per second. 

### Precautions

1. There may be a small different between the rate limit and actual traffic.
2. The rate limit function at the provider end is for service rather than security purpose. To prevent distributed denial of service(DDos) attacks, you need to take other measures.
3. Traffic control is a microservice-level rather than process-level function.

### Configuration

　　Rate limiting policies are configured in the microservice.yaml file. For related configuration items, see Table 2. To enable the rate limiting policy at the provider end, you also need to configure the rate limiting handler on the server in the processing chain and add dependencies in the pom.xml file. 

　　An example of microservice.yaml file configuration is as follows,

```yaml
servicecomb:
  handler:
    chain:
      Provider:
        default: qps-flowcontrol-provider
```

　　Add dependencies of handler-flowcontrol-qps in the pom.xml file,

```xml
<dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>handler-flowcontrol-qps</artifactId>
    <version>1.0.0-m1</version>
</dependency>
```

　　**Table2 Configuration items of the QPS rate limit**

| Configuration Item                       | Default Value       | Value Range              | Mandatory | Description                              | Remarks                                  |
| :--------------------------------------- | :------------------ | :----------------------- | :-------- | :--------------------------------------- | :--------------------------------------- |
| servicecomb.flowcontrol.Provider.qps.enabled     | true                | true/false               | No        | Specifies whether to enable traffic control  at the provider end. | -                                        |
| servicecomb.flowcontrol.Provider.qps.limit.\[ServiceName\] | 2147483647（max int） | \(0,2147483647\]，Integer | No        | Specifies the number of requests allowed per second. | This parameter can only be configured for microservice |
| servicecomb.flowcontrol.Provider.qps.global.limit | 2147483647（max int） | (0,2147483647\]，Integer  | No        | Specifies the total number of requests allowed per second at the provider end | If no configuration is set for any specific microservices, this parameter takes effect |

## 