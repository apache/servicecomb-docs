# 流量特征治理

流量特征治理旨在提供一种通用的，适合不同语言、不同微服务开发框架的治理规则。治理规则规定了微服务治理的过程、治理的策略，
可以使用不同的开发框架、技术实现治理规则约定的治理能力。

开发者可以在 [ServiceComb Java Chassis][java-chassis], [Go Chassis][go-chassis],[Spring Cloud][spring-cloud],
[Dubbo][dubbo] 中使用该功能。

[ServiceComb Java Chassis][java-chassis] 提供了实现 SDK，可以将其用于其他开发框架。SDK 默认采用 [Resilience4j][resilience4j]
实现治理过程。规范没有约束治理过程的实现框架，可以很方便的使用其他的治理框架实现治理过程。 

流量特征治理[概念和规范参考](https://github.com/huaweicloud/spring-cloud-huawei/wiki/using-governance)

[java-chassis]: https://github.com/apache/servicecomb-java-chassis
[go-chassis]: https://github.com/go-chassis/go-chassis
[spring-cloud]: https://github.com/huaweicloud/spring-cloud-huawei
[dubbo]: https://github.com/huaweicloud/dubbo-servicecomb
[resilience4j]: https://github.com/resilience4j

## 使用客户端熔断

在 `Handler` 中包含客户端熔断处理链：

```yaml
servicecomb:
  handler:
    chain:
      Consumer:
        default: loadbalance,instance-isolation-consumer
```

配置参数：

```
servicecomb:
  instanceIsolation:
    allOperation: |
      minimumNumberOfCalls: 10
      slidingWindowSize: 20
      slidingWindowType: COUNT_BASED
      failureRateThreshold: 50
      slowCallRateThreshold: 100
      slowCallDurationThreshold: 3000
      waitDurationInOpenState: 10000 
      permittedNumberOfCallsInHalfOpenState: 10
```

上诉参数使用计算滑动窗口，如果错误率超过50%，就会进行熔断。

## 使用客户端隔离仓

在 `Handler` 中包含客户端熔断处理链：

```yaml
servicecomb:
  handler:
    chain:
      Consumer:
        default: loadbalance,instance-bulkhead-consumer
```

配置参数：

```
servicecomb:
  instanceBulkhead:
    allOperation: |
      maxConcurrentCalls: 20
      maxWaitDuration: 1000
```

上诉参数控制最大并发数为20，超过的请求会等待1000毫秒以获取许可，如果得到许可，可以继续处理，否则会拒绝请求。

## 使用重试

配置参数：

```yaml
servicecomb:
  retry:
    allOperation: |
      maxAttempts: 2
      retryOnSame: 0
```

maxAttempts表示最大重试次数（不包括第1次调用），retryOnSame表示使用第1次调用的实例进行重试次数。后续的重试会根据负载均衡策略，重新选择一个新的实例重试（也可能选择到同一个实例）。 

**注意事项:**

* 并不是所有的异常都会触发重试。缺省的情况，只有网络异常，或者 502，503 错误码才会触发重试。 详细可以参考 `ServiceCombRetryExtension` 的定义。

## 组合使用

一个比较好的实践是组合使用 `重试` 、 `客户端熔断` 和 `客户端隔离仓`。

```yaml
servicecomb:
  handler:
    chain:
      Consumer:
        default: loadbalance,instance-isolation-consumer,instance-bulkhead-consumer
```

这种组合可以防止偶然的实例错误导致的失败，也可以防止单个实例处理能力下降（比如刚刚启动的实例、故障的实例等场景）导致的整体故障。

```
servicecomb:
  retry:
    allOperation: |
      maxAttempts: 2
      retryOnSame: 0
  instanceIsolation:
    allOperation: |
      minimumNumberOfCalls: 10
      slidingWindowSize: 20
      slidingWindowType: COUNT_BASED
      failureRateThreshold: 50
      slowCallRateThreshold: 100
      slowCallDurationThreshold: 3000
      waitDurationInOpenState: 10000 
      permittedNumberOfCallsInHalfOpenState: 10
  instanceBulkhead:
    allOperation: |
      maxConcurrentCalls: 20
      maxWaitDuration: 1000
```
