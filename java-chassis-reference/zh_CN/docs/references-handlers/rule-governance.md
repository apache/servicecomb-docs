# 流量特征治理

流量特征治理旨在提供一种通用的，适合不同语言、不同微服务开发框架的治理规则。治理规则规定了微服务治理的过程、治理的策略，可以使用不同的开发框架、技术实现治理规则约定的治理能力。

开发者可以在 Java Chassis, [Spring Cloud](https://github.com/huaweicloud/spring-cloud-huawei), [Go Chassis](https://github.com/go-chassis/go-chassis) 中使用该功能。

Java Chassis提供了实现 SDK，可以将其用于其他开发框架。SDK 默认采用 [Resilience4j](https://github.com/resilience4j) 实现治理过程，并在规范中参考引用了很多其设计理念。规范没有约束治理过程的实现框架，可以很方便的使用其他的治理框架实现治理过程。 

## 概念定义

流量特征治理可以从两个不同的角度进行描述。

从管理流程上，可以分为进行 `业务定义` 和设置 `治理规则` 两个步骤。系统架构师将请求流量根据特征打上标记，用于区分一个或者一组代表具体含义的业务，然后对这些业务设置治理规则。

从处理过程上，可以分为 `下发配置` 和 应用 `治理规则` 两个步骤。 可以通过配置文件、配置中心、环境变量等常见的配置管理手段下发配置。微服务 SDK 负责读取配置，解析治理规则，实现治理效果。

* `业务定义`

可以根据请求的特征进行业务定义。

```yaml
servicecomb:
  matchGroup:
    userLoginAction: |
      matches:
        - apiPath:
            exact: "/login"
          method:
            - POST
        - headers:
          Authentication: 
            prefix: Basic
```

比如上面的示例定义了一个业务 `userLoginAction`，如果流量的 `apiPath=/login&method=POST`， 或者 请求头 `Authentication=Basic*` 那么认为这个流量是一个登陆操作。

* `治理规则`

定义好业务后，可以给它们设置治理规则。

```yaml
servicecomb:
  rateLimiting:
    userLoginAction: |
      rate: 100
```

比如上面的示例设置 `userLoginAction` 的限流策略是 100 TPS。 

## 规范参考

### 业务定义

```yaml
servicecomb:
  matchGroup:
    userLoginAction: |
      matches:
        - name: firstMatch
          apiPath:
            exact: "/login/v1"
          method:
            - POST
          headers:
            Authentication: 
              prefix: Basic
          serviceName: exampleService
        - name: secondeMatch
          apiPath:
            exact: "/login/v2"
          method:
            - POST
          headers:
            Authentication: 
              prefix: Basic
           serviceName: exampleService
      services: exampleService
      name: userLoginAction
```

一个业务对应一个 Key， userLoginAction 为 Key 的名称。 一个业务可以定义多个标记规则，每个标记规则里面可以定义 `apiPath`, `method`, `headers`, `serviceName` 等匹配规则。 不同标记规则是或的关系，匹配规则是与的关系。

* `services`: 可选。指出这个业务定义的生效范围。 在应用系统中，业务定义可能对于所有微服务都是可见的（如果业务定义只下发到该微服务，则不需要这个配置），一个微服务只会启用 `services` 包含自己的规则。这个属性可选，表示这条规则默认生效。可以使用 `example:1.0.0` 格式指明服务和版本，多个服务用逗号分隔，比如：`foo:1.0.0,bar`。

* `name`: 可选。业务定义的名称。

在match中提供了一系列的算子来对 `apiPath` 或者 `headers` 进行匹配. 

* `exact`: 精确匹配
* `prefix`: 前缀匹配
* `suffix`: 后缀匹配
* `contains`: 包含， 目标字符串是否包含模式字符串
* `compare`: 比较： 支持 >,<,>=,<=,=,!= 符号匹配，处理时会把模式字符串和目标字符串转化为 Double 类型进行比较，支持的数据范围为 Double 的数据范围。在进行 = 和 != 判断时 ， 如果二者的差值小于1e-6就视为相等。例如模式串为: >-10 会对大于-10以上的目标串匹配成功。

业务定义可以在不同的应用层实现，比如在提供 REST 接口的服务端，可以通过 `HttpServletRequest` 获取请求信息。在 RestTemplate 调用的客户端，可以从
`RestTemplate` 获取请求信息。不同的框架和应用层，提取信息的方式不一样。 实现层通过将特征映射到 `GovernanceRequest` 来屏蔽这些差异，使得在不同的框架，不同的应用层都可以使用治理。

```java
public class GovernanceRequest {
     /**
      headers with this request, maybe null.
      For provider: headers indicates the request headers to me.
      For consumer: headers indicates the request headers to the target.
      */
     private Map<String, String> headers;

     /**
      uri with this request, maybe null.
      For provider: uri indicates the request uri to me.
      For consumer: uri indicates the request uri to the target.
      */
     private String uri;

     /**
      method with this request, maybe null.
      For provider: method indicates the request method to me.
      For consumer: method indicates the request method to the target.
      */
     private String method;

     /**
      instance id with this request, maybe null.
      For provider: instanceId indicates who calls me.
      For consumer: instanceId indicates the target instance.
      */
     private String instanceId;

     /**
      microservice id (microservice name or application name + microservice name) with this request, maybe null.
      For provider: serviceName indicates who calls me.
      For consumer: serviceName indicates the target service.
      */
     private String serviceName;
}

```

### 限流

```yaml
servicecomb:
  rateLimiting:
    userLoginAction: |
      timeoutDuration: 0
      limitRefreshPeriod: 1000
      rate: 1
```

规则解释：限流规则借鉴了`Resilience4j`的思想，其原理为： 每隔limitRefreshPeriod的时间会加入limitForPeriod（即rate）个新许可，如果获取不到新的许可(已经触发限流)，当前线程会park，最多等待timeoutDuration的时间，默认单位为毫秒。

### 基于header的限流

```yaml
servicecomb:
  identifierRateLimiting:
    userLoginAction: |
      timeoutDuration: 0
      limitRefreshPeriod: 1000
      rate: 1
      identifier: user-id
```

基于header的限流和限流含义类似，它会针对 `identifier` 指定的 header 值， 每个值创建一个限流器。

### 重试

```yaml
servicecomb:
  retry:
    userLoginAction: |
      maxAttempts: 3
      retryOnSame: 0
      retryOnResponseStatus: 
         - 502
         - 503
      waitDuration: 1
```

规则解释：重试规则借鉴了`Resilience4j`的思想，其原理为：如果响应的错误码(502, 503)计算结果满足重试条件，或者异常在重试异常清单里面，则进行重试。下一次重试等待时间为 waitDuration。 

重试等待时间和具体的框架与运行机制有关。重试等待时间必须大于0。

### 熔断

```yaml
servicecomb:
  circuitBreaker:
    userLoginAction: |
      failureRateThreshold: 50
      slowCallRateThreshold: 100
      slowCallDurationThreshold: 60000
      minimumNumberOfCalls: 100
      slidingWindowType: COUNT_BASED
      slidingWindowSize: 100
      recordFailureStatus:
        - 502
        - 503
      waitDurationInOpenState: 60000
      permittedNumberOfCallsInHalfOpenState: 10
      forceClosed: false
      forceOpen: false
```

规则解释：熔断规则借鉴了`Resilience4j`的思想，其原理为：达到指定 failureRateThreshold 错误率或者 slowCallRateThreshold 慢请求率时进行熔断，慢请求通过 slowCallDurationThreshold 定义。minimumNumberOfCalls 是达到熔断要求的最低请求数量门槛。slidingWindowType指定滑动窗口
类型，默认可选 COUNT_BASED和TIME_BASED 分别是基于请求数量窗口和基于时间窗口。slidingWindowSize 指定窗口大小，根据滑动窗口类型，单位是请求数量或者秒，根据滑动窗口类型决定。 forceClosed 表示强制关闭熔断器，即熔断器不工作；forceOpen表示强制开启熔断器，即请求都会发生熔断。

熔断时间是waitDurationInOpenState，达到时间会放通permittedNumberOfCallsInHalfOpenState个请求。放通后，如果降低到阈值一下，则恢复；如果没有降低到阈值以下，则继续隔离。

### 实例级熔断

```yaml
servicecomb:
  instanceIsolation:
    userLoginAction: |
      failureRateThreshold: 50
      slowCallRateThreshold: 100
      slowCallDurationThreshold: 60000
      minimumNumberOfCalls: 100
      slidingWindowType: COUNT_BASED
      slidingWindowSize: 100
      recordFailureStatus:
        - 502
        - 503
      waitDurationInOpenState: 60000
      permittedNumberOfCallsInHalfOpenState: 10
      forceClosed: false
      forceOpen: false
```

实例级熔断和熔断的含义类似，但是他会针对每个实例创建一个熔断器。Java Chassis会监听实例熔断事件，并调整熔断实例的优先级，降低对熔断实例的使用频率以达到实例隔离的作用。

### 隔离仓

```yaml
servicecomb:
  bulkhead:
    userLoginAction: |
      maxConcurrentCalls: 1000
      maxWaitDuration: 0
```

规则解释：隔离仓规则借鉴了`Resilience4j`的思想，其原理为：当最大并发数超过 maxConcurrentCalls，等待 maxWaitDuration
竞争资源，如果获得资源，则继续处理，如果获取不到，则拒绝执行请求。在异步框架，建议 maxWaitDuration 设置为0，防止阻塞事件派发线程。

### 实例级隔离仓

```yaml
servicecomb:
  instanceBulkhead:
    userLoginAction: |
      maxConcurrentCalls: 1000
      maxWaitDuration: 0
```

实例级隔离仓和隔离仓的含义类似，但是他会针对每个实例创建一个隔离仓。

### 错误注入

```yaml
servicecomb:
  faultInjection:
    userLoginAction: |
      type: delay
      delayTime: 1000
      percentage: 50
      errorCode: 500
      fallbackType: ThrowException
      forceClosed: false
```

规则解释：错误注入分为 `delay` 和 `abort` 两种。`delay` 表示对于 `percentage` 的请求，延迟 `delayTime`。 `abort` 表示对于 `percentage` 的请求，根据 `fallbackType` 抛出异常还是返回 null。 

### 公共参数

治理规则存在一些公共参数， 比如 `services`, `order`, `name`。比如：

```yaml
servicecomb:
  faultInjection:
    userLoginAction: |
      type: delay
      delayTime: 1000
      percentage: 50
      errorCode: 500
      fallbackType: ThrowException
      forceClosed: false
      services: helloService
      order: 1
      name: userLoginAction
```

* services: 表示该治理规则生效的微服务名称列表。 在应用系统中，治理规则可能对于所有微服务都是可见的（如果治理规则只下发到该微服务，则不需要这个配置），一个微服务只会启用 `services` 包含自己的规则。这个属性可选，表示这条规则默认生效。可以使用 `example:1.0.0` 格式指明服务和版本，多个服务用逗号分隔，比如：`foo:1.0.0,bar`。
* order: 表示该治理规则的优先级，值越小优先级越高。 当一个请求匹配多个治理规则的时候，按照优先级使用优先级高的治理规则。
* name: 表示该治理规则的名称，系统内部使用属性，其值等于规则里面的业务名称，用户不能修改。


