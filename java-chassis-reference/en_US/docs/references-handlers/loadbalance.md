# load balancing

## Scenario

ServiceComb provides very powerful load balancing capabilities, which consists of two core parts. The first part DiscoveryTree, whose core part is DiscoveryFilter, groups microservice instances by their interface compatibility, data center, status, etc. The second part is the load balancing scheme based on Ribbon, which supports various load balancing policies(IRule) include random, sequential, response time-based weights, and ServerListFilterExt which is based on Invocation state.

DiscoveryTree's logic is more complex, its processing progress is as below:
![](../assets/loadbalance-001.png)

Load balancing can be configured in the Consumer processing chain, the handler name is loadbalance, as follows:

```yaml
servicecomb:
  handler:
    chain:
      Consumer:
        default: loadbalance
```

POM dependence:
```xml
 <dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>handler-loadbalance</artifactId>
  </dependency>
```

## Routing and forwarding by data center information
Service providers and consumers can declare their service center information in microservice.yaml:
```yaml
servicecomb:
  datacenter:
    name: mydatacenter
    region: my-Region
    availableZone: my-Zone
```

Consumers compare their own data center information and providers' information, preferentially forward the request to the provider instance in the same region and availableZone; if the target instance is not available, it forwards request to the instance in the same region; if the target still does not exist, it forwards requests to other instances.

The region and availableZone here are general concepts, users can determine their business meanings to apply them to resource-isolated scenarios. See [Logical isolation relationships between microservice instances](../build-provider/definition/isolate-relationship.md) for more details of the isolation.

This rule is enabled by default. If it is not needed, set servicecomb.loadbalance.filter.zoneaware.enabled to false. Data center information isolation is implemented in ZoneAwareDiscoveryFilter.

## Routing and forwarding by instance attributes
Users can specify the properties of microservice instances in microservice.yaml, or by calling service center APIs.
```yaml
instance_description:
  properties:
    tags:
      tag_key: tag_value
```

Consumers can specify provider instances' attributes to determine which instances to call.
```yaml
servicecomb:
  loadbalance:
    # Here the "provider" means the config items below only take effect on the service named "provider"
    # In cross-app invocation, the AppID should be prefixed, like "AppIDOfProvider:provider"
    provider:
      transactionControl:
        options:
          tags:
            tag_key: expected_tag_value
```
The above configuration shows that only the instances of "provider" with the tag attribute `tag_key:expected_tag_value` are called.

This rule needs to be configured separately for each service. Global rule for all services is not supported.

This rule is enabled by default, it can be disabled by setting `servicecomb.loadbalance.filter.instanceProperty.enabled` to false. The instance attributes based routing policy is implemented in `InstancePropertyDiscoveryFilter`.

## Routing and forwarding by instance attributes with hierarchy value
This is a extension of the feature above.

You can specify the properties of microservice instances in microservice.yaml with hierarchy value, which is separated by `.` symbol.
```yaml
instance_description:
  properties:
    KEY: a.b.c
```

Consumer need to specify the key of instance which is used to match provider, the default key is `environment`

```yaml
servicecomb:
  loadbalance:
    filter:
      priorityInstanceProperty:
        key: KEY
```

Assuming there is a consumer instance with property value `a.b.c`, the match priority of provider will be `a.b.c`>`a.b`>`a`>`[empty]` and the table shown below gives detail match priority.
| consumer | match priority of provider|
| :--- | :--- | 
|a.b.c|a.b.c>a.b>a>[empty]|
|a.b|a.b>a>[empty]|
|a|a>[empty]|
|[empty]|[empty]|

> Note that [empty] is represent for the instances which is not set value of this property key

This rule is **NOT** enabled by default, which can be enabled by setting `servicecomb.loadbalance.filter.priorityInstanceProperty.enabled` to true. The policy is implemented in `PriorityInstancePropertyDiscoveryFilter`.

## Instance isolation
Developers can configure instance-isolated parameters to temporarily drop access to the wrong instance, improving system reliability and performance. Below are the configuration items and default values:
```yaml
servicecomb:
  loadbalance:
    isolation:
      enabled: true
      errorThresholdPercentage: 0
      enableRequestThreshold: 5
      singleTestTime: 60000
      continuousFailureThreshold: 5
```

The interval of isolation calculation is 1 minute. According to the above configuration, in 1 minute, if the total number of requests is greater than 5, and more than 2 consecutive  errors occur, the instance is isolated.

The default value of errorThresholdPercentage is 0, indicates that the rule is ommited. The item should be a integer less than 100, for example 20, then within 1 minutes, if the total number of request is greater than 5 and [1] error rate is greater than 20% or [2] more than 2 consecutive  errors occur, is instance is isolated.

After 60 seconds, the instance will be re-enabled and accessible if it matches the rules of load balancing policy.

Notes:

1. When error rate reaches the threshold, is instance is isolated and the error rate will be calculated again after the interval. Then with the successful accesses, the rate will decrease and become less than the threshold, then instance is available again. Since the rate is calculated by number of requests, if the total requests reaches the threshold and the error rate is much greater than its threshold, the instance would take a long time to recover.
2. ServiceComb starts a thread in the background to detect the instance state, and checks the instance state every 10 seconds (if the instance is accessed within 10 seconds, it is not detected). If the detection fails, the error number is accumulated with 1. The count here also affects instance isolation.

The default instance state detection mechanism is to send a telnet instruction, refer to the implementation of SimpleMicroserviceInstancePing. Users can overwrite the status detection mechanism with the following two steps:

1. Implement the MicroserviceInstancePing interface
2. Configure SPI: Add META-INF/services/org.apache.servicecomb.serviceregistry.consumer.MicroserviceInstancePing, the content is the full path of the implementation class

Developers can configure different isolation policies for different microservices. Just add a service name to the configuration item, for example:
```yaml
servicecomb:
  loadbalance:
    myservice:
      isolation:
        enabled: true
        errorThresholdPercentage: 20
        enableRequestThreshold: 5
        singleTestTime: 10000
        continuousFailureThreshold: 2
```

This rule is enabled by default and can be turned off by setting servicecomb.loadbalance.filter.isolation.enabled to false. Data center information isolation is implemented in IsolationDiscoveryFilter.

## Configuring route rules
Developers can specify load balancing policies through configuration items.
```yaml
servicecomb:
  loadbalance:
    strategy:
      name: RoundRobin # Support RoundRobin,Random,WeightedResponse,SessionStickiness
```

Developers can configure policies for different microservices by adding a service name, for example:
```yaml
servicecomb:
  loadbalance:
    myservice:
      strategy:
        name: RoundRobin # Support RoundRobin,Random,WeightedResponse,SessionStickiness
```

Each policy has some specific configuration items.

* SessionStickiness

```yaml
servicecomb:
  loadbalance:
    SessionStickinessRule:
      sessionTimeoutInSeconds: 30 # Client idle time, after the limit is exceeded, select the server behind
      successiveFailedTimes: 5 # The number of client failures will switch after the server is exceeded.
```

## Set retry strategy
The load balancing module also supports the policy retry.
```yaml
servicecomb:
  loadbalance:
    retryEnabled: false
    retryOnNext: 0
    retryOnSame: 0
```
Retry is not enabled by default. Developers can set different strategies for different services:
```yaml
servicecomb:
  loadbalance:
    myservice：
      retryEnabled: true
      retryOnNext: 1
      retryOnSame: 0
```

retryOnNext indicates that after the failure, according to the load balancing policy, re-select an instance to retry (may choose the same instance), while retryOnSame means that the last failed instance is still used for retry.

## Customization
The load balancing module provides various configurations that can support most application scenarios. It also provides flexible extension capabilities, including DiscoveryFilter, ServerListFilterExt, ExtensionsFactory (extension IRule, RetryHandler, etc.). The loadbalance module itself contains the implementation of each extension. The brief introduction of extending load balancing module is described below. Developers can download the ServiceComb source code to see the details.

* DiscoveryFilter
  * Implement the DiscoveryFilter interface
  * Configure SPI: Add META-INF/services/org.apache.servicecomb.serviceregistry.discovery.DiscoveryFilter file with the full path of the implementation class

* ServerListFilterExt
  * Implement the ServerListFilterExt interface
  * Configure SPI: Add META-INF/services/org.apache.servicecomb.loadbalance.ServerListFilterExt file, the content is the full pathof the implementation class
  * Note: This instruction applies to version 1.0.0 and later. Earlier versions are extended in a different way.

* ExtensionsFactory
  * Implement the ExtensionsFactory and publish it as a spring bean using @Component.
