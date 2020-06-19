# 连接多个服务中心

有些应用场景需要连接多个服务中心。比如一个应用系统会在不同的 region 部署，其中一个 region 的服务需要访问
另外一个 region 的服务， 这个时候，可以连接另外 region 的服务中心，发现服务信息。 

***注意:*** 连接多个服务中心指的是不同的服务中心集群，不是指一个集群内部的多个服务中心实例。 

连接多个服务中心比较简单， 只需要在项目里面定义新的服务中心的配置信息，通过 spring bean 的方式注入：

```java
@Configuration
public class ServerBServiceCenterConfiguration {
  @Bean("serverBServiceCenterConfig")
  public ServiceRegistryConfig serverBServiceCenterConfig() {
    ServiceRegistryConfig config = ServiceRegistryConfig.buildFromConfiguration();
    return ServiceRegistryConfigCustomizer.from(config)
        .addressListFromConfiguration("servicecomb.service.registry-serverB.address").get();
  }
}
```

上面的代码复用了缺省服务中心的配置信息，只修改了连接地址，代码指定了下面的配置项。如果需要自定义其他配置项，可以
通过继承 ServiceRegistryConfig 来实现。

```yaml
servicecomb:
  service:
    registry:
      address: http://127.0.0.1:30100
    registry-serverB:
      address: http://127.0.0.1:40100
```

启用多个服务中心以后，会在不同的服务中心查找服务的实例，并对信息进行合并。 

