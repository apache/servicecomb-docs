# 组合使用多个实现

通过组合多个服务注册发现实现，能够满足很多特殊场景的开发要求。 

***注意：*** 组合使用多个实现，必须使用 2.1.0 及其以上版本。 

## 调用第三方服务

可以有非常多的方式调用第三方服务，比如采用第三方提供的Rest Client。 但是需要提供一种
透明的方式，让调用第三方服务的客户端代码和调用 servicecomb 微服务的
客户端代码风格完全一样，并且拥有所有 servicecomb 的客户端治理能力。

在[调用第三方服务](../build-consumer/3rd-party-service-invoke.md)里面介绍了servicecomb提供的一种
调用第三方服务的使用方式，这种方式依赖于使用服务中心作为注册发现。 下面介绍一种组合使用服务中心和本地注册发现，
实现调用第三方服务。 

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

* 在 `microservices/thirdParty-service-center/ServiceCenterEndpoint.yaml` 中定义契约内容

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
