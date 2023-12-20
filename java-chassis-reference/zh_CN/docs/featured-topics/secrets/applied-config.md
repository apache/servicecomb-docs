# Java Chassis 3技术解密：应用视角的配置管理

谈论微服务配置管理的时候，最多的是以配置中心为视角，讨论其配置管理能力。 和注册中心一样，不同的配置中心会有一些关键的设计指标。 

* 配置的格式和类型。支持不同格式和类型的配置项，比如YAML、文本、JSON、XML等。
* 配置的逻辑层次。比如 Kie 提供了 Label 来表达配置的层次，可以简化为应用配置、服务配置和自定义配置等；Nacos 使用 Namespace、Group等概念来表达配置的层次。 
* 变更通知机制。和注册中心一样，配置中心也有变更通知机制，两者的机制相似。相较而言，配置中心对于变更感知周期的的要求更低。
* 配置历史和推送轨迹。通过配置历史，能够了解配置项的改动记录，方便进行审计和回退，推送轨迹则帮助了解配置项被应用到了哪些微服务。 

Java Chassis 3的设计目标之一，就是以应用的视角，支持不同的配置中心，并提供统一一致的使用方式。

Java Chassis 3简化了微服务定义，只包含如下核心概念：

* 环境名称：用于表示部署环境，不同环境的微服务之间不能进行服务发现。对于不同的注册中心和配置中心，会以对应的概念表示环境。比如Nacos使用 `namespace` 来表示环境。
* 应用名称：用于描述一组可以相互访问的微服务，不同应用名称之间是逻辑隔离的，不能进行服务发现。对于不同的注册中心和配置中心，会以对应的概念表示应用。比如Nacos使用 `group` 来表示应用。
* 微服务名称：用于标识一个微服务。可以通过微服务名称查询需要访问的目标微服务。
* 微服务版本：表示微服务的版本。当存在微服务属性变化、接口变化的场景，建议修改版本号。
* 微服务描述：简单的微服务描述信息。
* 微服务属性：用于描述微服务的扩展信息。

```yaml
servicecomb:
  service:
    application: hello-applicaton
    name: hello-service
    version: 0.0.1 
    properties: 
      key1: value1
      key2: value2
    description: This is a description about the microservice
    environment: production
```

当一个微服务接入配置中心以后，Java Chassis 3的配置管理模块，会自动从配置中心获取如下配置层次的配置信息：

* 应用配置。
* 服务配置。
* 版本配置。
* 自定义配置。

这些配置在不同配置中心的对应关系：

| 项目    | Nacos 配置中心                                                               | Kie 配置中心                                                                               | 备注  |
|-------|--------------------------------------------------------------------------|----------------------------------------------------------------------------------------|-----|
| 应用配置  | namespace=environment </br>group=application </br>dataId=application     | environment=environment </br>app=application                                           ||
| 服务配置  | namespace=environment </br>group=application </br>dataId=service         | environment=environment </br>app=application </br>service=service                      ||
| 版本配置  | namespace=environment </br>group=application </br>dataId=service-version | environment=environment </br>app=application </br>service=service </br>version=version ||
| 自定义配置 | namespace=environment </br>group=group </br>dataId=dataId                | customLabel=customLabelValue                                                           ||

以应用视角建立这种对应关系的好处，是用户不需要自行规划如何在配置中心存放数据，可以直接将一个优秀的管理实践应用于业务场景。将用户需要思考的问题，固定为几个具体的问题：如何创建应用级别的配置？如何创建服务级别的配置？如何创建微服务自定义的配置？

应用视角的配置管理另外一个关键问题，是开发者如何使用配置。

* Spring Boot使用配置

Spring Boot的开发者一般通过 `@Value`、`@ConfigurationProperties` 和 `Environment` 获取配置。 它提供了 `PropertySource` 来扩展配置源。 Spring Boot并未针对配置变更提供额外的处理机制，无法很好的处理配置变更。 尽管当 `PropertySource` 的内容变化后，通过 `Environment` 可以获取到最新的版本内容，但是 `@Value`、`@ConfigurationProperties` 定义的配置项则不会发生变化。 

* Spring Cloud使用配置

Spring Cloud在Spring Boot基础之上，提供了动态配置的能力。 可以使用 `@RefershScope` 标签声明 Bean， 在配置变化后，Spring Cloud会销毁老的 Bean， 并重建新的 Bean，新的 Bean会使用最新的配置值进行初始化。 Spring Cloud在处理配置变更的过程中，会对Bean的访问加读写锁。 


* Java Chassis 3使用配置

Java Chassis 3完全兼容 Spring Boot的配置使用方式。 并提供了更加友好的 API 监听配置变更和处理优先级配置。 配置监听 API 主要用于高性能场景：配置变更后需要进行必要的业务逻辑初始化，初始化可以在配置变更线程中执行，而不阻塞当前业务执行。 

```java
@RestSchema(schemaId = "ProviderController")
@RequestMapping(path = "/")
public class ProviderController {
  private DynamicProperties dynamicProperties;

  private String example;

  @Autowired
  public ProviderController(DynamicProperties dynamicProperties) {
    this.dynamicProperties = dynamicProperties;
    this.example = this.dynamicProperties.getStringProperty("basic.example",
            value -> this.example = value, "not set");
  }
}
```

优先级配置是Java Chassis3特有的管理配置优先级方式。比如对于某个方法，会考虑是否有应用级别的全局配置、针对服务的配置和针对这个方法的配置，针对方法的配置优先级最高。 这种配置方式被广泛应用于Java Chassis 3的限流等服务治理场景中。 下面的代码片段是Java Chassis的接口超时配置示例。

```java
@InjectProperties(prefix = "servicecomb")
public class OperationConfig {
  public static final List<String> CONSUMER_OP_ANY_PRIORITY = Arrays.asList(
      "${service}.${schema}.${operation}",
      "${service}.${schema}",
      "${service}");
  
  /**
   * consumer request timeout
   */
  @InjectProperty(keys = {"request.${op-any-priority}.timeout", "request.timeout"}, defaultValue = "30000")
  private long msRequestTimeout;
}
```

相对于Spring Cloud，Java Chassis3的配置API，能够更加方便的监听配置变化，并提供了更好的性能。 

>>> 客户故事：Spring Cloud配置变更会加锁。在高并发场景，配置变更会阻塞所有请求的执行。如果业务执行（已经获取读锁）包含RPC等相对慢的逻辑，配置变更等待写锁以及其他执业务线程等待读锁都会被阻塞，产生雪崩效应，触发应用吞吐急剧下降。Java Chassis 3配置变更不阻塞业务处理，能够有效的防止配置变更触发雪崩效应，特别是在高并发、需要动态调整运行、治理规则的业务场景。 
