# 限流

java-chassis 支持 Provider 限流和 Consumer 限流。 Provider 限流控制访问本微服务的流量， Consumer 限流控制发往其他微服务的流量。

***注意事项：***

1. 限流策略的控制并不是绝对精确的，可能会有少量误差。
2. 流量控制是业务层面的功能，不是安全意义上的流量控制，如需防止DDoS攻击，需要结合其他的一系列措施。
3. 流量控制是微服务级的，不是实例级的。例如一个consumer服务有三个实例，当对它们依赖的provider实例配置限流策略后，
  provider不会区分consumer的请求具体是由哪个实例发出的，而是汇总成微服务级的统计数据进行限流判断。

## 流控算法说明

2.1.3 版本之前，不提供流控策略的选择，默认流控实现算法是固定窗口算法。

2.1.3 版本以及之后，提供流控测流供选择，默认提供固定窗口算法、漏桶算法、令牌桶算法，且支持用户自定义流控策略实现。

* 算法说明：
  * 固定窗口算法：默认窗口大小为1s，最大可能产生2倍于指定流量设置大小的误差。
  * 令牌桶算法：令牌桶的主要思想是，设置一个固定大小的桶，以恒定速率向里面加入令牌，每次新
    请求到来时从里面取一个令牌出来，如果没有令牌可取，则请求直接失败(被限流)。
  * 漏桶算法：漏桶算法的主要思想是，设置一个固定大小的桶，请求不断加入桶中同时以固定大小从桶
    内部流出，如果达到桶的极限大小，则请求溢出(失败)。在内部实现上漏桶算法与令牌桶算法的实现
    原理相同，根据设置的桶大小不同，能承载的突发流量不同。
  * 用户自定义流控算法：可以参考 [示例实现][customize-flow] ,以及该实现下的配置方法。
  
[customize-flow]: https://github.com/apache/servicecomb-java-chassis/blob/master/demo/demo-springmvc/springmvc-server/src/main/java/org/apache/servicecomb/demo/springmvc/server/MyStrategyFactory.java

## Provider端使用限流

用户在provider端使用限流策略，可以限制指定微服务向其发送请求的频率，达到限制每秒钟最大请求数量的效果。


### 配置说明

限流策略配置在microservice.yaml文件中，相关配置项见表**QPS流控配置项说明**。要开启服务提供者端的限流策略，还需要在处理链中配置服
务端限流handler，并添加pom依赖。

* microservice.yaml配置示例如下：

        servicecomb:
          handler:
            chain:
              Provider:
                default: qps-flowcontrol-provider
  
* 添加handler-flowcontrol-qps的pom依赖：

        <dependency>
          <groupId>org.apache.servicecomb</groupId>
          <artifactId>handler-flowcontrol-qps</artifactId>
        </dependency>


**QPS流控配置项说明**

| 配置项 | 默认值 | 取值范围 | 是否必选 | 含义 | 注意 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| servicecomb.flowcontrol.Provider.qps.enabled | true | true/false | 否 | 是否启用Provider流控 | - |
| servicecomb.flowcontrol.strategy | FixedWindow | FixedWindow/LeakyBucket/TokenBucket/自定义 | 否 | 流控策略 | - |
| servicecomb.flowcontrol.Provider.qps.limit.\[ServiceName\].\[Schema\].\[operation\] | 2147483647（max int） | \(0,2147483647\]，整型 | 否 | 每秒钟允许的请求数 | 支持microservice/schema/operation三个级别的配置，后者的优先级高于前者 |
| servicecomb.flowcontrol.Provider.qps.global.limit | 2147483647（max int） | \(0,2147483647\]，整型 | 否 | provider接受请求流量的全局配置 | 没有具体的流控配置时，此配置生效 |
| servicecomb.flowcontrol.Provider.qps.bucket.\[ServiceName\].\[Schema\].\[operation\] | 两倍limit大小，不超过max int | \(0,2147483647\]，整型 | 否 | 令牌桶场景下桶的大小 | 支持microservice/schema/operation三个级别的配置，后者的优先级高于前者 |
| servicecomb.flowcontrol.Provider.qps.global.bucket | 两倍limit大小，不超过max int | \(0,2147483647\]，整型 | 否 | 令牌桶场景下provider桶的大小 | 没有具体的流控配置时，此配置生效 |


> **注意：**
> strategy是全局的策略选择，一旦选择所有流控接口都会应用统一的流控策略，且不支持动态配置变更，如果变更流控策略需要重启服务。

> **注意：**
> provider端限流策略配置中的`ServiceName`指的是调用该provider的consumer，而`schema`、`operation`指的是provider自身的。即provider端限流配置的含义是，限制指定consumer调用本provider的某个schema、operation的流量。

`ANY` 是一个特殊的 `ServiceName`， 表示不区分来源微服务， 对所有微服务使用同样的策略。 比如 
`servicecomb.flowcontrol.Provider.qps.limit.ANY.mySchema.myOperation=200` 表示对 `mySchema.myOperation` 单独限制 200 的流量。


## Consumer端使用限流

用户在consumer端使用限流策略，可以限制发往指定微服务的请求的频率。

### 配置说明

限流策略配置在microservice.yaml文件中，相关配置项见下表。要开启服务消费者端的限流策略，还需要在处理链中配置消费端限流handler，配置示例如下：

```yaml
servicecomb:
  handler:
    chain:
      Consumer:
        default: qps-flowcontrol-consumer
```

QPS流控配置项说明

| 配置项 | 默认值 | 取值范围 | 是否必选 | 含义 | 注意 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| servicecomb.flowcontrol.Consumer.qps.enabled | true | Boolean | 否 | 是否启用Consumer流控 | - |
| servicecomb.flowcontrol.strategy | FixedWindow | FixedWindow/LeakyBucket/TokenBucket/自定义 | 否 | 流控策略 | - |
| servicecomb.flowcontrol.Consumer.qps.global.limit | 2147483647（max int） | \(0,2147483647\]，整型 | 否 | consumer发送请求流量的全局配置 | 没有具体的流控配置时，此配置生效 |
| servicecomb.flowcontrol.Consumer.qps.limit.\[ServiceName\].\[Schema\].\[operation\] | 2147483647  \(max int\) | \(0,2147483647\]，整型 | 否 | 每秒钟允许的请求数 | 支持microservice、schema、operation三个级别的配置 |
| servicecomb.flowcontrol.Consumer.qps.global.bucket | 两倍limit大小，不超过max int | \(0,2147483647\]，整型 | 否 | 令牌桶场景下consumer桶的大小 | 没有具体的流控配置时，此配置生效 |
| servicecomb.flowcontrol.Consumer.qps.bucket.\[ServiceName\].\[Schema\].\[operation\] | 两倍limit大小，不超过max int | \(0,2147483647\]，整型 | 否 | 令牌桶场景下桶的大小 | 支持microservice/schema/operation三个级别的配置，后者的优先级高于前者 |


> **注意：**
> strategy是全局的策略选择，一旦选择所有流控接口都会应用统一的流控策略，且不支持动态配置变更，如果变更流控策略需要重启服务。

> **注意：**
> consumer端限流策略配置中的`ServiceName`、`schema`、`operation` 指的是请求的目标服务。

`ANY` 是一个特殊的 `ServiceName`， 表示不区分来源微服务， 对所有微服务使用同样的策略。 比如 
`servicecomb.flowcontrol.Consumer.qps.limit.ANY.mySchema.myOperation=200` 表示对 `mySchema.myOperation` 单独限制 200 的流量。
如果不同微服务存在一样的 `schema`、`operation`， 则共享一个流量控制。`ANY` 在 Consumer 流控很少使用。

