## Fallback Policy

### Concept Description

A fallback policy is used when a service request is abnormal.

There are three key concepts in fallback: isolation, fallbreak, and fault tolerance:

* Isolation is an exception detection mechanism. Two common items that need to be detected are timeout duration and the number of concurrent requests.
* Fallbreak is an exception response mechanism, and it depends on isolation. Fallbreak is triggered based on the error rate. Two common items need to set are the number of requests to collect and error rate.
* Fault tolerance is an exception handling mechanism that depends on fallbreak. Fault tolerance is called after a fallbreak. For fault tolerance, you need to set the number of fault tolerance call items.

During fallback, if M(the threshold) errors are detected in N requests, the consumer will no longer send requests  and the fault tolerance mechanism will be enabled. The preceding fallback process is accepted in Netflix Hystrix and helps you configure the parameters. Obtain information about the parameter configuration at [https://github.com/Netflix/Hystrix/wiki/Configuration](https://github.com/Netflix/Hystrix/wiki/Configuration). Currently, ServiceComb provides two types of fault tolerance modes: returning null values and throwing exceptions.

### Scenario

By configuring a fallback policy, you can handler microservice exceptions.

### Configuration

　　Configuration items of fallback policies are as follows:

　　**Table 3 Configuration items of the fallback policy**

| Configuration Item                       | Default value  | Value Range                   | Mandatory | Description                              | Remarks                                  |
| :--------------------------------------- | :------------- | :---------------------------- | :-------- | :--------------------------------------- | :--------------------------------------- |
| servicecomb.isolation.timeout.enabled            | FALSE          | -                             | No        | Specifies whether to enable timeout detection. |                                          |
| servicecomb.isolation.timeoutInMilliseconds      | 30000          | -                             | No        | Specifies the timeout duration threshold. |                                          |
| servicecomb.isolation.maxConcurrentRequests      | 10             | -                             | No        | Specifies the maximum number of concurrent requests. |                                          |
| servicecomb.circuitBreaker.enabled               | TRUE           | -                             | No        | Specifies whether to enable fallbreak.   |                                          |
| servicecomb.circuitBreaker.forceOpen             | FALSE          | -                             | No        | Specifies that fallbreak is enable regardless of the number of failed requests or the error rate. |                                          |
| servicecomb.circuitBreaker.forceClosed           | FALSE          | -                             | No        | Specifies that fallbreak can be implemented at any time. | If this parameter and servicecomb.circuitBreaker.forceOpen both need to be configured, servicecomb.circuitBreaker.forceOpen has priority. |
| servicecomb.circuitBreaker.sleepWindowInMilliseconds | 15000          | -                             | No        | Specifies the duration needed to recover from fallbreak. | After the recovery, the number of failed requests will be recalculated. Note: If the consumer fails to send a request to the provider after the recovery, fallbreak is enabled again. |
| servicecomb.circuitBreaker.requestVolumeThreshold | 20             | -                             | No        | Specifies the threshold of failed requests sent within 10 seconds. If the threshold is reached, fallbreak is triggered. | Ten seconds will be divided into ten 1 seconds, and the error rate is calculated 1 second later after an error occurred. Therefore, fallbreak can be implemented at least 1 second after the call. |
| servicecomb.circuitBreaker.errorThresholdPercentage | 50             | -                             | No        | Specifies the threshold of error rate. If the threshold is reached, fallbreak is triggered. |                                          |
| servicecomb.fallback.enabled                     | TRUE           | -                             | No        | Specifies whether to enable troubleshooting measures after an error occurred. |                                          |
| servicecomb.fallback.maxConcurrentRequests       | 10             | -                             | No        | Specifies the number of fault tolerance(servicecomb.fallbackpolicy.policy) requests concurrently called. If the value exceeds 10, the measures will no longer be called, and exception are returned. |                                          |
| servicecomb.fallbackpolicy.policy                | throwexception | returnnulll \| throwexception | No        | Specifies the error handling policies after an error occurred. |                                          |

**Caution:** Be cautious when setting servicecomb.isolation.timeout.enabled to TRUE, All processes are asynchronously processed in the system, and any error value returned by an intermediate process because the set timeout duration is reached can cause failure of the follow-up processes. Therefore, you are advised to keep the default value FALSE for servicecomb.isolation.timeout.enabled. For timeout duration from the network aspect, you are advised to set servicecomb.request.timeout=30000.
{: .notice--warning}

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
      policy: throwexception
```

> **NOTE:**
>
> You need to enable service governance for fallback, The provider handler is `bizkeeper-provider`, and the consumer handler is `bizkeeper-consumer`. If `Consumer:`/`Provider:` was omitted, your configuration would not work, and service governance would be enabled with default configuration. 