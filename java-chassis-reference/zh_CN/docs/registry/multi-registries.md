# 组合使用多个实现

通过组合多个服务注册发现实现，能够满足很多特殊场景的开发要求。 

***注意：*** 组合使用多个实现，必须使用 2.1.0 及其以上版本。 

## 调用第三方服务

可以有非常多的方式调用第三方服务，比如采用第三方提供的Rest Client。 但是需要提供一种
透明的方式，让调用第三方服务的客户端代码和调用 servicecomb 微服务的
客户端代码风格完全一样，并且拥有所有 servicecomb 的客户端治理能力。

在[调用第三方服务](../build-consumer/3rd-party-service-invoke.md)里面介绍了servicecomb提供的一种
调用第三方服务的使用方式，这种方式依赖于使用服务中心作为注册发现。 下面介绍一种组合使用服务中心和本地注册发现，
实现调用第三方服务。 在本方案中，第三方调用是通过本地注册发现实现的，java chassis 微服务之间是通过服务中心
实现的。可以看出，使用本地注册发现实现，比原来的第三方调用方案功能更加完善，开发更加灵活。

* 首先在项目中引入两种注册发现的实现

```xml
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>registry-local</artifactId>
    </dependency>
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>registry-service-center</artifactId>
    </dependency>
```

* 在 `registry.yaml` 中定义第三方的微服务信息

```yaml
thirdParty-service-center:
  - id: "001"
    version: "4.0.0"
    appid: demo-multi-registries
    schemaIds:
      - ServiceCenterEndpoint
    instances:
      - endpoints:
          - rest://localhost:30100
```

* 注册契约。 与开发服务接口一样， 调用第三方服务也可以采用 `Core First` 
  或者 `Contrast First` 两种方式注册契约。 

    * Code First 方式注册契约
  
      需要在服务启动完成后(`AFTER_REGISTRY`事件）， 调用接口完成契约注册。 
  
            @RequestMapping(path = "/v4/default/registry", produces = MediaType.APPLICATION_JSON)
            public interface IServiceCenterEndpoint {
              // java name can not be `x-domain-name`, so interfaces define all parameters.
              @GetMapping(path = "/getInstances")
              Object getInstances(@RequestParam(name = "appId") String appId,
                  @RequestParam(name = "serviceName") String serviceName,
                  @RequestParam(name = "global") String global,
                  @RequestParam(name = "version") String version,
                  @RequestHeader(name = "x-domain-name") String domain);
            }
         
             RegistrationManager.INSTANCE.getSwaggerLoader().registerSwagger(
                    "demo-multi-registries",
                    "thirdParty-service-center",
                    "ServiceCenterEndpoint", IServiceCenterEndpoint.class);

    * Contrast First 方式注册契约
  
      在 `microservices/thirdParty-service-center/ServiceCenterEndpoint.yaml` 中定义契约内容

            ```yaml
            swagger: "2.0"
            info:
              version: "1.0.0"
              title: "swagger definition for org.apache.servicecomb.demo.registry.ServiceCenterEndpoint"
              x-java-interface: "gen.swagger.ServiceCenterEndpointIntf"
            basePath: "/v4/default/registry"
            schemes:
              - "http"
            consumes:
              - "application/json"
            produces:
              - "application/json"
            paths:
              /instances:
                get:
                  operationId: "getInstances"
                  parameters:
                    - name: "appId"
                      in: "query"
                      required: true
                      type: "string"
                    - name: "serviceName"
                      in: "query"
                      required: true
                      type: "string"
                    - name: "global"
                      in: "query"
                      required: true
                      type: "string"
                    - name: "version"
                      in: "query"
                      required: true
                      type: "string"
                    - name: "x-domain-name"
                      in: "header"
                      required: true
                      type: "string"
                  responses:
                    "200":
                      description: "response of 200"
                      schema:
                        type: "object"
            ```


* 经过上面的准备，就可以像访问 servicecomb 的微服务一样访问第三方服务了。 比如采用 RPC 的方式访问这个
 服务的代码如下：
 
```java
public interface IServiceCenterEndpoint {
  // java name can not be `x-domain-name`, so interfaces define all parameters.
  @GetMapping(path = "/instances")
  Object getInstances(@RequestParam(name = "appId") String appId,
      @RequestParam(name = "serviceName") String serviceName,
      @RequestParam(name = "global") String global,
      @RequestParam(name = "version") String version,
      @RequestHeader(name = "x-domain-name") String domain);
}

@Component
public class ServiceCenterTestCase implements CategorizedTestCase {
  @RpcReference(microserviceName = "thirdParty-service-center", schemaId = "ServiceCenterEndpoint")
  IServiceCenterEndpoint serviceCenterEndpoint;

  @Override
  public void testRestTransport() throws Exception {
    // invoke service-center(3rd-parties)
    @SuppressWarnings("unchecked")
    Map<String, List<?>> result = (Map<String, List<?>>) serviceCenterEndpoint.getInstances(
        "demo-multi-registries",
        "demo-multi-registries-server",
        "true",
        "0.0.2",
        "default");
    TestMgr.check(result.get("instances").size(), 1);
  }
}
```

## 连接多个服务中心

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
    String address = DynamicPropertyFactory.getInstance()
        .getStringProperty("servicecomb.service.registry-serverB.address", null)
        .get();
    if (address == null) {
      throw new IllegalStateException("service center address is required.");
    }
    String[] urls = address.split(",");
    List<String> uriList = Arrays.asList(urls);
    ArrayList<IpPort> ipPortList = new ArrayList<>();
    uriList.forEach(anUriList -> {
      try {
        URI uri = new URI(anUriList.trim());
        if ("https".equals(uri.getScheme())) {
          config.setSsl(true);
        }
        ipPortList.add(NetUtils.parseIpPort(uri));
      } catch (Exception e) {
        throw new IllegalStateException("service center address is required.", e);
      }
    });
    config.setIpPort(ipPortList);
    return config;
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

