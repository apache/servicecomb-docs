# Java Chassis 3技术解密：熔断机制的改进路程

熔断机制是微服务治理非常重要的手段。当应用程序出现局部故障，比如多个微服务实例的其中一个实例故障，或者一个微服务实例的多个接口中的一个故障，恰当的熔断机制能够避免出现雪崩效应。熔断机制通常有如下几个重要的技术部件。

* 熔断的目标对象。目标对象可以是一个实例的某个服务接口，也可以是正在访问的某个微服务实例，也可以是正在访问的某个微服务实例的某个接口。 站在Provider视角和站在Consumer视角，会有不同的目标对象。需要对目标对象进行准确的抽象，才能够提供一个好用的熔断机制。 
* 故障检测方法。对目标对象的每次访问，需要对访问结果进行检查和分类，并统计相关指标。通常检查的结果包括抛出异常、返回状态码、请求处理时延等。 还需要考虑适当的算法进行指标统计，比如采用基于时间或者基于请求数量的滑动窗口算法。
* 熔断的策略。当故障积累的时候，如何避免故障积累，产生雪崩效应。常见的策略包括：快速失败，对目标对象的访问，立即抛出异常，返回失败；隔离错误对象，当目标对象存在可替换副本，比如其他的微服务实例，不再访问故障实例，只访问其他非故障实例。 
* 熔断的恢复策略。目标对象的熔断时长，如何从熔断状态中恢复也是非常重要的。

可以看出，设计一个良好的熔断机制是非常复杂的，Java Chassis 3的熔断机制也经历了多次调整和优化。 

* Spring Cloud Circuit Breaker

从 `Spring Cloud` 官网提供的例子以及开发指南，可以简单的分解下上述技术部件：

```java
@Service
public static class DemoControllerService {
	private ReactiveCircuitBreakerFactory cbFactory;
	private WebClient webClient;


	public DemoControllerService(WebClient webClient, ReactiveCircuitBreakerFactory cbFactory) {
		this.webClient = webClient;
		this.cbFactory = cbFactory;
	}

	public Mono<String> slow() {
		return webClient.get().uri("/slow").retrieve().bodyToMono(String.class).transform(
		it -> cbFactory.create("slow").run(it, throwable -> return Mono.just("fallback")));
	}
}
```

目标对象是由开发者在代码中指定的。 对于接口方法这类目标对象，开发起来是比较容易的，但是对于实例，则非常麻烦，而且无法动态的调整目标对象，在开发的时候就需要确定好。 故障检测方法主要是基于异常，即目标对象抛出异常的时候，会触发熔断。熔断的策略为快速失败模式。 

* Java Chassis Bizkeeper

Java Chassis 的早期版本，基于 Bizkeeper 提供了熔断功能。 Bizkeeper 集成了 `Hystrix` 组件。下面是一个配置示例。  

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
      enabled: true
      sleepWindowInMilliseconds: 15000
      requestVolumeThreshold: 20
  fallback:
    Consumer:
      enabled: true
  fallbackpolicy:
    Consumer:
      policy: throwException
```

目标对象是当前访问的方法，可以指定所有方法、某个Schema的所有方法、某个具体方法。故障检测方法有异常、超时错误两种。熔断的策略为快速失败模式。 

由于 `Hystrix` 已经停止维护，这个机制在 Java Chassis 3已经删除。 

* Java Chassis Instance Isolation

这个机制是基于 loadbalancer filter 开发的实例隔离功能。 

```yaml
servicecomb:
  loadbalance:
    isolation:
      enabled: false
      errorThresholdPercentage: 0
      enableRequestThreshold: 5
      singleTestTime: 60000
      continuousFailureThreshold: 5
      maxSingleTestWindow: 60000 # 为了保证在并发情况下只有一个实例放通，会锁定放通实例。这个时间表示最大锁定时间。
      minIsolationTime: 3000 # 最短隔离时间。并发情况下，实例隔离后进行中的请求可能快速刷新隔离状态，增加最短隔离时间。
      recoverImmediatelyWhenSuccess: true # 放通实例，如果调用成功，立即清除统计状态，保证后续请求能够使用该实例。 
```

目标对象是实例。 故障检测方法是基于异常。 熔断的策略为不再访问故障实例，只访问其他非故障实例。 

该功能在故障统计方面没有滑动窗口等算法，在计算错误率的时候，会存在不稳定波动。 错误率计算问题会导致隔离和隔离恢复出现问题，可以看出，他的恢复机制设计参数比较多。 这个机制在 Java Chassis 3已经删除。 

* Java Chassis 3 的熔断机制

Java Chassis 3 针对 `Provider` 和 `Consumer` 两个视角，提供了熔断机制。 两个机制的故障检测的方法、熔断策略和熔断恢复策略是相同的，只是在目标对象不一致。 

`Provider` 视角的熔断配置：

```yaml
servicecomb:
  circuitBreaker:
    allOperation: |
      minimumNumberOfCalls: 10
      slidingWindowSize: 20
      slidingWindowType: COUNT_BASED
      failureRateThreshold: 50
      recordFailureStatus: 
        - 502
        - 503
      slowCallRateThreshold: 100
      slowCallDurationThreshold: 3000
      waitDurationInOpenState: 10000 
      permittedNumberOfCallsInHalfOpenState: 10
```

`Consumer` 视角的熔断配置：

```yaml
servicecomb:
  instanceIsolation:
    allOperation: |
      minimumNumberOfCalls: 10
      slidingWindowSize: 20
      slidingWindowType: COUNT_BASED
      failureRateThreshold: 50
      slowCallRateThreshold: 100
      recordFailureStatus: 
        - 502
        - 503
      slowCallDurationThreshold: 3000
      waitDurationInOpenState: 10000 
      permittedNumberOfCallsInHalfOpenState: 10
```

Java Chassis提供了基于慢请求、异常、错误码，以及 `AbstractCircuitBreakerExtension`、`AbstractInstanceIsolationExtension` 接口让开发者自定义等故障检测方法。 对于性能场景，还可以基于隔离仓增加并发数限制故障检测方法。 

`Provider` 视角的隔离仓配置：

```yaml
servicecomb:
  bulkhead:
    allOperation: |
      maxConcurrentCalls: 20
      maxWaitDuration: 1000
```

`Consumer` 视角的隔离仓配置：

```yaml
servicecomb:
  instanceBulkhead:
    allOperation: |
      maxConcurrentCalls: 20
      maxWaitDuration: 1000
```

`Provider` 视角的熔断器，熔断策略是快速失败，抛出异常；`Consumer` 视角的熔断器，熔断策略是为不再访问故障实例，只访问其他非故障实例。 

在前面的示例中，`allOperation` 代表了熔断对象。 Java Chassis 3的熔断对象定义也是非常简单和灵活的：

```yaml
servicecomb:
  matchGroup:
    allOperation: |
      matches:
        - apiPath:
            exact: "/"
          method:
            - POST
          headers:
            Authentication: 
              prefix: Basic
          serviceName: exampleService
```

站在`Provider` 视角， 上述定义表示熔断对象是来自 `exampleService` 的设置了认证头的所有 POST 方法； 站在`Consumer` 视角， 上述定义表示熔断对象是发往 `exampleService` 的某个具体的实例，并且设置了认证头的所有 POST 方法。 

Java Chassis 3熔断机制逐步成为是一个简单易用， 满足绝大部分业务场景需要的通用设计规范。 

>>> 客户故事：客户期望建立一种持续演进的故障处理机制，以降低随着系统长期运行，随机故障、系统变慢等场景对整体故障的影响，动态适应持续变化的环境对可靠性带来的挑战。Java Chassis 3的服务治理配置机制，可以使得客户不需要修改代码和重启应用，就能够动态调整耗时接口和故障接口的熔断策略。通过规范赋能，运维人员就能够解决一些常见的过载防护问题。 
