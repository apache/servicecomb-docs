## Load Balancing Policy
### Scenario

　　ServiceComb provides a Ribbon-based load balancing solution. You can configure a load balancing policy in the configuration file. Currently, a load balancing routing policy can be random, sequential, or based on response time weight.

### Configuration

　　Load balancing policies are configured by setting the parameter `servicecomb.loadbalance.[MicroServiceName].[property name]` in the microservice.yaml fiel. If MicroServiceName is not set, the configuration is set for all microservices. Otherwise, the configuration is set for a specific microservice.

　　**Table 1 Configuration items of load balancing policy**

| Configuration Items                      | Default Value                            | Value Range                              | Mandatory | Description                              | Remarks                                  |
| :--------------------------------------- | :--------------------------------------- | :--------------------------------------- | :-------- | :--------------------------------------- | :--------------------------------------- |
| servicecomb.loadbalance.NFLoadBalancerRuleClassName | com.netflix.loadbalancer.RoundRobinRule  | com.netflix.loadbalancer.RoundRobinRule（polling）com.netflix.loadbalancer.RandomRule（random）com.netflix.loadbalancer.WeightedResponseTimeRule（server response time weight）org.apache.servicecomb.loadbalance.SessionStickinessRule（session stickiness） | No        | Specifiles the load balancing policy     | -                                        |
| servicecomb.loadbalance.SessionStickinessRule.sessionTimeoutInSeconds | 30                                       | Integer                                  | No        | Specifies the idle time of a client. If the idle time exceeds the set value, ServiceComb will select another server. | Currently, this parameter cannot be set for a certain microservice. For example, servicecomb.loadbalance.SessionStickinessRule.sessionTimeoutInSeconds cannot be set to servicecomb.loadbalance.DemoService.SessionStickinessRule.sessionTimeoutInSeconds |
| servicecomb.loadbalance.SessionStickinessRule.successiveFailedTimes | 5                                        | Integer                                  | No        | Specifies the number of failed requests from the client. If the number exceeds the set value, ServiceComb will switch to another server | Currently, this parameter cannot be set for a certain microservice. |
| servicecomb.loadbalance.retryEnabled             | FALSE                                    | Boolean                                  | No        | Specifies whether to call a service again when a exception is captured by the load balance. | -                                        |
| servicecomb.loadbalance.retryOnNext              | 0                                        | Integer                                  | No        | Specifies the number of attempts to connect to another server. | -                                        |
| servicecomb.loadbalance.retryOnSame              | 0                                        | Integer                                  | No        | Specifies the number of attempts to connect to the same server. | -                                        |
| servicecomb.loadbalance.isolation.enabled        | FALSE                                    | Boolean                                  | No        | Specifies whether to enable faulty instance isolation. | -                                        |
| servicecomb.loadbalance.isolation.enableRequestThreshold | 20                                       | Integer                                  | No        | Specifies the threshold number of instance calls. If this value is reached, isolation is enabled. | -                                        |
| servicecomb.loadbalance.isolation.errorThresholdPercentage | 20                                       | Integer，\(0,100\]                        | No        | Specifies the error percentage. Instance fault isolation is enabled when the set value is reached. | -                                        |
| servicecomb.loadbalance.isolation.singleTestTime | 10000                                    | Integer                                  | No        | Specifies the duration of a faulty instance test on a single node. | This unit is ms.                         |
| servicecomb.loadbalance.transactionControl.policy | org.apache.servicecomb.loadbalance.filter.SimpleTransactionControlFilter | -                                        | No        | Specifies the offload policies for dynamic routing. | The framework provides simple offload mechanisms. You can also customize offload policies. |
| servicecomb.loadbalance.transactionControl.options | -                                        | key/value pairs                          | No        | Specifies the parameter configured for the SimpleTransactionControlFilter offload policy. You can add any filtration tag for this item. | -                                        |

### Sample Code

　　in the src/main/resources/microservice.yaml file, configure a load balancing policy.

　　Configure a processing link：

```yaml
servicecomb:
  # other configurations omitted
  handler:
    chain:
      Consumer:
        default: loadbalance
  # other configurations omitted
```

　　Add a routing policy:

```yaml
servicecomb：
  # other configurations omitted
  loadbalance:
    NFLoadBalancerRuleClassName: com.netflix.loadbalancer.RoundRobinRule
  # other configurations omitted
```

## Customizing Routing Policies

　　Based on the routing policy framework provided by ServiceComb, you can program to customize routing policies as required. Perform the following steps:

* Encode using the API method defined in the `com.netflix.loadbalancer.IRule` API. Encode in the public Server  choose(Object key) method. LoadBalancerStats is a structure that encapsulates the running state of the load balancer. Determine on which instance the current routing request will be processed based on the running indexes of each instance by using the Server choose(Object key) method. Use method `org.apache.servicecomb.loadbalance.SessionStickinessRule`for instance processing.

* Compile the developed policy and ensure that the generated class is under classpath.

* Use the software development kit(SDK) to configure the routing policy. Use AbcRule as a routing policy example. The configuration is as follows:        `servicecomb.loadbalance.NFLoadBalancerRuleClassName=org.apache.servicecomb.ribbon.rule.AbcRule`

## 过滤器机制

handler-loadbalance模块提供了Filter机制，用来过滤选择provider实例，ServiceComb提供的Filter有`IsolationServerListFilter`和`ZoneAwareServerListFilterExt`，用户也可自行扩展Filter。

关于`IsolationServerListFilter`的用法参见[实例级故障隔离](/build-consumer/instance-isolation.md)。

### 使用`ZoneAwareServerListFilterExt`选择provider实例

`ZoneAwareServerListFilterExt`使得consumer实例可以优先选择和自己处于同一region和zone的provider实例进行调用。

> 这里的region和zone是一般性的概念，用户可以自定确定其业务含义以便应用于资源隔离的场景中。关于华为云ServiceStage中的实例隔离层次关系，参见[微服务实例之间的逻辑隔离关系](/build-provider/definition/isolate-relationship.md)。

#### 1. provider端配置

启动两个provider实例，其中一个provider实例的microservice.yaml文件中增加如下配置：
```yaml
servicecomb:
  # config region and zone information
  datacenter:
    name: myDC
    region: my-Region
    availableZone: my-Zone
```

#### 2. consumer端配置

在consumer端的microservice.yaml文件中增加如下配置：
```yaml
servicecomb:
  loadbalance:
    # add zone aware filter
    serverListFilters: zoneAware
    serverListFilter:
      zoneAware:
        className: org.apache.servicecomb.loadbalance.filter.ZoneAwareServerListFilterExt
  # config region and zone information
  datacenter:
    name: myDC
    region: my-Region
    availableZone: my-Zone
```

#### 3. 使consumer调用provider

由于`ZoneAwareServerListFilterExt`的存在，consumer实例会优先选择和自己同一个region和availableZone下的provider实例进行调用。如果没有region和zone都相同的provider实例，则选择region相同的实例；如果还是没有符合条件的实例，则选择任一可用实例做调用。

### 开发自定义过滤器

用户可以开发自定义的过滤器来满足自己的业务场景，步骤如下：
- 实现`ServerListFilterExt`接口，过滤provider实例列表的逻辑在`List<T> getFilteredListOfServers(List<T> servers)`方法中实现。
- 确保编译的filter实现类在classpath下。
- 在microservice.yaml文件中增加filter配置

#### 示例开发

现在假设用户需要为每个consumer和provider实例配置各自的优先级，从低到高为0~9，高优先级的provider实例只可以调用平级或低优先级的consumer实例，以此为前提开发一个示例。

1. 开发一个Filter，实现`ServerListFilterExt`接口，代码如下：
```java
  package org.servicecombexam.loadbalance.filter;
  // import is omitted
  public class ExamFilter implements ServerListFilterExt {
    public static final String PRIORITY_LEVEL = "priorityLevel";
    @Override
    public List<Server> getFilteredListOfServers(List<Server> servers) {
      List<Server> result = new ArrayList<>();
      String priority = RegistryUtils.getMicroserviceInstance().getProperties().get(PRIORITY_LEVEL);
      for (Server server : servers) {
        if (priorityMatched(priority, server)) {
          result.add(server);
        }
      }
      return result;
    }
    /**
     * if the priority level is not specified, it will be regarded as 0
     * @return whether a server can be invoked by this consumer instance, according to priority level
     */
    private boolean priorityMatched(String priority, Server server) {
      String serverPriority = ((CseServer) server).getInstance().getProperties().get(PRIORITY_LEVEL);
      if (!StringUtils.isEmpty(priority) && !StringUtils.isEmpty(serverPriority)) {
        return priority.compareTo(serverPriority) >= 0;
      }
      if (StringUtils.isEmpty(serverPriority)) {
        return true;
      }

      return false;
    }
  }
```
2. 在provider的microservice.yaml文件中配置优先级等级：
```yaml
  instance_description:
    properties:
      # instance_description.properties下的是实例级配置项，本示例将优先级配置放在这里存储。实验中会启动三个实例，优先级分别为0~2
      priorityLevel: 2
```
3. 在consumer的microservice.yaml文件中配置优先级等级和Filter：
```yaml
  instance_description:
    properties:
      # consumer优先级等级为1，可以调用优先级为0或1的provider实例
      priorityLevel: 1
  servicecomb:
    loadbalance:
      serverListFilters: priorityFilter # filter名称，可以以','分隔配置多个filter
      serverListFilter:
        priorityFilter: # 此处配置的filter名称需要与servicecomb.loadbalance.serverListFilters中配置的相符
          className: org.servicecombexam.loadbalance.filter.ExamFilter # 自定义filter的类名
```

令consumer调用provider进行验证，可以发现只有优先级为0和1的provider实例会被调用，而优先级为2的provider实例不会被调用。
