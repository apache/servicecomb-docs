# 隔离熔断容错

bizkeeper 模块集成了 [Hystrix](https://github.com/Netflix/Hystrix/wiki/Configuration) , 提供隔离、熔断和容错等服务故障保护能力。 Java
Chassis 对 Hystrix 进行了封装， 只需要进行简单的配置即可启用这些功能。 

在项目中引入如下 Handler 模块， 

```xml
 <dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>handler-bizkeeper</artifactId>
  </dependency>
```

并且增加 Handler 配置：

```yaml
servicecomb:
  handler:
    chain:
      Consumer:
        default: bizkeeper-consumer
      Provider:
        default: bizkeeper-provider
```

** 注意事项： **

在实际微服务运维实践中，发现 Hystrix 存在如下一些问题， 开发者可以结合实际业务情况，谨慎的使用这个模块。 Java Chassis 的
[负载均衡](loadbalance.md) 也提供了实例隔离和错误重试能力， 加上内置的[线程池隔离](../build-provider/thread-pool.md)， 能够
实现大部分 Hystrix 核心治理能力。 

* 调用栈很深，在某些异常情况下，可能屏蔽底层异常，导致问题原因分析困难。
* 超时机制、重试机制和线程池隔离机制和 Java Chassis 的一些内部机制的协作存在一些不友好的情况，需要特别注意合理的开启超时和重试。 默认情况下是禁用的。Java Chassis 只能使用信号量隔离机制。
* Hystrix 的引入对性能影响很大， 会有 20% 以上的框架性能损失。    
* Hystrix 项目目前已经停止维护。 

## 概念阐述

服务故障保护指服务请求异常时，微服务所采用的异常处理策略， 根据处理机制和效果把它分解为三个技术概念：“隔离”、“熔断”、“容错”：

* “隔离”是一种异常检测机制，常用的检测方法是请求超时、流量过大等。一般的设置参数包括超时时间、同时并发请求个数等。
* “熔断”是一种异常反应机制，“熔断”依赖于“隔离”。熔断通常基于错误率来实现。一般的设置参数包括统计请求的个数、错误率等。
* “容错”是一种异常处理机制，“容错”依赖于“熔断”。熔断以后，会调用“容错”的方法。一般的设置参数包括调用容错方法的次数等。

当前 ServiceComb 提供两种容错方式，分别为返回 null 值和抛出异常。

*** 注意 ： *** 在不同的上下文，“隔离”、“熔断”、“容错”、“降级” 等概念可能存在不一样的含义，发现这里的定义和其他地方存在不一样的
的时候不用感到意外， 但是不用担心， 当服务出现故障的时候， 需要一定的措施进行应对， 对于措施和应对方式的理解胜于对于名词的理解。

## 配置说明

配置项支持对所有接口生效，或者对某个微服务的某个具体方法生效。

* 配置项生效范围
    * 按照类型\(type\)：配置项能够针对Provider, Consumer进行配置
    * 按照范围\(scope\)：配置项能够针对服务进行配置, 也可以针对接口进行配置

本章节如果没有特殊说明，所有的配置项都支持按照下面的格式进行配置：

```
servicecomb.[namespace].[type].[scope].[property name]
```

type 指 Provider 或者 Consumser。 scope 指配置项生效范围， 针对特定的微服务的配置，需要增加 MicroServiceName, 针对接口配置的，需要指定接口名称，接口名
称由 `schemaId` 和 `operationId` 组成。

下面是一些配置示例：

```
servicecomb.isolation.Consumer.timeout.enabled # 全局配置
servicecomb.isolation.Consumer.DemoService.timeout.enabled # 服务配置
servicecomb.isolation.Consumer.DemoService.hello.sayHello.timeout.enabled # 接口配置
servicecomb.isolation.Provider.timeout.enabled # 全局配置
servicecomb.isolation.Provider.DemoService.timeout.enabled # 服务配置
servicecomb.isolation.Provider.DemoService.hello.sayHello.timeout.enabled # 接口配置
```

* 配置项列表

| 配置项 | 默认值 | 取值范围 | 是否必选 | 含义 | 注意 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| servicecomb.isolation.[type].[scope].timeout.enabled | FALSE | - | 否 | 是否启用超时检测 |  |
| servicecomb.isolation.[type].[scope].timeoutInMilliseconds | 30000 | - | 否 | 超时时间阈值 |  |
| servicecomb.isolation.[type].[scope].maxConcurrentRequests | 1000 | - | 否 | 最大并发数阈值 |  |
| servicecomb.circuitBreaker.[type].[scope].enabled | TRUE | - | 否 | 是否启用熔断措施 |  |
| servicecomb.circuitBreaker.[type].[scope].forceOpen | FALSE | - | 否 | 不管失败次数，都进行熔断 |  |
| servicecomb.circuitBreaker.[type].[scope].forceClosed | FALSE | - | 否 | 任何时候都不熔断 | 当与forceOpen同时配置时，forceOpen优先。 |
| servicecomb.circuitBreaker.[type].[scope].sleepWindowInMilliseconds | 15000 | - | 否 | 熔断后，多长时间恢复 | 恢复后，会重新计算失败情况。注意：如果恢复后的调用立即失败，那么会立即重新进入熔断。 |
| servicecomb.circuitBreaker.[type].[scope].requestVolumeThreshold | 20 | - | 否 | 10s内请求数需要大于等于这个参数值，才开始计算错误率和判断是否进行熔断。 |  |
| servicecomb.circuitBreaker.[type].[scope].errorThresholdPercentage | 50 | - | 否 | 错误率阈值，达到阈值则触发熔断 | 由于10秒还会被划分为10个1秒的统计周期，经过1s中后才会开始计算错误率，因此从调用开始至少经过1s，才会发生熔断。 |
| servicecomb.fallback.[type].[scope].maxConcurrentRequests | 10 | - | 否 | 并发调用容错处理措施（servicecomb.fallbackpolicy.policy）的请求数，超过这个值则不再调用处理措施，直接返回异常 |  |
| servicecomb.fallbackpolicy.[type].[scope].policy | throwException | returnNull \| throwexception | 否 | 出错后的处理策略 |  |

**注意**：谨慎使用 `servicecomb.isolation.timeout.enabled=true` 。因为系统处理链都是异步执行，中间处理链的返回，会导致
后面处理链的逻辑处理效果丢失。尽可能将 `servicecomb.isolation.timeout.enabled` 保持默认值false，并且正确设置网络层超时时
间 `servicecomb.request.timeout=30000` 。 配置范围不支持 Schema 级别的配置。


* 示例代码

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

> **说明：**  
> 降级策略需要启用服务治理能力，对应的服务提供者的handler是`bizkeeper-provider`，服务消费者的handler是`bizkeeper-consumer`。



