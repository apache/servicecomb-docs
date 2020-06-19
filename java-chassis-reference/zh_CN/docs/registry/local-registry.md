# 本地注册发现

本地注册发现是一种静态的服务发现机制。使用本地注册发现，需要在项目中引入如下依赖：

```xml
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>registry-local</artifactId>
    </dependency>
```

本地服务发现可以在很多不同的场景使用，能够帮助开发者解决很多系统集成问题，比如和网关的集成，和第三方服务的集成。

## 注册过程

和使用服务中心一样， 系统会自动完成注册。系统会从配置文件中读取本微服务的信息和实例信息，以及本微服务发布的
契约信息，将信息注册到内存中。

## 发现过程

发现过程也是从本地进行查找。因此系统需要配置本地的微服务信息和实例信息，以及契约信息。 提供了下面两种方式：

* 使用配置文件的方式定义服务

  这种方式从配置文件(registry.yaml)中读取服务的 `Microservice` 和 
  `MicroserviceInstance` 信息，从目录 `microservices/{serviceName}/{schemaId}.yaml` 或者 
  `applications/{appId}/{serviceName}/{schemaId}.yaml` 读取微服务的契约
   信息。

   registry.yaml 格式：

        ```yaml
        ms1:
          - id: "001"
            version: "1.0"
            appid: exampleApp
            environment: development
            schemaIds:
              - hello
            instances:
              - endpoints:
                  - rest://127.0.0.1:8080
          - id: "002"
            version: "2.0"
            environment: development
            appid: exampleApp
            schemaIds:
              - hello
            instances:
              - endpoints:
                  - rest://127.0.0.2:8080
        ms2:
          - id: "003"
            version: "1.0"
            environment: development
            appid: exampleApp
            schemaIds:
              - hello
            instances:
              - endpoints:
                  - rest://127.0.0.1:8081
        ``` 

  `registry.yaml` 指定了微服务的基本信息：应用ID (appId)， 微服务名称 (serviceName),
  微服务版本(version)，环境(environment) 和契约；微服务实例基本信息：网络地址(endpoints)。
  
* 使用 `bean` 的方式定义服务

        ```java
          @Bean
          public RegistryBean demoLocalRegistryServerBean2() {
            List<String> endpoints = new ArrayList<>();
            endpoints.add("rest://localhost:8080");
            List<Instance> instances = new ArrayList<>();
            instances.add(new Instance().setEndpoints(endpoints));
        
            return new RegistryBean()
                .setServiceName("demo-local-registry-server-bean2")
                .setId("003")
                .setVersion("0.0.3")
                .setAppId("demo-local-registry")
                .addSchemaInterface("CodeFirstEndpoint2", CodeFirstService.class)
                .setInstances(new Instances().setInstances(instances));
          }
        ```

  `RegistryBean` 的信息和 `registry.yaml` 的信息类似， 可以添加 `Schema Interface` 来添加
  契约信息， 如果没有添加契约信息，这种方式也会从本地配置文件查找契约。 CodeFirstService 是一个接口，
  和普通的 provider 接口定义类似：
  
        @Path("/register/url/codeFirst")
        @Produces("application/json")
        public interface CodeFirstService {
          @GET
          @Path("getName")
          String getName(@QueryParam("name") String name);
        }
  
## 本地注册发现的应用 - 调用第三方服务

可以有非常多的方式调用第三方服务，比如采用第三方提供的 Rest Client。 但是需要提供一种
透明的方式，让调用第三方服务的客户端代码和调用 servicecomb 微服务的
客户端代码风格完全一样，并且拥有所有 servicecomb 的客户端治理能力。

在[调用第三方服务](../build-consumer/3rd-party-service-invoke.md)里面介绍了servicecomb提供的一种
调用第三方服务的使用方式，这种方式依赖于使用服务中心作为注册发现。 可以看出使用本地服务发现能够非常方便的调用第三方服务。

只需要在原来的项目中引入本地注册发现，按照上述两种方式之一定义第三方服务的信息。 定义完成后，可以像访问 servicecomb
服务一样访问第三方服务，不用关心第三方服务是采用什么框架开发的。 下面代码片段来源于 demo，
演示了通过 java chassis 的方式调用服务中心接口。

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



