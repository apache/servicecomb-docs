# 负载均衡

## 场景描述

ServiceComb提供了非常强大的负载均衡能力。它的核心包括两部分，第一部分是DiscoveryTree，通过将微服务实例根据接口兼容性、数据中心、实例状态等分组，DiscoveryFilter是其主要组成部分；第二部分是基于Ribbon的负载均衡方案，支持随机、顺序、基于响应时间的权值等多种负载均衡路由策略IRule，以及可以支持Invocation状态的ServerListFilterExt。

DiscoveryTree的逻辑比较复杂，可以通过下面的处理流程了解其处理过程。
![](../assets/loadbalance-001.png)

负载均衡适用于Consumer处理链，名称为loadbalance，示例如下：
```yaml
servicecomb:
  handler:
    chain:
      Consumer:
        default: loadbalance
```

POM依赖：
```xml
 <dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>handler-loadbalance</artifactId>
  </dependency>
```

## 按照数据中心信息进行路由转发
服务提供者和消费者都可以通过在microservice.yaml中声明自己的服务中心信息：
```yaml
servicecomb:
  datacenter:
    name: mydatacenter
    region: my-Region
    availableZone: my-Zone
```

消费者通过比较自己的数据中心信息和提供者的信息，优先将请求转发到region和availableZone都相同的实例；如果不存在，则转发到region相同的实例；如果仍然不存在，则转发到其他实例。

这里的region和availableZone是一般性的概念，用户可以自行确定其业务含义以便应用于资源隔离的场景中。可以参见[微服务实例之间的逻辑隔离关系](../build-provider/definition/isolate-relationship.md)，了解更多其他实例发现相关的隔离机制。

该规则默认启用，如果不需要使用，可以通过servicecomb.loadbalance.filter.zoneaware.enabled进行关闭。数据中心信息隔离功能在ZoneAwareDiscoveryFilter实现。

## 根据实例属性进行路由转发
微服务可以指定实例的属性。实例属性可以在microservice.yaml中指定，也可以通过服务中心的API进行修改。
```yaml
instance_description:
  properties:
    tags:
      tag_key: tag_value
```

消费者可以指定消费具备某些属性的实例，不访问其他实例
```yaml
servicecomb:
  loadbalance:
    provider:   # 这里表示配置对名为"provider"的服务生效，如果是跨应用调用，则还需要加上AppID，如"AppIDOfProvider:provider"
      transactionControl:
        options:
          tags:
            tag_key: expected_tag_value
```
上面的配置表示只访问myservice所有实例中`tag_key`属性为`expected_tag_value`的实例。

该规则需要给每个服务单独配置，未配置表示不启用该规则，不支持对于所有服务的全局配置。

该规则默认启用，如果不需要使用，可以通过`servicecomb.loadbalance.filter.instanceProperty.enabled`进行关闭。根据实例属性进行路由转发功能在`InstancePropertyDiscoveryFilter`实现。

## 根据实例属性值的层级进行路由转发
实例属性优先级匹配可以看做是针对实例属性匹配的一种逻辑扩展。

微服务的实例属性可以定义为具备优先级的格式，通过`.`符号进行分割。

```yaml
instance_description:
  properties:
    KEY: a.b.c
```

消费者需要指定用于优先级匹配的实例属性key，默认的key为`environment`。

```yaml
servicecomb:
  loadbalance:
    filter:
      priorityInstanceProperty:
        key: KEY
```

假设某个consumer的属性值为`a.b.c`，那么将会按照`a.b.c`>`a.b`>`a`>`[空]` 这样的优先级顺序匹配provider的实例，一旦匹配到即终止，下面的表格给出了不同情况的具体示例

| consumer | match priority of provider|
| :--- | :--- | 
|a.b.c|a.b.c>a.b>a>[空]|
|a.b|a.b>a>[空]|
|a|a>[空]|
|[空]|[空]|

> 注意[空]是一种特殊情况，即未设置该属性的实例

该规则默认关闭，如果需要开启，可以通过`servicecomb.loadbalance.filter.priorityInstanceProperty.enabled`配置打开。该功能在`PriorityInstancePropertyDiscoveryFilter`中实现。

## 配置路由规则
开发者可以通过配置项指定负载均衡策略。
```yaml
servicecomb:
  loadbalance:
    strategy:
      name: RoundRobin # Support RoundRobin,Random,WeightedResponse,SessionStickiness
```

开发者可以针对不同的微服务配置不一样的策略，只需要给配置项增加服务名，例如：
```yaml
servicecomb:
  loadbalance:
    myservice:
      strategy:
        name: RoundRobin # Support RoundRobin,Random,WeightedResponse,SessionStickiness
```

每种策略还有一些专属配置项，也支持针对不同微服务进行配置。

* SessionStickiness

```yaml
servicecomb:
  loadbalance:
    SessionStickinessRule:
      sessionTimeoutInSeconds: 30 # 客户端闲置时间，超过限制后选择后面的服务器
      successiveFailedTimes: 5 # 客户端失败次数，超过后会切换服务器
```

## 自定义
负载均衡模块提供的功能已经非常强大，能够通过配置支持大部分应用场景。同时它也提供了强大的扩展能力，包括DiscoveryFilter、ServerListFilterExt、ExtensionsFactory（扩展IRule，RetryHandler等）。loadbalance模块本身包含了每一个扩展的实现，这里不再详细描述如何扩展，只简单描述步骤。开发者可以自行下载ServiceComb源码进行参考。

* DiscoveryFilter
  * 实现DiscoveryFilter接口
  * 配置SPI：增加META-INF/services/org.apache.servicecomb.serviceregistry.discovery.DiscoveryFilter文件，内容为实现类的全名

* ServerListFilterExt
  * 实现ServerListFilterExt接口
  * 配置SPI：增加META-INF/services/org.apache.servicecomb.loadbalance.ServerListFilterExt文件，内容为实现类的全名
  * 注意：这个开发说明适用于1.0.0及其以后的版本，早期的版本开发方式不同。

* ExtensionsFactory
  * 实现ExtensionsFactory，并使用@Component将其发布为一个spring bean。
