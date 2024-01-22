# Java Chassis 3技术解密：易扩展的多种注册中心支持

Java Chassis 的早期版本依赖于 Service Center，提供了很多差异化的竞争力：

* 接口级别转发。 通过注册中心管理微服务的每个版本的元数据，特别是契约数据。 结合契约数据，能够实现版本级别的路由能力。 比如一个微服务存在 v1 和 v2 两个版本， 其中 v1 版本存在接口 op1, op2， v2 版本存在接口 op1, op2, op3， 在灰度场景， Java Chassis能够自动将 op3 的访问转发到 v2 版本，将 op1, op2 的访问在 v1, v2版本做负载均衡。 
* 基于 version-rule 的实例选择。 客户端能够配置 version-rule， 比如 last, 2.0+等。 这样客户端能够根据实际情况，筛选实例的版本。 

Java Chassis过度依赖 Service Center， 为产品的发展带来了一些瓶颈。 Java Chassis的生态推广依赖于 Service Center的生态推广， 不利于Java Chassis被更多用户使用。 随着云的发展， 越来越多的客户也期望一套代码，能够在不同的云环境运行，有些云产商未提供Service Center运行环境，那么用户选择Java Chassis 就会存在顾虑。 

基于上述原因， Java Chassis简化了注册发现的依赖，定义了简单容易实现的接口，并基于 `Nacos` 提供了实现，未来还会提供 `zookeeper` 等实现。 Java Chassis 采用了一系列新的设计模式， 保证了在降低注册中心功能依赖的前提下，不降低应用自身的可靠性。 

## 接口级别转发的替代方案

依赖于 Service Center， Java Chassis提供了接口级别转发。 Java Chassis 3 首先做的一个变化是删除了对于接口级别转发的支持。 这样对于注册中心的依赖复杂度至少可以降低 70%。 然而灰度场景依然对很多业务比较重要， Java Chassis 3使用灰度发布解决这个问题。 使用灰度发布的好处是不用依赖注册中心提供版本元数据管理能力，只需要每个实例具备版本号等简单元数据信息。 

```yaml
servicecomb:
  # enable router for edge service
  router:
    type: router
  routeRule:
    business: |
      - precedence: 2
        match:
          apiPath:
            prefix: "/business/v2"
        route:
          - weight: 100
            tags:
              version: 2.0.0
      - precedence: 1
        match:
          apiPath:
            prefix: "/business/v1/dec"
        route:
          - weight: 50
            tags:
              version: 1.1.0
          - weight: 50
            tags:
              version: 2.0.0
```

## 注册发现接口及其实现

Java Chassis 3 只需要使用 `Discovery` 接口就能够提供新的注册发现支持。 Java Chassis会调用 `findServiceInstances` 查询实例，如果后续实例发生变更，注册中心实现通过 `InstanceChangedListener` 通知 Java Chassis. 

```java
/**
 * This is the core service discovery interface. <br/>
 */
public interface Discovery<D extends DiscoveryInstance> extends SPIEnabled, SPIOrder, LifeCycle {
  interface InstanceChangedListener<D extends DiscoveryInstance> {
    /**
     * Called by Discovery Implementations when instance list changed.
     * @param registryName Name of the calling discovery implementation
     * @param application Microservice application
     * @param serviceName Microservice name
     * @param updatedInstances The latest updated instances.
     */
    void onInstanceChanged(String registryName, String application, String serviceName, List<D> updatedInstances);
  }

  String name();

  /**
   * If this implementation enabled for this microservice.
   */
  boolean enabled(String application, String serviceName);

  /**
   * Find all instances.
   *
   * Life Cycle：This method is called anytime after <code>run</code>.
   *
   * @param application application
   * @param serviceName microservice name
   * @return all instances match the criteria.
   */
  List<D> findServiceInstances(String application, String serviceName);

  /**
   * Discovery can call InstanceChangedListener when instance get changed.
   */
  void setInstanceChangedListener(InstanceChangedListener<D> instanceChangedListener);
}

```

Java Chassis 3 通过 `Registration` 来管理注册， 注册过程分为 `init`、`run`、`destroy`简单的生命周期， 可以在 `init` 准备注册的数据， `run` 执行注册， `destroy` 则在注册失败或者系统停止的时候执行。 

```java
/**
 * This is the core service registration interface. <br/>
 */
public interface Registration<R extends RegistrationInstance> extends SPIEnabled, SPIOrder, LifeCycle {
  String name();

  /**
   * get MicroserviceInstance </br>
   *
   * Life Cycle：This method is called anytime after <code>run</code>.
   */
  R getMicroserviceInstance();

  /**
   * update MicroserviceInstance status </br>
   *
   * Life Cycle：This method is called anytime after <code>run</code>.
   */
  boolean updateMicroserviceInstanceStatus(MicroserviceInstanceStatus status);

  /**
   * adding schemas to Microservice </br>
   *
   * Life Cycle：This method is called after <code>init</code> and before <code>run</code>.
   */
  void addSchema(String schemaId, String content);

  /**
   * adding endpoints to MicroserviceInstance </br>
   *
   * Life Cycle：This method is called after <code>init</code> and before <code>run</code>.
   */
  void addEndpoint(String endpoint);

  /**
   * adding property to MicroserviceInstance </br>
   *
   * Life Cycle：This method is called after <code>init</code> and before <code>run</code>.
   */
  void addProperty(String key, String value);
}

```

## 注册发现的组合

Java Chassis 3可以独立实现多个 `Discovery` 和 `Registration`, 达到向多个注册中心注册和从多个注册中心发现实例的作用。 每个实例根据实例ID唯一来标识。 如果实例ID相同， 会被认为是同一个实例， 如果不同， 则会认为是不同的实例。 在 `Java Chassis 3技术解密：注册中心分区隔离` 中聊到了， Java Chassis 要求每次实例注册（新的进程）， 生成唯一的实例ID， 以解决注册分区隔离带来的实例假下线问题。 `Discovery` 和 `Registration` 都包含了 Java Chassis 定义的基础信息。

```java
/**
 * Standard information used for microservice instance registration and discovery.
 */
public interface MicroserviceInstance {
  /**
   * Environment(Required): Used for logic separation of microservice instance. Only
   * microservice instance with same environment can discovery each other.
   */
  String getEnvironment();

  /**
   * Application(Required): Used for logic separation of microservice instance. Only
   * microservice instance with same application can discovery each other.
   */
  String getApplication();

  /**
   * Service Name(Required): Unique identifier for microservice.
   */
  String getServiceName();

  /**
   * Service Name Alias(Optional): Unique identifier for microservice.
   *   This alias is used by registry implementation to support rename
   *   of a microservice, e.g. old consumers use old service name can
   *   find a renamed microservice service.
   */
  String getAlias();

  /**
   * Service Version(Required): version of this microservice.
   */
  String getVersion();

  /**
   * Data center info(Optional).
   */
  DataCenterInfo getDataCenterInfo();

  /**
   * Service Description(Optional)
   */
  String getDescription();

  /**
   * Service Properties(Optional)
   */
  Map<String, String> getProperties();

  /**
   * Service Schemas(Optional): Open API information.
   */
  Map<String, String> getSchemas();

  /**
   * Service endpoints(Optional).
   */
  List<String> getEndpoints();

  /**
   * Microservice instance id(Required). This id can be generated when microservice instance is starting
   * or assigned by registry implementation.
   *
   * When microservice instance is restarted, this id should be changed.
   */
  String getInstanceId();

  /**
   * Microservice service id(Optional). This is used for service center, other implementations may not
   * support service id.
   */
  default String getServiceId() {
    return "";
  }
}

```

在实现注册发现的时候，需要保证该接口定义的基础信息能够注册到注册中心，查询实例的时候，能够获取到这些信息。 

>>> 客户故事：不把鸡蛋放到同一个篮子里面，是技术选型里面很重要的考量。解决方案的开放性和可替代性、云服务的可替代性，是很多客户都关注的问题。对于一个开源的技术框架，Java Chassis早期的版本虽然设计上也支持不同的注册中心扩展，但是实现难度很高，不自觉的把客户使用其他注册中心替换 service center的要求变得不可行。提供更加简化的注册发现实现，虽然减少了少量有有竞争力的功能特性，但是极大降低了客户选型的顾虑。 
