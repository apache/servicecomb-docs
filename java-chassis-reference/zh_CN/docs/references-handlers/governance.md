# 基于动态配置的流量特征治理

基于动态配置的流量特征治理旨在提供一种通用的，适合不同语言、不同微服务开发框架的治理规则。治理规则规定了微服务治理的过程、治理的策略，
可以使用不同的开发框架、技术实现治理规则约定的治理能力。

开发者可以在 [ServiceComb Java Chassis][java-chassis], [Go Chassis][go-chassis],[Spring Cloud][spring-cloud],
[Dubbo][dubbo] 中使用该功能。

[ServiceComb Java Chassis][java-chassis] 提供了实现 SDK，可以将其用于其他开发框架。SDK 默认采用 [Resilience4j][resilience4j]
实现治理过程。规范没有约束治理过程的实现框架，可以很方便的使用其他的治理框架实现治理过程。 

## 治理过程

治理过程可以从两个不同的角度进行描述。

从管理流程上，可以分为 `流量标记` 和 `设置治理规则` 两个步骤。系统架构师将请求流量根据特征打上标记，用于区分一个或者一组代表具体
业务含义的流量，然后对这些流量设置治理规则。

从处理过程上，可以分为 `下发配置` 和 `应用治理规则` 两个步骤。 可以通过配置文件、配置中心、环境变量等常见的配置管理手段下发配置。
微服务 SDK 负责读取配置，解析治理规则，实现治理效果。

## 治理策略

治理策略分两部分进行描述，一部分描述 `流量标记`， 一部分描述 `治理规则`。 

* `流量标记`

可以根据请求的特征进行流量标记。

```yaml
servicecomb:
  matchGroup:
    userLoginAction: |
      matches:
        - apiPath:
            exact: "/login"
          method:
            - POST
        - headers
          Authentication: 
            prefix: Basic
```

比如上面的示例定义了一个流量特征 `userLoginAction`，如果流量的 apiPath=/login&method=POST， 或者 请求头 Authentication=Basic*
那么认为这个流量是一个登陆操作。

* `治理规则`

定义好流量特征后，可以给它们设置治理规则。

```yaml
servicecomb:
  rateLimiting:
    userLoginAction: |
      rate: 100
```

比如上面的示例设置流量特征 `userLoginAction` 的限流策略是 100 TPS。 

## 规范参考

### 流量标记

```yaml
servicecomb:
  matchGroup:
    userLoginAction: |
      matches:
        - apiPath:
            exact: "/login"
          method:
            - POST
        - headers
          Authentication: 
            prefix: Basic
      services: helloService
```

一个流量对应一个 Key， userLoginAction 为 Key 的名称。 一个流量可以定义多个标记规则，每个标记规则里面可以定义 `apiPath`,
`method`, `headers` 匹配规则。 不同标记规则是或的关系，匹配规则是与的关系。

`services` 是治理规则公共属性，指出这个限流规则的生效范围。在应用系统设计的规程中，流量标记、治理规则对于所有微服务都是可见的，一个微服务只会启用
`services` 包含自己的规则。这个属性可选，表示这条规则默认生效。可以使用 `example:1.0.0` 格式指明服务和版本，多个服务用逗号分隔，比如：
`foo:1.0.0,bar`。

* 算子

在match中提供了一系列的算子来对 `apiPath` 或者 `headers` 进行匹配. 

  * exact : 精确匹配
  * prefix: 前缀匹配
  * suffix: 后缀匹配
  * contains: 包含， 目标字符串是否包含模式字符串
  * compare: 比较： 支持 >,<,>=,<=,=,!= 符号匹配，处理时会把模式字符串和目标字符串转化为 Double 类型进行比较，支持的数据范围为 Double 的
     数据范围。在进行 = 和 != 判断时 ， 如果二者的差值小于1e-6就视为相等。例如模式串为: >-10 会对大于-10以上的目标串匹配成功。

流量标记可以在不同的应用层实现，比如在提供 REST 接口的服务端，可以通过 `HttpServletRequest` 获取流量信息。在 RestTemplate 调用的客户端，可以从
`RestTemplate` 获取流量信息。不同的框架和应用层，提取信息的方式不一样。 实现层通过将特征映射到 `GovernanceRequest` 来屏蔽这些差异，使得在不同的框架，
不同的应用层都可以使用治理。

```java
public class GovernanceRequest {
  private Map<String, String> headers;

  private String uri;

  private String method;
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
      services: helloService
```

规则解释：限流规则借鉴了 [Resilience4j][resilience4j] 的思想，其原理为： 每隔limitRefreshPeriod的时间会加入limitForPeriod（即rate）个新许可，
如果获取不到新的许可(已经触发限流)，当前线程会park，最多等待timeoutDuration的时间，默认单位为ms。在异步框架中，建议 timeoutDuration
设置为0，否则可能阻塞事件派发线程。

### 重试

```yaml
servicecomb:
  retry:
    userLoginAction: |
      maxAttempts: 3
      retryOnResponseStatus： 502
      waitDuration：0
      services: helloService
```

规则解释：重试规则借鉴了 [Resilience4j][resilience4j] 的思想，其原理为：如果响应的错误码(502)和返回值的计算结果满足重试条件，
并且异常在重试异常清单里面，则进行重试。下一次重试等待时间为 waitDuration。 

重试等待时间和具体的框架与运行机制有关。在同步框架里面，重试等待时间必须大于等于0。异步框架里面，重试等待时间必须大于0，否则不会重试，
并且重试是在独立的线程池里面执行的。

重试条件是框架相关的，通过扩展 `RetryExtension`， 不同框架实现机制可能不同，
```java
public interface RetryExtension {
  boolean isRetry(List<Integer> statusList, Object result);

  Class<? extends Throwable>[] retryExceptions();
}
```

### 熔断

```yaml
servicecomb:
  circuitBreaker:
    userLoginAction: |
      failureRateThreshold：50
      slowCallRateThreshold： 100
      slowCallDurationThreshold： 60000
      minimumNumberOfCalls: 100
      slidingWindowType: count
      slidingWindowSize: 100
      services: helloService
```

规则解释：熔断规则借鉴了 [Resilience4j][resilience4j] 的思想，其原理为：达到指定 failureRateThreshold 错误率或者 slowCallRateThreshold 慢请求
率时进行熔断，慢请求通过 slowCallDurationThreshold 定义。minimumNumberOfCalls 是达到熔断要求的最低请求数量门槛。slidingWindowType指定滑动窗口
类型，默认可选 count / time 分别是基于请求数量窗口和基于时间窗口。slidingWindowSize 指定窗口大小，根据滑动窗口类型，单位可能是请求数量或者秒。

### 隔离仓

```yaml
servicecomb:
  bulkhead:
    userLoginAction: |
      maxConcurrentCalls: 1000
      maxWaitDuration: 0
      services: helloService
```

规则解释：隔离仓规则借鉴了 [Resilience4j][resilience4j] 的思想，其原理为：当最大并发数超过 maxConcurrentCalls，等待 maxWaitDuration
竞争资源，如果获得资源，则继续处理，如果获取不到，则拒绝执行请求。在异步框架，建议 maxWaitDuration 设置为0，防止阻塞事件派发线程。

## 基于流量标记治理使用指南

* Java Chassis

Java Chassis 通过 Handler 实现了基于流量标记治理能力。其中 Provider 实现了限流、熔断和隔离仓，Consumer 实现了重试。使用流量标
记治理能力，首先需要在代码中引入依赖：

```xml
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>handler-governance</artifactId>
</dependency>
```

然后配置 Handler 链

```yaml
servicecomb:
  handler:
    chain:
      Consumer:
        default: governance-consumer,loadbalance
      Provider:
        default: governance-provider
```

Java Chassis是基于Open API的REST/RPC框架，在模型上和单纯的REST框架存在差异。Java Chassis提供两种模式匹配规则，
第一种是基于REST的，第二种是基于RPC的。可以通过配置项：`servicecomb.governance.{operation}.matchType` 指定匹配规则，
默认使用REST。比如：

```
servicecomb: 
  governance: 
    matchType: rest # 设置全局默认是rest匹配模式
    GovernanceEndpoint.helloRpc: 
      matchType: rpc # 设置服务端的接口helloRpc采用RPC匹配模式
```

在REST匹配模式下， apiPath使用url， 比如： 

```
servicecomb: 
  matchGroup: 
    userLoginAction: | 
      matches: 
        - apiPath: 
            exact: "/user/login" 
```

在RPC匹配模式下, apiPath使用operation, 比如： 

```
servicecomb: 
  matchGroup: 
    userLoginAction: | 
      matches: 
        - apiPath: 
            exact: "UserSchema.login"
```

对于服务端治理，比如限流，REST模式下从HTTP取header；对于客户端治理，比如重试，REST模式下从InvocationContext取header。

* Spring Cloud

Spring Cloud通过Aspect拦截RequestMappingHandlerAdater实现了限流、熔断和隔离仓，通过拦截RestTemplate和FeignClient实现了重试。
使用流量标记治理能力，首先需要在代码中引入依赖：

```xml
<dependency>
  <groupId>com.huaweicloud</groupId>
  <artifactId>spring-cloud-starter-huawei-governance</artifactId>
</dependency>
```

Spring Cloud是基于REST的框架，能比较好的符合流量特征治理的匹配语义，apiPath和headers分别对应HTTP协议的概念： 

```
servicecomb: 
  matchGroup: 
    userLoginAction: | 
      matches: 
        - apiPath: 
            exact: "/user/login" 
           method: 
             - POST 
        - headers:
            Authentication: 
              prefix: Basic
```

* Dubbo

Dubbo的Provider通过Filter拦截请求实现了限流、熔断和隔离仓，通过拦截ClusterInvoker实现了重试。使用流量标记治理能力，首先需要在代码中引入依赖：

```xml
<dependency>
  <groupId>com.huaweicloud.dubbo-servicecomb</groupId>
  <artifactId>dubbo-servicecomb-governance-center</artifactId>
  <version>${project.version}</version>
</dependency>
```

如果要使用重试，需要修改dubbo的Spring配置文件，将dubbo默认的ClusterInvoker修改为dubbo-servicecomb：

```xml
<dubbo:consumer cluster="dubbo-servicecomb"></dubbo:consumer>
```

Dubbo是一个RPC框架，需要定义operation和apiPath的映射关系，比如，服务端限流、熔断、隔离仓场景：
 `com.huaweicloud.it.order.OrderGovernanceService.hello` ；客户端重试场景：
 `com.huaweicloud.it.order.OrderGovernanceService.retry` 。 headers使用Attachments，需要包含在Attachments里面的头才会参与匹配。 

```
servicecomb: 
  matchGroup: 
    userLoginAction: | 
      matches: 
        - apiPath: 
            exact: "com.huaweicloud.it.order.OrderGovernanceService.hello" 
          method: 
            - POST 
        - headers 
            Authentication: 
              prefix: Basic
```

* 自定义

服务治理的默认实现并不一定能够解决业务的所有问题。自定义治理功能可以方便的在不同的场景下使用基于流量的治理能力，比如在网关场景下进行流控。
SDK基于Spring，使用Spring的框架都能够灵活的使用这些API，方法类似。下面以流控为例，说明如何使用API。 使用API开发的自定义代码，也
可以通过动态配置下发治理规则。

代码的基本过程包括声明RateLimitingHandler的引用，创建GovernanceRequest，拦截（包装）业务逻辑，处理治理异常。

```java
@Autowired
private RateLimitingHandler rateLimitingHandler;

GovernanceRequest governanceRequest = convert(request);

CheckedFunction0<Object> next = pjp::proceed;
DecorateCheckedSupplier<Object> dcs = Decorators.ofCheckedSupplier(next);

try {
  SpringCloudInvocationContext.setInvocationContext();

  RateLimiter rateLimiter = rateLimitingHandler.getActuator(request);
  if (rateLimiter != null) {
	dcs.withRateLimiter(rateLimiter);
  }

  return dcs.get();
} catch (Throwable th) {
  if (th instanceof RequestNotPermitted) {
	response.setStatus(429);
	response.getWriter().print("rate limited.");
	LOGGER.warn("the request is rate limit by policy : {}",
		th.getMessage());
  } else {
	if (serverRecoverPolicy != null) {
	  return serverRecoverPolicy.apply(th);
	}
	throw th;
  }
} finally {
  SpringCloudInvocationContext.removeInvocationContext();
}
```

上面简单的介绍了自定义开发。对于更加深入的使用方式，也可以直接参考Java Chassis、Spring Cloud、Dubbo项目中的默认实现代码。

[java-chassis]: https://github.com/apache/servicecomb-java-chassis
[go-chassis]: https://github.com/go-chassis/go-chassis
[spring-cloud]: https://github.com/huaweicloud/spring-cloud-huawei
[dubbo]: https://github.com/huaweicloud/dubbo-servicecomb
[resilience4j]: https://github.com/resilience4j