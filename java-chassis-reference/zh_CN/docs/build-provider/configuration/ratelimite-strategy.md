## 场景描述

用户在provider端使用限流策略，可以限制指定微服务向其发送请求的频率，达到限制每秒钟最大请求数量的效果。

## 注意事项

1. 限流策略的控制并不是绝对精确的，可能会有少量误差。
2. provider端的流量控制是业务层面的功能，不是安全意义上的流量控制，如需防止DDoS攻击，需要结合其他的一系列措施。
3. 流量控制是微服务级的，不是实例级的。例如一个consumer服务有三个实例，当对它们依赖的provider实例配置限流策略后，provider不会区分consumer的请求具体是由哪个实例发出的，而是汇总成微服务级的统计数据进行限流判断。

## 流控算法说明

2.1.1版本之前，不提供流控策略的选择，默认流控实现算法是固定窗口算法。
2.1.1版本以及之后，提供流控测流供选择，默认提供固定窗口算法、漏桶算法、令牌桶算法，且支持用户自定义流控策略实现。

算法说明：
   * 固定窗口算法：默认窗口大小为1s，最大可能产生2倍于指定流量设置大小的误差。
   * 令牌桶算法：令牌桶的主要思想是，设置一个固定大小的桶，以恒定速率向里面加入令牌，每次新请求到来时从里面取一个令牌出来，如果没有令牌可取，则请求直接失败(被限流)。
   * 漏桶算法：漏桶算法的主要思想是，设置一个固定大小的桶，请求不断加入桶中同时以固定大小从桶内部流出，如果达到桶的极限大小，则请求溢出(失败)。
              在内部实现上漏桶算法与令牌桶算法的实现原理相同，根据设置的桶大小不同，能承载的突发流量不同。
   * 用户自定义流控算法：可以[参考实现](https://github.com/apache/servicecomb-java-chassis/blob/master/demo/demo-springmvc/springmvc-server/src/main/java/org/apache/servicecomb/demo/springmvc/server/MyStrategyFactory.java),以及该demo下的配置方法。
   
## 配置说明

限流策略配置在microservice.yaml文件中，相关配置项见表**QPS流控配置项说明**。要开启服务提供者端的限流策略，还需要在处理链中配置服务端限流handler，并添加pom依赖。

* microservice.yaml配置示例如下：
  ```yaml
  servicecomb:
    handler:
      chain:
        Provider:
          default: qps-flowcontrol-provider
  ```
* 添加handler-flowcontrol-qps的pom依赖：
  ```xml
  <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>handler-flowcontrol-qps</artifactId>
      <version>1.0.0.B003</version>
  </dependency>
  ```

**QPS流控配置项说明**

| 配置项 | 默认值 | 取值范围 | 是否必选 | 含义 | 注意 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| servicecomb.flowcontrol.Provider.qps.enabled | true | true/false | 否 | 是否启用Provider流控 | - |
| servicecomb.flowcontrol.Provider.qps.limit.\[ServiceName\].\[Schema\].\[operation\] | 2147483647（max int） | \(0,2147483647\]，整形 | 否 | 每秒钟允许的请求数 | 支持microservice/schema/operation三个级别的配置，后者的优先级高于前者 |
| servicecomb.flowcontrol.Provider.qps.global.limit | 2147483647（max int） | \(0,2147483647\]，整形 | 否 | provider接受请求流量的全局配置 | 没有具体的流控配置时，此配置生效 |


2.1.1版本流控配置变更：

| 配置项 | 默认值 | 取值范围 | 是否必选 | 含义 | 注意 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| servicecomb.flowcontrol.Provider.qps.strategy | FixedWindow | FixedWindow/LeakyBucket/TokenBucket/自定义 | 否 | 流控策略 | - |
| servicecomb.flowcontrol.Provider.qps.enabled | true | true/false | 否 | 是否启用Provider流控 | - |
| servicecomb.flowcontrol.Provider.qps.limit.\[ServiceName\].\[Schema\].\[operation\] | 2147483647（max int） | \(0,2147483647\]，整形 | 否 | 每秒钟允许的请求数 | 支持microservice/schema/operation三个级别的配置，后者的优先级高于前者 |
| servicecomb.flowcontrol.Provider.qps.global.limit | 2147483647（max int） | \(0,2147483647\]，整形 | 否 | provider接受请求流量的全局配置 | 没有具体的流控配置时，此配置生效 |
| servicecomb.flowcontrol.Provider.qps.bucket.\[ServiceName\].\[Schema\].\[operation\] | 两倍limit大小，不超过max int | \(0,2147483647\]，整形 | 否 | 令牌桶场景下桶的大小 | 支持microservice/schema/operation三个级别的配置，后者的优先级高于前者 |
| servicecomb.flowcontrol.Provider.qps.global.bucket | 两倍limit大小，不超过max int | \(0,2147483647\]，整形 | 否 | 令牌桶场景下provider桶的大小 | 没有具体的流控配置时，此配置生效 |

> **注意：**
> strategy是全局的策略选择，一旦选择所有流控接口都会应用统一的流控策略，且不支持动态配置变更，如果变更流控策略需要重启服务。

> **注意：**
> provider端限流策略配置中的`ServiceName`指的是调用该provider的consumer，而`schema`、`operation`指的是provider自身的。即provider端限流配置的含义是，限制指定consumer调用本provider的某个schema、operation的流量。

