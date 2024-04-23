# Java Chassis 3技术解密：ZooKeeper注册和配置中心

[ZooKeeper](https://zookeeper.apache.org/) 是一个高可用的分布式协调系统，它也被广泛用于服务注册发现、服务配置等场景。 

Java Chassis 3 使用 [Curator Service Discovery Extensions](https://curator.apache.org/docs/service-discovery) 实现注册发现。 

## 注册和配置基本原理

使用ZooKeeper实现注册配置的原理比较简单，只需要将实例信息和配置信息作为合适的 key-value 对写入。注册场景使用下面的结构：

```
servicecomb:
  registry:
    ${environment}
      ${application}:
        ${service}:
          ${instance-id}: 详细的注册内容
```

配置场景使用下面的结构：

```
servicecomb:
  config:
    environment:  
      ${environment}: 详细的配置内容
    application:
      ${environment}:
        ${application}: 详细的配置内容
    service:
      ${environment}:
        ${application}:
          ${service}: 详细的配置内容
    version:
      ${environment}:
        ${application}:
          ${service}:
            ${version}: 详细的配置内容
    tag:
      ${environment}:
        ${application}:
          ${service}:
            ${tag}: 详细的配置内容
```

## 可靠性设计

ZooKeeper自身被设计为一个高可靠的中间件，Java Chassis 3进一步增强了其作为注册中心的可靠性，即使在ZooKeeper自身不可用的情况下，仍然不影响服务之间的调用，详细了解这个机制，可以参考[Java Chassis 3技术解密：注册中心分区隔离](zone-isolation.md)。 

为了验证这部分可靠性，可以设计一个简单的测试场景：

```
测试工具 -> edge service -> consumer -> provider
```

启动 edge service、 consumer 和 provider， 通过测试工具请求接口。 然后停止 ZooKeeper， 并使用测试工具持续调用，可以发现这个过程中没有请求失败。 启动 Zookeeper, 服务注册信息恢复，这个过程中仍然没有请求失败。 

当然，在ZooKeeper不可用的过程中，无法注册新的实例。

## 关于 Zookeeper 作为注册中心的深入讨论

有观点认为， ZooKeeper不适合作为注册中心，一般的，CP系统都不适合作为注册中心，而AP作为注册中心才是最佳选择。 个人觉得这样的观点是片面而且非常不恰当的。 

从[ZooKeeper 并不适合做注册中心](https://blog.csdn.net/looook/article/details/109168239?spm=1001.2014.3001.5501) 和 [为什么我们要把服务注册发现改为阿里巴巴的Nacos而不用 ZooKeeper？](zoo-nacos) 摘取了几个核心观点：

* 网络分区隔离情况下，ZooKeeper会导致服务间调用错误，也会导致新的服务无法注册，不适合作为注册中心。
* ZooKeeper所有写操作都在Leader进行，无法支持大规模微服务实例，不适合作为注册中心。

下面简单讨论下这两个观点。

### 关于网络分区隔离

网络分区隔离的场景比较多，在[Java Chassis 3技术解密：注册中心分区隔离](zone-isolation.md)描述的场景下，Java Chassis能够保证服务之间的调用不受影响。在[为什么我们要把服务注册发现改为阿里巴巴的Nacos而不用 ZooKeeper？](zoo-nacos)提到的场景中，Java Chassis也能够保证服务之间的调用不受影响，但是服务无法注册。网络分区隔离场景下，核心需要讨论的问题变成是否需要允许服务进行注册/扩容？尽管可能存在争议，但我们的观点是系统出现部分故障的情况下，系统不应该扩容，而是尽可能维持处理能力不变，这样会使得故障恢复更加可控，从而减少系统恢复时间。

[为什么我们要把服务注册发现改为阿里巴巴的Nacos而不用 ZooKeeper？](zoo-nacos)提到的场景相对于实际部署场景还过于简单，我们把它扩展到实际场景：

![](zookeeper-scale.png)

实际场景除了保障单AZ内的请求闭环，还需要保证不同AZ的实例能够分担流量。当出现AZ网络隔离，由于每个AZ实例感知到的总的实例数减少，会触发弹性扩缩容，从而需要注册中心支持新实例注册。 但是本质上，这个场景系统的处理能力并没有降低，弹性扩缩容将会是一个错误的行为，这个错误的行为，会给系统资源的使用和故障恢复带来更多的不可预测因素。

### 关于性能

ZooKeeper只有Leader可以写入，通过扩容Learner(Follower/Observer)提升读取性能。注册配置中心的场景实际上是一个读要求高，写要求不高的场景, ZooKeeper很好的满足了写不频繁，读很频繁的要求。 最复杂的业务系统，ZooKeeper管理的实例个数在10000以下，即使这些系统被设计为允许动态弹性扩缩容。超大规模的业务系统，一般微服务网关来提升系统韧性，并防止未知故障带来的爆炸半径扩大。 在前期[Java Chassis 3技术解密：与Spring Cloud的互操作](interoperability.md)分享了架构韧性的一些内容。

![](serialization-arch.png)

因此，支持超大规模服务注册的场景，不具备大的现实意义。 关于超大规模实例管理的问题，可能更多来自于不恰当的架构设计或者微服务发现机制（比如早期Dubbo版本使用的基于接口的服务发现，实例个数和接口数量成正比）。

## 总结

Java Chassis 3使用ZooKeeper作为注册中心是非常好的选择，ZooKeeper可以在应用系统中同时扮演注册、配置和选举等功能，能够极大的简化应用部署和服务依赖。CP一致性也使得常见故障场景下应用程序的行为具备更好的预测性。大规模系统可以采用微服务网关来提升系统韧性，降低系统爆炸半径。


zoo-nacos: https://blog.csdn.net/u012921921/article/details/106521181/?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-1--blog-109168239.235^v43^pc_blog_bottom_relevance_base3&spm=1001.2101.3001.4242.

