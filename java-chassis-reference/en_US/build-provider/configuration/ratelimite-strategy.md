
## Rate Limiting Policy
### Scenario

Users can set the rate limiting policy in the provider's configuration. By setting the request frequency from a particular micro service, provider can limit the max number of requests per second.

### Cautions

1. There may be a small difference between the rate limit and actual traffic.
2. The provider's rate limit control is for service rather than security. To prevent distributed denial of service(DDos) attacks, you need to take other measures.
3. Traffic control is scoped to microservice rather than instance. Consume a consumer microservice has 3 instances, and calls a provider service. After configuring the rate limit policy, the provider won't distinguish which consumer instance makes the request, but take all requests together as the 'consume request' for rate limiting.

### Configuration

Rate limiting policies are configured in the microservice.yaml file. The table below shows all the configuration items. To enable the provider's rate limit policy, you also need to configure the rate limiting handler in the server's handler chain and add dependencies in the pom.xml file. 

- An example of rate limit configuration in microservice.yaml:

```yaml
servicecomb:
  handler:
    chain:
      Provider:
        default: qps-flowcontrol-provider
```

- Add the handler-flowcontrol-qps dependency in the pom.xml file:

```xml
<dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>handler-flowcontrol-qps</artifactId>
    <version>1.0.0-m1</version>
</dependency>
```

**QPS rate limit configuration items**

| Configuration Item                                         | Default Value         | Value Range               | Required | Description                                          | Remarks                                                      |
| :--------------------------------------------------------- | :-------------------- | :------------------------ | :------- | :--------------------------------------------------- | :----------------------------------------------------------- |
| servicecomb.flowcontrol.Provider.qps.enabled               | true                  | true/false                | No       | Enable provider's traffic control  or not            | -                                                            |
| servicecomb.flowcontrol.Provider.qps.limit.\[ServiceName\] | 2147483647（max int） | \(0,2147483647\]，Integer | No       | Specifies the number of requests allowed per second. | This parameter can be configured to microservice/schema/operation, the latter has a higher priorty |
| servicecomb.flowcontrol.Provider.qps.global.limit          | 2147483647（max int） | (0,2147483647\]，Integer  | No       | Specifies the provider's total number of requests    | If no configuration is set for any specific microservice, this parameter takes effect |

> **Notes:**
>
> The `ServiceName` in provider's rate limit config is the name of the consumer that calls the provider. While `schema` and `operation` is the provider's own config item. That is, the rate limit policy controls the consumer requests that  call the provider's schema or operation.