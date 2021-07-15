## Fallback
### Concepts

A fallback policy is applied when a service request is abnormal.

There are three key concepts in fallback: isolation, circuit breaking, and fault tolerance:

* **Isolation** is an exception detection mechanism. There are two common "exception"s: timeout and overload, which can be controlled by timeout duration and max concurrent requests.
* **Circuit breaking** is an exception response mechanism which depends on isolation. Circuit breaking is triggered by the error rate, like the number of bad requests, or the rate of invalid calls.
* **Fault tolerance** is an exception handling mechanism that depends on circuit breaking. Fault tolerance is called after a circuit breaking is triggered. Users can set the number of fault tolerance calls in the configuration.

Let's combine the 3 concepts: the **isolation** mechanism detects there are M(the threshold) errors in N requests, the **circuit breaking** is triggered and make sure there are no more requests sent, and then **fault tolerance** method is called. Technically the concept definition is the same with Netflix Hystrix, making it easy to understand the config items(Reference: [Hystrix Configuration]([https://github.com/Netflix/Hystrix/wiki/Configuration](https://github.com/Netflix/Hystrix/wiki/Configuration))). ServiceComb provides 2 fault tolerance methods: returning null values and throwing exceptions.

### Scenario

Users configure a fallback policy to handle microservices' exceptions.

### Configuration

Configuration items can be set to be applied to all APIs or a particular method of a microservice.

### Configuration Scope

- Configuration by type: items can be applied to Providers and Consumers
- Configuration by scope: items can be applied to a specific microservice, or [x-schema-id+operationId]

All the items in this chapter can be configured in the following format:

```
servicecomb.[namespace].[type].[MicroServiceName].[interface name].[property name]
```

The type can be Consumer or Provider. Specify the [MicroServiceName] to apply configuration to specific microservice. To make the configuration applied to API, we have to specify the API name in the format x-[schema-id+operationId]

The possible Isolation config items are as follows:

```
servicecomb.isolation.Consumer.timeout.enabled
servicecomb.isolation.Consumer.DemoService.timeout.enabled
servicecomb.isolation.Consumer.DemoService.hello.sayHello.timeout.enabled
servicecomb.isolation.Provider.timeout.enabled
servicecomb.isolation.Provider.DemoService.timeout.enabled
servicecomb.isolation.Provider.DemoService.hello.sayHello.timeout.enabled
```



### Configuration Items

For Providers, the configuration item should be: servicecomb.isolation.Consumer.timeout.enabled

For Consumers, the conriguration item should be servicecomb.isolation.Provider.timeout.enabled

**Table 1-1 The fallback policy config items**

| Configuration Item                                   | Default value  | Value Range                   | Required | Description                                                  | Tips                                                         |
| :--------------------------------------------------- | :------------- | :---------------------------- | :------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| servicecomb.isolation.[type].timeout.enabled                | FALSE          | -                             | No       | Enable timeout detection or not.                             |                                                              |
| servicecomb.isolation.[type].timeoutInMilliseconds          | 30000          | -                             | No       | The timeout duration threshold.                              |                                                              |
| servicecomb.isolation.[type].maxConcurrentRequests          | 10             | -                             | No       | The maximum number of concurrent requests.                   |                                                              |
| servicecomb.circuitBreaker.[type].enabled                   | TRUE           | -                             | No       | Enable circuit breaking or not.                              |                                                              |
| servicecomb.circuitBreaker.[type].forceOpen                 | FALSE          | -                             | No       | Force circuit breaker to be enabled regardless of the number of errors. |                                                              |
| servicecomb.circuitBreaker.[type].forceClosed               | FALSE          | -                             | No       | Force circuit breaker to be disabled.                        | When forceOpen and forceClose are set at the same time, forceOpen will take effect. |
| servicecomb.circuitBreaker.[type].sleepWindowInMilliseconds | 15000          | -                             | No       | How long to recover from a circuit breaking.                 | After the recovery, the number of failures will be reset. Note: If the call fails immediately after a recover, the circuit breaker is triggered immediately again. |
| servicecomb.circuitBreaker.[type].requestVolumeThreshold    | 20             | -                             | No       | The threshold of failed requests within 10 seconds. If the threshold is reached, circuit breaker is triggered. | The 10 seconds duration is splitted evenly into 10 segments for error calculation. The calculation will start after 1 second. So circuit breakers are triggered after at least 1 second. |
| servicecomb.circuitBreaker.[type].errorThresholdPercentage  | 50             | -                             | No       | The threshold of error rate. If the threshold is reached, circuit breaker is triggered. |                                                              |
| servicecomb.fallback.[type].maxConcurrentRequests           | 10             | -                             | No       | The max number of concurrent fallback(specified by servicecomb.fallbackpolicy.policy) calls. When the threshold is reached, the fallback method is not called by return exception directly. |                                                              |
| servicecomb.fallbackpolicy.[type].policy                    | throwException | returnNull \| throwException | No       | The fallback policy when errors occurred.                    |                                                              |

**Caution:** Be cautious to set servicecomb.isolation.timeout.enabled to true. All handlers in the handler chain are asynchronously executed, the intermediate handlers' return will make the follow-up handlers processing abandoned. Therefore, we recommend to set servicecomb.isolation.timeout.enabled to be false(by default) and set the network timeout duration servicecomb.request.timeout to 30000.



## Sample Code

```yaml
servicecomb:
  handler:
    chain:
      Consumer:
        default: bizkeeper-consumer
  isolation:
    Consumer:
      timeout:
        enabled: true
      timeoutInMilliseconds: 30000
  circuitBreaker:
    Consumer:
      sleepWindowInMilliseconds: 15000
      requestVolumeThreshold: 20
  fallback:
    Consumer:
      enabled: true
  fallbackpolicy:
    Consumer:
      policy: throwException
```

> **NOTE:**
>
> You need to enable service governance for fallback. The corresponding provider handler  `bizkeeper-provider`, and the consumer handler is `bizkeeper-consumer`.
